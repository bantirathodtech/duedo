import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuantumTimeline {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int debtFreeAge;
  final int monthsToDebtFree;
  final double totalInterestPaid;
  final double projectedNetWorth10Yr;
  final int colorHex;

  const QuantumTimeline({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.debtFreeAge,
    required this.monthsToDebtFree,
    required this.totalInterestPaid,
    required this.projectedNetWorth10Yr,
    required this.colorHex,
  });
}

class QuantumLifeState {
  final int currentAge;
  final double monthlyIncome;
  final double totalDebt;
  final double currentMonthlyEmi;
  final List<QuantumTimeline> timelines;

  const QuantumLifeState({
    this.currentAge = 29,
    this.monthlyIncome = 85000.0,
    this.totalDebt = 480000.0,
    this.currentMonthlyEmi = 24000.0,
    this.timelines = const [],
  });

  QuantumLifeState copyWith({
    int? currentAge,
    double? monthlyIncome,
    double? totalDebt,
    double? currentMonthlyEmi,
    List<QuantumTimeline>? timelines,
  }) {
    return QuantumLifeState(
      currentAge: currentAge ?? this.currentAge,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      totalDebt: totalDebt ?? this.totalDebt,
      currentMonthlyEmi: currentMonthlyEmi ?? this.currentMonthlyEmi,
      timelines: timelines ?? this.timelines,
    );
  }
}

final quantumLifeSimulatorProvider =
    StateNotifierProvider<QuantumLifeSimulatorNotifier, QuantumLifeState>((ref) {
  return QuantumLifeSimulatorNotifier();
});

class QuantumLifeSimulatorNotifier extends StateNotifier<QuantumLifeState> {
  QuantumLifeSimulatorNotifier() : super(const QuantumLifeState()) {
    simulateTimelines(
      monthlyIncome: 85000.0,
      totalDebt: 480000.0,
      currentMonthlyEmi: 24000.0,
      currentAge: 29,
    );
  }

  void simulateTimelines({
    required double monthlyIncome,
    required double totalDebt,
    required double currentMonthlyEmi,
    required int currentAge,
  }) {
    final safeEmi = currentMonthlyEmi > 0 ? currentMonthlyEmi : 20000.0;
    final safeDebt = max(0.0, totalDebt);

    // Timeline Alpha: Current Course Baseline
    final monthsAlpha = safeDebt > 0 ? (safeDebt / safeEmi).ceil() : 0;
    final interestAlpha = safeDebt * 0.14 * (monthsAlpha / 12);
    final debtFreeAgeAlpha = currentAge + (monthsAlpha / 12).ceil();
    // After debt clearance, monthly EMI goes into 12% compounding investment for remainder of 10 years
    final postDebtMonthsAlpha = max(0, 120 - monthsAlpha);
    final netWorthAlpha = _calculateCompoundFv(safeEmi, 0.12, postDebtMonthsAlpha);

    // Timeline Beta: The Home Loan Leap (Adds ₹40L at 8.6% for 20 yrs)
    const homeLoanPrincipal = 4000000.0;
    const homeLoanEmi = 34960.0; // standard 20yr EMI at 8.6%
    const monthsBeta = 240; // 20 years
    final interestBeta = (homeLoanEmi * 240) - homeLoanPrincipal + interestAlpha;
    final debtFreeAgeBeta = currentAge + 20;
    const netWorthBeta = homeLoanPrincipal * 1.6; // Real estate equity appreciation

    // Timeline Gamma: Aggressive Slaying Blitz (+40% Extra Strike monthly)
    final aggressiveEmi = safeEmi * 1.40;
    final monthsGamma = safeDebt > 0 ? (safeDebt / aggressiveEmi).ceil() : 0;
    final interestGamma = safeDebt * 0.14 * (monthsGamma / 12);
    final debtFreeAgeGamma = currentAge + (monthsGamma / 12).ceil();
    final postDebtMonthsGamma = max(0, 120 - monthsGamma);
    final netWorthGamma = _calculateCompoundFv(aggressiveEmi, 0.12, postDebtMonthsGamma);

    final timelines = [
      QuantumTimeline(
        id: 'timeline-alpha',
        title: 'Timeline Alpha',
        subtitle: 'Status Quo Baseline',
        icon: '🌊',
        debtFreeAge: debtFreeAgeAlpha,
        monthsToDebtFree: monthsAlpha,
        totalInterestPaid: interestAlpha,
        projectedNetWorth10Yr: netWorthAlpha,
        colorHex: 0xFF38BDF8, // Cyan
      ),
      QuantumTimeline(
        id: 'timeline-beta',
        title: 'Timeline Beta',
        subtitle: 'Mortgage / Big Leap',
        icon: '🏡',
        debtFreeAge: debtFreeAgeBeta,
        monthsToDebtFree: monthsBeta,
        totalInterestPaid: interestBeta,
        projectedNetWorth10Yr: netWorthBeta,
        colorHex: 0xFFF59E0B, // Amber
      ),
      QuantumTimeline(
        id: 'timeline-gamma',
        title: 'Timeline Gamma',
        subtitle: 'Aggressive Blitzkrieg',
        icon: '⚡',
        debtFreeAge: debtFreeAgeGamma,
        monthsToDebtFree: monthsGamma,
        totalInterestPaid: interestGamma,
        projectedNetWorth10Yr: netWorthGamma,
        colorHex: 0xFF10B981, // Emerald
      ),
    ];

    state = state.copyWith(
      currentAge: currentAge,
      monthlyIncome: monthlyIncome,
      totalDebt: totalDebt,
      currentMonthlyEmi: currentMonthlyEmi,
      timelines: timelines,
    );
  }

  static double _calculateCompoundFv(double monthlyPmt, double annualRate, int months) {
    if (months <= 0 || monthlyPmt <= 0) return 0.0;
    final r = annualRate / 12;
    return monthlyPmt * ((pow(1 + r, months) - 1) / r) * (1 + r);
  }
}
