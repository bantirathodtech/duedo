import 'package:shared_preferences/shared_preferences.dart';

class QuickTileService {
  static const String _keyTileTitle = 'duedo_quick_tile_title';
  static const String _keyTileSubtitle = 'duedo_quick_tile_subtitle';
  static const String _keyTileAction = 'duedo_quick_tile_action';

  /// Syncs live financial metrics for the OS Quick Settings Tile / Control Center widget
  static Future<void> syncQuickTile({
    required double safeToSpend,
    required int streakDays,
    required String currency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTileTitle,
      '🛡️ $currency${safeToSpend.toStringAsFixed(0)} Safe',
    );
    await prefs.setString(
      _keyTileSubtitle,
      '🔥 $streakDays Day Streak • Clean Day Ready',
    );
    await prefs.setString(_keyTileAction, 'clean_day_toggle');
  }

  /// Reads cached tile display data
  static Future<Map<String, String>> getQuickTileData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'title': prefs.getString(_keyTileTitle) ?? '🛡️ ₹1,250 Safe',
      'subtitle': prefs.getString(_keyTileSubtitle) ?? '🔥 3 Day Streak',
      'action': prefs.getString(_keyTileAction) ?? 'clean_day_toggle',
    };
  }
}
