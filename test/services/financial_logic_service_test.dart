import 'package:flutter_test/flutter_test.dart';
import 'package:duedo/services/financial_logic_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';
import 'package:drift/drift.dart';

void main() {
  late FinancialLogicService service;

  setUp(() {
    service = FinancialLogicService();
  });

  Obligation createObligation({
    int id = 1,
    String title = 'Test Debt',
    ObligationType type = ObligationType.emi,
    double amount = 1000,
    DateTime? startDate,
    DateTime? nextDueDate,
    DateTime? endDate,
    PriorityLevel priority = PriorityLevel.medium,
    ObligationStatus status = ObligationStatus.pending,
    bool isActive = true,
    double totalBalance = 1000,
    double interestRate = 10.0,
  }) {
    final now = DateTime.now();
    return Obligation(
      id: id,
      title: title,
      type: type,
      amount: amount,
      startDate: startDate ?? now,
      nextDueDate: nextDueDate,
      endDate: endDate,
      gracePeriodDays: 3,
      emiPaidMonths: 0,
      priority: priority,
      status: status,
      category: 'General',
      totalBalance: totalBalance,
      interestRate: interestRate,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
      displayOrder: 0,
    );
  }

  group('calculatePressureLevel', () {
    test('should return 0.0 when there are no active obligations', () {
      final score = service.calculatePressureLevel([], 5000);
      expect(score, 0.0);
    });

    test('should return 1.0 when monthly income is 0', () {
      final obligation = createObligation(amount: 1000);
      final score = service.calculatePressureLevel([obligation], 0);
      expect(score, 1.0);
    });

    test('should calculate base pressure correctly', () {
      final obligation = createObligation(amount: 1000, type: ObligationType.emi);
      final score = service.calculatePressureLevel([obligation], 4000);
      expect(score, 0.25);
    });

    test('should add stress factor for imminent high priority debt', () {
      final now = DateTime.now();
      final imminentDebt = createObligation(
        amount: 1000,
        priority: PriorityLevel.high,
        nextDueDate: now.add(const Duration(hours: 24)),
      );
      
      final score = service.calculatePressureLevel([imminentDebt], 4000);
      expect(score, closeTo(0.275, 0.001));
    });
  });

  group('getUrgencyLabel', () {
    test('should return safe for inactive or paid obligations', () {
      final o1 = createObligation(isActive: false);
      final o2 = createObligation(status: ObligationStatus.paid);
      expect(service.getUrgencyLabel(o1), 'safe');
      expect(service.getUrgencyLabel(o2), 'safe');
    });

    test('should return overdue if past deadline', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final obligation = createObligation(nextDueDate: pastDate);
      expect(service.getUrgencyLabel(obligation), 'overdue');
    });

    test('should return urgent if within grace period', () {
      final today = DateTime.now();
      final obligation = createObligation(nextDueDate: today);
      expect(service.getUrgencyLabel(obligation), 'urgent');
    });
  });

  group('generateInsights', () {
    test('should generate critical insight for overdue obligation', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final obligation = createObligation(nextDueDate: pastDate, title: 'Rent');
      
      final insights = service.generateInsights([obligation], 5000, 1);
      
      expect(insights.any((i) => i.severity == InsightSeverity.critical && i.description.contains('Rent')), true);
    });

    test('should generate warning for high pressure before payday', () {
      const payday = 30;
      final soonDate = DateTime(DateTime.now().year, DateTime.now().month, 25);
      final obligation = createObligation(amount: 2000, nextDueDate: soonDate);
      
      final insights = service.generateInsights([obligation], 5000, payday);
      
      expect(insights.any((i) => i.severity == InsightSeverity.warning), true);
    });
  });

  group('calculateFreedomData (Snowball)', () {
    test('should handle empty debts', () {
      final data = service.calculateFreedomData([], 5000);
      expect(data.daysLeft, 0);
    });

    test('should handle insufficient income', () {
      final recurring = createObligation(amount: 6000, type: ObligationType.recurring);
      final debt = createObligation(amount: 1000, totalBalance: 5000);
      final data = service.calculateFreedomData([recurring, debt], 5000);
      expect(data.daysLeft, 3650); // capped high
    });

    test('should simulate snowball correctly', () {
      final debt = createObligation(amount: 1000, totalBalance: 3000, type: ObligationType.emi);
      final data = service.calculateFreedomData([debt], 5000);
      
      expect(data.daysLeft > 0, true);
      expect(data.monthlyBalances.length > 1, true);
      expect(data.monthlyBalances.last, 0.0);
    });
  });

  group('calculateBadges', () {
    test('should unlock badges based on percentage paid', () {
      // Original amount 1000, balance 500 -> 50% paid
      final debt = createObligation(amount: 1000, totalBalance: 500);
      final badges = service.calculateBadges([debt]);
      
      expect(badges.firstWhere((b) => b.id == 'first_blood').isUnlocked, true);
      expect(badges.firstWhere((b) => b.id == 'halfway_there').isUnlocked, true);
      expect(badges.firstWhere((b) => b.id == 'debt_destroyer').isUnlocked, false);
    });
  });

  group('calculateTaxSavings', () {
    test('should annualize and cap Indian tax categories', () {
      final ob80C = createObligation(amount: 20000).copyWith(taxCategory: const Value('80C'));
      final ob80D = createObligation(amount: 5000).copyWith(taxCategory: const Value('80D'));
      
      final savings = service.calculateTaxSavings([ob80C, ob80D]);
      
      expect(savings['80C'], 150000); // 240k capped at 150k
      expect(savings['80D'], 25000);  // 60k capped at 25k
    });
  });

  group('calculateFinancialRank', () {
    test('should return correct rank strings', () {
      expect(service.calculateFinancialRank(960), 'Top 1%');
      expect(service.calculateFinancialRank(400), 'Top 85%');
    });
  });

  group('calculateHealthScore', () {
    test('should combine DTI and streak', () {
      // DTI 0.0 -> 800, Streak 5 -> 100. Total 900.
      expect(service.calculateHealthScore(0.0, 5), 900);
      // DTI 0.5 -> 200, Streak 0 -> 0. Total 200.
      expect(service.calculateHealthScore(0.5, 0), 200);
    });
  });
}
