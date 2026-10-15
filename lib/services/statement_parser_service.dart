import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_enums.dart';

final statementParserServiceProvider = Provider((ref) => StatementParserService());

class ParsedStatementResult {
  final String title;
  final double totalBalance;
  final double monthlyAmount;
  final double interestRate;
  final int? emiDurationMonths;
  final int? dueDayOfMonth;
  final DateTime? dueDate;
  final ObligationType type;
  final PriorityLevel priority;
  final String category;
  final double confidenceScore;
  final String? detectedBankOrInstitution;

  const ParsedStatementResult({
    required this.title,
    required this.totalBalance,
    required this.monthlyAmount,
    this.interestRate = 0.0,
    this.emiDurationMonths,
    this.dueDayOfMonth,
    this.dueDate,
    this.type = ObligationType.emi,
    this.priority = PriorityLevel.high,
    this.category = 'EMI',
    this.confidenceScore = 0.85,
    this.detectedBankOrInstitution,
  });
}

class StatementParserService {
  /// Parses raw text from a bank sanction letter, loan agreement, credit card statement, or SMS
  ParsedStatementResult? parseText(String rawInput) {
    final text = rawInput.trim();
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();

    // 1. Detect Bank or Financial Institution
    String? bank;
    final bankList = [
      'hdfc', 'sbi', 'state bank of india', 'icici', 'axis', 'kotak', 
      'bajaj finserv', 'bajaj', 'tata capital', 'idfc', 'punjab national bank',
      'pnb', 'bank of baroda', 'bob', 'canara', 'chase', 'citi', 'american express', 'amex'
    ];
    for (final b in bankList) {
      if (lower.contains(b)) {
        bank = _formatBankName(b);
        break;
      }
    }

    // 2. Detect Loan Type & Title
    ObligationType type = ObligationType.emi;
    String detectedTypeStr = 'Loan';
    String category = 'EMI';
    PriorityLevel priority = PriorityLevel.high;

    if (lower.contains('credit card') || lower.contains('card ending') || lower.contains('card statement')) {
      type = ObligationType.emi;
      detectedTypeStr = 'Credit Card';
      category = 'Bills';
      priority = PriorityLevel.high;
    } else if (lower.contains('home loan') || lower.contains('mortgage')) {
      type = ObligationType.emi;
      detectedTypeStr = 'Home Loan';
      category = 'EMI';
      priority = PriorityLevel.high;
    } else if (lower.contains('car loan') || lower.contains('auto loan') || lower.contains('vehicle loan')) {
      type = ObligationType.emi;
      detectedTypeStr = 'Auto Loan';
      category = 'EMI';
      priority = PriorityLevel.high;
    } else if (lower.contains('personal loan')) {
      type = ObligationType.emi;
      detectedTypeStr = 'Personal Loan';
      category = 'EMI';
      priority = PriorityLevel.high;
    } else if (lower.contains('rent')) {
      type = ObligationType.recurring;
      detectedTypeStr = 'Rent';
      category = 'Rent';
      priority = PriorityLevel.high;
    } else if (lower.contains('insurance') || lower.contains('premium') || lower.contains('lic')) {
      type = ObligationType.recurring;
      detectedTypeStr = 'Insurance Premium';
      category = 'Investment';
      priority = PriorityLevel.medium;
    }

    final title = bank != null ? '$bank $detectedTypeStr' : detectedTypeStr;

    // 3. Extract Amounts (Total Outstanding / Principal & Monthly EMI)
    double totalBalance = 0.0;
    double monthlyAmount = 0.0;

    // Regex for currency amounts: Rs. 50,000 or INR 50000 or ₹ 50,000
    // Try matching Total Outstanding or Sanctioned / Loan Amount
    final principalRegex = RegExp(
      r'(?:sanction(?:ed)?(?:\s+amount)?|loan(?:\s+amount)?|principal|total(?:\s+amount)?(?:\s+due)?|total\s+outstanding|outstanding(?:\s+balance)?)\s*(?:is|of|:)?\s*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final principalMatch = principalRegex.firstMatch(text);
    if (principalMatch != null) {
      totalBalance = _cleanAmount(principalMatch.group(1));
    }

    // Try matching EMI / Monthly Amount / Minimum Due
    final emiRegex = RegExp(
      r'(?:monthly\s+emi|emi|installment|minimum(?:\s+amount)?\s+due)\s*(?:is|of|:)?\s*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final emiMatch = emiRegex.firstMatch(text);
    if (emiMatch != null) {
      monthlyAmount = _cleanAmount(emiMatch.group(1));
    }

    // Fallback: If either amount is missing, scan for additional currency amounts in text
    if (totalBalance == 0.0 || monthlyAmount == 0.0) {
      final genericAmountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);
      final allMatches = genericAmountRegex.allMatches(text).toList();
      final remainingAmounts = allMatches
          .map((m) => _cleanAmount(m.group(1)))
          .where((a) => a > 0 && a != totalBalance && a != monthlyAmount)
          .toList();

      if (remainingAmounts.isNotEmpty) {
        remainingAmounts.sort((a, b) => b.compareTo(a)); // largest first
        if (totalBalance == 0.0) {
          totalBalance = remainingAmounts.first;
        } else if (monthlyAmount == 0.0) {
          monthlyAmount = remainingAmounts.last;
        }
      }
    }

    // Secondary fallback: deduce standard estimates if strictly one is still 0
    if (monthlyAmount == 0.0 && totalBalance > 0.0) {
      if (type == ObligationType.recurring) {
        monthlyAmount = totalBalance;
      } else {
        // Approximate standard EMI as ~2.5% of principal if unspecified
        monthlyAmount = (totalBalance * 0.025).roundToDouble();
      }
    }
    if (totalBalance == 0.0 && monthlyAmount > 0.0) {
      totalBalance = type == ObligationType.recurring ? monthlyAmount : monthlyAmount * 12;
    }

    // 4. Extract Interest Rate (% p.a.)
    double interestRate = 0.0;
    final rateRegex = RegExp(r'([\d]+(?:\.\d{1,2})?)\s*%\s*(?:p\.?a\.?|per\s+annum|interest)?', caseSensitive: false);
    final rateMatch = rateRegex.firstMatch(text);
    if (rateMatch != null) {
      interestRate = double.tryParse(rateMatch.group(1) ?? '') ?? 0.0;
    } else if (detectedTypeStr == 'Credit Card') {
      interestRate = 36.0; // Standard credit card APR in India / US
    }

    // 5. Extract Due Date or Day of Month
    int? dueDay;
    DateTime? dueDate;
    final dayRegex = RegExp(r'(?:due(?:\s+date)?|payable(?:\s+by)?|on)\s*(?:is|:)?\s*(\d{1,2})(?:st|nd|rd|th)?', caseSensitive: false);
    final dayMatch = dayRegex.firstMatch(text);
    if (dayMatch != null) {
      final day = int.tryParse(dayMatch.group(1) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        dueDay = day;
        final now = DateTime.now();
        dueDate = DateTime(now.year, now.month, day);
        if (dueDate.isBefore(now)) {
          dueDate = DateTime(now.year, now.month + 1, day);
        }
      }
    }

    // 6. Extract Tenure / Duration (Months)
    int? durationMonths;
    final tenureRegex = RegExp(r'(\d+)\s*(?:months|tenure|installments)', caseSensitive: false);
    final tenureMatch = tenureRegex.firstMatch(text);
    if (tenureMatch != null) {
      durationMonths = int.tryParse(tenureMatch.group(1) ?? '');
    }

    // Calculate confidence score based on how many fields were resolved
    double score = 0.5;
    if (bank != null) score += 0.15;
    if (totalBalance > 0) score += 0.15;
    if (monthlyAmount > 0) score += 0.1;
    if (interestRate > 0) score += 0.05;
    if (dueDay != null) score += 0.05;

    return ParsedStatementResult(
      title: title,
      totalBalance: totalBalance,
      monthlyAmount: monthlyAmount,
      interestRate: interestRate,
      emiDurationMonths: durationMonths,
      dueDayOfMonth: dueDay,
      dueDate: dueDate,
      type: type,
      priority: priority,
      category: category,
      confidenceScore: score.clamp(0.0, 1.0),
      detectedBankOrInstitution: bank,
    );
  }

  double _cleanAmount(String? text) {
    if (text == null) return 0.0;
    final clean = text.replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  String _formatBankName(String bankKey) {
    switch (bankKey) {
      case 'hdfc':
        return 'HDFC Bank';
      case 'sbi':
      case 'state bank of india':
        return 'SBI';
      case 'icici':
        return 'ICICI Bank';
      case 'axis':
        return 'Axis Bank';
      case 'kotak':
        return 'Kotak Bank';
      case 'bajaj finserv':
      case 'bajaj':
        return 'Bajaj Finserv';
      case 'tata capital':
        return 'Tata Capital';
      case 'idfc':
        return 'IDFC FIRST';
      case 'pnb':
      case 'punjab national bank':
        return 'PNB';
      case 'bob':
      case 'bank of baroda':
        return 'Bank of Baroda';
      case 'chase':
        return 'Chase';
      case 'citi':
        return 'Citi';
      case 'amex':
      case 'american express':
        return 'Amex';
      default:
        return bankKey.toUpperCase();
    }
  }
}
