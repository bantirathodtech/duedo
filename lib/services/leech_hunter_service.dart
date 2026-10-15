import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

enum LeechFeeType {
  annualFee,
  financeCharge,
  gstOnInterest,
  latePaymentPenalty,
  bounceCharge,
  overlimitFee,
}

enum LeechStatus {
  detected,
  disputeDrafted,
  waived,
}

class LeechChargeItem {
  final String id;
  final String lender;
  final String accountOrCardLast4;
  final LeechFeeType feeType;
  final double amount;
  final DateTime detectedDate;
  final LeechStatus status;
  final int daysOfFreedomDestroyed;
  final String disputeLetter;

  const LeechChargeItem({
    required this.id,
    required this.lender,
    required this.accountOrCardLast4,
    required this.feeType,
    required this.amount,
    required this.detectedDate,
    required this.status,
    required this.daysOfFreedomDestroyed,
    required this.disputeLetter,
  });

  String get feeLabel {
    switch (feeType) {
      case LeechFeeType.annualFee:
        return 'Annual Card / Renewal Fee';
      case LeechFeeType.financeCharge:
        return 'Finance / Interest Charge';
      case LeechFeeType.gstOnInterest:
        return '18% GST on Finance Charges';
      case LeechFeeType.latePaymentPenalty:
        return 'Late Payment Penalty';
      case LeechFeeType.bounceCharge:
        return 'ECS / NACH Return Charge';
      case LeechFeeType.overlimitFee:
        return 'Overlimit Penalty Surcharge';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lender': lender,
    'accountOrCardLast4': accountOrCardLast4,
    'feeType': feeType.name,
    'amount': amount,
    'detectedDate': detectedDate.toIso8601String(),
    'status': status.name,
    'daysOfFreedomDestroyed': daysOfFreedomDestroyed,
    'disputeLetter': disputeLetter,
  };

  factory LeechChargeItem.fromJson(Map<String, dynamic> json) {
    return LeechChargeItem(
      id: json['id'] as String,
      lender: json['lender'] as String? ?? 'Bank',
      accountOrCardLast4: json['accountOrCardLast4'] as String? ?? 'XXXX',
      feeType: LeechFeeType.values.firstWhere(
        (e) => e.name == json['feeType'],
        orElse: () => LeechFeeType.financeCharge,
      ),
      amount: (json['amount'] as num).toDouble(),
      detectedDate: DateTime.parse(json['detectedDate'] as String),
      status: LeechStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeechStatus.detected,
      ),
      daysOfFreedomDestroyed: json['daysOfFreedomDestroyed'] as int? ?? 1,
      disputeLetter: json['disputeLetter'] as String? ?? '',
    );
  }

  LeechChargeItem copyWith({
    LeechStatus? status,
    String? disputeLetter,
  }) {
    return LeechChargeItem(
      id: id,
      lender: lender,
      accountOrCardLast4: accountOrCardLast4,
      feeType: feeType,
      amount: amount,
      detectedDate: detectedDate,
      status: status ?? this.status,
      daysOfFreedomDestroyed: daysOfFreedomDestroyed,
      disputeLetter: disputeLetter ?? this.disputeLetter,
    );
  }
}

class LeechHunterState {
  final List<LeechChargeItem> leeches;
  final double totalLeachedAmount;
  final double totalRecoveredAmount;
  final int totalDaysDestroyed;

  const LeechHunterState({
    this.leeches = const [],
    this.totalLeachedAmount = 0.0,
    this.totalRecoveredAmount = 0.0,
    this.totalDaysDestroyed = 0,
  });

  List<LeechChargeItem> get activeLeeches =>
      leeches.where((l) => l.status != LeechStatus.waived).toList();

  List<LeechChargeItem> get waivedLeeches =>
      leeches.where((l) => l.status == LeechStatus.waived).toList();

