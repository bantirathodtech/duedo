import 'package:flutter/foundation.dart';
import 'logger_service.dart';

class AuditLog {
  static final List<String> _logs = [];
  static final Map<String, DateTime> _timers = {};

  static void info(String message, {String? tag}) {
    final log = '[DUEDO_AUDIT${tag != null ? ':$tag' : ''}] $message';
    _logs.add(log);
    debugPrint(log);
  }

  static void startTimer(String label) {
    _timers[label] = DateTime.now();
    info('START: $label', tag: 'PERF');
  }

  static void stopTimer(String label) {
    final start = _timers[label];
    if (start != null) {
      final duration = DateTime.now().difference(start);
      info('COMPLETE: $label in ${duration.inMilliseconds}ms', tag: 'PERF');
      _timers.remove(label);
    }
  }

  /// Ironman: Instance-based logging for cleaner code
  void log(String message, {LogCategory category = LogCategory.info}) {
    info(message, tag: category.name.toUpperCase());
  }

  /// Ironman: Performance tracing
  void perf(String label, {LogCategory category = LogCategory.performance}) {
    _timers[label] = DateTime.now();
    info('START: $label', tag: 'PERF');
  }

  /// Ironman: Performance completion
  void perfComplete(String label, {LogCategory category = LogCategory.performance}) {
    stopTimer(label);
  }

  static List<String> get logs => List.unmodifiable(_logs);
}
