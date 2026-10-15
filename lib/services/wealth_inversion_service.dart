import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class WealthBucket {
  final String id;
  final String title;
  final String icon;
  final double percentageShare;
  final double allocatedMonthly;
  final double accumulatedTotal;
  final double expectedCagr;

  const WealthBucket({
    required this.id,
    required this.title,
    required this.icon,
    required this.percentageShare,
    required this.allocatedMonthly,
    required this.accumulatedTotal,
    required this.expectedCagr,
  });

  WealthBucket copyWith({
    double? allocatedMonthly,
    double? accumulatedTotal,
    double? percentageShare,
  }) {
    return WealthBucket(
      id: id,
      title: title,
      icon: icon,
      percentageShare: percentageShare ?? this.percentageShare,
      allocatedMonthly: allocatedMonthly ?? this.allocatedMonthly,
      accumulatedTotal: accumulatedTotal ?? this.accumulatedTotal,
      expectedCagr: expectedCagr,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'percentageShare': percentageShare,
    'allocatedMonthly': allocatedMonthly,
    'accumulatedTotal': accumulatedTotal,
    'expectedCagr': expectedCagr,
  };

  factory WealthBucket.fromJson(Map<String, dynamic> json) {
    return WealthBucket(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '📈',
      percentageShare: (json['percentageShare'] as num?)?.toDouble() ?? 33.3,
      allocatedMonthly: (json['allocatedMonthly'] as num?)?.toDouble() ?? 0.0,
      accumulatedTotal: (json['accumulatedTotal'] as num?)?.toDouble() ?? 0.0,
      expectedCagr: (json['expectedCagr'] as num?)?.toDouble() ?? 12.0,
    );
  }
}

class WealthInversionState {
  final bool isInversionActive;
  final DateTime? unlockedDate;
  final double previousMonthlyEmiRedirected;
  final double totalWealthAccumulated;
  final List<WealthBucket> buckets;
  final double projectedWealth5Yr;
  final double projectedWealth10Yr;
  final double projectedWealth15Yr;

  const WealthInversionState({
    this.isInversionActive = false,
    this.unlockedDate,
    this.previousMonthlyEmiRedirected = 25000.0,
    this.totalWealthAccumulated = 0.0,
    this.buckets = const [],
    this.projectedWealth5Yr = 0.0,
    this.projectedWealth10Yr = 0.0,
    this.projectedWealth15Yr = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'isInversionActive': isInversionActive,
    'unlockedDate': unlockedDate?.toIso8601String(),
    'previousMonthlyEmiRedirected': previousMonthlyEmiRedirected,
    'totalWealthAccumulated': totalWealthAccumulated,
    'buckets': buckets.map((e) => e.toJson()).toList(),
    'projectedWealth5Yr': projectedWealth5Yr,
    'projectedWealth10Yr': projectedWealth10Yr,
    'projectedWealth15Yr': projectedWealth15Yr,
  };

  factory WealthInversionState.fromJson(Map<String, dynamic> json) {
    return WealthInversionState(
      isInversionActive: json['isInversionActive'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] != null ? DateTime.parse(json['unlockedDate'] as String) : null,
      previousMonthlyEmiRedirected: (json['previousMonthlyEmiRedirected'] as num?)?.toDouble() ?? 25000.0,
      totalWealthAccumulated: (json['totalWealthAccumulated'] as num?)?.toDouble() ?? 0.0,
      buckets: (json['buckets'] as List<dynamic>?)
              ?.map((e) => WealthBucket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projectedWealth5Yr: (json['projectedWealth5Yr'] as num?)?.toDouble() ?? 0.0,
      projectedWealth10Yr: (json['projectedWealth10Yr'] as num?)?.toDouble() ?? 0.0,
      projectedWealth15Yr: (json['projectedWealth15Yr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  WealthInversionState copyWith({
    bool? isInversionActive,
    DateTime? unlockedDate,
    double? previousMonthlyEmiRedirected,
    double? totalWealthAccumulated,
    List<WealthBucket>? buckets,
    double? projectedWealth5Yr,
    double? projectedWealth10Yr,
    double? projectedWealth15Yr,
  }) {
    return WealthInversionState(
      isInversionActive: isInversionActive ?? this.isInversionActive,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      previousMonthlyEmiRedirected: previousMonthlyEmiRedirected ?? this.previousMonthlyEmiRedirected,
      totalWealthAccumulated: totalWealthAccumulated ?? this.totalWealthAccumulated,
      buckets: buckets ?? this.buckets,
      projectedWealth5Yr: projectedWealth5Yr ?? this.projectedWealth5Yr,
      projectedWealth10Yr: projectedWealth10Yr ?? this.projectedWealth10Yr,
      projectedWealth15Yr: projectedWealth15Yr ?? this.projectedWealth15Yr,
    );
  }
}

final wealthInversionProvider =
    StateNotifierProvider<WealthInversionNotifier, WealthInversionState>((ref) {
  return WealthInversionNotifier();
});

class WealthInversionNotifier extends StateNotifier<WealthInversionState> {
  static const String _prefKey = 'duedo_wealth_inversion_state_v1';

  WealthInversionNotifier() : super(const WealthInversionState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = WealthInversionState.fromJson(map);
        return;
      } catch (_) {}
    }
    // Initialize default projections
    _recalculate(25000.0, 0.0);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.toJson());
    await prefs.setString(_prefKey, jsonStr);
  }

  /// Calculates Future Value for monthly SIP compounding:
  /// FV = P * [((1 + r)^n - 1) / r] * (1 + r)
  static double calculateSipFutureValue(double monthlyInvestment, double annualRatePct, int years) {
    if (monthlyInvestment <= 0) return 0.0;
    final r = (annualRatePct / 100) / 12;
    final n = years * 12;
    final fv = monthlyInvestment * ((pow(1 + r, n) - 1) / r) * (1 + r);
    return fv;
  }

  void _recalculate(double monthlyEmi, double totalAccumulated, {List<WealthBucket>? existingBuckets}) {
    final buckets = existingBuckets ?? [
      WealthBucket(
        id: 'nifty-50',
        title: 'Nifty 50 Index SIP',
        icon: '📈',
        percentageShare: 50.0,
        allocatedMonthly: monthlyEmi * 0.50,
        accumulatedTotal: totalAccumulated * 0.50,
        expectedCagr: 12.5,
      ),
      WealthBucket(
        id: 'gold-sovereign',
        title: 'Digital Sovereign Gold',
        icon: '🪙',
        percentageShare: 20.0,
        allocatedMonthly: monthlyEmi * 0.20,
        accumulatedTotal: totalAccumulated * 0.20,
        expectedCagr: 10.0,
      ),
      WealthBucket(
        id: 'liquid-shield',
        title: 'High-Yield Liquid Grace',
        icon: '🛡️',
        percentageShare: 30.0,
        allocatedMonthly: monthlyEmi * 0.30,
        accumulatedTotal: totalAccumulated * 0.30,
        expectedCagr: 7.2,
      ),
    ];

    final fv5 = calculateSipFutureValue(monthlyEmi, 12.0, 5);
    final fv10 = calculateSipFutureValue(monthlyEmi, 12.0, 10);
    final fv15 = calculateSipFutureValue(monthlyEmi, 12.0, 15);

    state = state.copyWith(
      previousMonthlyEmiRedirected: monthlyEmi,
      totalWealthAccumulated: totalAccumulated,
      buckets: buckets,
      projectedWealth5Yr: fv5,
      projectedWealth10Yr: fv10,
      projectedWealth15Yr: fv15,
    );
  }

  Future<void> activateInversion({required double monthlyEmi}) async {
    HapticService.dopamineCascade();

    final safeEmi = monthlyEmi > 0 ? monthlyEmi : 25000.0;
    _recalculate(safeEmi, state.totalWealthAccumulated);
    state = state.copyWith(
      isInversionActive: true,
      unlockedDate: DateTime.now(),
    );

    await _save();
  }

  Future<void> logWealthStrike({required String bucketId, required double amount}) async {
    HapticService.dopamineCascade();

    final updatedBuckets = state.buckets.map((b) {
      if (b.id == bucketId) {
        return b.copyWith(accumulatedTotal: b.accumulatedTotal + amount);
      }
      return b;
    }).toList();

    final total = state.totalWealthAccumulated + amount;
    state = state.copyWith(
      totalWealthAccumulated: total,
      buckets: updatedBuckets,
    );

    await _save();
  }

  Future<void> toggleInversionMode() async {
    HapticService.selection();
    state = state.copyWith(isInversionActive: !state.isInversionActive);
    await _save();
  }
}
