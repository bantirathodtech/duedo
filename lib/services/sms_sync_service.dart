import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/obligation_repository.dart';
import 'notification_service.dart';
import 'dart:developer' as dev;

class SmsSyncService {
  final Telephony _telephony = Telephony.instance;
  final Ref _ref;

  SmsSyncService(this._ref);

  /// Requests permissions and starts listening for SMS
  Future<void> init() async {
    if (!Platform.isAndroid) return; // Telephony is Android only
    
    bool? permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      _telephony.listenIncomingSms(
        onNewMessage: _handleSms,
        listenInBackground: false,
      );
    }
  }

  void _handleSms(SmsMessage message) async {
    final settings = await _ref.read(obligationRepositoryProvider).getSettings().first;
    if (settings?.smsSyncEnabled != true) return;

    final body = message.body?.toLowerCase() ?? '';
    final sender = message.address?.toUpperCase() ?? '';

    // Logic for detectting Bank Transaction
    // Example: "Hdfc bank: emi of rs 15,000 for loan ... debited from a/c ..."
    if (body.contains('rs') || body.contains('inr') || body.contains('debited') || body.contains('spent')) {
      _processFinancialSms(body, sender);
    }
  }

  void _processFinancialSms(String body, String sender) async {
    dev.log('Duedo SMS Debug: Processing from $sender - $body');

    // 1. Extract Amount - Improved regex for Indian SMS formats
    // Matches "Rs. 15,000", "Rs 15000", "INR 15,000.00", etc.
    final amountMatch = RegExp(r'(?:rs|inr|amt)\.?\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(body);
    if (amountMatch == null) return;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) return;

    // 2. Identify if it's an EMI or Recurring Expense
    bool isEmi = body.contains('emi') || body.contains('loan');
    
    // 3. Match against existing obligations
    final repo = _ref.read(obligationRepositoryProvider);
    final obligations = await repo.getAllObligations().first;

    for (final ob in obligations) {
      if (!ob.isActive) continue;
      
      // Simple string matching for now (Fuzzy matching can be added later)
      // Check if title or category exists in SMS body
      if (body.contains(ob.title.toLowerCase())) {
        await repo.markAsPaid(ob, amount, note: 'Auto-synced via SMS from $sender');
        
        // Witty Confirmation
        _ref.read(notificationServiceProvider).showInstantAlert(
          id: 5555,
          title: "Got It! ⚡",
          body: "We just spotted your ${ob.title} payment. Synchronized like a pro! 🎯",
        );
        return;
      }
    }

    // Default: Check for large debits even if not explicitly matched
    if (isEmi && amount > 1000) {
      // Potentially notify user to link this to an obligation
      dev.log('Duedo SMS: Unlinked EMI detected: $amount');
    }
  }
}

final smsSyncServiceProvider = Provider((ref) => SmsSyncService(ref));
