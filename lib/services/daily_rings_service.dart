import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

final dailyRingsServiceProvider = StateNotifierProvider<DailyRingsNotifier, DailyRingsState>((ref) {
  return DailyRingsNotifier();
});

class DailyRingsState {
  final bool cleanDayCompleted;
  final bool snowflakeCompleted;
  final bool checkInCompleted;
  final int currentStreak;
  final int longestStreak;
  final int totalCleanDays;
  final DateTime? lastActiveDate;
  final bool ringsClosedToday;

  const DailyRingsState({
    this.cleanDayCompleted = false,
    this.snowflakeCompleted = false,
    this.checkInCompleted = true, // Auto-checked when opening app
    this.currentStreak = 3,
    this.longestStreak = 7,
    this.totalCleanDays = 12,
    this.lastActiveDate,
    this.ringsClosedToday = false,
  });

  double get cleanProgress => cleanDayCompleted ? 1.0 : 0.0;
  double get snowflakeProgress => snowflakeCompleted ? 1.0 : 0.0;
  double get checkInProgress => checkInCompleted ? 1.0 : 0.0;
  double get overallProgress => (cleanProgress + snowflakeProgress + checkInProgress) / 3.0;

  DailyRingsState copyWith({
    bool? cleanDayCompleted,
    bool? snowflakeCompleted,
    bool? checkInCompleted,
    int? currentStreak,
    int? longestStreak,
    int? totalCleanDays,
    DateTime? lastActiveDate,
    bool? ringsClosedToday,
  }) {
    return DailyRingsState(
      cleanDayCompleted: cleanDayCompleted ?? this.cleanDayCompleted,
      snowflakeCompleted: snowflakeCompleted ?? this.snowflakeCompleted,
      checkInCompleted: checkInCompleted ?? this.checkInCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      ringsClosedToday: ringsClosedToday ?? this.ringsClosedToday,
    );
  }

  Map<String, dynamic> toJson() => {
    'cleanDayCompleted': cleanDayCompleted,
    'snowflakeCompleted': snowflakeCompleted,
    'checkInCompleted': checkInCompleted,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalCleanDays': totalCleanDays,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'ringsClosedToday': ringsClosedToday,
  };

  factory DailyRingsState.fromJson(Map<String, dynamic> json) {
    return DailyRingsState(
      cleanDayCompleted: json['cleanDayCompleted'] as bool? ?? false,
      snowflakeCompleted: json['snowflakeCompleted'] as bool? ?? false,
      checkInCompleted: json['checkInCompleted'] as bool? ?? true,
      currentStreak: json['currentStreak'] as int? ?? 1,
      longestStreak: json['longestStreak'] as int? ?? 1,
      totalCleanDays: json['totalCleanDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.tryParse(json['lastActiveDate'] as String) : null,
      ringsClosedToday: json['ringsClosedToday'] as bool? ?? false,
    );
  }
}

class DailyRingsNotifier extends StateNotifier<DailyRingsState> {
  static const _prefKey = 'duedo_daily_rings_state_v1';

  DailyRingsNotifier() : super(const DailyRingsState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    final now = DateTime.now();

    if (jsonStr != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final loaded = DailyRingsState.fromJson(data);
        final last = loaded.lastActiveDate;

        if (last != null) {
          final isSameDay = last.year == now.year && last.month == now.month && last.day == now.day;
          final isConsecutiveDay = now.difference(DateTime(last.year, last.month, last.day)).inDays == 1;

          if (isSameDay) {
            state = loaded.copyWith(checkInCompleted: true);
          } else if (isConsecutiveDay) {
            // New day in streak
            state = loaded.copyWith(
              cleanDayCompleted: false,
              snowflakeCompleted: false,
              checkInCompleted: true,
              ringsClosedToday: false,
              lastActiveDate: now,
            );
          } else {
            // Streak broken (gap of >1 day)
            state = loaded.copyWith(
              cleanDayCompleted: false,
              snowflakeCompleted: false,
              checkInCompleted: true,
              ringsClosedToday: false,
              currentStreak: 1,
              lastActiveDate: now,
            );
          }
        } else {
          state = loaded.copyWith(lastActiveDate: now, checkInCompleted: true);
        }
      } catch (_) {
        state = state.copyWith(lastActiveDate: now, checkInCompleted: true);
      }
    } else {
      state = state.copyWith(lastActiveDate: now, checkInCompleted: true);
    }
    _save();
  }

  Future<void> toggleCleanDay() async {
    final newValue = !state.cleanDayCompleted;
    int streak = state.currentStreak;
    int longest = state.longestStreak;
    int totalClean = state.totalCleanDays + (newValue ? 1 : -1);

    if (newValue) {
      HapticService.victoryPop();
    } else {
      HapticService.subtleClick();
    }

    final allClosed = newValue && state.snowflakeCompleted && state.checkInCompleted;
    if (allClosed && !state.ringsClosedToday) {
      streak += 1;
      if (streak > longest) longest = streak;
      HapticService.dopamineCascade();
    }

    state = state.copyWith(
      cleanDayCompleted: newValue,
      totalCleanDays: totalClean < 0 ? 0 : totalClean,
      currentStreak: streak,
      longestStreak: longest,
      ringsClosedToday: allClosed,
      lastActiveDate: DateTime.now(),
    );
    await _save();
  }

  Future<void> recordSnowflake() async {
    HapticService.victoryPop();
    int streak = state.currentStreak;
    int longest = state.longestStreak;

    final allClosed = state.cleanDayCompleted && state.checkInCompleted;
    if (allClosed && !state.ringsClosedToday) {
      streak += 1;
      if (streak > longest) longest = streak;
      HapticService.dopamineCascade();
    }

    state = state.copyWith(
      snowflakeCompleted: true,
      currentStreak: streak,
      longestStreak: longest,
      ringsClosedToday: allClosed,
      lastActiveDate: DateTime.now(),
    );
    await _save();
  }

  Future<void> recordCheckIn() async {
    final allClosed = state.cleanDayCompleted && state.snowflakeCompleted;
    int streak = state.currentStreak;
    int longest = state.longestStreak;
    if (allClosed && !state.ringsClosedToday) {
      streak += 1;
      if (streak > longest) longest = streak;
      HapticService.dopamineCascade();
    } else {
      HapticService.subtleClick();
    }

    state = state.copyWith(
      checkInCompleted: true,
      currentStreak: streak,
      longestStreak: longest,
      ringsClosedToday: allClosed,
      lastActiveDate: DateTime.now(),
    );
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(state.toJson()));
  }
}
