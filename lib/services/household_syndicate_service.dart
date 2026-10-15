import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class SyndicateProfile {
  final String syndicateCode;
  final String partnerName;
  final bool isConnected;
  final String jointTargetTitle;
  final double jointTargetAmount;
  final double userContributedTotal;
  final double partnerContributedTotal;
  final int collectiveFreedomDaysSaved;
  final int duoStreakWeeks;
  final bool userCleanThisWeek;
  final bool partnerCleanThisWeek;

  const SyndicateProfile({
    required this.syndicateCode,
    this.partnerName = 'Partner',
    this.isConnected = false,
    this.jointTargetTitle = 'Primary Snowball Target',
    this.jointTargetAmount = 250000.0,
    this.userContributedTotal = 0.0,
    this.partnerContributedTotal = 0.0,
    this.collectiveFreedomDaysSaved = 0,
    this.duoStreakWeeks = 1,
    this.userCleanThisWeek = true,
    this.partnerCleanThisWeek = true,
  });

  double get totalCombinedStrikes => userContributedTotal + partnerContributedTotal;

  double get progressRatio => jointTargetAmount > 0
      ? (totalCombinedStrikes / jointTargetAmount).clamp(0.0, 1.0)
      : 0.0;

  double get userContributionPercent => totalCombinedStrikes > 0
      ? (userContributedTotal / totalCombinedStrikes) * 100
      : 50.0;

  double get partnerContributionPercent => totalCombinedStrikes > 0
      ? (partnerContributedTotal / totalCombinedStrikes) * 100
      : 50.0;

  bool get bothCleanThisWeek => userCleanThisWeek && partnerCleanThisWeek;

  double get leagueMultiplier => bothCleanThisWeek ? 2.0 : 1.0;

  Map<String, dynamic> toJson() => {
    'syndicateCode': syndicateCode,
    'partnerName': partnerName,
    'isConnected': isConnected,
    'jointTargetTitle': jointTargetTitle,
    'jointTargetAmount': jointTargetAmount,
    'userContributedTotal': userContributedTotal,
    'partnerContributedTotal': partnerContributedTotal,
    'collectiveFreedomDaysSaved': collectiveFreedomDaysSaved,
    'duoStreakWeeks': duoStreakWeeks,
    'userCleanThisWeek': userCleanThisWeek,
    'partnerCleanThisWeek': partnerCleanThisWeek,
  };

  factory SyndicateProfile.fromJson(Map<String, dynamic> json) {
    return SyndicateProfile(
      syndicateCode: json['syndicateCode'] as String? ?? 'DUEDO-SYN-7788',
      partnerName: json['partnerName'] as String? ?? 'Partner',
      isConnected: json['isConnected'] as bool? ?? false,
      jointTargetTitle: json['jointTargetTitle'] as String? ?? 'Primary Snowball Target',
      jointTargetAmount: (json['jointTargetAmount'] as num?)?.toDouble() ?? 250000.0,
      userContributedTotal: (json['userContributedTotal'] as num?)?.toDouble() ?? 0.0,
      partnerContributedTotal: (json['partnerContributedTotal'] as num?)?.toDouble() ?? 0.0,
      collectiveFreedomDaysSaved: json['collectiveFreedomDaysSaved'] as int? ?? 0,
      duoStreakWeeks: json['duoStreakWeeks'] as int? ?? 1,
      userCleanThisWeek: json['userCleanThisWeek'] as bool? ?? true,
      partnerCleanThisWeek: json['partnerCleanThisWeek'] as bool? ?? true,
    );
  }

  SyndicateProfile copyWith({
    String? syndicateCode,
    String? partnerName,
    bool? isConnected,
    String? jointTargetTitle,
    double? jointTargetAmount,
    double? userContributedTotal,
    double? partnerContributedTotal,
    int? collectiveFreedomDaysSaved,
    int? duoStreakWeeks,
    bool? userCleanThisWeek,
    bool? partnerCleanThisWeek,
  }) {
    return SyndicateProfile(
      syndicateCode: syndicateCode ?? this.syndicateCode,
      partnerName: partnerName ?? this.partnerName,
      isConnected: isConnected ?? this.isConnected,
      jointTargetTitle: jointTargetTitle ?? this.jointTargetTitle,
      jointTargetAmount: jointTargetAmount ?? this.jointTargetAmount,
      userContributedTotal: userContributedTotal ?? this.userContributedTotal,
      partnerContributedTotal: partnerContributedTotal ?? this.partnerContributedTotal,
      collectiveFreedomDaysSaved: collectiveFreedomDaysSaved ?? this.collectiveFreedomDaysSaved,
      duoStreakWeeks: duoStreakWeeks ?? this.duoStreakWeeks,
      userCleanThisWeek: userCleanThisWeek ?? this.userCleanThisWeek,
      partnerCleanThisWeek: partnerCleanThisWeek ?? this.partnerCleanThisWeek,
    );
  }
}

