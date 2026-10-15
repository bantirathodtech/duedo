import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/streak_armor_service.dart';
import 'package:duedo/services/slain_debt_trophy_service.dart';
import 'package:duedo/services/financial_logic_service.dart';
import 'package:duedo/services/daily_rings_service.dart';
import 'package:duedo/services/freedom_league_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initiative 1: Streak Armor & Relapse Rescue Protocol', () {
    test('Initial state banks 1 shield by default', () {
      final notifier = StreakArmorNotifier();
      expect(notifier.state.shieldsBanked, 1);
      expect(notifier.state.isArmorDeployed, isFalse);
    });

    test('Auto-deploys armor on rollover gap and preserves streak', () async {
      final notifier = StreakArmorNotifier();
      final deployed = await notifier.checkAndDeployArmor(daysSinceActive: 2);
      expect(deployed, isTrue);
      expect(notifier.state.isArmorDeployed, isTrue);
      expect(notifier.state.shieldsBanked, 0);
      expect(notifier.state.lastDeployedReason, contains('2-day gap'));

      // If no shields left, cannot deploy again
      final secondDeploy = await notifier.checkAndDeployArmor(daysSinceActive: 3);
      expect(secondDeploy, isFalse);
    });

    test('Completing Relapse Rescue Quest recharges shield and clears armor deployment', () async {
      final notifier = StreakArmorNotifier();
      await notifier.checkAndDeployArmor(daysSinceActive: 2);
      expect(notifier.state.isArmorDeployed, isTrue);

      await notifier.completeRescueQuest();
      expect(notifier.state.isArmorDeployed, isFalse);
      expect(notifier.state.shieldsBanked, 1);
      expect(notifier.state.lastDeployedReason, isNull);
    });

    test('14 clean days milestone earns a shield up to max 2', () async {
      final notifier = StreakArmorNotifier();
      expect(notifier.state.shieldsBanked, 1);

      await notifier.onCleanDayRecorded(14);
      expect(notifier.state.shieldsBanked, 2);

      // Capped at 2
      await notifier.onCleanDayRecorded(28);
      expect(notifier.state.shieldsBanked, 2);
    });
  });

  group('Initiative 2: Debt Cremation Ceremony & Permanent Trophy Case', () {
    test('Registers slain debt with correct tier and interest destroyed', () async {
      final notifier = SlainDebtTrophyNotifier();

      final highValueDebt = Obligation(
        id: 101,
        title: 'HDFC Personal Loan',
        amount: 15000.0,
        totalBalance: 250000.0,
        interestRate: 14.5,
        category: 'Personal Loan',
        type: ObligationType.emi,
        status: ObligationStatus.paid,
        startDate: DateTime(2025, 1, 1),
        isActive: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime.now(),
        displayOrder: 0,
        emiPaidMonths: 24,
        gracePeriodDays: 0,
        priority: PriorityLevel.high,
      );

      final trophy = await notifier.registerSlainDebt(highValueDebt);
      expect(trophy.title, 'HDFC Personal Loan');
      expect(trophy.totalBalancePaid, 250000.0);
      expect(trophy.medalTier, 'Diamond');
      expect(trophy.totalInterestDestroyed, greaterThan(0.0));

      expect(notifier.state.length, 1);
      expect(notifier.state.first.obligationId, 101);
    });

    test('Silver and Gold medal tier thresholds are accurate', () async {
      final notifier = SlainDebtTrophyNotifier();

      final midDebt = Obligation(
        id: 102,
        title: 'Credit Card Balance',
        amount: 5000.0,
        totalBalance: 75000.0,
        interestRate: 36.0,
        category: 'Credit Card',
        type: ObligationType.oneTime,
        status: ObligationStatus.paid,
        startDate: DateTime(2025, 1, 1),
        isActive: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime.now(),
        displayOrder: 1,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.high,
      );

      final midTrophy = await notifier.registerSlainDebt(midDebt);
      expect(midTrophy.medalTier, 'Gold');

      final smallDebt = Obligation(
        id: 103,
        title: 'Phone EMI',
        amount: 2000.0,
        totalBalance: 20000.0,
        interestRate: 0.0,
        category: 'Electronics',
        type: ObligationType.emi,
        status: ObligationStatus.paid,
        startDate: DateTime(2025, 1, 1),
        isActive: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime.now(),
        displayOrder: 2,
        emiPaidMonths: 6,
        gracePeriodDays: 0,
        priority: PriorityLevel.medium,
      );

      final smallTrophy = await notifier.registerSlainDebt(smallDebt);
      expect(smallTrophy.medalTier, 'Silver');
    });
  });

  group('Initiative 3: Freedom Time Machine Simulation Engine', () {
    final engine = FinancialLogicService();

    final testObligations = <Obligation>[
      Obligation(
        id: 1,
        title: 'Credit Card',
        amount: 5000.0,
        totalBalance: 20000.0, // 4 months to payoff
        interestRate: 40.0,
        category: 'Credit Card',
        type: ObligationType.oneTime,
        status: ObligationStatus.pending,
        startDate: DateTime(2026, 1, 1),
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        displayOrder: 0,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.high,
      ),
      Obligation(
        id: 2,
        title: 'Car Loan',
        amount: 10000.0,
        totalBalance: 120000.0, // 12 months to payoff
        interestRate: 9.0,
        category: 'Auto Loan',
        type: ObligationType.emi,
        status: ObligationStatus.pending,
        startDate: DateTime(2026, 1, 1),
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        displayOrder: 1,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.medium,
      ),
    ];

    test('Month 0: Both debts remaining, 0 cashflow unlocked, Defense mode active', () {
      final snap = engine.calculateTimeMachineSnapshot(
        obligations: testObligations,
        monthlyIncome: 60000.0,
        monthOffset: 0,
      );

      expect(snap.monthOffset, 0);
      expect(snap.remainingDebtBalance, 140000.0);
      expect(snap.unlockedMonthlyCashflow, 0.0);
      expect(snap.slainDebts, isEmpty);
      expect(snap.remainingDebts.length, 2);
      expect(snap.isDebtFree, isFalse);
    });

    test('Month 4: Credit card incinerated, +5,000 cashflow unlocked', () {
      final snap = engine.calculateTimeMachineSnapshot(
        obligations: testObligations,
        monthlyIncome: 60000.0,
        monthOffset: 4,
      );

      expect(snap.slainDebts.length, 1);
      expect(snap.slainDebts.first.title, 'Credit Card');
      expect(snap.unlockedMonthlyCashflow, 5000.0);
      expect(snap.remainingDebts.length, 1);
      expect(snap.remainingDebts.first.title, 'Car Loan');
      expect(snap.isDebtFree, isFalse);
    });

    test('Month 12: DEBT ZERO REACHED - Offense Mode activated', () {
      final snap = engine.calculateTimeMachineSnapshot(
        obligations: testObligations,
        monthlyIncome: 60000.0,
        monthOffset: 12,
      );

      expect(snap.slainDebts.length, 2);
      expect(snap.remainingDebts, isEmpty);
      expect(snap.unlockedMonthlyCashflow, 15000.0);
      expect(snap.remainingDebtBalance, 0.0);
      expect(snap.isDebtFree, isTrue);
      expect(snap.progressPercentage, 1.0);
    });
  });

  group('Initiative 4: Interactive Lock-Screen Rich Notification Actions', () {
    test('markCleanDayFromNotification updates rings state and streak', () async {
      await DailyRingsNotifier.markCleanDayFromNotification();

      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('duedo_daily_rings_state_v1');
      expect(jsonStr, isNotNull);
      expect(jsonStr, contains('"cleanDayCompleted":true'));
    });

    test('awardPointsFromNotification increments league score', () async {
      await FreedomLeagueNotifier.awardPointsFromNotification(50);

      final prefs = await SharedPreferences.getInstance();
      final points = prefs.getInt('duedo_league_points');
      expect(points, 1850 + 50);
    });
  });
}
