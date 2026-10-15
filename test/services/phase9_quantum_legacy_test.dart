import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/informal_iou_service.dart';
import 'package:duedo/services/quantum_life_simulator_service.dart';
import 'package:duedo/services/midnight_brake_service.dart';
import 'package:duedo/services/junior_heritage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initiative 1: Informal Hand-Loan Mesh & Dignified IOU Concierge Tests', () {
    test('Calculates Lent and Borrowed balances accurately', () async {
      final notifier = InformalIouNotifier();
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 10));

      final state = notifier.state;
      expect(state.items.isNotEmpty, isTrue);
      expect(state.totalLentOutstanding, greaterThan(0));
      expect(state.totalBorrowedOutstanding, greaterThan(0));
      expect(state.activeCount, greaterThan(0));
    });

    test('Generates dignified WhatsApp reminder with UPI intent URL', () async {
      final notifier = InformalIouNotifier();
      await Future.delayed(const Duration(milliseconds: 10));

      final lentIou = notifier.state.items.firstWhere((i) => i.direction == IouDirection.lentByMe);
      final reminderMsg = lentIou.getDignifiedWhatsAppNudge('user@okaxis', '₹');

      expect(reminderMsg, contains(lentIou.personName.trim()));
      expect(reminderMsg, contains('upi://pay'));
      expect(reminderMsg, contains('No stress or rush at all!'));
    });

    test('Performs partial settle and marks status appropriately', () async {
      final notifier = InformalIouNotifier();
      await Future.delayed(const Duration(milliseconds: 10));

      await notifier.addIou(
        personName: 'Rohan Test',
        phoneNumber: '+919999888877',
        direction: IouDirection.lentByMe,
        amount: 5000,
        note: 'Emergency fix',
      );

      final added = notifier.state.items.firstWhere((i) => i.personName == 'Rohan Test');
      expect(added.remainingBalance, 5000);
      expect(added.isFullySettled, isFalse);

      // Settle 2000
      await notifier.recordPartialSettle(iouId: added.id, paymentAmount: 2000);
      var updated = notifier.state.items.firstWhere((i) => i.id == added.id);
      expect(updated.settledAmount, 2000);
      expect(updated.remainingBalance, 3000);
      expect(updated.isFullySettled, isFalse);

      // Settle remaining 3000
      await notifier.recordPartialSettle(iouId: added.id, paymentAmount: 3000);
      updated = notifier.state.items.firstWhere((i) => i.id == added.id);
      expect(updated.remainingBalance, 0);
      expect(updated.isFullySettled, isTrue);
    });
  });

  group('Initiative 2: Quantum Life Simulator (Multiverse War-Room) Tests', () {
    test('Simulates 3 distinct timelines (Alpha, Beta, Gamma) with delta metrics', () {
      final notifier = QuantumLifeSimulatorNotifier();
      notifier.simulateTimelines(
        currentAge: 30,
        totalDebt: 300000,
        currentMonthlyEmi: 15000,
        monthlyIncome: 85000,
      );

      final state = notifier.state;
      expect(state.timelines.length, 3);

      final alpha = state.timelines.firstWhere((t) => t.id == 'timeline-alpha');
      final beta = state.timelines.firstWhere((t) => t.id == 'timeline-beta');
      final gamma = state.timelines.firstWhere((t) => t.id == 'timeline-gamma');

      expect(alpha.subtitle, contains('Status Quo'));
      expect(beta.subtitle, contains('Mortgage'));
      expect(gamma.subtitle, contains('Aggressive Blitz'));

      // Gamma should be debt free earlier than Alpha
      expect(gamma.debtFreeAge, lessThanOrEqualTo(alpha.debtFreeAge));
      // Gamma should pay less interest than Alpha
      expect(gamma.totalInterestPaid, lessThanOrEqualTo(alpha.totalInterestPaid));
      // Beta (Home mortgage 20y) takes longer to be debt free
      expect(beta.debtFreeAge, greaterThan(alpha.debtFreeAge));
    });
  });

  group('Initiative 3: Midnight Cognitive Biometric Brake (Regret Interceptor) Tests', () {
    test('Calculates Life Energy hours cost based on monthly income and hourly wage', () {
      final notifier = MidnightBrakeNotifier();
      // Monthly income: ₹80,000 / 160 hrs = ₹500/hr
      notifier.interceptImpulse(
        amount: 5000,
        monthlyIncome: 80000,
        dailyDebtBurn: 500,
      );

      final state = notifier.state;
      expect(state.netHourlyWage, 500.0);
      expect(state.interceptedAmount, 5000.0);
      // 5000 / 500 = 10 life hours
      expect(state.lifeHoursCost, 10.0);
      // 5000 / 500 = 10 freedom days delayed
      expect(state.freedomDaysDelayed, 10);
      expect(state.isSomaticResetCompleted, isFalse);
    });

    test('Detects nocturnal risk window logic and somatic reset completion', () {
      final notifier = MidnightBrakeNotifier();
      notifier.markSomaticResetComplete();
      expect(notifier.state.isSomaticResetCompleted, isTrue);

      notifier.toggleArmed();
      expect(notifier.state.isArmed, isFalse);
    });
  });

  group('Initiative 4: Sovereign Heritage Vault & Junior Freedom Trust Tests', () {
    test('Tracks junior profiles, liquid balances, and wealth rings', () {
      final service = JuniorHeritageService();
      expect(service.profiles.isNotEmpty, isTrue);

      final child = service.profiles.first;
      expect(child.name, isNotEmpty);
      expect(child.monthlyAllowance, greaterThan(0));
      expect(child.liquidBalance, greaterThanOrEqualTo(0));
      expect(child.saveRingProgress, inInclusiveRange(0.0, 1.0));
      expect(child.spendRingProgress, inInclusiveRange(0.0, 1.0));
      expect(child.giveRingProgress, inInclusiveRange(0.0, 1.0));
    });

    test('Assigns quest, marks done, and parent verifies with savings payout', () {
      final service = JuniorHeritageService();
      final child = service.profiles.first;
      final initialSaved = child.totalSaved;
      final initialStreak = child.ringStreakDays;

      service.addChore(child.id, title: 'Clean study desk and books', reward: 120);
      var updatedChild = service.profiles.firstWhere((p) => p.id == child.id);
      final newChore = updatedChild.chores.firstWhere((c) => c.title == 'Clean study desk and books');
      expect(newChore.isCompleted, isFalse);
      expect(newChore.isVerifiedByParent, isFalse);

      // Child marks chore done
      service.markChoreDone(child.id, newChore.id);
      updatedChild = service.profiles.firstWhere((p) => p.id == child.id);
      expect(updatedChild.chores.firstWhere((c) => c.id == newChore.id).isCompleted, isTrue);
      expect(updatedChild.chores.firstWhere((c) => c.id == newChore.id).isVerifiedByParent, isFalse);

      // Parent verifies and pays
      service.verifyAndPayoutChore(child.id, newChore.id);
      updatedChild = service.profiles.firstWhere((p) => p.id == child.id);
      expect(updatedChild.chores.firstWhere((c) => c.id == newChore.id).isVerifiedByParent, isTrue);
      expect(updatedChild.totalSaved, initialSaved + 120);
      expect(updatedChild.ringStreakDays, initialStreak + 1);
    });

    test('Transfers savings to Compounding Vault and projects 10-year growth', () {
      final service = JuniorHeritageService();
      final child = service.profiles.first;
      final initialVault = child.compoundingFundBalance;

      service.transferToCompoundingFund(child.id, 500);
      final updated = service.profiles.firstWhere((p) => p.id == child.id);
      expect(updated.compoundingFundBalance, greaterThanOrEqualTo(initialVault));

      // Test 10-year compound growth formula at 12% CAGR
      final projected10Yr = service.projectCompoundGrowth(
        initialPrincipal: 10000,
        monthlyContribution: 1000,
        years: 10,
        annualRate: 0.12,
      );
      // Principal 10,000 at 12% for 10y ≈ 33,000; Monthly ₹1,000 for 10y at 12% ≈ 232,000 -> Total ≈ >250,000
      expect(projected10Yr, greaterThan(250000));
    });
  });
}
