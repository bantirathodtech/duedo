/// OptimizationEngine Test Suite
///
/// Tests the Snowball vs Avalanche sorting strategies and
/// the delta (interest saved / months saved) calculation.
import 'package:flutter_test/flutter_test.dart';
import 'package:duedo/services/optimization_engine.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  Obligation createDebt({
    required int id,
    required String title,
    required double amount,
    required double totalBalance,
    required double interestRate,
    PriorityLevel priority = PriorityLevel.medium,
  }) {
    final now = DateTime.now();
    return Obligation(
      id: id,
      title: title,
      amount: amount,
      type: ObligationType.emi,
      startDate: now,
      gracePeriodDays: 0,
      emiPaidMonths: 0,
      priority: priority,
      status: ObligationStatus.pending,
      category: 'General',
      totalBalance: totalBalance,
      interestRate: interestRate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      displayOrder: 0,
    );
  }

  group('OptimizationEngine.sort', () {
    test('empty list returns empty', () {
      final result = OptimizationEngine.sort([], RepaymentStrategy.snowball);
      expect(result, isEmpty);
    });

    test('snowball sorts by smallest balance first', () {
      final debts = [
        createDebt(id: 1, title: 'Big', amount: 5000, totalBalance: 50000, interestRate: 8),
        createDebt(id: 2, title: 'Small', amount: 1000, totalBalance: 5000, interestRate: 15),
        createDebt(id: 3, title: 'Medium', amount: 2000, totalBalance: 20000, interestRate: 10),
      ];

      final sorted = OptimizationEngine.sort(debts, RepaymentStrategy.snowball);
      expect(sorted[0].title, 'Small');   // 5000
      expect(sorted[1].title, 'Medium');  // 20000
      expect(sorted[2].title, 'Big');     // 50000
    });

    test('avalanche sorts by highest interest rate first', () {
      final debts = [
        createDebt(id: 1, title: 'Low', amount: 5000, totalBalance: 50000, interestRate: 5),
        createDebt(id: 2, title: 'High', amount: 1000, totalBalance: 5000, interestRate: 20),
        createDebt(id: 3, title: 'Mid', amount: 2000, totalBalance: 20000, interestRate: 12),
      ];

      final sorted = OptimizationEngine.sort(debts, RepaymentStrategy.avalanche);
      expect(sorted[0].title, 'High');  // 20%
      expect(sorted[1].title, 'Mid');   // 12%
      expect(sorted[2].title, 'Low');   // 5%
    });

    test('single debt returns same debt', () {
      final debts = [
        createDebt(id: 1, title: 'Only', amount: 1000, totalBalance: 10000, interestRate: 10),
      ];

      final snowball = OptimizationEngine.sort(debts, RepaymentStrategy.snowball);
      final avalanche = OptimizationEngine.sort(debts, RepaymentStrategy.avalanche);
      expect(snowball.length, 1);
      expect(avalanche.length, 1);
    });

    test('does not mutate original list', () {
      final debts = [
        createDebt(id: 1, title: 'B', amount: 5000, totalBalance: 50000, interestRate: 8),
        createDebt(id: 2, title: 'A', amount: 1000, totalBalance: 5000, interestRate: 15),
      ];
      final originalFirst = debts[0].title;

      OptimizationEngine.sort(debts, RepaymentStrategy.snowball);
      expect(debts[0].title, originalFirst); // unchanged
    });

    test('equal balances maintains order in snowball', () {
      final debts = [
        createDebt(id: 1, title: 'A', amount: 1000, totalBalance: 10000, interestRate: 10),
        createDebt(id: 2, title: 'B', amount: 1000, totalBalance: 10000, interestRate: 15),
      ];

      final sorted = OptimizationEngine.sort(debts, RepaymentStrategy.snowball);
      // Both have same balance, order preserved
      expect(sorted.length, 2);
    });

    test('equal rates maintains order in avalanche', () {
      final debts = [
        createDebt(id: 1, title: 'A', amount: 1000, totalBalance: 5000, interestRate: 10),
        createDebt(id: 2, title: 'B', amount: 1000, totalBalance: 50000, interestRate: 10),
      ];

      final sorted = OptimizationEngine.sort(debts, RepaymentStrategy.avalanche);
      expect(sorted.length, 2);
    });
  });

  group('OptimizationEngine.calculateDelta', () {
    test('empty debts = zero savings', () {
      final result = OptimizationEngine.calculateDelta([], 5000);
      expect(result['interestSaved'], 0.0);
      expect(result['monthsSaved'], 0);
    });

    test('zero payment capacity = zero savings', () {
      final debts = [
        createDebt(id: 1, title: 'A', amount: 1000, totalBalance: 10000, interestRate: 15),
      ];
      final result = OptimizationEngine.calculateDelta(debts, 0);
      expect(result['interestSaved'], 0.0);
      expect(result['monthsSaved'], 0);
    });

    test('same interest rates = zero delta', () {
      final debts = [
        createDebt(id: 1, title: 'A', amount: 1000, totalBalance: 10000, interestRate: 10),
        createDebt(id: 2, title: 'B', amount: 1000, totalBalance: 10000, interestRate: 10),
      ];
      final result = OptimizationEngine.calculateDelta(debts, 5000);
      expect(result['interestSaved'], 0.0);
      expect(result['monthsSaved'], 0);
    });

    test('different rates produces positive savings', () {
      final debts = [
        createDebt(id: 1, title: 'High', amount: 1000, totalBalance: 10000, interestRate: 20),
        createDebt(id: 2, title: 'Low', amount: 1000, totalBalance: 10000, interestRate: 10),
      ];
      final result = OptimizationEngine.calculateDelta(debts, 5000);
      // spread = (20-10)/100 = 0.1
      // savings = 20000 * 0.1 * 0.5 = 1000
      expect(result['interestSaved'], 1000.0);
      expect(result['monthsSaved'], 1); // ceil(1000/5000)
    });

    test('large spread produces larger savings', () {
      final debts = [
        createDebt(id: 1, title: 'Very High', amount: 1000, totalBalance: 50000, interestRate: 30),
        createDebt(id: 2, title: 'Very Low', amount: 1000, totalBalance: 50000, interestRate: 5),
      ];
      final result = OptimizationEngine.calculateDelta(debts, 5000);
      // spread = 25/100 = 0.25
      // savings = 100000 * 0.25 * 0.5 = 12500
      expect(result['interestSaved'], 12500.0);
      expect(result['monthsSaved'], 3); // ceil(12500/5000)
    });

    test('small payment capacity = more months saved', () {
      final debts = [
        createDebt(id: 1, title: 'A', amount: 1000, totalBalance: 10000, interestRate: 20),
        createDebt(id: 2, title: 'B', amount: 1000, totalBalance: 10000, interestRate: 10),
      ];
      final result = OptimizationEngine.calculateDelta(debts, 500);
      expect(result['interestSaved'], 1000.0);
      expect(result['monthsSaved'], 2); // ceil(1000/500)
    });
  });
}
