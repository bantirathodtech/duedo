import 'package:shared_preferences/shared_preferences.dart';

class GlanceWidgetData {
  final double safeToSpendAmount;
  final bool cleanDayCompleted;
  final int streakDays;
  final bool ringsClosed;
  final DateTime lastUpdated;

  const GlanceWidgetData({
    required this.safeToSpendAmount,
    required this.cleanDayCompleted,
    required this.streakDays,
    required this.ringsClosed,
    required this.lastUpdated,
  });
}

class GlanceWidgetService {
  static const String _keySafeToSpend = 'duedo_glance_safe_to_spend';
  static const String _keyCleanDay = 'duedo_glance_clean_day';
  static const String _keyStreak = 'duedo_glance_streak';
  static const String _keyRingsClosed = 'duedo_glance_rings_closed';
  static const String _keyUpdatedAt = 'duedo_glance_updated_at';

  /// Syncs app state into platform widget storage
  static Future<void> syncGlanceData({
    required double safeToSpend,
    required bool cleanDay,
    required int streak,
    required bool ringsClosed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySafeToSpend, safeToSpend);
    await prefs.setBool(_keyCleanDay, cleanDay);
    await prefs.setInt(_keyStreak, streak);
    await prefs.setBool(_keyRingsClosed, ringsClosed);
    await prefs.setInt(_keyUpdatedAt, DateTime.now().millisecondsSinceEpoch);
  }

  /// Retrieves persisted glance data for lock-screen simulation and widgets
  static Future<GlanceWidgetData> getGlanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final safeToSpend = prefs.getDouble(_keySafeToSpend) ?? 1250.0;
    final cleanDay = prefs.getBool(_keyCleanDay) ?? true;
    final streak = prefs.getInt(_keyStreak) ?? 5;
    final ringsClosed = prefs.getBool(_keyRingsClosed) ?? false;
    final updatedMs = prefs.getInt(_keyUpdatedAt);

    return GlanceWidgetData(
      safeToSpendAmount: safeToSpend,
      cleanDayCompleted: cleanDay,
      streakDays: streak,
      ringsClosed: ringsClosed,
      lastUpdated: updatedMs != null 
          ? DateTime.fromMillisecondsSinceEpoch(updatedMs) 
          : DateTime.now(),
    );
  }
}
