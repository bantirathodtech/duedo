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

    for (final obligation in activeObligations) {
      if (obligation.type == ObligationType.emi) {
        totalMonthlyLoad += obligation.amount;
      } else if (obligation.type == ObligationType.oneTime) {
        if (obligation.endDate != null && 
            obligation.endDate!.month == now.month && 
            obligation.endDate!.year == now.year) {
          totalMonthlyLoad += obligation.amount;
        }
      }
    }
    return (totalMonthlyLoad / monthlyIncome);
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

  FreedomData calculateFreedomData(List<Obligation> obligations) {
    if (obligations.isEmpty) return FreedomData(daysLeft: 0, totalRemainingBalance: 0, targetDate: DateTime.now());
    double totalBalance = 0;
    DateTime latestDate = DateTime.now();
    for (final ob in obligations) {
      if (!ob.isActive) continue;
      totalBalance += ob.totalBalance;
      
      DateTime projectedEnd;
      if (ob.endDate != null && ob.endDate!.isAfter(DateTime.now())) {
        projectedEnd = ob.endDate!;
      } else if (ob.type == ObligationType.emi && ob.totalBalance > 0 && ob.amount > 0) {
        int monthsLeft = (ob.totalBalance / ob.amount).ceil();
        DateTime startFrom = ob.nextDueDate ?? DateTime.now();
        projectedEnd = DateTime(startFrom.year, startFrom.month + monthsLeft, startFrom.day);
      } else {
        projectedEnd = ob.nextDueDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30));
      }
      
      if (projectedEnd.isAfter(latestDate)) latestDate = projectedEnd;
    }
    final daysLeft = latestDate.difference(DateTime.now()).inDays;
    return FreedomData(
      daysLeft: daysLeft < 0 ? 0 : daysLeft,
      totalRemainingBalance: totalBalance,
      targetDate: latestDate,
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
      // Calculate max payoff percentage any debt has achieved
      // Calculate max payoff percentage any debt has achieved
      // Let's rely on standard logic: if amount < totalBalance? No, amount is EMI or One-Time original amount.
      // Database has `amount` which is the original principal, and `totalBalance` which is remaining.
      // Let's recalculate accurately just using this assumption:
      double originalPrincipal = debt.amount; 
      double paidAmount = originalPrincipal - debt.totalBalance;
      if (paidAmount < 0) paidAmount = 0; // Prevent weird interest capitalization bounds 

      double percentagePaid = originalPrincipal > 0 ? (paidAmount / originalPrincipal) : 0;

      for (var badge in badges) {
        if (!badge.isUnlocked && percentagePaid >= badge.requiredPercentage) {
          badge.isUnlocked = true;
        }
      }
    }

    return badges;
  }
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
  FreedomData({required this.daysLeft, required this.totalRemainingBalance, required this.targetDate});
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
