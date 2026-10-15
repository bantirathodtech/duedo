import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';

final voiceSlayServiceProvider = Provider((ref) => VoiceSlayService());

enum VoiceIntentType {
  paymentSnowflake,
  expenseSpent,
  vaultImpulse,
  queryStatus,
}

class VoiceSlayIntent {
  final VoiceIntentType type;
  final double amount;
  final String? target;
  final Obligation? matchedObligation;
  final String confirmationMessage;

  const VoiceSlayIntent({
    required this.type,
    required this.amount,
    this.target,
    this.matchedObligation,
    required this.confirmationMessage,
  });
}

class VoiceSlayService {
  /// Parses natural language voice commands into actionable financial mutations
  VoiceSlayIntent parseVoiceCommand(String rawText, List<Obligation> obligations) {
    final lower = rawText.toLowerCase().trim();

    // 1. Extract amount
    double amount = 0.0;
    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)');
    final match = amountRegex.firstMatch(lower);
    if (match != null) {
      final clean = match.group(1)?.replaceAll(',', '');
      amount = double.tryParse(clean ?? '') ?? 0.0;
    }

    // 2. Query Status Intent
    if (lower.contains('how much') || lower.contains('safe today') || lower.contains('status') || lower.contains('streak')) {
      return const VoiceSlayIntent(
        type: VoiceIntentType.queryStatus,
        amount: 0.0,
        confirmationMessage: 'Querying live Safe-to-Spend & Daily Ring status.',
      );
    }

    // 3. Vault Impulse Intent
    if (lower.contains('vault') || lower.contains('resist') || lower.contains('impulse') || lower.contains('prevent')) {
      final itemTarget = _extractItemAfterKeywords(lower, ['vault', 'resist', 'saved', 'for']);
      return VoiceSlayIntent(
        type: VoiceIntentType.vaultImpulse,
        amount: amount,
        target: itemTarget ?? 'Impulse Item',
        confirmationMessage: 'Vaulted ${itemTarget ?? 'item'} ($amount) into 24h cooling chamber.',
      );
    }

    // 4. Payment / Snowflake Slay Intent
    if (lower.contains('slay') || lower.contains('paid') || lower.contains('settle') || lower.contains('snowball')) {
      Obligation? matched;
      for (final ob in obligations) {
        final obTitle = ob.title.toLowerCase();
        if (lower.contains(obTitle)) {
          matched = ob;
          break;
        }
      }

      // If no exact match, check bank or keywords
      if (matched == null) {
        final keywords = ['hdfc', 'sbi', 'icici', 'axis', 'card', 'loan', 'emi', 'bajaj'];
        for (final kw in keywords) {
          if (lower.contains(kw)) {
            matched = obligations.firstWhere(
              (o) => o.title.toLowerCase().contains(kw),
              orElse: () => obligations.isNotEmpty ? obligations.first : obligations.first,
            );
            break;
          }
        }
      }

      matched ??= obligations.isNotEmpty ? obligations.first : null;

      final targetName = matched?.title ?? 'Debt Snowflake';
      return VoiceSlayIntent(
        type: VoiceIntentType.paymentSnowflake,
        amount: amount,
        target: targetName,
        matchedObligation: matched,
        confirmationMessage: 'Ready to slay ₹${amount.toStringAsFixed(0)} on $targetName.',
      );
    }

    // 5. Default: Expense Spent Intent
    final spentTarget = _extractItemAfterKeywords(lower, ['on', 'for', 'spent']) ?? 'Daily Expense';
    return VoiceSlayIntent(
      type: VoiceIntentType.expenseSpent,
      amount: amount,
      target: spentTarget,
      confirmationMessage: 'Deducted ₹${amount.toStringAsFixed(0)} ($spentTarget) from today\'s Safe-to-Spend.',
    );
  }

  String? _extractItemAfterKeywords(String text, List<String> keywords) {
    for (final kw in keywords) {
      final idx = text.indexOf(kw);
      if (idx != -1) {
        final sub = text.substring(idx + kw.length).trim();
        // Remove amount if present
        final cleaned = sub.replaceAll(RegExp(r'(?:rs\.?|inr|₹)?\s*[\d,]+'), '').trim();
        if (cleaned.isNotEmpty) return cleaned;
      }
    }
    return null;
  }
}
