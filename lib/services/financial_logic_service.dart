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
      final end = ob.endDate ?? ob.nextDueDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30));
      if (end.isAfter(latestDate)) latestDate = end;
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
}
