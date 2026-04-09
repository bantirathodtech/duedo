import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

enum LogCategory { info, warning, error, financial, security, performance }

class LoggerService {
  static void log(String message, {
    LogCategory category = LogCategory.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // In Release mode, we only log critical errors or high-level info
    // We also sanitize financial data if it was accidentally passed in the main string
    final sanitizedMessage = _sanitize(message);
    
    final logLabel = '[Duedo|${category.name.toUpperCase()}]';
    
    if (kDebugMode) {
      debugPrint('$logLabel $sanitizedMessage');
      if (error != null) {
        debugPrint('Error: $error');
        if (stackTrace != null) debugPrint('Stack: $stackTrace');
      }
    } else {
      // In Profile/Release, we use dev.log which is more efficient
      dev.log(
        sanitizedMessage,
        name: 'com.avishio.duedo',
        error: error,
        stackTrace: stackTrace,
        level: _getSeverity(category),
      );
    }
  }

  static String _sanitize(String input) {
    // Basic regex to hide potential sensitive amounts in generic logs
    // Matches patterns like "Rs. 1000", "INR 500"
    return input.replaceAll(RegExp(r'(rs|inr)\.?\s?\d+', caseSensitive: false), '[SECRET_AMOUNT]');
  }

  static int _getSeverity(LogCategory category) {
    switch (category) {
      case LogCategory.error: return 1000;
      case LogCategory.warning: return 900;
      case LogCategory.security: return 800;
      case LogCategory.financial: return 500;
      case LogCategory.performance: return 200;
      case LogCategory.info: return 0;
    }
  }
}
