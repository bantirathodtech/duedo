import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/leech_hunter_service.dart';
import 'package:duedo/services/household_syndicate_service.dart';
import 'package:duedo/services/black_swan_crisis_service.dart';
import 'package:duedo/services/wealth_inversion_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initiative 1: Predatory Fee & Hidden Leech Hunter Tests', () {
    test('Detects annual card fee, GST, and late payment fees from statement excerpt', () async {
      final notifier = LeechHunterNotifier();
      const statement = '''
HDFC Bank Statement - Card ending 4091
Transaction Details:
Annual Membership Fee: ₹999.00
GST @ 18%: ₹179.82
Late Payment Penalty: ₹750.00
Payment Received - Thank You: ₹15,000
''';

      final detected = await notifier.scanStatementText(
        statement,
        lender: 'HDFC Bank',
        last4: '4091',
        dailyDebtBurn: 400.0,
      );

      expect(detected.length, greaterThanOrEqualTo(3));
      final annualFee = detected.firstWhere((e) => e.feeType == LeechFeeType.annualFee);
      expect(annualFee.amount, 999.0);
      expect(annualFee.daysOfFreedomDestroyed, (999.0 / 400.0).round());

      final gstFee = detected.firstWhere((e) => e.feeType == LeechFeeType.gstOnInterest);
      expect(gstFee.amount, 179.82);

      final lateFee = detected.firstWhere((e) => e.feeType == LeechFeeType.latePaymentPenalty);
      expect(lateFee.amount, 750.0);
    });

    test('Audits amortization discrepancy between reported balance and theoretical balance', () async {
      final notifier = LeechHunterNotifier();
      // Reported balance is ₹1,550 higher than theoretical amortization
      final item = await notifier.auditAmortizationDiscrepancy(
        lender: 'Axis Bank',
        last4: '5512',
        reportedBalance: 151550.0,
        theoreticalExpectedBalance: 150000.0,
        dailyDebtBurn: 500.0,
      );

      expect(item, isNotNull);
      expect(item!.amount, 1550.0);
      expect(item.feeType, LeechFeeType.financeCharge);
      expect(item.daysOfFreedomDestroyed, (1550.0 / 500.0).round());
      expect(item.disputeLetter, contains('Axis Bank'));
      expect(item.disputeLetter, contains('RBI/2023-24/53'));
    });

    test('Generates RBI-compliant dispute letter with relevant legal mandates', () {
      final item = LeechChargeItem(
        id: 'test-1',
        lender: 'ICICI Bank',
        accountOrCardLast4: '9982',
        feeType: LeechFeeType.annualFee,
        amount: 590.0,
        detectedDate: DateTime.now(),
        status: LeechStatus.detected,
        daysOfFreedomDestroyed: 2,
        disputeLetter: '',
      );

      final letter = item.feeLabel;
      expect(letter, contains('Annual Card'));
    });

    test('Marking fee waived increments recovered amount and removes destroyed days', () async {
      final notifier = LeechHunterNotifier();
      final initialWaived = notifier.state.totalRecoveredAmount;

      if (notifier.state.leeches.isNotEmpty) {
        final firstId = notifier.state.leeches.first.id;
        final feeAmount = notifier.state.leeches.first.amount;

        await notifier.markStatus(firstId, LeechStatus.waived);
        expect(notifier.state.totalRecoveredAmount, initialWaived + feeAmount);
      }
    });
  });

  group('Initiative 2: Household Syndicate & Stealth Split Tests', () {
    test('Initializes with default syndicate code', () {
      final notifier = HouseholdSyndicateNotifier();
      expect(notifier.state.syndicateCode, startsWith('DUEDO-SYN-'));
      expect(notifier.state.isConnected, isFalse);
    });

    test('Rejects pairing with own code or empty code', () async {
      final notifier = HouseholdSyndicateNotifier();
      final okSame = await notifier.pairWithPartner(
        partnerCode: notifier.state.syndicateCode,
        partnerName: 'Priya',
      );
      expect(okSame, isFalse);

      final okEmpty = await notifier.pairWithPartner(
        partnerCode: '   ',
        partnerName: 'Priya',
      );
      expect(okEmpty, isFalse);
    });

    test('Pairs with partner code and tracks stealth split contributions', () async {
      final notifier = HouseholdSyndicateNotifier();
      final ok = await notifier.pairWithPartner(
        partnerCode: 'DUEDO-SYN-9999',
        partnerName: 'Priya',
        jointTarget: 'HDFC Home Loan',
        targetAmount: 300000.0,
      );

      expect(ok, isTrue);
      expect(notifier.state.isConnected, isTrue);
      expect(notifier.state.partnerName, 'Priya');
      expect(notifier.state.jointTargetTitle, 'HDFC Home Loan');
      expect(notifier.state.jointTargetAmount, 300000.0);
      expect(notifier.state.totalCombinedStrikes, greaterThan(0));

      // Record joint strike
      final prevDays = notifier.state.collectiveFreedomDaysSaved;
      await notifier.recordJointStrike(amount: 2000.0, isUserStrike: true, dailyDebtBurn: 400.0);

      expect(notifier.state.collectiveFreedomDaysSaved, prevDays + 5);
      expect(notifier.state.progressRatio, greaterThan(0));
    });

    test('Toggle weekly clean activates duo-streak multiplier', () async {
      final notifier = HouseholdSyndicateNotifier();
      await notifier.pairWithPartner(
        partnerCode: 'DUEDO-SYN-3344',
        partnerName: 'Rohan',
      );

      expect(notifier.state.leagueMultiplier, 2.0);
      expect(notifier.state.bothCleanThisWeek, isTrue);

      // Toggling user clean off reduces multiplier to 1.0
      await notifier.toggleWeeklyClean(isUser: true);
      expect(notifier.state.userCleanThisWeek, isFalse);
      expect(notifier.state.leagueMultiplier, 1.0);

      // Toggling back on restores 2.0 multiplier and increases streak
      final prevStreak = notifier.state.duoStreakWeeks;
      await notifier.toggleWeeklyClean(isUser: true);
      expect(notifier.state.userCleanThisWeek, isTrue);
      expect(notifier.state.leagueMultiplier, 2.0);
      expect(notifier.state.duoStreakWeeks, greaterThanOrEqualTo(prevStreak));
    });
  });

  group('Initiative 3: Black Swan Crisis Defibrillator Tests', () {
    test('Declares crisis, freezes aggressive targets and calculates survival runway', () async {
      final notifier = BlackSwanCrisisNotifier();
      await notifier.declareCrisis(
        reason: CrisisReason.medicalEmergency,
        monthlySurvivalBudget: 15000.0,
        liquidBuffer: 60000.0,
        minimumEmi: 5000.0,
        pausedSnowflakes: 8000.0,
      );

      expect(notifier.state.isCrisisActive, isTrue);
      expect(notifier.state.reason, CrisisReason.medicalEmergency);
      expect(notifier.state.reasonLabel, 'Medical Emergency');
      expect(notifier.state.monthlyTriageBurn, 20000.0);

      // Daily burn = 20,000 / 30 = ~666.67. 60,000 / 666.67 = 90 days
      expect(notifier.state.runwayDaysRemaining, 90);
    });

    test('Generates formal RBI hardship moratorium letter', () {
      final notifier = BlackSwanCrisisNotifier();
      final letter = notifier.generateMoratoriumLetter(
        bankName: 'SBI Cards',
        loanAccountNumber: 'SBI-CC-8821',
        borrowerName: 'Amit Sharma',
        requestedMonths: 3,
      );

      expect(letter, contains('SBI Cards'));
      expect(letter, contains('SBI-CC-8821'));
      expect(letter, contains('Amit Sharma'));
      expect(letter, contains('moratorium of 3 months'));
      expect(letter, contains('Reserve Bank of India (RBI)'));
      expect(notifier.state.moratoriumLetterDrafted, isTrue);
    });

    test('Resolves crisis and deactivates defibrillator', () async {
      final notifier = BlackSwanCrisisNotifier();
      await notifier.resolveCrisis();

      expect(notifier.state.isCrisisActive, isFalse);
      expect(notifier.state.moratoriumLetterDrafted, isFalse);
    });
  });

  group('Initiative 4: Wealth Inversion Flywheel Tests', () {
    test('Calculates monthly SIP compound future value accurately', () {
      // 25,000/mo at 12% for 5 years
      final fv5 = WealthInversionNotifier.calculateSipFutureValue(25000.0, 12.0, 5);
      // Theoretical ~ ₹20,62,159
      expect(fv5, greaterThan(2000000));
      expect(fv5, lessThan(2150000));

      // 10 years at 12%: theoretical ~ ₹58,08,477
      final fv10 = WealthInversionNotifier.calculateSipFutureValue(25000.0, 12.0, 10);
      expect(fv10, greaterThan(5700000));
      expect(fv10, lessThan(5900000));
    });

    test('Activates inversion mode and partitions previous monthly EMI', () async {
      final notifier = WealthInversionNotifier();
      await notifier.activateInversion(monthlyEmi: 30000.0);

      expect(notifier.state.isInversionActive, isTrue);
      expect(notifier.state.previousMonthlyEmiRedirected, 30000.0);
      expect(notifier.state.buckets.length, 3);

      final indexBucket = notifier.state.buckets.firstWhere((b) => b.id == 'nifty-50');
      expect(indexBucket.percentageShare, 50.0);
      expect(indexBucket.allocatedMonthly, 15000.0); // 50% of 30,000
    });

    test('Logs wealth strike and accumulates sovereign wealth', () async {
      final notifier = WealthInversionNotifier();
      await notifier.activateInversion(monthlyEmi: 25000.0);
      final initialTotal = notifier.state.totalWealthAccumulated;

      await notifier.logWealthStrike(bucketId: 'nifty-50', amount: 5000.0);

      expect(notifier.state.totalWealthAccumulated, initialTotal + 5000.0);
      final indexBucket = notifier.state.buckets.firstWhere((b) => b.id == 'nifty-50');
      expect(indexBucket.accumulatedTotal, greaterThanOrEqualTo(5000.0));
    });
  });
}
