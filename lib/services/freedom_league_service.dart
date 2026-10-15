import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

enum LeagueTier {
  bronze,
  silver,
  gold,
  diamond,
  valhalla,
}

extension LeagueTierExtension on LeagueTier {
  String get displayName {
    switch (this) {
      case LeagueTier.bronze:
        return 'Bronze League';
      case LeagueTier.silver:
        return 'Silver League';
      case LeagueTier.gold:
        return 'Gold League';
      case LeagueTier.diamond:
        return 'Diamond League';
      case LeagueTier.valhalla:
        return 'Zero-Debt Valhalla';
    }
  }

  String get trophyEmoji {
    switch (this) {
      case LeagueTier.bronze:
        return '🥉';
      case LeagueTier.silver:
        return '🥈';
      case LeagueTier.gold:
        return '🥇';
      case LeagueTier.diamond:
        return '💎';
      case LeagueTier.valhalla:
        return '⚡';
    }
  }

  int get minPoints {
    switch (this) {
      case LeagueTier.bronze:
        return 0;
      case LeagueTier.silver:
        return 500;
      case LeagueTier.gold:
        return 1500;
      case LeagueTier.diamond:
        return 3000;
      case LeagueTier.valhalla:
        return 6000;
    }
  }
}

class LeagueMember {
  final String id;
  final String displayName;
  final String avatarEmoji;
  final int points;
  final int streakDays;
  final bool isUser;

  const LeagueMember({
    required this.id,
    required this.displayName,
    required this.avatarEmoji,
    required this.points,
    required this.streakDays,
    this.isUser = false,
  });

  LeagueMember copyWith({
    String? id,
    String? displayName,
    String? avatarEmoji,
    int? points,
    int? streakDays,
    bool? isUser,
  }) {
    return LeagueMember(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      points: points ?? this.points,
      streakDays: streakDays ?? this.streakDays,
      isUser: isUser ?? this.isUser,
    );
  }
}

class FreedomLeagueState {
  final LeagueTier currentTier;
  final int userPoints;
  final int userRank;
  final List<LeagueMember> cohort;
  final int daysRemainingInSeason;

  const FreedomLeagueState({
    this.currentTier = LeagueTier.gold,
    this.userPoints = 1850,
    this.userRank = 4,
    this.cohort = const [],
    this.daysRemainingInSeason = 3,
  });

  FreedomLeagueState copyWith({
    LeagueTier? currentTier,
    int? userPoints,
    int? userRank,
    List<LeagueMember>? cohort,
    int? daysRemainingInSeason,
  }) {
    return FreedomLeagueState(
      currentTier: currentTier ?? this.currentTier,
      userPoints: userPoints ?? this.userPoints,
      userRank: userRank ?? this.userRank,
      cohort: cohort ?? this.cohort,
      daysRemainingInSeason: daysRemainingInSeason ?? this.daysRemainingInSeason,
    );
  }
}

final freedomLeagueProvider =
    StateNotifierProvider<FreedomLeagueNotifier, FreedomLeagueState>((ref) {
  return FreedomLeagueNotifier();
});

class FreedomLeagueNotifier extends StateNotifier<FreedomLeagueState> {
  static const String _keyPoints = 'duedo_league_points';
  static const String _keyTier = 'duedo_league_tier';

  FreedomLeagueNotifier() : super(const FreedomLeagueState()) {
    _loadLeagueState();
  }

  Future<void> _loadLeagueState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPoints = prefs.getInt(_keyPoints) ?? 1850;
    final savedTierIndex = prefs.getInt(_keyTier) ?? LeagueTier.gold.index;
    final tier = LeagueTier.values[savedTierIndex.clamp(0, LeagueTier.values.length - 1)];

    final cohort = _generateCohort(savedPoints);
    final userRank = cohort.indexWhere((m) => m.isUser) + 1;

    state = state.copyWith(
      userPoints: savedPoints,
      currentTier: tier,
      cohort: cohort,
      userRank: userRank > 0 ? userRank : 4,
    );
  }

  /// Awards discipline points (50: ring, 100: vault impulse, 150: snowflake, 200: payday)
  Future<void> awardPoints(int pointsToAdd) async {
    final newPoints = state.userPoints + pointsToAdd;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, newPoints);

    // Check tier promotion
    LeagueTier newTier = state.currentTier;
    for (final t in LeagueTier.values.reversed) {
      if (newPoints >= t.minPoints) {
        newTier = t;
        break;
      }
    }
    await prefs.setInt(_keyTier, newTier.index);

    final updatedCohort = _generateCohort(newPoints);
    final newRank = updatedCohort.indexWhere((m) => m.isUser) + 1;

    HapticService.dopamineCascade();

    state = state.copyWith(
      userPoints: newPoints,
      currentTier: newTier,
      cohort: updatedCohort,
      userRank: newRank > 0 ? newRank : 1,
    );
  }

  List<LeagueMember> _generateCohort(int userScore) {
    final simulatedPeers = [
      const LeagueMember(id: 'p1', displayName: 'ApexSlayer_99', avatarEmoji: '🐺', points: 2450, streakDays: 24),
      const LeagueMember(id: 'p2', displayName: 'ZenDebtFree', avatarEmoji: '🧘‍♂️', points: 2180, streakDays: 18),
      const LeagueMember(id: 'p3', displayName: 'FrugalTitan', avatarEmoji: '🛡️', points: 1950, streakDays: 14),
      LeagueMember(id: 'user', displayName: 'You (Duedo Pioneer)', avatarEmoji: '⚡', points: userScore, streakDays: 12, isUser: true),
      const LeagueMember(id: 'p4', displayName: 'CompoundQueen', avatarEmoji: '👑', points: 1720, streakDays: 11),
      const LeagueMember(id: 'p5', displayName: 'VampireBuster_7', avatarEmoji: '🗡️', points: 1610, streakDays: 9),
      const LeagueMember(id: 'p6', displayName: 'SnowflakeSam', avatarEmoji: '❄️', points: 1480, streakDays: 8),
      const LeagueMember(id: 'p7', displayName: 'ZeroCreditCard', avatarEmoji: '💳', points: 1350, streakDays: 7),
      const LeagueMember(id: 'p8', displayName: 'FreedomSeeker_88', avatarEmoji: '🚀', points: 1240, streakDays: 6),
      const LeagueMember(id: 'p9', displayName: 'PrudentSparrow', avatarEmoji: '🦅', points: 1150, streakDays: 5),
      const LeagueMember(id: 'p10', displayName: 'DisciplineDan', avatarEmoji: '🎯', points: 1020, streakDays: 5),
      const LeagueMember(id: 'p11', displayName: 'AntiImpulse_X', avatarEmoji: '🧊', points: 940, streakDays: 4),
      const LeagueMember(id: 'p12', displayName: 'BudgetNomad', avatarEmoji: '🏕️', points: 830, streakDays: 4),
      const LeagueMember(id: 'p13', displayName: 'CleanDayHero', avatarEmoji: '✨', points: 720, streakDays: 3),
      const LeagueMember(id: 'p14', displayName: 'PennyArchitect', avatarEmoji: '🏛️', points: 610, streakDays: 2),
      const LeagueMember(id: 'p15', displayName: 'DebtFreePath', avatarEmoji: '🛤️', points: 490, streakDays: 1),
    ];

    simulatedPeers.sort((a, b) => b.points.compareTo(a.points));
    return simulatedPeers;
  }
}
