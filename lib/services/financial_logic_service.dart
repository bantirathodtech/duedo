import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/app_enums.dart';
import 'database.dart';

final financialLogicServiceProvider = Provider((ref) => FinancialLogicService());

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

  FreedomData calculateFreedomData(List<Obligation> obligations, double monthlyIncome, {double extraMonthlyPayment = 0.0}) {
    // We move the actual logic to a static method so 'compute' can use it
    return _calculateFreedomDataInternal(obligations, monthlyIncome, extraMonthlyPayment: extraMonthlyPayment);
  }

  /// Internal logic for background or synchronous execution
  static FreedomData _calculateFreedomDataInternal(List<Obligation> obligations, double monthlyIncome, {double extraMonthlyPayment = 0.0}) {
    final activeDebts = obligations.where((ob) => ob.isActive && ob.type != ObligationType.recurring).toList();
    if (activeDebts.isEmpty) return FreedomData(daysLeft: 0, totalRemainingBalance: 0, targetDate: DateTime.now());
    
    final totalBalance = activeDebts.fold(0.0, (sum, ob) => sum + ob.totalBalance);
    final recurringTotal = obligations
        .where((ob) => ob.isActive && ob.type == ObligationType.recurring)
        .fold(0.0, (sum, ob) => sum + ob.amount);

    double baseDisposable = monthlyIncome - recurringTotal + extraMonthlyPayment;
    if (baseDisposable <= 0) {
      return FreedomData(daysLeft: 3650, totalRemainingBalance: totalBalance, targetDate: DateTime.now().add(const Duration(days: 3650)));
    }

    List<_DebtSim> simDebts = activeDebts.map((d) => _DebtSim(
      balance: d.totalBalance,
      minPayment: d.type == ObligationType.emi ? d.amount : 0, 
      priority: d.priority.index,
    )).toList();

    simDebts.sort((a, b) {
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      return a.balance.compareTo(b.balance);
    });

    int monthCount = 0;
    const maxMonths = 600; 
    final monthlyBalances = <double>[];
    final monthlyWealth = <double>[];
    monthlyBalances.add(simDebts.fold(0.0, (sum, d) => sum + d.balance));
    monthlyWealth.add(0.0);

    double investmentPool = 0;
    const double annualReturn = 0.12; 
    double monthlyRate = annualReturn / 12;

    while (monthCount < maxMonths) {
      if (!simDebts.any((d) => d.balance > 0) && monthCount >= 60) break;
      
      monthCount++;
      double currentCapacity = baseDisposable;
      
      for (var debt in simDebts) {
        if (debt.balance <= 0) continue;
        double payment = debt.minPayment.clamp(0, debt.balance);
        debt.balance -= payment;
        currentCapacity -= payment;
      }

      if (currentCapacity > 0) {
        for (var debt in simDebts) {
          if (debt.balance <= 0) continue;
          double extraPayment = currentCapacity.clamp(0, debt.balance);
          debt.balance -= extraPayment;
          currentCapacity -= extraPayment;
          if (currentCapacity <= 0) break;
        }
      }

      investmentPool = (investmentPool * (1 + monthlyRate)) + currentCapacity;
      monthlyBalances.add(simDebts.fold(0.0, (sum, d) => sum + d.balance));
      monthlyWealth.add(investmentPool);

      if (simDebts.every((d) => d.balance <= 0) && monthCount > 120) break; 
    }

    return FreedomData(
      daysLeft: monthCount * 30,
      totalRemainingBalance: totalBalance,
      targetDate: DateTime.now().add(Duration(days: monthCount * 30)),
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

  /// Calculates the immediate compound interest and time savings of an extra micro-payment
  SnowflakeImpact calculateSnowflakeImpact(Obligation debt, double snowflakeAmount) {
    final rate = debt.interestRate > 0 ? debt.interestRate : 11.5;
    final months = (debt.emiDurationMonths != null && debt.emiDurationMonths! > 0)
        ? debt.emiDurationMonths!
        : 24;
    
    final interestSaved = snowflakeAmount * (rate / 100.0) * (months / 12.0) * 0.7;
    final daysSaved = ((snowflakeAmount / (debt.amount > 0 ? debt.amount : 5000.0)) * 24).round().clamp(1, 365);

    String hook;
    if (snowflakeAmount >= 2000) {
      hook = 'MASSIVE STRIKE! You just destroyed debt interest.';
    } else if (snowflakeAmount >= 1000) {
      hook = 'CRITICAL HIT! Freedom countdown pushed forward.';
    } else {
      hook = 'SNOWFLAKE ACTIVE! Micro-discipline yields macro-freedom.';
    }

    return SnowflakeImpact(
      amount: snowflakeAmount,
      interestSaved: interestSaved > 0 ? interestSaved : snowflakeAmount * 0.15,
      daysSaved: daysSaved,
      motivationalHook: hook,
    );
  }

  /// Calculates survival runway if income immediately drops to 0
  CrisisStressTestResult calculateCrisisStressTest(
    List<Obligation> obligations, 
    double monthlyIncome, 
    double emergencyFund,
  ) {
    double totalBurn = 0;
    double discretionarySavings = 0;
    final plan = <CrisisTriageItem>[];

    for (final ob in obligations) {
      if (!ob.isActive) continue;
      final isDiscretionary = ob.category.toLowerCase() == 'entertainment' || 
                              ob.category.toLowerCase() == 'subscription' || 
                              ob.category.toLowerCase() == 'shopping';
      
      final isHighPriority = ob.priority == PriorityLevel.high || ob.type == ObligationType.emi;

      if (isDiscretionary) {
        discretionarySavings += ob.amount;
        plan.add(CrisisTriageItem(
          title: ob.title,
          monthlyAmount: ob.amount,
          actionRecommendation: 'Freeze immediately. Zero credit score penalty.',
          priorityLevel: 1,
        ));
      } else if (ob.gracePeriodDays > 0) {
        totalBurn += ob.amount;
        plan.add(CrisisTriageItem(
          title: ob.title,
          monthlyAmount: ob.amount,
          actionRecommendation: 'Deploy ${ob.gracePeriodDays}-day grace shield to delay cash outflow.',
          priorityLevel: 2,
        ));
      } else {
        totalBurn += ob.amount;
        plan.add(CrisisTriageItem(
          title: ob.title,
          monthlyAmount: ob.amount,
          actionRecommendation: isHighPriority ? 'Sacred core. Must pay to protect credit score.' : 'Essential obligation.',
          priorityLevel: 3,
        ));
      }
    }

    final effectiveLiquidFund = emergencyFund > 0 ? emergencyFund : (monthlyIncome > 0 ? monthlyIncome * 0.75 : totalBurn * 0.5);
    final dailyBurn = totalBurn > 0 ? (totalBurn / 30.0) : 100.0;
    final runwayDays = (effectiveLiquidFund / dailyBurn).round();

    return CrisisStressTestResult(
      runwayDays: runwayDays,
      monthlySurvivalBurn: totalBurn,
      discretionarySavingsPotential: discretionarySavings,
      triagePlan: plan,
    );
  }

  /// Calculates the real-time interest bleed rate across all active debts
  InterestBleedMetrics calculateInterestBleed(List<Obligation> obligations) {
    double monthlyInterest = 0.0;
    int debtCount = 0;

    for (final ob in obligations) {
      if (!ob.isActive) continue;
      if (ob.type == ObligationType.emi || ob.totalBalance > 0) {
        debtCount++;
        final balance = ob.totalBalance > 0 ? ob.totalBalance : (ob.amount * 12.0);
        final rate = ob.interestRate > 0 ? ob.interestRate : 13.5;
        final annualInterest = balance * (rate / 100.0);
        monthlyInterest += (annualInterest / 12.0);
      }
    }

    final dailyBleed = monthlyInterest > 0 ? (monthlyInterest / 30.0) : 0.0;
    final hourlyBleed = monthlyInterest > 0 ? (monthlyInterest / 720.0) : 0.0;
    final perMinuteBleed = hourlyBleed > 0 ? (hourlyBleed / 60.0) : 0.0;

    return InterestBleedMetrics(
      monthlyInterest: monthlyInterest,
      dailyBleed: dailyBleed,
      hourlyBleed: hourlyBleed,
      perMinuteBleed: perMinuteBleed,
      activeDebtsCount: debtCount,
    );
  }

  /// Scans for high-interest debts (>18% APR) and simulates consolidation arbitrage
  List<ArbitrageOpportunity> detectArbitrageOpportunities(List<Obligation> obligations) {
    final opportunities = <ArbitrageOpportunity>[];
    const targetApr = 11.5; // Benchmark prime consolidation loan rate

    for (final ob in obligations) {
      if (!ob.isActive || ob.status == ObligationStatus.paid) continue;
      if (ob.interestRate >= 18.0) {
        final balance = ob.totalBalance > 0 ? ob.totalBalance : (ob.amount * 12.0);
        final currentAnnualInterest = balance * (ob.interestRate / 100.0);
        final targetAnnualInterest = balance * (targetApr / 100.0);
        final annualSaved = currentAnnualInterest - targetAnnualInterest;
        final monthlySavings = annualSaved / 12.0;
        final totalInterestSaved = annualSaved * 1.5;
        final monthsAccelerated = (totalInterestSaved / (ob.amount > 0 ? ob.amount : 1000)).round().clamp(1, 36);

        opportunities.add(ArbitrageOpportunity(
          obligation: ob,
          currentApr: ob.interestRate,
          targetApr: targetApr,
          monthlySavings: monthlySavings,
          totalInterestSaved: totalInterestSaved,
          monthsAccelerated: monthsAccelerated,
        ));
      }
    }
    return opportunities;
  }

  /// Calculates dynamic daily safe-to-spend allowance based on uncommitted monthly cash
  SafeToSpendMetrics calculateSafeToSpend({
    required List<Obligation> obligations,
    required double monthlyIncome,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day + 1).clamp(1, 31);

    double pendingObligations = 0.0;
    for (final ob in obligations) {
      if (!ob.isActive || ob.status == ObligationStatus.paid) continue;
      final due = ob.nextDueDate ?? ob.startDate;
      if (due.isBefore(DateTime(now.year, now.month + 1, 1))) {
        pendingObligations += ob.amount;
      }
    }

    final freePool = monthlyIncome > 0 ? (monthlyIncome - pendingObligations) : 0.0;
    final dailySafe = freePool > 0 ? (freePool / daysLeft) : 0.0;

    SafeToSpendStatus status;
    if (monthlyIncome <= 0 || freePool <= 0) {
      status = SafeToSpendStatus.critical;
    } else if (dailySafe > (monthlyIncome / 30.0) * 0.4) {
      status = SafeToSpendStatus.abundant;
    } else if (dailySafe > (monthlyIncome / 30.0) * 0.15) {
      status = SafeToSpendStatus.moderate;
    } else {
      status = SafeToSpendStatus.restricted;
    }

    return SafeToSpendMetrics(
      dailyAmount: dailySafe,
      monthlyRemainingPool: freePool,
      pendingObligationsThisMonth: pendingObligations,
      daysLeftInMonth: daysLeft,
      status: status,
    );
  }

  /// Scans recurring obligations for ghost leakage and subscription overlap
  List<GhostSubscriptionInsight> detectGhostSubscriptions(List<Obligation> obligations) {
    final insights = <GhostSubscriptionInsight>[];
    final recurring = obligations.where((o) => o.isActive && o.type == ObligationType.recurring).toList();

    const ottKeywords = ['netflix', 'prime', 'hotstar', 'disney', 'spotify', 'youtube', 'apple music', 'hulu', 'hbo', 'sony'];
    final matchedOtt = recurring.where((o) => ottKeywords.any((k) => o.title.toLowerCase().contains(k))).toList();

    if (matchedOtt.length >= 2) {
      final totalMonthly = matchedOtt.fold(0.0, (sum, o) => sum + o.amount);
      final fiveYearValue = totalMonthly * 82.486; // 5Y FV at 12% CAGR

      insights.add(GhostSubscriptionInsight(
        title: 'Streaming Overlap Detected',
        category: 'Entertainment',
        count: matchedOtt.length,
        monthlyLeak: totalMonthly,
        fiveYearOpportunityCost: fiveYearValue,
        description: 'You have ${matchedOtt.length} overlapping entertainment subscriptions (${matchedOtt.map((e) => e.title).join(', ')}).',
        suspectObligations: matchedOtt,
      ));
    }

    for (final ob in recurring) {
      if (ob.priority == PriorityLevel.low && ob.amount > 500) {
        final fiveYearValue = ob.amount * 82.486;
        insights.add(GhostSubscriptionInsight(
          title: 'Low-Priority Leak: ${ob.title}',
          category: ob.category,
          count: 1,
          monthlyLeak: ob.amount,
          fiveYearOpportunityCost: fiveYearValue,
          description: '${ob.title} is marked low priority. Reclaiming this frees ${ob.amount.toStringAsFixed(0)}/mo.',
          suspectObligations: [ob],
        ));
      }
    }

    return insights;
  }

  /// Formulates the 60-second Payday Blitz reallocation plan
  PaydayBlitzPlan calculatePaydayBlitz({
    required double monthlyIncome,
    required List<Obligation> obligations,
  }) {
    double totalLockedDues = 0.0;
    final activeDues = <Obligation>[];
    for (final ob in obligations) {
      if (!ob.isActive || ob.status == ObligationStatus.paid) continue;
      if (ob.type == ObligationType.emi || ob.type == ObligationType.recurring) {
        totalLockedDues += ob.amount;
        activeDues.add(ob);
      }
    }

    final discretionaryPool = (monthlyIncome - totalLockedDues).clamp(0.0, double.infinity);
    
    // Find highest APR debt with outstanding balance
    Obligation? targetDebt;
    final debtsWithApr = obligations
        .where((o) => o.isActive && o.status != ObligationStatus.paid && (o.totalBalance > 0 || o.type == ObligationType.emi))
        .toList();
    if (debtsWithApr.isNotEmpty) {
      debtsWithApr.sort((a, b) => b.interestRate.compareTo(a.interestRate));
      targetDebt = debtsWithApr.first;
    }

    final recommendedSnowflake = discretionaryPool > 0 
        ? ((discretionaryPool * 0.15).clamp(500.0, discretionaryPool).toDouble())
        : 0.0;

    final newDailySafeToSpend = discretionaryPool > recommendedSnowflake 
        ? (discretionaryPool - recommendedSnowflake) / 30.0 
        : (discretionaryPool / 30.0);

    int daysAccelerated = 0;
    if (targetDebt != null && recommendedSnowflake > 0) {
      daysAccelerated = ((recommendedSnowflake / (targetDebt.amount > 0 ? targetDebt.amount : 1000)) * 30).round().clamp(5, 120);
    }

    return PaydayBlitzPlan(
      monthlyIncome: monthlyIncome,
      totalLockedDues: totalLockedDues,
      discretionaryPool: discretionaryPool,
      recommendedSnowflake: recommendedSnowflake,
      targetDebt: targetDebt,
      newDailySafeToSpend: newDailySafeToSpend,
      daysAccelerated: daysAccelerated,
      lockedObligations: activeDues,
    );
  }

  /// Calculates the viral, privacy-first Monthly Freedom Tape story metrics
  FreedomTapeMetrics calculateFreedomTapeMetrics({
    required List<Obligation> obligations,
    required double totalShieldedFromVault,
    required int currentStreak,
    double monthlyIncome = 0.0,
  }) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    final bleed = calculateInterestBleed(obligations);
    final freedom = calculateFreedomData(obligations, monthlyIncome);

    final interestPrevented = totalShieldedFromVault * 0.18;
    final totalInterestKilled = interestPrevented + (bleed.monthlyInterest * 0.25);
    final freedomDaysGained = ((totalShieldedFromVault / 500) + (currentStreak * 1.5)).round().clamp(3, 180);

    return FreedomTapeMetrics(
      monthName: monthName,
      totalInterestKilled: totalInterestKilled,
      totalShieldedFromVault: totalShieldedFromVault,
      freedomDaysGained: freedomDaysGained,
      streakDays: currentStreak,
      projectedDebtFreeYear: freedom.targetDate.year,
      activeDebtsCount: bleed.activeDebtsCount,
    );
  }

  /// Calculates Credit Score Armor and grace period prioritization during cash crunches
  GraceShieldPlan calculateGraceShield({
    required List<Obligation> obligations,
    required double availableEmergencyCash,
  }) {
    final activeDues = obligations
        .where((o) => o.isActive && o.status != ObligationStatus.paid)
        .toList();

    final tier1 = <Obligation>[];
    final tier2 = <Obligation>[];
    final tier3 = <Obligation>[];

    for (final ob in activeDues) {
      final cat = ob.category.toLowerCase();
      final title = ob.title.toLowerCase();
      if (cat.contains('credit') || cat.contains('card') || title.contains('card') || ob.interestRate >= 30) {
        tier1.add(ob);
      } else if (cat.contains('home') || cat.contains('housing') || cat.contains('auto') || cat.contains('vehicle')) {
        tier3.add(ob);
      } else {
        tier2.add(ob);
      }
    }

    final prioritizedOrder = [...tier1, ...tier2, ...tier3];
    double runningCash = availableEmergencyCash;
    final coveredObligations = <Obligation>[];
    final deferredObligations = <GraceShieldDeferredItem>[];

    for (final ob in prioritizedOrder) {
      if (runningCash >= ob.amount) {
        runningCash -= ob.amount;
        coveredObligations.add(ob);
      } else {
        int safeBufferDays = 0;
        String actionPlan = '';
        if (tier1.contains(ob)) {
          safeBufferDays = 1;
          actionPlan = 'CRITICAL: Pay minimum due or request 48-hour waiver to protect CIBIL.';
        } else if (tier2.contains(ob)) {
          safeBufferDays = 3;
          actionPlan = 'GRACE PERIOD: Contact lender to utilize 3-day window with zero credit report.';
        } else {
          safeBufferDays = 7;
          actionPlan = 'SHIELDED BUFFER: Secured loans have 7-day technical grace before NPA classification.';
        }

        deferredObligations.add(GraceShieldDeferredItem(
          obligation: ob,
          safeBufferDays: safeBufferDays,
          defenseAction: actionPlan,
        ));
      }
    }

    String securityStatus;
    if (deferredObligations.isEmpty) {
      securityStatus = 'ARMORED (100% COVERED)';
    } else if (!deferredObligations.any((d) => tier1.contains(d.obligation))) {
      securityStatus = 'DEFENDED (CREDIT CARDS SHIELDED)';
    } else {
      securityStatus = 'CRITICAL ACTION REQUIRED';
    }

    return GraceShieldPlan(
      availableCash: availableEmergencyCash,
      coveredObligations: coveredObligations,
      deferredObligations: deferredObligations,
      securityStatus: securityStatus,
      totalUncovered: deferredObligations.fold(0.0, (sum, d) => sum + d.obligation.amount),
    );
  }

  /// Simulates future timeline state at a specific month offset (0 to 36)
  FreedomTimeMachineSnapshot calculateTimeMachineSnapshot({
    required List<Obligation> obligations,
    required double monthlyIncome,
    required int monthOffset,
  }) {
    final activeDebts = obligations
        .where((o) => o.isActive && (o.totalBalance > 0 || o.type == ObligationType.emi))
        .toList();

    double initialTotalDebt = 0.0;
    for (final d in activeDebts) {
      initialTotalDebt += (d.totalBalance > 0 ? d.totalBalance : d.amount * 12.0);
    }

    final remainingDebts = <Obligation>[];
    final slainDebts = <Obligation>[];
    double unlockedMonthlyCashflow = 0.0;
    double remainingDebtBalance = 0.0;

    for (final d in activeDebts) {
      final balance = d.totalBalance > 0 ? d.totalBalance : (d.amount * 12.0);
      final monthlyPayment = d.amount > 0 ? d.amount : 1000.0;
      final monthsToPayoff = (balance / monthlyPayment).ceil().clamp(1, 120);

      if (monthOffset >= monthsToPayoff) {
        slainDebts.add(d);
        unlockedMonthlyCashflow += d.amount;
      } else {
        remainingDebts.add(d);
        final remainingBal = (balance - (monthlyPayment * monthOffset)).clamp(0.0, balance);
        remainingDebtBalance += remainingBal;
      }
    }

    final isDebtFree = initialTotalDebt > 0 ? (remainingDebtBalance <= 0) : true;
    final progress = initialTotalDebt > 0 
        ? ((initialTotalDebt - remainingDebtBalance) / initialTotalDebt).clamp(0.0, 1.0)
        : 1.0;

    return FreedomTimeMachineSnapshot(
      monthOffset: monthOffset,
      simulatedDate: DateTime.now().add(Duration(days: monthOffset * 30)),
      remainingDebtBalance: remainingDebtBalance,
      unlockedMonthlyCashflow: unlockedMonthlyCashflow,
      progressPercentage: progress,
      slainDebts: slainDebts,
      remainingDebts: remainingDebts,
      isDebtFree: isDebtFree,
    );
  }
}

