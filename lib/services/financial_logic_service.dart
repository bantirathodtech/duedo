import '../models/app_enums.dart';
import 'database.dart';

enum InsightSeverity { info, warning, critical }

class ActionableInsight {
  final String title;
  final String description;
  final InsightSeverity severity;
  final String? suggestedActionLabel;
  
  ActionableInsight({
    required this.title, 
    required this.description, 
    required this.severity, 
    this.suggestedActionLabel,
  });
}

class FinancialLogicService {
  /// Calculates the financial pressure level based on obligations and income.
  double calculatePressureLevel(List<Obligation> activeObligations, double monthlyIncome) {
    if (monthlyIncome <= 0) return 1.0;
    double totalMonthlyLoad = 0;
    final now = DateTime.now();
    bool hasImminentHighPriority = false;

    for (final obligation in activeObligations) {
      if (obligation.type == ObligationType.emi || obligation.type == ObligationType.recurring) {
        totalMonthlyLoad += obligation.amount;
      } else if (obligation.type == ObligationType.oneTime) {
        if (obligation.endDate != null && 
            obligation.endDate!.month == now.month && 
            obligation.endDate!.year == now.year) {
          totalMonthlyLoad += obligation.amount;
        }
      }

      // Proximity Weighting: If a high priority debt is due in < 48 hours, add a slight 'stress' factor
      if (obligation.priority == PriorityLevel.high && obligation.isActive) {
        final dueDate = obligation.nextDueDate ?? obligation.endDate ?? obligation.startDate;
        if (dueDate.difference(now).inHours < 48 && dueDate.isAfter(now)) {
          hasImminentHighPriority = true;
        }
      }
    }
    
    double basePressure = (totalMonthlyLoad / monthlyIncome);
    // Add 10% stress if a major deadline is tomorrow to signify psychological 'crunch'
    return hasImminentHighPriority ? (basePressure * 1.1).clamp(0.0, 1.2) : basePressure.clamp(0.0, 1.2);
  }

  String getUrgencyLabel(Obligation obligation) {
    if (!obligation.isActive) return 'safe';
    if (obligation.status == ObligationStatus.paid) return 'safe';
    final startDate = obligation.nextDueDate ?? obligation.endDate ?? obligation.startDate;
    final deadlineDate = startDate.add(Duration(days: obligation.gracePeriodDays));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);
    if (today.isAfter(deadline)) return 'overdue';
    
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    if (today.isAfter(start.subtract(const Duration(days: 1))) && 
        today.isBefore(deadline.add(const Duration(days: 1)))) {
      return 'urgent'; 
    }
    
