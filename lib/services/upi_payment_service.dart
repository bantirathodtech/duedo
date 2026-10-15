import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'haptic_service.dart';

enum UpiLaunchStatus {
  success,
  unsupported,
  failed,
}

class UpiLaunchResult {
  final UpiLaunchStatus status;
  final String? message;
  final String rawUri;

  const UpiLaunchResult({
    required this.status,
    required this.rawUri,
    this.message,
  });
}

class UpiPaymentService {
  /// Known bank VPA patterns or defaults for major Indian lenders
  static const Map<String, String> defaultBillerVpas = {
    'hdfc': 'hdfcbank@hdfcbank',
    'sbi': 'sbi.cards@sbi',
    'icici': 'icici.cards@icici',
    'axis': 'axis.cards@axisbank',
    'kotak': 'kotak.cards@kotak',
    'cred': 'cred.pay@axisbank',
    'amex': 'amex.cards@scb',
    'onecard': 'onecard@icici',
  };

  /// Resolves default biller VPA for a lender name
  static String getVpaForLender(String lender) {
    final lower = lender.toLowerCase();
    for (final entry in defaultBillerVpas.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'billpay@hdfcbank';
  }

  /// Constructs an NPCI-compliant UPI URI
  static String buildUpiUri({
    required String vpa,
    required String payeeName,
    required double amount,
    String transactionNote = 'Duedo Debt Slayer Snowflake',
    String currency = 'INR',
  }) {
    final cleanVpa = vpa.trim().replaceAll(' ', '');
    final cleanPayee = Uri.encodeComponent(payeeName.trim());
    final cleanNote = Uri.encodeComponent(transactionNote.trim());
    final formattedAmount = amount.toStringAsFixed(2);

    return 'upi://pay?pa=$cleanVpa&pn=$cleanPayee&am=$formattedAmount&cu=$currency&tn=$cleanNote';
  }

  /// Attempts to launch the native UPI intent.
  /// If no UPI handler is found (e.g. simulator/desktop), returns [UpiLaunchStatus.unsupported].
  static Future<UpiLaunchResult> launchUpiPayment({
    required String vpa,
    required String payeeName,
    required double amount,
    String transactionNote = 'Duedo Debt Slayer Snowflake',
  }) async {
    final uriString = buildUpiUri(
      vpa: vpa,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );

    final uri = Uri.parse(uriString);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        HapticService.dopamineCascade();
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          return UpiLaunchResult(
            status: UpiLaunchStatus.success,
            rawUri: uriString,
            message: 'UPI app opened successfully.',
          );
        }
      }
      
      // Fallback for devices without native UPI handler or restrictive intent policies
      return UpiLaunchResult(
        status: UpiLaunchStatus.unsupported,
        rawUri: uriString,
        message: 'No active UPI application found to handle payment.',
      );
    } catch (e) {
      return UpiLaunchResult(
        status: UpiLaunchStatus.failed,
        rawUri: uriString,
        message: 'Failed to launch UPI intent: ${e.toString()}',
      );
    }
  }

  /// Helper to copy UPI details to system clipboard for manual transfer
  static Future<void> copyUpiDetailsToClipboard({
    required String vpa,
    required double amount,
  }) async {
    HapticService.selection();
    await Clipboard.setData(ClipboardData(text: vpa));
  }

  /// Infers biller VPA from obligation title and category
  static String inferVpa(String title, String category) {
    final combined = '${title.toLowerCase()} ${category.toLowerCase()}';
    for (final entry in defaultBillerVpas.entries) {
      if (combined.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'payee@upi';
  }
}