class FreedomTimeMachineSnapshot {
  final int monthOffset;
  final DateTime simulatedDate;
  final double remainingDebtBalance;
  final double unlockedMonthlyCashflow;
  final double progressPercentage;
  final List<Obligation> slainDebts;
  final List<Obligation> remainingDebts;
  final bool isDebtFree;

  const FreedomTimeMachineSnapshot({
    required this.monthOffset,
    required this.simulatedDate,
    required this.remainingDebtBalance,
    required this.unlockedMonthlyCashflow,
    required this.progressPercentage,
    required this.slainDebts,
    required this.remainingDebts,
    required this.isDebtFree,
  });
}

class PaydayBlitzPlan {
  final double monthlyIncome;
  final double totalLockedDues;
  final double discretionaryPool;
  final double recommendedSnowflake;
  final Obligation? targetDebt;
  final double newDailySafeToSpend;
  final int daysAccelerated;
  final List<Obligation> lockedObligations;

  PaydayBlitzPlan({
    required this.monthlyIncome,
    required this.totalLockedDues,
    required this.discretionaryPool,
    required this.recommendedSnowflake,
    required this.targetDebt,
    required this.newDailySafeToSpend,
    required this.daysAccelerated,
    required this.lockedObligations,
  });
}

class FreedomTapeMetrics {
  final String monthName;
  final double totalInterestKilled;
  final double totalShieldedFromVault;
  final int freedomDaysGained;
  final int streakDays;
  final int projectedDebtFreeYear;
  final int activeDebtsCount;

