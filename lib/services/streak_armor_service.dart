import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class StreakArmorState {
  final int shieldsBanked; // Max 2
  final bool isArmorDeployed;
  final int daysUntilNextShield; // 14 - (totalCleanDays % 14)
  final String? lastDeployedReason;

  const StreakArmorState({
    this.shieldsBanked = 1,
    this.isArmorDeployed = false,
    this.daysUntilNextShield = 9,
    this.lastDeployedReason,
  });

  StreakArmorState copyWith({
    int? shieldsBanked,
    bool? isArmorDeployed,
    int? daysUntilNextShield,
    String? lastDeployedReason,
    bool clearDeployedReason = false,
  }) {
    return StreakArmorState(
      shieldsBanked: shieldsBanked ?? this.shieldsBanked,
      isArmorDeployed: isArmorDeployed ?? this.isArmorDeployed,
      daysUntilNextShield: daysUntilNextShield ?? this.daysUntilNextShield,
      lastDeployedReason: clearDeployedReason ? null : (lastDeployedReason ?? this.lastDeployedReason),
    );
  }
}

final streakArmorProvider =
    StateNotifierProvider<StreakArmorNotifier, StreakArmorState>((ref) {
  return StreakArmorNotifier();
});

class StreakArmorNotifier extends StateNotifier<StreakArmorState> {
  static const String _keyShields = 'duedo_streak_shields_banked';
  static const String _keyDeployed = 'duedo_streak_armor_deployed';

  StreakArmorNotifier() : super(const StreakArmorState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final shields = prefs.getInt(_keyShields) ?? 1;
    final deployed = prefs.getBool(_keyDeployed) ?? false;

    state = state.copyWith(
      shieldsBanked: shields,
      isArmorDeployed: deployed,
    );
  }

  /// Evaluates rollover. If day missed but shield available, consumes 1 shield to protect streak!
  Future<bool> checkAndDeployArmor({required int daysSinceActive}) async {
    if (daysSinceActive > 1 && state.shieldsBanked > 0 && !state.isArmorDeployed) {
      final newShields = (state.shieldsBanked - 1).clamp(0, 2);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyShields, newShields);
      await prefs.setBool(_keyDeployed, true);

      HapticService.dopamineCascade();

      state = state.copyWith(
        shieldsBanked: newShields,
        isArmorDeployed: true,
        lastDeployedReason: 'Auto-deployed during a $daysSinceActive-day gap to defend your hard-earned streak.',
      );
      return true; // Armor protected the streak
    }
    return false;
  }

  /// Recharges a shield by completing a Relapse Rescue Quest (e.g. micro-snowflake or impulse resist)
  Future<void> completeRescueQuest() async {
    final prefs = await SharedPreferences.getInstance();
    final newShields = (state.shieldsBanked + 1).clamp(0, 2);
    await prefs.setInt(_keyShields, newShields);
    await prefs.setBool(_keyDeployed, false);

    HapticService.dopamineCascade();

    state = state.copyWith(
      shieldsBanked: newShields,
      isArmorDeployed: false,
      clearDeployedReason: true,
    );
  }

  /// Updates progress toward earning the next shield (every 14 clean days)
  Future<void> onCleanDayRecorded(int totalCleanDays) async {
    final remainder = totalCleanDays % 14;
    final daysLeft = remainder == 0 ? 14 : (14 - remainder);

    // If exact milestone hit and bank has space, earn +1 shield
    if (remainder == 0 && state.shieldsBanked < 2) {
      final newShields = (state.shieldsBanked + 1).clamp(0, 2);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyShields, newShields);
      state = state.copyWith(shieldsBanked: newShields, daysUntilNextShield: 14);
      HapticService.dopamineCascade();
    } else {
      state = state.copyWith(daysUntilNextShield: daysLeft);
    }
  }
}
