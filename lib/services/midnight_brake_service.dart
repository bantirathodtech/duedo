import 'package:flutter_riverpod/flutter_riverpod.dart';

class MidnightBrakeState {
  final bool isArmed;
  final double netHourlyWage;
  final double interceptedAmount;
  final double lifeHoursCost;
  final int freedomDaysDelayed;
  final bool isSomaticResetCompleted;

  const MidnightBrakeState({
    this.isArmed = true,
    this.netHourlyWage = 500.0,
    this.interceptedAmount = 0.0,
    this.lifeHoursCost = 0.0,
    this.freedomDaysDelayed = 0,
    this.isSomaticResetCompleted = false,
  });

  MidnightBrakeState copyWith({
    bool? isArmed,
    double? netHourlyWage,
    double? interceptedAmount,
    double? lifeHoursCost,
    int? freedomDaysDelayed,
    bool? isSomaticResetCompleted,
  }) {
    return MidnightBrakeState(
      isArmed: isArmed ?? this.isArmed,
      netHourlyWage: netHourlyWage ?? this.netHourlyWage,
      interceptedAmount: interceptedAmount ?? this.interceptedAmount,
      lifeHoursCost: lifeHoursCost ?? this.lifeHoursCost,
      freedomDaysDelayed: freedomDaysDelayed ?? this.freedomDaysDelayed,
      isSomaticResetCompleted: isSomaticResetCompleted ?? this.isSomaticResetCompleted,
    );
  }
}

final midnightBrakeProvider =
    StateNotifierProvider<MidnightBrakeNotifier, MidnightBrakeState>((ref) {
  return MidnightBrakeNotifier();
});

class MidnightBrakeNotifier extends StateNotifier<MidnightBrakeState> {
  MidnightBrakeNotifier() : super(const MidnightBrakeState());

  /// Returns true if current local time is within the nocturnal risk window (10 PM to 5 AM)
  bool isNightRiskWindowActive() {
    final hour = DateTime.now().hour;
    return hour >= 22 || hour < 5;
  }

  void interceptImpulse({
    required double amount,
    required double monthlyIncome,
    double dailyDebtBurn = 400.0,
  }) {
    // Standard 160 hours monthly working time
    final hourlyWage = monthlyIncome > 0 ? (monthlyIncome / 160) : 500.0;
    final hoursCost = amount / (hourlyWage > 0 ? hourlyWage : 500.0);
    final daysDelay = (amount / (dailyDebtBurn > 0 ? dailyDebtBurn : 400.0)).round().clamp(1, 90);

    state = state.copyWith(
      netHourlyWage: hourlyWage,
      interceptedAmount: amount,
      lifeHoursCost: hoursCost,
      freedomDaysDelayed: daysDelay,
      isSomaticResetCompleted: false,
    );
  }

  void markSomaticResetComplete() {
    state = state.copyWith(isSomaticResetCompleted: true);
  }

  void toggleArmed() {
    state = state.copyWith(isArmed: !state.isArmed);
  }
}