  FreedomTapeMetrics({
    required this.monthName,
    required this.totalInterestKilled,
    required this.totalShieldedFromVault,
    required this.freedomDaysGained,
    required this.streakDays,
    required this.projectedDebtFreeYear,
    required this.activeDebtsCount,
  });
}

class GraceShieldDeferredItem {
  final Obligation obligation;
  final int safeBufferDays;
  final String defenseAction;

  GraceShieldDeferredItem({
    required this.obligation,
    required this.safeBufferDays,
    required this.defenseAction,
  });
}

class GraceShieldPlan {
  final double availableCash;
  final List<Obligation> coveredObligations;
  final List<GraceShieldDeferredItem> deferredObligations;
  final String securityStatus;
  final double totalUncovered;

  GraceShieldPlan({
    required this.availableCash,
    required this.coveredObligations,
    required this.deferredObligations,
    required this.securityStatus,
    required this.totalUncovered,
  });
}

enum SafeToSpendStatus { abundant, moderate, restricted, critical }

class SafeToSpendMetrics {
  final double dailyAmount;
  final double monthlyRemainingPool;
  final double pendingObligationsThisMonth;
  final int daysLeftInMonth;
  final SafeToSpendStatus status;

  SafeToSpendMetrics({
    required this.dailyAmount,
    required this.monthlyRemainingPool,
    required this.pendingObligationsThisMonth,
    required this.daysLeftInMonth,
    required this.status,
  });
}

