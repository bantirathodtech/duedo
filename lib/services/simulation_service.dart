import '../models/app_enums.dart';
import 'database.dart';
import 'financial_logic_service.dart';

class SimulationService {
  /// Simulates a future scenario based on modifiers.
  /// 
  /// [baseIncome] is the current real income.
  /// [incomeModifier] is a multiplier (e.g., 1.2 for a 20% raise, 0.9 for a 10% cut).
  /// [debts] is the current real list of obligations.
  /// [simulatedExtraDebt] is an optional hypothetical new debt to add to the simulation.
  static FreedomData runSimulation({
    required double baseIncome,
    required double incomeModifier,
    required List<Obligation> debts,
    Obligation? simulatedExtraDebt,
  }) {
    if (debts.isEmpty && simulatedExtraDebt == null) {
      return FreedomData(targetDate: DateTime.now(), daysLeft: 0, totalRemainingBalance: 0);
    }

    final simulatedIncome = baseIncome * incomeModifier;
    
    final simulationDebts = List<Obligation>.from(debts);
    if (simulatedExtraDebt != null) {
      simulationDebts.add(simulatedExtraDebt);
    }

    double totalRecurring = 0;
    double totalDebt = 0;
    double totalEmi = 0;

    for (var debt in simulationDebts) {
      if (debt.type == ObligationType.recurring) {
        totalRecurring += debt.amount;
      } else {
        totalDebt += debt.totalBalance;
        if (debt.type == ObligationType.emi) {
          totalEmi += debt.amount;
        }
      }
    }

    // Capacity is Net income after recurring expenses
    final monthlyCapacity = simulatedIncome - totalRecurring; 

    // In a real scenario, EMI is a fixed minimum. Extra capacity goes to principal.
    // If our capacity is less than required minimum EMI, freedom is impossible.
    if (monthlyCapacity < totalEmi && monthlyCapacity > 0) {
        // Just return a very large number for edge case
        return FreedomData(
          targetDate: DateTime.now().add(const Duration(days: 365 * 100)),
          daysLeft: 1200 * 30,
          totalRemainingBalance: totalDebt,
        );
    }

    double effectiveMonthlyPayment = monthlyCapacity > 0 ? monthlyCapacity : totalEmi;
    if (effectiveMonthlyPayment <= 0) {
      return FreedomData(targetDate: DateTime.now(), daysLeft: 0, totalRemainingBalance: totalDebt);
    }

    int monthsNeeded = (totalDebt / effectiveMonthlyPayment).ceil();
    final simulatedDate = DateTime.now().add(Duration(days: monthsNeeded * 30));

    return FreedomData(
      targetDate: simulatedDate,
      daysLeft: monthsNeeded * 30,
      totalRemainingBalance: totalDebt,
    );
  }
}
