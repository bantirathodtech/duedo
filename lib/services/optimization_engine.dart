import '../services/database.dart';

enum RepaymentStrategy { snowball, avalanche }

class OptimizationEngine {
  /// Sort debts based on the chosen strategy
  static List<Obligation> sort(List<Obligation> debts, RepaymentStrategy strategy) {
    if (debts.isEmpty) return [];

    final sorted = List<Obligation>.from(debts);

    switch (strategy) {
      case RepaymentStrategy.snowball:
        // Smallest balance first
        sorted.sort((a, b) => a.totalBalance.compareTo(b.totalBalance));
        break;
      case RepaymentStrategy.avalanche:
        // Highest interest rate first
        sorted.sort((a, b) => b.interestRate.compareTo(a.interestRate));
        break;
    }

    return sorted;
  }

  /// Extremely simplified delta calculation to show impact.
  /// (True amortization delta requires complex compounding, 
  /// here we provide a high-level estimation for UI motivation)
  static Map<String, dynamic> calculateDelta(
      List<Obligation> debts, 
      double monthlyPaymentCapacity) {
    
    // Quick heuristic: Avalanche usually saves ~5-15% of total interest 
    // compared to Snowball depending on rate spread, and maybe 1-2 months.
    // For Duedo Phase 1, we calculate a deterministic theoretical impact 
    // based on the spread of interest rates.

    double totalBalance = debts.fold(0, (sum, d) => sum + d.totalBalance);
    if (totalBalance == 0 || monthlyPaymentCapacity <= 0) {
      return {'interestSaved': 0.0, 'monthsSaved': 0};
    }

    double maxRate = debts.map((e) => e.interestRate).reduce((a, b) => a > b ? a : b);
    double minRate = debts.map((e) => e.interestRate).reduce((a, b) => a < b ? a : b);

    // If all rates are the same, avalanche and snowball behave identically
    if (maxRate == minRate) {
        return {'interestSaved': 0.0, 'monthsSaved': 0};
    }

    // Rough calculation of savings focusing on the highest rate debt vs average
    double spread = (maxRate - minRate) / 100.0;
    
    // Theoretical interest saved by attacking the highest rate first
    // This is an emulation of the avalanche impact for the UX.
    double theoreticalInterestSaved = (totalBalance * spread) * 0.5; // Roughly 50% impact of the spread over typical life
    
    int monthsSaved = (theoreticalInterestSaved / monthlyPaymentCapacity).ceil();

    return {
      'interestSaved': theoreticalInterestSaved,
      'monthsSaved': monthsSaved,
    };
  }
}
