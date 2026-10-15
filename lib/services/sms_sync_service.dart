import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/obligation_repository.dart';
import 'notification_service.dart';
import 'logger_service.dart';

/// Service managing optional financial transaction syncing.
/// Native SMS scanning is disabled for Google Play Store compliance
/// (Google Play SMS Policy prohibits background SMS reading for financial apps).
class SmsSyncService {
  final Ref _ref;

  SmsSyncService(this._ref);

  /// Initializes transaction sync listener if enabled.
  Future<void> init() async {
    final settings = await _ref.read(obligationRepositoryProvider).getSettings().first;
    if (settings?.smsSyncEnabled != true) return;
    
    LoggerService.log(
      'SMS sync requested, but background SMS permissions are restricted on Google Play.',
      category: LogCategory.info,
    );
  }

  /// Processes text-based financial transactions (e.g. from clipboard or manual paste)
  Future<void> processTransactionText(String body, String sender) async {
    // 1. Extract Amount - Matches "Rs. 15,000", "Rs 15000", "INR 15,000.00", etc.
    final amountMatch = RegExp(r'(?:rs|inr|amt)\.?\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(body);
    if (amountMatch == null) return;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) return;

    // 2. Match against existing obligations
    final repo = _ref.read(obligationRepositoryProvider);
    final obligations = await repo.getAllObligations().first;

    for (final ob in obligations) {
      if (!ob.isActive) continue;

      if (body.toLowerCase().contains(ob.title.toLowerCase())) {
        await repo.markAsPaid(ob, amount, note: 'Synced transaction from $sender');

        _ref.read(notificationServiceProvider).showInstantAlert(
          id: 5555,
          title: "Got It! ⚡",
          body: "We just spotted your ${ob.title} payment. Synchronized like a pro! 🎯",
        );
        return;
      }
    }
  }
}

final smsSyncServiceProvider = Provider((ref) => SmsSyncService(ref));