class GhostSubscriptionInsight {
  final String title;
  final String category;
  final int count;
  final double monthlyLeak;
  final double fiveYearOpportunityCost;
  final String description;
  final List<Obligation> suspectObligations;

  GhostSubscriptionInsight({
    required this.title,
    required this.category,
    required this.count,
    required this.monthlyLeak,
    required this.fiveYearOpportunityCost,
    required this.description,
    required this.suspectObligations,
  });
}

class ArbitrageOpportunity {
  final Obligation obligation;
  final double currentApr;
  final double targetApr;
  final double monthlySavings;
  final double totalInterestSaved;
  final int monthsAccelerated;

  ArbitrageOpportunity({
    required this.obligation,
    required this.currentApr,
    required this.targetApr,
    required this.monthlySavings,
    required this.totalInterestSaved,
    required this.monthsAccelerated,
  });
}

class InterestBleedMetrics {
  final double monthlyInterest;
  final double dailyBleed;
  final double hourlyBleed;
  final double perMinuteBleed;
  final int activeDebtsCount;

  InterestBleedMetrics({
    required this.monthlyInterest,
    required this.dailyBleed,
    required this.hourlyBleed,
    required this.perMinuteBleed,
    required this.activeDebtsCount,
  });
}

class SnowflakeImpact {
  final double amount;
  final double interestSaved;
  final int daysSaved;
  final String motivationalHook;

  SnowflakeImpact({
    required this.amount,
    required this.interestSaved,
    required this.daysSaved,
    required this.motivationalHook,
  });
}

class CrisisTriageItem {
  final String title;
  final double monthlyAmount;
  final String actionRecommendation;
  final int priorityLevel;

  CrisisTriageItem({
    required this.title,
    required this.monthlyAmount,
    required this.actionRecommendation,
    required this.priorityLevel,
  });
}

class CrisisStressTestResult {
  final int runwayDays;
  final double monthlySurvivalBurn;
  final double discretionarySavingsPotential;
  final List<CrisisTriageItem> triagePlan;

  CrisisStressTestResult({
    required this.runwayDays,
    required this.monthlySurvivalBurn,
    required this.discretionarySavingsPotential,
    required this.triagePlan,
  });
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
