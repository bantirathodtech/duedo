import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/upi_payment_service.dart';
import 'package:duedo/services/debt_negotiation_service.dart';
import 'package:duedo/services/freedom_league_service.dart';
import 'package:duedo/services/glance_widget_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpiPaymentService Tests', () {
    test('buildUpiUri formats compliant NPCI string', () {
      final uri = UpiPaymentService.buildUpiUri(
        vpa: 'hdfcbank@hdfcbank',
        payeeName: 'HDFC Credit Card',
        amount: 500.0,
        transactionNote: 'Snowflake Strike',
      );

      expect(uri.startsWith('upi://pay?'), isTrue);
      expect(uri.contains('pa=hdfcbank@hdfcbank'), isTrue);
      expect(uri.contains('am=500.00'), isTrue);
      expect(uri.contains('cu=INR'), isTrue);
      expect(uri.contains('pn=HDFC%20Credit%20Card'), isTrue);
    });

    test('inferVpa maps known Indian bank billers accurately', () {
      final hdfcVpa = UpiPaymentService.inferVpa('HDFC Regalia Card', 'Credit Card');
      expect(hdfcVpa, equals('hdfcbank@hdfcbank'));

      final sbiVpa = UpiPaymentService.inferVpa('SBI SimplyClick', 'Credit Card');
      expect(sbiVpa, equals('sbi.cards@sbi'));

      final iciciVpa = UpiPaymentService.inferVpa('ICICI Amazon Pay', 'Credit Card');
      expect(iciciVpa, equals('icici.cards@icici'));

      final genericVpa = UpiPaymentService.inferVpa('Local Grocery Bill', 'Personal');
      expect(genericVpa, equals('payee@upi'));
    });
  });

  group('DebtNegotiationService Tests', () {
    final now = DateTime.now();
    final testDebt = Obligation(
      id: 1,
      title: 'HDFC Millennia Credit Card',
      type: ObligationType.emi,
      amount: 12000,
      startDate: now,
      priority: PriorityLevel.high,
      category: 'Credit Card',
      totalBalance: 65000,
      interestRate: 42.0,
      isActive: true,
      status: ObligationStatus.pending,
      gracePeriodDays: 0,
      emiPaidMonths: 6,
      createdAt: now,
      updatedAt: now,
      displayOrder: 0,
    );

    test('generates all 4 RBI-compliant legal negotiation scripts', () {
      final scripts = DebtNegotiationService.generateScripts(
        obligation: testDebt,
        paymentStreak: 8,
        accountSuffix: '4210',
      );

      expect(scripts.length, equals(4));

      // 1. APR Reduction
      final aprScript = scripts.firstWhere((s) => s.type == NegotiationType.aprReduction);
      expect(aprScript.rbiReference.contains('Credit Card'), isTrue);
      expect(aprScript.teleprompterScript.contains('42.0%'), isTrue);
      expect(aprScript.teleprompterScript.contains('8 consecutive billing cycles'), isTrue);
      expect(aprScript.customerCareNumber, equals('18002026161'));

      // 2. Fee Waiver
      final feeScript = scripts.firstWhere((s) => s.type == NegotiationType.feeWaiver);
      expect(feeScript.teleprompterScript.contains('courtesy basis'), isTrue);

      // 3. Foreclosure Penalty Waiver
      final foreclosureScript = scripts.firstWhere((s) => s.type == NegotiationType.foreclosureWaiver);
      expect(foreclosureScript.rbiReference.contains('DBOD.No.Dir.BC.107'), isTrue);
      expect(foreclosureScript.teleprompterScript.contains('zero foreclosure charges'), isTrue);

      // 4. Grace Period Buffer
      final graceScript = scripts.firstWhere((s) => s.type == NegotiationType.graceBuffer);
      expect(graceScript.rbiReference.contains('IRAC'), isTrue);
      expect(graceScript.teleprompterScript.contains('7-day grace memorandum'), isTrue);
    });
  });

  group('FreedomLeagueService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'duedo_league_points': 1400,
        'duedo_league_tier': LeagueTier.silver.index,
      });
    });

    test('initializes with saved points, cohort, and correct rank', () async {
      final notifier = FreedomLeagueNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.userPoints, equals(1400));
      expect(notifier.state.currentTier, equals(LeagueTier.silver));
      expect(notifier.state.cohort.isNotEmpty, isTrue);
      expect(notifier.state.cohort.any((m) => m.isUser), isTrue);
      expect(notifier.state.userRank, greaterThan(0));
    });

    test('awardPoints promotes tier and updates cohort standings', () async {
      final notifier = FreedomLeagueNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      // Award 200 points (1400 + 200 = 1600 -> promotes to Gold League >= 1500 pts)
      await notifier.awardPoints(200);

      expect(notifier.state.userPoints, equals(1600));
      expect(notifier.state.currentTier, equals(LeagueTier.gold));
      expect(notifier.state.cohort.firstWhere((m) => m.isUser).points, equals(1600));
    });
  });

  group('GlanceWidgetService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('syncGlanceData and getGlanceData persist and retrieve lock-screen state', () async {
      await GlanceWidgetService.syncGlanceData(
        safeToSpend: 1540.50,
        cleanDay: true,
        streak: 9,
        ringsClosed: true,
      );

      final glance = await GlanceWidgetService.getGlanceData();
      expect(glance.safeToSpendAmount, equals(1540.50));
      expect(glance.cleanDayCompleted, isTrue);
      expect(glance.streakDays, equals(9));
      expect(glance.ringsClosed, isTrue);
      expect(glance.lastUpdated, isNotNull);
    });
  });
}
