import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import '../models/app_enums.dart';

final windfallAllocatorServiceProvider = Provider((ref) => WindfallAllocatorService());

class WindfallAllocationPlan {
  final double totalWindfall;
  final double strikeAmount;
  final double armorAmount;
  final double joyAmount;
  final Obligation? targetDebt;
  final int monthsSaved;
  final double interestSaved;
  final int runwayDaysAdded;

  const WindfallAllocationPlan({
    required this.totalWindfall,
    required this.strikeAmount,
    required this.armorAmount,
    required this.joyAmount,
    this.targetDebt,
    required this.monthsSaved,
    required this.interestSaved,
    required this.runwayDaysAdded,
  });
}

class WindfallAllocatorService {
  /// Calculates the Golden 50/30/20 Windfall Allocation Split
  WindfallAllocationPlan calculatePlan({
    required double windfallAmount,
    required List<Obligation> obligations,
    double strikeRatio = 0.50,
    double armorRatio = 0.30,
    double joyRatio = 0.20,
  }) {
    if (windfallAmount <= 0) {
      return const WindfallAllocationPlan(
        totalWindfall: 0,
        strikeAmount: 0,
        armorAmount: 0,
        joyAmount: 0,
        monthsSaved: 0,
        interestSaved: 0,
        runwayDaysAdded: 0,
      );
    }

    final strike = (windfallAmount * strikeRatio).roundToDouble();
    final armor = (windfallAmount * armorRatio).roundToDouble();
    final joy = (windfallAmount * joyRatio).roundToDouble();

    // Find highest APR active debt
    final activeDebts = obligations
        .where((o) => o.isActive && (o.totalBalance > 0 || o.type == ObligationType.emi))
        .toList();

    activeDebts.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    final target = activeDebts.isNotEmpty ? activeDebts.first : null;

    int monthsSaved = 0;
    double interestSaved = 0.0;

    if (target != null) {
      final monthlyPayment = target.amount > 0 ? target.amount : 2000.0;
      monthsSaved = (strike / monthlyPayment).ceil().clamp(1, 48);
      final rate = target.interestRate > 0 ? target.interestRate : 18.0;
      interestSaved = (strike * (rate / 100.0) * 1.5).roundToDouble();
    }

    // Runway days added based on a standard ₹1,200/day living allowance
    final runwayDaysAdded = (armor / 1200.0).round().clamp(1, 365);

    return WindfallAllocationPlan(
      totalWindfall: windfallAmount,
      strikeAmount: strike,
      armorAmount: armor,
      joyAmount: joy,
      targetDebt: target,
      monthsSaved: monthsSaved,
      interestSaved: interestSaved,
      runwayDaysAdded: runwayDaysAdded,
    );
  }
}
