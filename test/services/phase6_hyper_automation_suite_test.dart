import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/statement_parser_service.dart';
import 'package:duedo/services/document_scanner_service.dart';
import 'package:duedo/services/vampire_subscription_service.dart';
import 'package:duedo/services/windfall_allocator_service.dart';
import 'package:duedo/services/voice_slay_service.dart';
import 'package:duedo/services/quick_tile_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initiative 1: 1-Snap Document Scanner & Reconciliation', () {
    final parser = StatementParserService();
    final scanner = DocumentScannerService(parser);

    test('Parses bank sanction letter accurately', () {
      const rawText =
          'HDFC Bank Loan Sanction Letter: Sanction Amount ₹2,50,000 at 14.5% interest per annum. Monthly EMI ₹12,450 payable on 5th of every month. Tenure 24 months.';
      final parsed = scanner.scanAndParse(rawText);

      expect(parsed, isNotNull);
      expect(parsed!.title, contains('HDFC'));
      expect(parsed.totalBalance, 250000.0);
      expect(parsed.monthlyAmount, 12450.0);
      expect(parsed.interestRate, 14.5);
      expect(parsed.dueDayOfMonth, 5);
      expect(parsed.emiDurationMonths, 24);
    });

    test('Reconciles and matches existing obligation to avoid duplicates', () {
      const rawText = 'HDFC Bank Personal Loan: Sanction Amount ₹1,95,000 at 14.5% interest. EMI ₹12,450.';
      final parsed = scanner.scanAndParse(rawText)!;

      final existingObligations = [
        Obligation(
          id: 1,
          title: 'HDFC Bank Personal Loan',
          amount: 12450.0,
          totalBalance: 250000.0,
          interestRate: 14.5,
          category: 'EMI',
          type: ObligationType.emi,
          status: ObligationStatus.pending,
          startDate: DateTime(2025, 1, 1),
          isActive: true,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          displayOrder: 0,
          emiPaidMonths: 5,
          gracePeriodDays: 0,
          priority: PriorityLevel.high,
        ),
      ];

      final rec = scanner.reconcile(parsed, existingObligations);
      expect(rec.isUpdate, isTrue);
      expect(rec.matchedObligation, isNotNull);
      expect(rec.matchedObligation!.id, 1);
      expect(rec.previousBalance, 250000.0);
      expect(rec.newBalance, 195000.0);
    });

    test('Recommends new obligation when no existing match is found', () {
      const rawText = 'SBI Auto Loan: Sanction Amount ₹4,50,000 at 8.75% interest. Monthly EMI ₹15,200.';
      final parsed = scanner.scanAndParse(rawText)!;

      final rec = scanner.reconcile(parsed, []);
      expect(rec.isUpdate, isFalse);
      expect(rec.matchedObligation, isNull);
      expect(rec.newBalance, 450000.0);
    });
  });

  group('Initiative 2: Vampire Slasher Subscription Decapitation', () {
    final service = VampireSubscriptionService();

    final testObligations = [
      Obligation(
        id: 1,
        title: 'Netflix Premium 4K',
        amount: 999.0,
        totalBalance: 0.0,
        interestRate: 0.0,
        category: 'Entertainment',
        type: ObligationType.recurring,
        status: ObligationStatus.pending,
        startDate: DateTime(2025, 1, 1),
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        displayOrder: 0,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.low,
      ),
      Obligation(
        id: 2,
        title: 'Cult.fit Elite Gym Pass',
        amount: 2500.0,
        totalBalance: 0.0,
        interestRate: 0.0,
        category: 'Fitness',
        type: ObligationType.recurring,
        status: ObligationStatus.pending,
        startDate: DateTime(2025, 1, 1),
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        displayOrder: 1,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.medium,
      ),
      Obligation(
        id: 3,
        title: 'Home Rent',
        amount: 25000.0,
        totalBalance: 0.0,
        interestRate: 0.0,
        category: 'Rent',
        type: ObligationType.recurring,
        status: ObligationStatus.pending,
        startDate: DateTime(2025, 1, 1),
        isActive: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        displayOrder: 2,
        emiPaidMonths: 0,
        gracePeriodDays: 0,
        priority: PriorityLevel.high,
      ),
    ];

    test('Detects true subscription vampires and excludes essential rent', () {
      final vampires = service.detectVampires(testObligations);
      expect(vampires.length, 2);
      expect(vampires.any((v) => v.obligation.title == 'Home Rent'), isFalse);
      expect(vampires.any((v) => v.obligation.title.contains('Netflix')), isTrue);
      expect(vampires.any((v) => v.obligation.title.contains('Cult.fit')), isTrue);
    });

    test('Calculates 5-year compounded opportunity cost correctly at 12% benchmark', () {
      final cost = service.calculateFiveYearOpportunityCost(1000.0);
      // Monthly 1000 compounded at 12% over 5 years is ~82,486
      expect(cost, greaterThan(80000.0));
      expect(cost, lessThan(85000.0));
    });

    test('Generates preformatted formal cancellation email', () {
      final vampires = service.detectVampires(testObligations);
      final netflix = vampires.firstWhere((v) => v.obligation.title.contains('Netflix'));
      expect(netflix.cancellationEmailTemplate, contains('formal notice of immediate cancellation'));
      expect(netflix.cancellationEmailTemplate, contains('Netflix Premium 4K'));
    });
  });

  group('Initiative 3: Windfall Fortress Allocator Engine', () {
    final service = WindfallAllocatorService();

    final testDebts = [
      Obligation(
        id: 1,
        title: 'Credit Card',
        amount: 6000.0,
        totalBalance: 50000.0,
        interestRate: 42.0,
        category: 'Credit Card',
        type: ObligationType.emi,
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
        amount: 8000.0,
        totalBalance: 200000.0,
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

    test('Calculates 50/30/20 allocation accurately on ₹50,000 bonus', () {
      final plan = service.calculatePlan(
        windfallAmount: 50000.0,
        obligations: testDebts,
      );

      expect(plan.totalWindfall, 50000.0);
      expect(plan.strikeAmount, 25000.0); // 50%
      expect(plan.armorAmount, 15000.0);  // 30%
      expect(plan.joyAmount, 10000.0);    // 20%

      // Target debt should be the 42% APR Credit Card
      expect(plan.targetDebt, isNotNull);
      expect(plan.targetDebt!.title, 'Credit Card');
      expect(plan.interestSaved, greaterThan(10000.0));
      expect(plan.runwayDaysAdded, greaterThan(10));
    });
  });

  group('Initiative 4: Voice Slay NLP & Quick Tile Service', () {
    final service = VoiceSlayService();

    final testObligations = [
      Obligation(
        id: 1,
        title: 'HDFC Credit Card',
        amount: 5000.0,
        totalBalance: 30000.0,
        interestRate: 36.0,
        category: 'Credit Card',
        type: ObligationType.emi,
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
    ];

    test('Parses payment slay intent and matches target debt', () {
      final intent = service.parseVoiceCommand('Slayed 500 on HDFC Card', testObligations);
      expect(intent.type, VoiceIntentType.paymentSnowflake);
      expect(intent.amount, 500.0);
      expect(intent.matchedObligation, isNotNull);
      expect(intent.matchedObligation!.title, 'HDFC Credit Card');
    });

    test('Parses expense spent intent', () {
      final intent = service.parseVoiceCommand('Spent 350 on dinner', testObligations);
      expect(intent.type, VoiceIntentType.expenseSpent);
      expect(intent.amount, 350.0);
      expect(intent.target, contains('dinner'));
    });

    test('Parses impulse vaulting intent', () {
      final intent = service.parseVoiceCommand('Vault 4000 sneakers', testObligations);
      expect(intent.type, VoiceIntentType.vaultImpulse);
      expect(intent.amount, 4000.0);
      expect(intent.target, contains('sneakers'));
    });

    test('QuickTileService syncs and retrieves display text', () async {
      await QuickTileService.syncQuickTile(
        safeToSpend: 1450.0,
        streakDays: 12,
        currency: '₹',
      );

      final data = await QuickTileService.getQuickTileData();
      expect(data['title'], contains('1450'));
      expect(data['subtitle'], contains('12 Day Streak'));
    });
  });
}
