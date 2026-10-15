import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/daily_rings_service.dart';
import 'package:duedo/services/impulse_vault_service.dart';
import 'package:duedo/services/persona_voice_service.dart';
import 'package:duedo/services/financial_logic_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyRingsNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with default state and checkIn completed', () async {
      final notifier = DailyRingsNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.checkInCompleted, isTrue);
      expect(notifier.state.cleanDayCompleted, isFalse);
      expect(notifier.state.snowflakeCompleted, isFalse);
      expect(notifier.state.currentStreak, greaterThanOrEqualTo(1));
    });

    test('toggleCleanDay flips status and updates total clean days', () async {
      final notifier = DailyRingsNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialCleanDays = notifier.state.totalCleanDays;
      await notifier.toggleCleanDay();

      expect(notifier.state.cleanDayCompleted, isTrue);
      expect(notifier.state.totalCleanDays, equals(initialCleanDays + 1));

      // Toggle off
      await notifier.toggleCleanDay();
      expect(notifier.state.cleanDayCompleted, isFalse);
      expect(notifier.state.totalCleanDays, equals(initialCleanDays));
    });

    test('recordSnowflake marks snowflakeCompleted and updates progress', () async {
      final notifier = DailyRingsNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.snowflakeCompleted, isFalse);
      await notifier.recordSnowflake();

      expect(notifier.state.snowflakeCompleted, isTrue);
      expect(notifier.state.snowflakeProgress, equals(1.0));
    });

    test('completing all 3 quests closes all rings and preserves streak', () async {
      final notifier = DailyRingsNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.recordSnowflake();
      await notifier.toggleCleanDay();

      expect(notifier.state.cleanDayCompleted, isTrue);
      expect(notifier.state.snowflakeCompleted, isTrue);
      expect(notifier.state.checkInCompleted, isTrue);
      expect(notifier.state.ringsClosedToday, isTrue);
      expect(notifier.state.overallProgress, equals(1.0));
    });
  });

  group('ImpulseVaultNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('shieldImpulse locks item in 24h cooling chamber with calculated metrics', () async {
      final notifier = ImpulseVaultNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final item = await notifier.shieldImpulse(
        title: 'Noise Cancelling Headphones',
        amount: 3500.0,
        annualInterestRate: 15.0,
        dailyDebtBurn: 500.0,
      );

      expect(item.title, equals('Noise Cancelling Headphones'));
      expect(item.amount, equals(3500.0));
      expect(item.status, equals(ImpulseStatus.cooling));
      expect(item.coolingDurationHours, equals(24));
      expect(item.freedomDaysRestored, equals(7)); // 3500 / 500 = 7 days
      expect(item.interestPrevented, greaterThan(0));

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.activeCoolingItems.length, equals(1));
    });

    test('markResisted transfers cooling item into saved freedom metric', () async {
      final notifier = ImpulseVaultNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final item = await notifier.shieldImpulse(
        title: 'Weekend Party Outing',
        amount: 2000.0,
        dailyDebtBurn: 400.0,
      );

      expect(notifier.state.totalShielded, equals(0.0));
      await notifier.markResisted(item.id);

      expect(notifier.state.activeCoolingItems.isEmpty, isTrue);
      expect(notifier.state.resistedItems.length, equals(1));
      expect(notifier.state.totalShielded, equals(2000.0));
      expect(notifier.state.totalDaysSaved, greaterThan(0));
    });

    test('deleteItem removes item from vault', () async {
      final notifier = ImpulseVaultNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final item = await notifier.shieldImpulse(
        title: 'Sneakers',
        amount: 1500.0,
      );

      expect(notifier.state.items.length, equals(1));
      await notifier.deleteItem(item.id);
      expect(notifier.state.items.isEmpty, isTrue);
    });
  });

  group('PersonaVoiceService Tests', () {
    final persona = PersonaVoiceService();

    test('returns distinctive savage vs zen quotes', () {
      final savageQuote = persona.getDailyHeroQuote(true);
      final zenQuote = persona.getDailyHeroQuote(false);

      expect(savageQuote.isNotEmpty, isTrue);
      expect(zenQuote.isNotEmpty, isTrue);
      expect(savageQuote, isNot(equals(zenQuote)));
    });

    test('generates dynamic impulse cooling and snowflake win copy', () {
      final savageCooling = persona.getImpulseCoolingPrompt(true, 'Watch', 5000);
      final zenCooling = persona.getImpulseCoolingPrompt(false, 'Watch', 5000);

      expect(savageCooling.contains('Watch'), isTrue);
      expect(zenCooling.contains('Watch'), isTrue);

      final savageWin = persona.getSnowflakeWinQuote(true, 1200, 4);
      final zenWin = persona.getSnowflakeWinQuote(false, 1200, 4);

      expect(savageWin.contains('1200'), isTrue);
      expect(zenWin.contains('1200'), isTrue);
    });
  });

  group('Interest Vampire Bleed Calculation Tests', () {
    final financialLogic = FinancialLogicService();

    test('calculates correct hourly and daily interest bleed', () {
      final obligations = [
        Obligation(
          id: 1,
          title: 'Car Loan',
          type: ObligationType.emi,
          amount: 15000,
          startDate: DateTime.now(),
          priority: PriorityLevel.high,
          category: 'Auto',
          totalBalance: 600000,
          interestRate: 10.0, // 60,000 / yr -> 5,000 / mo
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 0,
        ),
      ];

      final bleed = financialLogic.calculateInterestBleed(obligations);

      expect(bleed.monthlyInterest, closeTo(5000.0, 1.0));
      expect(bleed.dailyBleed, closeTo(5000.0 / 30.0, 1.0));
      expect(bleed.hourlyBleed, closeTo(5000.0 / 720.0, 0.5));
      expect(bleed.activeDebtsCount, equals(1));
    });

    test('returns zero bleed if no active debts exist', () {
      final bleed = financialLogic.calculateInterestBleed([]);
      expect(bleed.monthlyInterest, equals(0.0));
      expect(bleed.hourlyBleed, equals(0.0));
      expect(bleed.activeDebtsCount, equals(0));
    });
  });

  group('High-APR Refinance & Arbitrage Radar Tests', () {
    final financialLogic = FinancialLogicService();

    test('detects obligations with >= 18% APR and computes consolidation arbitrage', () {
      final obligations = [
        Obligation(
          id: 1,
          title: 'Credit Card Outstanding',
          type: ObligationType.emi,
          amount: 5000,
          startDate: DateTime.now(),
          priority: PriorityLevel.high,
          category: 'Credit Card',
          totalBalance: 120000,
          interestRate: 36.0, // 36% APR -> Prime target!
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 0,
        ),
        Obligation(
          id: 2,
          title: 'Home Loan',
          type: ObligationType.emi,
          amount: 35000,
          startDate: DateTime.now(),
          priority: PriorityLevel.high,
          category: 'Housing',
          totalBalance: 3500000,
          interestRate: 8.5, // 8.5% APR -> Not high APR
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 1,
        ),
        Obligation(
          id: 3,
          title: 'Old High APR Closed Debt',
          type: ObligationType.emi,
          amount: 10000,
          startDate: DateTime.now(),
          priority: PriorityLevel.medium,
          category: 'Personal',
          totalBalance: 0,
          interestRate: 24.0,
          isActive: true,
          status: ObligationStatus.paid, // Already paid -> Should be ignored
          gracePeriodDays: 0,
          emiPaidMonths: 12,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 2,
        ),
      ];

      final opportunities = financialLogic.detectArbitrageOpportunities(obligations);

      expect(opportunities.length, equals(1));
      final opp = opportunities.first;
      expect(opp.obligation.title, equals('Credit Card Outstanding'));
      expect(opp.currentApr, equals(36.0));
      expect(opp.targetApr, equals(11.5));
      expect(opp.monthlySavings, greaterThan(0));
      expect(opp.totalInterestSaved, greaterThan(0));
      expect(opp.monthsAccelerated, greaterThanOrEqualTo(1));
    });

    test('returns empty list if all debts are below 18% APR', () {
      final obligations = [
        Obligation(
          id: 1,
          title: 'Auto Loan',
          type: ObligationType.emi,
          amount: 12000,
          startDate: DateTime.now(),
          priority: PriorityLevel.medium,
          category: 'Auto',
          totalBalance: 400000,
          interestRate: 10.5,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 0,
        ),
      ];

      final opportunities = financialLogic.detectArbitrageOpportunities(obligations);
      expect(opportunities.isEmpty, isTrue);
    });
  });

  group('Safe-to-Spend Dynamic Calculation Tests', () {
    final financialLogic = FinancialLogicService();

    test('calculates correct daily allowance and abundant status with positive cashflow', () {
      final now = DateTime(2026, 10, 15);
      final obligations = [
        Obligation(
          id: 1,
          title: 'Car Loan',
          type: ObligationType.emi,
          amount: 15000,
          startDate: DateTime(2026, 10, 5),
          priority: PriorityLevel.high,
          category: 'Auto',
          totalBalance: 300000,
          interestRate: 10.0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 0,
        ),
      ];

      // Income: 60,000. Pending: 15,000. Free Pool: 45,000.
      // Days left in October (31 days): 31 - 15 + 1 = 17 days.
      // Daily safe: 45,000 / 17 = 2,647.
      final metrics = financialLogic.calculateSafeToSpend(
        obligations: obligations,
        monthlyIncome: 60000.0,
        currentDate: now,
      );

      expect(metrics.monthlyRemainingPool, equals(45000.0));
      expect(metrics.pendingObligationsThisMonth, equals(15000.0));
      expect(metrics.daysLeftInMonth, equals(17));
      expect(metrics.dailyAmount, closeTo(2647.05, 1.0));
      expect(metrics.status, equals(SafeToSpendStatus.abundant));
    });

    test('reports critical deficit status if obligations exceed income', () {
      final now = DateTime(2026, 10, 10);
      final obligations = [
        Obligation(
          id: 1,
          title: 'Mega Loan',
          type: ObligationType.emi,
          amount: 75000,
          startDate: DateTime(2026, 10, 5),
          priority: PriorityLevel.high,
          category: 'Personal',
          totalBalance: 500000,
          interestRate: 15.0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 0,
        ),
      ];

      final metrics = financialLogic.calculateSafeToSpend(
        obligations: obligations,
        monthlyIncome: 50000.0,
        currentDate: now,
      );

      expect(metrics.monthlyRemainingPool, equals(-25000.0));
      expect(metrics.dailyAmount, equals(0.0));
      expect(metrics.status, equals(SafeToSpendStatus.critical));
    });
  });

  group('Ghost Bill Hunter Detection Tests', () {
    final financialLogic = FinancialLogicService();

    test('detects overlapping streaming subscriptions and computes 5-year opportunity cost', () {
      final obligations = [
        Obligation(
          id: 1,
          title: 'Netflix Premium 4K',
          type: ObligationType.recurring,
          amount: 649,
          startDate: DateTime.now(),
          priority: PriorityLevel.medium,
          category: 'Entertainment',
          totalBalance: 0,
          interestRate: 0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 0,
        ),
        Obligation(
          id: 2,
          title: 'Disney Hotstar VIP',
          type: ObligationType.recurring,
          amount: 499,
          startDate: DateTime.now(),
          priority: PriorityLevel.medium,
          category: 'Entertainment',
          totalBalance: 0,
          interestRate: 0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 1,
        ),
        Obligation(
          id: 3,
          title: 'Gym Membership',
          type: ObligationType.recurring,
          amount: 2500,
          startDate: DateTime.now(),
          priority: PriorityLevel.low, // Marked low priority
          category: 'Fitness',
          totalBalance: 0,
          interestRate: 0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          displayOrder: 2,
        ),
      ];

      final insights = financialLogic.detectGhostSubscriptions(obligations);

      expect(insights.length, greaterThanOrEqualTo(2));
      final ottInsight = insights.firstWhere((i) => i.title.contains('Streaming Overlap'));
      expect(ottInsight.count, equals(2));
      expect(ottInsight.monthlyLeak, equals(1148.0));
      expect(ottInsight.fiveYearOpportunityCost, greaterThan(80000.0));

      final lowPriorityInsight = insights.firstWhere((i) => i.title.contains('Low-Priority Leak'));
      expect(lowPriorityInsight.monthlyLeak, equals(2500.0));
    });
  });

  group('Payday Blitz Workflow Tests', () {
    final financialLogic = FinancialLogicService();

    test('ring-fences locked dues, targets highest APR debt with 15% snowflake, and establishes daily allowance', () {
      final now = DateTime.now();
      final obligations = [
        Obligation(
          id: 1,
          title: 'Credit Card Bill',
          type: ObligationType.emi,
          amount: 15000,
          startDate: now,
          priority: PriorityLevel.high,
          category: 'Credit Card',
          totalBalance: 45000,
          interestRate: 42.0, // Highest APR
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 0,
        ),
        Obligation(
          id: 2,
          title: 'Car Loan EMI',
          type: ObligationType.emi,
          amount: 10000,
          startDate: now,
          priority: PriorityLevel.medium,
          category: 'Auto Loan',
          totalBalance: 300000,
          interestRate: 9.5,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 7,
          emiPaidMonths: 12,
          createdAt: now,
          updatedAt: now,
          displayOrder: 1,
        ),
        Obligation(
          id: 3,
          title: 'Broadband Internet',
          type: ObligationType.recurring,
          amount: 1200,
          startDate: now,
          priority: PriorityLevel.medium,
          category: 'Utilities',
          totalBalance: 0,
          interestRate: 0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 3,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 2,
        ),
      ];

      final plan = financialLogic.calculatePaydayBlitz(
        monthlyIncome: 60000.0,
        obligations: obligations,
      );

      // Locked dues: 15000 + 10000 + 1200 = 26200
      expect(plan.monthlyIncome, equals(60000.0));
      expect(plan.totalLockedDues, equals(26200.0));
      // Discretionary pool: 60000 - 26200 = 33800
      expect(plan.discretionaryPool, equals(33800.0));
      // Target debt should be the 42% APR Credit Card
      expect(plan.targetDebt?.id, equals(1));
      expect(plan.targetDebt?.interestRate, equals(42.0));
      // Recommended snowflake: 15% of 33800 = 5070
      expect(plan.recommendedSnowflake, equals(5070.0));
      // Daily safe to spend: (33800 - 5070) / 30 = 957.66
      expect(plan.newDailySafeToSpend, closeTo(957.66, 0.1));
      expect(plan.daysAccelerated, greaterThan(0));
      expect(plan.lockedObligations.length, equals(3));
    });
  });

  group('Monthly Freedom Tape Story Metrics Tests', () {
    final financialLogic = FinancialLogicService();

    test('computes viral interest killed, vault shielded metrics, and debt-free year with zero bank balances exposed', () {
      final now = DateTime.now();
      final obligations = [
        Obligation(
          id: 1,
          title: 'Personal Loan',
          type: ObligationType.emi,
          amount: 8000,
          startDate: now,
          priority: PriorityLevel.high,
          category: 'Personal Loan',
          totalBalance: 120000,
          interestRate: 14.0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 3,
          emiPaidMonths: 6,
          createdAt: now,
          updatedAt: now,
          displayOrder: 0,
        ),
      ];

      final metrics = financialLogic.calculateFreedomTapeMetrics(
        obligations: obligations,
        totalShieldedFromVault: 15000.0,
        currentStreak: 45,
        monthlyIncome: 65000.0,
      );

      expect(metrics.totalShieldedFromVault, equals(15000.0));
      expect(metrics.streakDays, equals(45));
      expect(metrics.freedomDaysGained, greaterThanOrEqualTo(45));
      expect(metrics.totalInterestKilled, greaterThan(2700.0));
      expect(metrics.projectedDebtFreeYear, greaterThanOrEqualTo(now.year));
      expect(metrics.activeDebtsCount, equals(1));
    });
  });

  group('Emergency Grace Shield Credit Score Armor Tests', () {
    final financialLogic = FinancialLogicService();

    test('triages cash to prioritize Credit Cards and defers secured loans with safe buffer days', () {
      final now = DateTime.now();
      final obligations = [
        Obligation(
          id: 1,
          title: 'HDFC Credit Card',
          type: ObligationType.emi,
          amount: 12000,
          startDate: now,
          priority: PriorityLevel.high,
          category: 'Credit Card',
          totalBalance: 50000,
          interestRate: 40.0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 0,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 0,
        ),
        Obligation(
          id: 2,
          title: 'Personal Loan',
          type: ObligationType.emi,
          amount: 8000,
          startDate: now,
          priority: PriorityLevel.medium,
          category: 'Personal Loan',
          totalBalance: 100000,
          interestRate: 15.0,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 3,
          emiPaidMonths: 0,
          createdAt: now,
          updatedAt: now,
          displayOrder: 1,
        ),
        Obligation(
          id: 3,
          title: 'Housing Loan EMI',
          type: ObligationType.emi,
          amount: 25000,
          startDate: now,
          priority: PriorityLevel.high,
          category: 'Home Loan',
          totalBalance: 2500000,
          interestRate: 8.5,
          isActive: true,
          status: ObligationStatus.pending,
          gracePeriodDays: 7,
          emiPaidMonths: 10,
          createdAt: now,
          updatedAt: now,
          displayOrder: 2,
        ),
      ];

      // Scenario 1: Only 15,000 emergency cash available
      // Tier 1 (Credit Card = 12,000) is covered.
      // Remaining 3,000 cannot cover Tier 2 (Personal Loan = 8,000) or Tier 3 (Home Loan = 25,000).
      final shieldPlan = financialLogic.calculateGraceShield(
        obligations: obligations,
        availableEmergencyCash: 15000.0,
      );

      expect(shieldPlan.coveredObligations.length, equals(1));
      expect(shieldPlan.coveredObligations.first.id, equals(1)); // Credit Card protected!
      expect(shieldPlan.deferredObligations.length, equals(2));

      // Personal loan gets 3-day grace
      final personalLoanDeferred = shieldPlan.deferredObligations.firstWhere((d) => d.obligation.id == 2);
      expect(personalLoanDeferred.safeBufferDays, equals(3));
      expect(personalLoanDeferred.defenseAction.contains('3-day window'), isTrue);

      // Home loan gets 7-day grace
      final homeLoanDeferred = shieldPlan.deferredObligations.firstWhere((d) => d.obligation.id == 3);
      expect(homeLoanDeferred.safeBufferDays, equals(7));
      expect(homeLoanDeferred.defenseAction.contains('7-day technical grace'), isTrue);

      // Since Credit card is covered, status is DEFENDED (CREDIT CARDS SHIELDED)
      expect(shieldPlan.securityStatus, equals('DEFENDED (CREDIT CARDS SHIELDED)'));
    });
  });
}

