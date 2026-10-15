import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duedo/services/freedom_pact_service.dart';
import 'package:duedo/services/execudo_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FreedomPactNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with a generated PACT code and unpaired status', () async {
      final notifier = FreedomPactNotifier();
      // Wait for async _init
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.myPactCode.startsWith('PACT-'), isTrue);
      expect(notifier.state.isPaired, isFalse);
      expect(notifier.state.partnerCode, isNull);
    });

    test('rejects pairing with own code or empty code', () async {
      final notifier = FreedomPactNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final emptyResult = await notifier.pairWithCode('');
      expect(emptyResult, isFalse);

      final ownResult = await notifier.pairWithCode(notifier.state.myPactCode);
      expect(ownResult, isFalse);
      expect(notifier.state.isPaired, isFalse);
    });

    test('pairs successfully with partner code and stores state', () async {
      final notifier = FreedomPactNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      final success = await notifier.pairWithCode('PACT-998877', name: 'Alex');
      expect(success, isTrue);
      expect(notifier.state.isPaired, isTrue);
      expect(notifier.state.partnerCode, equals('PACT-998877'));
      expect(notifier.state.partnerName, equals('Alex'));
      expect(notifier.state.partnerTotalDebt, greaterThan(0));
      expect(notifier.state.partnerSnowflakesSaved, greaterThan(0));
      expect(notifier.state.lastSyncedAt, isNotNull);
    });

    test('syncNow refreshes lastSyncedAt for paired pact', () async {
      final notifier = FreedomPactNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.pairWithCode('PACT-123456');

      final before = notifier.state.lastSyncedAt;
      await Future.delayed(const Duration(milliseconds: 10));
      await notifier.syncNow();

      expect(notifier.state.lastSyncedAt, isNotNull);
      expect(notifier.state.lastSyncedAt!.millisecondsSinceEpoch >= before!.millisecondsSinceEpoch, isTrue);
      expect(notifier.state.isSyncing, isFalse);
    });

    test('unlinkPact resets pairing status', () async {
      final notifier = FreedomPactNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.pairWithCode('PACT-555555');
      expect(notifier.state.isPaired, isTrue);

      await notifier.unlinkPact();
      expect(notifier.state.isPaired, isFalse);
      expect(notifier.state.partnerCode, isNull);
      expect(notifier.state.partnerTotalDebt, equals(0.0));
    });
  });

  group('ExecudoBridgeNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes as disconnected by default', () async {
      final notifier = ExecudoBridgeNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isConnected, isFalse);
      expect(notifier.state.deepFocusStreakDays, equals(14));
      expect(notifier.state.impulseSavingsGenerated, greaterThan(0));
    });

    test('setConnected updates state and persists connection', () async {
      final notifier = ExecudoBridgeNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.setConnected(true);
      expect(notifier.state.isConnected, isTrue);
      expect(notifier.state.lastSyncTime, isNotNull);

      await notifier.setConnected(false);
      expect(notifier.state.isConnected, isFalse);
    });
  });
}
