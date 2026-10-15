import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/bureau_arbitrage_service.dart';
import 'package:duedo/services/freedom_wrapped_service.dart';
import 'package:duedo/services/banker_combat_service.dart';
import 'package:duedo/services/sovereign_vault_service.dart';
import 'package:duedo/services/upi_payment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initiative 1: Bureau Strike Clock & Utilization Arbitrage Tests', () {
    test('Calculates current card utilization and sweet spot strike accurately', () {
      const card = CreditCardBureauWindow(
        cardId: 'card-1',
        cardTitle: 'HDFC Regalia',
        lender: 'HDFC Bank',
        creditLimit: 100000.0,
        currentBalance: 48000.0, // 48% utilization
        statementCutoffDayOfMonth: 20,
        targetOptimalUtilizationPct: 7.0,
      );

      expect(card.currentUtilizationPct, 48.0);
      expect(card.targetReportedBalance, closeTo(7000.0, 0.01)); // 7% of 100k
      expect(card.recommendedArbitrageStrikeAmount, 41000.0); // 48k - 7k = 41k
      expect(card.estimatedScoreBoostPoints, 20); // between 30% and 50%
    });

    test('Records arbitrage strike and reduces balance', () async {
      final notifier = BureauArbitrageNotifier();
      final initialRecommended = notifier.state.totalArbitrageStrikesRecommended;

      if (notifier.state.cards.isNotEmpty) {
        final card = notifier.state.cards.first;
        final initialBal = card.currentBalance;

        await notifier.recordArbitrageSlay(cardId: card.cardId, strikeAmount: 5000.0);

        final updatedCard = notifier.state.cards.firstWhere((c) => c.cardId == card.cardId);
        expect(updatedCard.currentBalance, initialBal - 5000.0);
        expect(notifier.state.totalArbitrageStrikesRecommended, lessThanOrEqualTo(initialRecommended));
      }
    });

    test('Resolves default biller VPA for Indian lenders', () {
      expect(UpiPaymentService.getVpaForLender('HDFC Bank'), contains('hdfcbank'));
      expect(UpiPaymentService.getVpaForLender('ICICI Amazon Pay'), contains('icici'));
      expect(UpiPaymentService.getVpaForLender('SBI Card'), contains('sbi'));
    });
  });

  group('Initiative 2: Freedom Wrapped & Annual Slaying Autopsy Tests', () {
    test('Compiles annual wrapped report with warrior archetype', () {
      const report = FreedomWrappedReport(
        year: 2026,
        warriorArchetype: 'The Debt Guillotine',
        warriorBadge: '🔥',
        totalDebtSlain: 412000.0,
        interestDestroyed: 84200.0,
        impulseCravingsResistedCount: 38,
        impulseMoneyShielded: 64000.0,
        cleanDaysCompleted: 214,
        freedomDaysRestored: 214,
        leagueRankTier: 'Diamond Sovereign',
      );

      expect(report.year, 2026);
      expect(report.warriorArchetype, 'The Debt Guillotine');
      expect(report.totalDebtSlain, 412000.0);

      final caption = report.getViralShareCaption('₹');
      expect(caption, contains('MY 2026 DEBT FREEDOM AUTOPSY'));
      expect(caption, contains('The Debt Guillotine'));
      expect(caption, contains('₹4,12,000'));
      expect(caption, contains('₹84,200'));
      expect(caption, contains('#Duedo'));
    });
  });

  group('Initiative 3: Banker Combat Negotiation Simulator Tests', () {
    test('Contains pre-built high-stakes combat scenarios', () {
      final notifier = BankerCombatNotifier();
      expect(notifier.scenarios.length, greaterThanOrEqualTo(3));

      final harassmentScenario = notifier.scenarios.firstWhere((s) => s.id == 'recovery-harassment');
      expect(harassmentScenario.opponentName, 'Vikram');
      expect(harassmentScenario.options.length, greaterThanOrEqualTo(2));
    });

    test('Executes hardball counter option: awards score and advances mastery', () async {
      final notifier = BankerCombatNotifier();
      final initialScore = notifier.state.totalCombatScore;
      final scenario = notifier.scenarios.first;
      final hardballOpt = scenario.options.firstWhere((o) => o.isHardballCounter);

      await notifier.executeDialogueOption(
        scenarioId: scenario.id,
        option: hardballOpt,
      );

      expect(notifier.state.totalCombatScore, initialScore + hardballOpt.scoreDelta);
      expect(notifier.state.lastSelectedOption, hardballOpt);
      expect(notifier.state.lastSelectedOption!.isHardballCounter, isTrue);
      expect(notifier.state.lastSelectedOption!.rbiLegalCitation, contains('RBI'));
    });

    test('Penalizes timid surrender options', () async {
      final notifier = BankerCombatNotifier();
      final initialScore = notifier.state.totalCombatScore;
      final scenario = notifier.scenarios.first;
      final timidOpt = scenario.options.firstWhere((o) => !o.isHardballCounter);

      await notifier.executeDialogueOption(
        scenarioId: scenario.id,
        option: timidOpt,
      );

      expect(notifier.state.totalCombatScore, lessThanOrEqualTo(initialScore));
    });
  });

  group('Initiative 4: Sovereign Vault & Panic Decoy Shield Tests', () {
    test('Decoy PIN activates sanitized panic decoy mode', () async {
      final notifier = SovereignVaultNotifier();
      await notifier.setPrimaryPin('1234');
      await notifier.setDecoyPin('9999');

      // Enter Decoy PIN
      final isPrimary = notifier.verifyPin('9999');
      expect(isPrimary, isFalse);
      expect(notifier.state.isDecoyModeActive, isTrue);

      // Enter Primary PIN restores real mode
      final isPrimaryRestored = notifier.verifyPin('1234');
      expect(isPrimaryRestored, isTrue);
      expect(notifier.state.isDecoyModeActive, isFalse);
    });

    test('Exports zero-knowledge encrypted vault backup with SHA-256 integrity hash', () {
      final notifier = SovereignVaultNotifier();
      final sampleData = {
        'income': 85000.0,
        'obligations': ['loan-1', 'card-2'],
      };

      final bundleJson = notifier.exportZeroKnowledgeVault(sampleData);
      expect(bundleJson, contains('DUEDO_SOVEREIGN_VAULT_V1'));

      final Map<String, dynamic> parsed = jsonDecode(bundleJson);
      expect(parsed['sha256'], isNotEmpty);
      expect(parsed['payload'], isNotEmpty);
      expect(parsed['mnemonicCount'], 12);
    });

    test('Generates cryptographic SHA-256 Freedom Certificate', () {
      final notifier = SovereignVaultNotifier();
      final hash = notifier.generateFreedomCertificate(
        userName: 'Sovereign Warrior',
        totalDebtCleared: 450000.0,
        daysWon: 280,
      );

      expect(hash.length, 64); // Standard SHA-256 hex length
      expect(notifier.state.freedomCertificateHash, hash);
    });
  });
}
