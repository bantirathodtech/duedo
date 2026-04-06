import 'package:flutter_test/flutter_test.dart';
import 'package:duedo/services/financial_logic_service.dart';
import 'package:duedo/services/optimization_engine.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  late FinancialLogicService logicService;

  setUp(() {
    logicService = FinancialLogicService();
  });

  Obligation createTestObligation({
    required int id,
    required String title,
    required double amount,
    required ObligationType type,
    required double totalBalance,
    required double interestRate,
    PriorityLevel priority = PriorityLevel.medium,
    DateTime? nextDueDate,
  }) {
    final now = DateTime.now();
    return Obligation(
      id: id,
      title: title,
      amount: amount,
      type: type,
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
      nextDueDate: nextDueDate,
    );
  }

  group('FinancialLogicService Math Audit', () {
    test('calculatePressureLevel - Zero Income', () {
      final obligations = [
        createTestObligation(id: 1, title: 'EMI', amount: 5000, type: ObligationType.emi, totalBalance: 50000, interestRate: 12),
      ];
      expect(logicService.calculatePressureLevel(obligations, 0), 1.0);
    });

    test('calculatePressureLevel - High Pressure with Imminent Deadline', () {
      final now = DateTime.now();
      final obligations = [
        createTestObligation(
          id: 1, 
          title: 'Urgent EMI', 
          amount: 10000, 
          type: ObligationType.emi, 
          totalBalance: 100000, 
          interestRate: 15,
          priority: PriorityLevel.high,
          nextDueDate: now.add(const Duration(hours: 24)),
        ),
      ];
      // Income: 20,000. Load: 10,000. Base Pressure: 0.5. 
      // Imminent High Priority (+10%): 0.5 * 1.1 = 0.55
      expect(logicService.calculatePressureLevel(obligations, 20000), 0.55);
    });

    test('calculateFreedomData - Debt Free Projection', () {
      final obligations = [
        createTestObligation(id: 1, title: 'Loan', amount: 5000, type: ObligationType.emi, totalBalance: 10000, interestRate: 0),
      ];
      // 10,000 / 5,000 = 2 months. 
      // Note: FinancialLogicService floors projection at 60 months for visualization.
      final data = logicService.calculateFreedomData(obligations, 10000);
      expect(data.daysLeft, 1800); // 60 months * 30 days
      expect(data.totalRemainingBalance, 10000);
    });
  });

  group('OptimizationEngine Math Audit', () {
    test('calculateDelta - Interest Savings Estimation', () {
      final debts = [
        createTestObligation(id: 1, title: 'High Rate', amount: 1000, type: ObligationType.emi, totalBalance: 10000, interestRate: 20, priority: PriorityLevel.high),
        createTestObligation(id: 2, title: 'Low Rate', amount: 1000, type: ObligationType.emi, totalBalance: 10000, interestRate: 10, priority: PriorityLevel.low),
      ];
      
      final delta = OptimizationEngine.calculateDelta(debts, 5000);
      
      // totalBalance = 20000
      // spread = (20 - 10) / 100 = 0.1
      // theoreticalInterestSaved = (20000 * 0.1) * 0.5 = 1000.0
      expect(delta['interestSaved'], 1000.0);
      expect(delta['monthsSaved'], 1); // 1000 / 5000 ceil = 1
    });

    test('calculateDelta - Same Rates', () {
      final debts = [
        createTestObligation(id: 1, title: 'Debt A', amount: 1000, type: ObligationType.emi, totalBalance: 10000, interestRate: 10),
        createTestObligation(id: 2, title: 'Debt B', amount: 1000, type: ObligationType.emi, totalBalance: 10000, interestRate: 10),
      ];
      
      final delta = OptimizationEngine.calculateDelta(debts, 5000);
      expect(delta['interestSaved'], 0.0);
      expect(delta['monthsSaved'], 0);
    });
  });
}