final householdSyndicateProvider =
    StateNotifierProvider<HouseholdSyndicateNotifier, SyndicateProfile>((ref) {
  return HouseholdSyndicateNotifier();
});

class HouseholdSyndicateNotifier extends StateNotifier<SyndicateProfile> {
  static const String _prefKey = 'duedo_household_syndicate_profile_v1';

  HouseholdSyndicateNotifier() : super(const SyndicateProfile(syndicateCode: 'DUEDO-SYN-8841')) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = SyndicateProfile.fromJson(map);
        return;
      } catch (_) {}
    }
    // Generate fresh random code
    final randomDigits = 1000 + Random().nextInt(9000);
    state = state.copyWith(syndicateCode: 'DUEDO-SYN-$randomDigits');
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.toJson());
    await prefs.setString(_prefKey, jsonStr);
  }

  Future<bool> pairWithPartner({
    required String partnerCode,
    required String partnerName,
    String jointTarget = 'Shared Primary Loan',
    double targetAmount = 200000.0,
  }) async {
    final cleanCode = partnerCode.trim().toUpperCase();
    if (cleanCode.isEmpty || cleanCode == state.syndicateCode) {
      return false;
    }

    HapticService.dopamineCascade();

    state = state.copyWith(
      isConnected: true,
      partnerName: partnerName.trim().isEmpty ? 'Partner' : partnerName.trim(),
      jointTargetTitle: jointTarget,
      jointTargetAmount: targetAmount > 0 ? targetAmount : 200000.0,
      userContributedTotal: 12500.0,
      partnerContributedTotal: 10000.0,
      collectiveFreedomDaysSaved: 16,
      duoStreakWeeks: 2,
    );

    await _save();
    return true;
  }

  Future<void> recordJointStrike({
    required double amount,
    required bool isUserStrike,
    double dailyDebtBurn = 400.0,
  }) async {
    HapticService.dopamineCascade();

    final addedDays = (amount / (dailyDebtBurn > 0 ? dailyDebtBurn : 400.0)).round().clamp(1, 60);

    state = state.copyWith(
      userContributedTotal: isUserStrike ? state.userContributedTotal + amount : state.userContributedTotal,
      partnerContributedTotal: !isUserStrike ? state.partnerContributedTotal + amount : state.partnerContributedTotal,
      collectiveFreedomDaysSaved: state.collectiveFreedomDaysSaved + addedDays,
    );

    await _save();
  }

  Future<void> toggleWeeklyClean({required bool isUser}) async {
    HapticService.selection();

    final newUserClean = isUser ? !state.userCleanThisWeek : state.userCleanThisWeek;
    final newPartnerClean = !isUser ? !state.partnerCleanThisWeek : state.partnerCleanThisWeek;

    int streak = state.duoStreakWeeks;
    if (newUserClean && newPartnerClean) {
      streak += 1;
      HapticService.dopamineCascade();
    }

    state = state.copyWith(
      userCleanThisWeek: newUserClean,
      partnerCleanThisWeek: newPartnerClean,
      duoStreakWeeks: streak,
    );

    await _save();
  }

  Future<void> unlinkSyndicate() async {
    HapticService.selection();
    final randomDigits = 1000 + Random().nextInt(9000);
    state = SyndicateProfile(syndicateCode: 'DUEDO-SYN-$randomDigits');
    await _save();
  }
}