  LeechHunterState copyWith({
    List<LeechChargeItem>? leeches,
    double? totalLeachedAmount,
    double? totalRecoveredAmount,
    int? totalDaysDestroyed,
  }) {
    return LeechHunterState(
      leeches: leeches ?? this.leeches,
      totalLeachedAmount: totalLeachedAmount ?? this.totalLeachedAmount,
      totalRecoveredAmount: totalRecoveredAmount ?? this.totalRecoveredAmount,
      totalDaysDestroyed: totalDaysDestroyed ?? this.totalDaysDestroyed,
    );
  }
}

final leechHunterServiceProvider =
    StateNotifierProvider<LeechHunterNotifier, LeechHunterState>((ref) {
  return LeechHunterNotifier();
});

class LeechHunterNotifier extends StateNotifier<LeechHunterState> {
  static const String _prefKey = 'duedo_leech_hunter_items_v1';

  LeechHunterNotifier() : super(const LeechHunterState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = list.map((e) => LeechChargeItem.fromJson(e as Map<String, dynamic>)).toList();
        _updateMetrics(items);
        return;
      } catch (_) {}
    }
    // Default seed for initial discovery demo
    final seed = [
      LeechChargeItem(
        id: 'seed-leech-1',
        lender: 'HDFC Bank',
        accountOrCardLast4: '4091',
        feeType: LeechFeeType.annualFee,
        amount: 590.0,
        detectedDate: DateTime.now().subtract(const Duration(days: 3)),
        status: LeechStatus.detected,
        daysOfFreedomDestroyed: 2,
        disputeLetter: _buildRbiLetter('HDFC Bank', '4091', 590.0, 'Annual Card Membership Fee'),
      ),
      LeechChargeItem(
        id: 'seed-leech-2',
        lender: 'ICICI Bank',
        accountOrCardLast4: '8821',
        feeType: LeechFeeType.gstOnInterest,
        amount: 324.0,
        detectedDate: DateTime.now().subtract(const Duration(days: 5)),
        status: LeechStatus.detected,
        daysOfFreedomDestroyed: 1,
        disputeLetter: _buildRbiLetter('ICICI Bank', '8821', 324.0, '18% GST Surcharge on Finance Charges'),
      ),
    ];
    _updateMetrics(seed);
  }

  void _updateMetrics(List<LeechChargeItem> items) {
    double leached = 0.0;
    double recovered = 0.0;
    int days = 0;

    for (final l in items) {
      leached += l.amount;
      if (l.status == LeechStatus.waived) {
        recovered += l.amount;
      } else {
        days += l.daysOfFreedomDestroyed;
      }
    }

    state = state.copyWith(
      leeches: items,
      totalLeachedAmount: leached,
      totalRecoveredAmount: recovered,
      totalDaysDestroyed: days,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.leeches.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, jsonStr);
  }

  /// Scans statement text for predatory fees using pattern matching
  Future<List<LeechChargeItem>> scanStatementText(
    String text, {
    String lender = 'Bank',
    String last4 = 'XXXX',
    double dailyDebtBurn = 400.0,
  }) async {
    final detected = <LeechChargeItem>[];
    final lines = text.split('\n');

    final patterns = [
      (RegExp(r'(?:annual|membership|renewal)\s*(?:fee|charge)?[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.annualFee),
      (RegExp(r'(?:gst|cgst|sgst|igst)\s*(?:@\s*18%|charges)?[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.gstOnInterest),
      (RegExp(r'(?:late\s*payment|penal\s*interest)\s*(?:fee|penalty|charge)?[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.latePaymentPenalty),
      (RegExp(r'(?:bounce|return|nach\s*fail|ecs\s*return)\s*(?:fee|charge)?[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.bounceCharge),
      (RegExp(r'(?:over\s*limit|limit\s*breach)\s*(?:fee|penalty|charge)?[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.overlimitFee),
      (RegExp(r'(?:finance|service)\s*(?:charge|fee)[:\s]*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false), LeechFeeType.financeCharge),
    ];

    for (final line in lines) {
      for (final (regex, feeType) in patterns) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final amtStr = match.group(1)?.replaceAll(',', '');
          if (amtStr != null) {
            final amt = double.tryParse(amtStr) ?? 0.0;
            if (amt > 20.0) {
              final daysDestroyed = dailyDebtBurn > 0 ? (amt / dailyDebtBurn).round().clamp(1, 60) : 1;
              final item = LeechChargeItem(
                id: 'leech-${DateTime.now().millisecondsSinceEpoch}-${detected.length}',
                lender: lender,
                accountOrCardLast4: last4,
                feeType: feeType,
                amount: amt,
                detectedDate: DateTime.now(),
                status: LeechStatus.detected,
                daysOfFreedomDestroyed: daysDestroyed,
                disputeLetter: _buildRbiLetter(lender, last4, amt, line.trim()),
              );
              detected.add(item);
            }
          }
        }
      }
    }

    if (detected.isNotEmpty) {
      HapticService.savageThud();
      final updated = [...detected, ...state.leeches];
      _updateMetrics(updated);
      await _save();
    }

    return detected;
  }

  /// Audits theoretical balance vs reported balance discrepancy
  Future<LeechChargeItem?> auditAmortizationDiscrepancy({
    required String lender,
    required String last4,
    required double reportedBalance,
    required double theoreticalExpectedBalance,
    double dailyDebtBurn = 400.0,
  }) async {
    final delta = reportedBalance - theoreticalExpectedBalance;
    if (delta >= 150.0) {
      final daysDestroyed = (delta / (dailyDebtBurn > 0 ? dailyDebtBurn : 400.0)).round().clamp(1, 90);
      final item = LeechChargeItem(
        id: 'discrepancy-${DateTime.now().millisecondsSinceEpoch}',
        lender: lender,
        accountOrCardLast4: last4,
        feeType: LeechFeeType.financeCharge,
        amount: delta,
        detectedDate: DateTime.now(),
        status: LeechStatus.detected,
        daysOfFreedomDestroyed: daysDestroyed,
        disputeLetter: _buildRbiLetter(lender, last4, delta, 'Unreconciled Monthly Amortization Drift & Finance Surcharge'),
      );
      final updated = [item, ...state.leeches];
      _updateMetrics(updated);
      await _save();
      return item;
    }
    return null;
  }

  Future<void> markStatus(String id, LeechStatus newStatus) async {
    if (newStatus == LeechStatus.waived) {
      HapticService.dopamineCascade();
    } else {
      HapticService.selection();
    }

    final updated = state.leeches.map((e) {
      if (e.id == id) {
        return e.copyWith(status: newStatus);
      }
      return e;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }

  Future<void> deleteLeech(String id) async {
    HapticService.selection();
    final updated = state.leeches.where((e) => e.id != id).toList();
    _updateMetrics(updated);
    await _save();
  }

  static String _buildRbiLetter(String lender, String last4, double amount, String feeDesc) {
    return '''
To: Grievance Redressal Officer / Nodal Officer, $lender
Subject: Urgent: Request for Reversal of Inadmissible Charges (Card/A/c ending in $last4)

Dear Sir/Madam,

I am writing regarding my account/credit facility ending in $last4 with $lender. 
Upon auditing my latest statement, I noticed an inadmissible charge of ₹${amount.toStringAsFixed(2)} categorized under: "$feeDesc".

I bring to your attention the following regulatory mandates:
1. RBI Master Direction & Circular (RBI/2023-24/53 DOR.MCS.REC.28/01.01.001/2023-24) on Fair Practices Code and Penal Charges in Loan Accounts, stipulating that penalty charges must not be used as a revenue-enhancement tool and must remain strictly compensatory and transparent.
2. The charges levied were neither explicitly consented to beforehand nor proportionate to any default on my part, given my continuous record of on-time debt servicing.

As a loyal customer maintaining prompt repayment obligations, I formally request an immediate 100% waiver and credit of ₹${amount.toStringAsFixed(2)} back into my account within 7 working days.

Kindly issue a revised statement reflecting this reversal. In the event this dispute is not satisfactorily resolved, I reserve the right to escalate this matter to the RBI Banking Ombudsman under the Integrated Ombudsman Scheme, 2021.

Thank you.
Sincerely,
Account Holder ($lender Card/Loan Ending $last4)
Generated via Duedo Shield Audit Engine
'''.trim();
  }
}