    if (obligation.priority == PriorityLevel.high || obligation.endDate == null) {
      if (start.difference(today).inDays < 30) return 'urgent';
      return 'upcoming';
    }
    if (start.difference(today).inDays < 7) return 'urgent';
    return 'safe';
  }

  List<ActionableInsight> generateInsights(List<Obligation> obligations, double monthlyIncome, int payday) {
    final insights = <ActionableInsight>[];
    final today = DateTime.now();
    final normToday = DateTime(today.year, today.month, today.day);
    double sumBeforePayday = 0;
    
    for (final ob in obligations) {
      if (!ob.isActive) continue;
      final start = ob.nextDueDate ?? ob.startDate;
      final deadline = start.add(Duration(days: ob.gracePeriodDays));
      final normDeadline = DateTime(deadline.year, deadline.month, deadline.day);

      if (normToday.isAfter(normDeadline)) {
        insights.add(ActionableInsight(
          title: 'Immediate Action Required',
          description: '${ob.title} is overdue.',
          severity: InsightSeverity.critical,
        ));
      }

      if (normDeadline.year == normToday.year && normDeadline.month == normToday.month && normDeadline.day < payday) {
        sumBeforePayday += ob.amount;
      }
    }

    if (monthlyIncome > 0 && (sumBeforePayday / monthlyIncome) > 0.3) {
      insights.add(ActionableInsight(
        title: 'High Pressure Before Payday',
        description: 'Prepare liquidity for bills due before payday.',
        severity: InsightSeverity.warning,
      ));
    }
    return insights;
  }

  FreedomData calculateFreedomData(List<Obligation> obligations, double monthlyIncome) {
    final activeDebts = obligations.where((ob) => ob.isActive && ob.type != ObligationType.recurring).toList();
    if (activeDebts.isEmpty) return FreedomData(daysLeft: 0, totalRemainingBalance: 0, targetDate: DateTime.now());
    
    final totalBalance = activeDebts.fold(0.0, (sum, ob) => sum + ob.totalBalance);
    final recurringTotal = obligations
        .where((ob) => ob.isActive && ob.type == ObligationType.recurring)
        .fold(0.0, (sum, ob) => sum + ob.amount);

    double baseDisposable = monthlyIncome - recurringTotal;
    if (baseDisposable <= 0) {
      // If income can't even cover recurring expenses, freedom is theoretically infinite/far
      return FreedomData(daysLeft: 3650, totalRemainingBalance: totalBalance, targetDate: DateTime.now().add(const Duration(days: 3650)));
    }

    // --- Snowball Simulation (Month-by-Month) ---
    List<_DebtSim> simDebts = activeDebts.map((d) => _DebtSim(
      balance: d.totalBalance,
      minPayment: d.type == ObligationType.emi ? d.amount : 0, 
      priority: d.priority.index,
    )).toList();

    // Sort by priority (higher index = higher priority) then by balance (smallest first for snowball)
    simDebts.sort((a, b) {
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      return a.balance.compareTo(b.balance);
    });

    int monthCount = 0;
    const maxMonths = 600; // 50 years safety cap

    final monthlyBalances = <double>[];
    final monthlyWealth = <double>[];
    monthlyBalances.add(simDebts.fold(0.0, (sum, d) => sum + d.balance));
    monthlyWealth.add(0.0);

    double investmentPool = 0;
    const double annualReturn = 0.12; // 12% APR default for "Wealth Flip"
    double monthlyRate = annualReturn / 12;

    while (monthCount < maxMonths) {
      if (!simDebts.any((d) => d.balance > 0) && monthCount >= 60) {
        // Stop after debt free + 5 years of wealth projection for visualization
        break;
      }
      
      monthCount++;
      double currentCapacity = baseDisposable;
      
      // 1. First Pass: Pay all mandatory EMIs
      for (var debt in simDebts) {
        if (debt.balance <= 0) continue;
        double payment = debt.minPayment.clamp(0, debt.balance);
        debt.balance -= payment;
        currentCapacity -= payment;
      }

      // 2. Second Pass: Apply remaining capacity to the highest priority "Snowball" target
      if (currentCapacity > 0) {
        for (var debt in simDebts) {
          if (debt.balance <= 0) continue;
          double extraPayment = currentCapacity.clamp(0, debt.balance);
          debt.balance -= extraPayment;
          currentCapacity -= extraPayment;
          if (currentCapacity <= 0) break;
        }
      }

      // 3. Wealth Flip: If all debts are paid, invest the REMAINING capacity + current pool growth
      if (!simDebts.any((d) => d.balance > 0)) {
        investmentPool = (investmentPool * (1 + monthlyRate)) + currentCapacity;
      } else {
        // Even while paying debts, any leftover capacity (rare in snowball) grows
        investmentPool = (investmentPool * (1 + monthlyRate)) + currentCapacity;
      }

      monthlyBalances.add(simDebts.fold(0.0, (sum, d) => sum + d.balance));
      monthlyWealth.add(investmentPool);

      if (simDebts.every((d) => d.balance <= 0) && monthCount > 120) break; // Cap at 10 years for chart
    }

    final targetDate = DateTime.now().add(Duration(days: monthCount * 30));
    return FreedomData(
      daysLeft: monthCount * 30, // Note: This should ideally only count debt-free months
      totalRemainingBalance: totalBalance,
      targetDate: targetDate,
      monthlyBalances: monthlyBalances,
      monthlyWealth: monthlyWealth,
    );
  }

  List<IntelligenceAlert> generateAIIntelligence(List<Obligation> obligations, double monthlyIncome) {
    final alerts = <IntelligenceAlert>[];
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    double nextWeekTotal = 0;
    for (final ob in obligations) {
      if (!ob.isActive) continue;
      final due = ob.nextDueDate ?? ob.endDate;
      if (due != null && due.isAfter(DateTime.now()) && due.isBefore(nextWeek)) nextWeekTotal += ob.amount;
    }

    if (monthlyIncome > 0 && (nextWeekTotal / (monthlyIncome / 4)) > 0.7) {
      alerts.add(IntelligenceAlert(
        title: 'Action Recommended',
        message: 'Heavy payment week ahead.',
        type: AlertType.warning,
      ));
    }

    final highInterest = obligations.where((ob) => ob.type == ObligationType.emi && ob.interestRate > 12).toList();
    if (highInterest.isNotEmpty) {
      alerts.add(IntelligenceAlert(
        title: 'Saving Opportunity',
        message: 'Refinance high-interest loans.',
        type: AlertType.refinance,
      ));
    }
    return alerts;
  }

  // --- Phase 5: Gamification Engine ---

  /// Calculates a 0-1000 score based on active DTI (Base 800) and Streak (Bonus 200).
  int calculateHealthScore(double dti, int monthlyStreak) {
    // 1. DTI Score Component (0 to 800)
    // DTI of 0.0 -> 800 points
    // DTI > 0.5 (50%) -> 200 points
    // Linear scale clamped
    double dtiScore = 800.0;
    if (dti > 0) {
      if (dti >= 0.5) {
        dtiScore = 200.0;
      } else {
        // Map DTI 0.0 -> 0.5 to Score 800 -> 200
        dtiScore = 800.0 - (dti * 1200.0); // 0.5 * 1200 = 600. 800 - 600 = 200.
      }
    }

    // 2. Streak Bonus Component (0 to 200)
    // Each consecutive month adds 20 points, capping at 10 months (200 points)
    int streakBonus = (monthlyStreak * 20).clamp(0, 200);

    int finalScore = (dtiScore + streakBonus).round();
    return finalScore.clamp(0, 1000);
  }

  /// Calculates which badges the user has unlocked based on their obligations.
  List<GamificationBadge> calculateBadges(List<Obligation> debts) {
    final badges = [
      GamificationBadge(id: 'first_blood', title: 'First Blood', description: 'Pay off 25% of any loan', requiredPercentage: 0.25),
      GamificationBadge(id: 'halfway_there', title: 'Halfway There', description: 'Pay off 50% of any loan', requiredPercentage: 0.50),
      GamificationBadge(id: 'finishing_strike', title: 'Finishing Strike', description: 'Pay off 75% of any loan', requiredPercentage: 0.75),
      GamificationBadge(id: 'debt_destroyer', title: 'Debt Destroyer', description: 'Completely destroy a debt', requiredPercentage: 1.0),
    ];

    for (var debt in debts) {
      double originalPrincipal = debt.amount; 
      double paidAmount = originalPrincipal - debt.totalBalance;
      if (paidAmount < 0) paidAmount = 0; 

      double percentagePaid = originalPrincipal > 0 ? (paidAmount / originalPrincipal) : 0;

      for (var badge in badges) {
        if (!badge.isUnlocked && percentagePaid >= badge.requiredPercentage) {
          badge.isUnlocked = true;
        }
      }
    }

    return badges;
  }

  /// Calculates Indian Tax Savings (80C, 80D) based on categorized obligations
  Map<String, double> calculateTaxSavings(List<Obligation> obligations) {
    double total80C = 0;
    double total80D = 0;

    for (final ob in obligations) {
      if (ob.taxCategory == '80C') {
        total80C += ob.amount * 12; // Annualize 
      } else if (ob.taxCategory == '80D') {
        total80D += ob.amount * 12; // Annualize
      }
    }

    // Caps in India
    const double cap80C = 150000;
    const double cap80D = 25000;

    return {
      '80C': total80C > cap80C ? cap80C : total80C,
      '80D': total80D > cap80D ? cap80D : total80D,
      'total': (total80C > cap80C ? cap80C : total80C) + (total80D > cap80D ? cap80D : total80D),
    };
  }

  /// Calculates a simulated global percentile rank (Top X%) based on Health Score.
  /// 900+ -> Top 1-5%
  /// 700+ -> Top 10-20%
  /// 500+ -> Top 40-50%
  String calculateFinancialRank(int healthScore) {
    if (healthScore >= 950) return 'Top 1%';
    if (healthScore >= 900) return 'Top 5%';
    if (healthScore >= 800) return 'Top 12%';
    if (healthScore >= 700) return 'Top 25%';
    if (healthScore >= 600) return 'Top 40%';
    if (healthScore >= 500) return 'Top 55%';
    return 'Top 85%';
  }
}

class _DebtSim {
  double balance;
  final double minPayment;
  final int priority;
  _DebtSim({required this.balance, required this.minPayment, required this.priority});
}

class GamificationBadge {
  final String id;
  final String title;
  final String description;
  final double requiredPercentage;
  bool isUnlocked;

  GamificationBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPercentage,
    this.isUnlocked = false,
  });
}

class FreedomData {
  final int daysLeft;
  final double totalRemainingBalance;
  final DateTime targetDate;
  final List<double> monthlyBalances; // To plot the Snowball Curve
  final List<double> monthlyWealth; // To plot the Wealth Flip

  FreedomData({
    required this.daysLeft, 
    required this.totalRemainingBalance, 
    required this.targetDate,
    this.monthlyBalances = const [],
    this.monthlyWealth = const [],
  });
  
  DateTime get debtFreeDate => targetDate;
}

enum AlertType { warning, success, info, refinance }

class IntelligenceAlert {
  final String title;
  final String message;
  final AlertType type;
  IntelligenceAlert({required this.title, required this.message, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntelligenceAlert &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => title.hashCode ^ message.hashCode ^ type.hashCode;
}
