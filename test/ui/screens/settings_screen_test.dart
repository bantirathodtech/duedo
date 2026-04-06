import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duedo/ui/screens/settings_screen.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/vault_service.dart';
import 'package:duedo/viewmodels/home_viewmodel.dart';
import 'package:duedo/services/database.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}
class MockVaultService extends Mock implements VaultService {}
class MockHomeViewModel extends StateNotifier<HomeState> with Mock implements HomeViewModel {
  MockHomeViewModel() : super(HomeState(obligations: [], payments: []));
}

void main() {
  late MockObligationRepository mockRepository;
  late MockVaultService mockVaultService;

  setUpAll(() {
    registerFallbackValue(UserSettingsCompanion());
    registerFallbackValue(ObligationsCompanion());
  });

  setUp(() {
    mockRepository = MockObligationRepository();
    mockVaultService = MockVaultService();

    final settings = UserSetting(
      id: 1,
      monthlyIncome: 50000,
      currency: 'INR',
      notificationsEnabled: true,
      reminderDaysBefore: 3,
      paydayOfMonth: 1,
      projectionMonths: 1,
      themeMode: 'system',
      isPremium: false,
      paymentStreak: 0,
      smsSyncEnabled: false,
      lastPaymentDate: null,
    );

    when(() => mockRepository.getAllObligations()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getAllPaymentsStream()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getSettings()).thenAnswer((_) => Stream.value(settings));
    when(() => mockVaultService.isVaultEnabled()).thenAnswer((_) => Future.value(false));
    when(() => mockRepository.updateSettings(any())).thenAnswer((_) => Future.value(null));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        obligationRepositoryProvider.overrideWithValue(mockRepository),
        vaultServiceProvider.overrideWithValue(mockVaultService),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('should load initial settings and display income', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FINANCIAL PLANNER'), findsOneWidget);
    });

    testWidgets('should update settings correctly', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Monthly Net Income'), '75000');
      await tester.enterText(find.widgetWithText(TextField, 'Payday (Day of Month, 1-31)'), '5');
      
      await tester.tap(find.text('Save Financial Profile'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.updateSettings(any())).called(1);
    });

    testWidgets('should show error for invalid payday', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Payday (Day of Month, 1-31)'), '40');
      await tester.tap(find.text('Save Financial Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Payday must be between 1 and 31'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('should toggle biometric vault', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockVaultService.authenticate(reason: any(named: 'reason'))).thenAnswer((_) => Future.value(true));
      when(() => mockVaultService.setVaultEnabled(any())).thenAnswer((_) => Future.value(null));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final vaultSwitch = find.byType(Switch).first;
      await tester.tap(vaultSwitch, warnIfMissed: false);
      await tester.pumpAndSettle();

      verify(() => mockVaultService.authenticate(reason: any(named: 'reason'))).called(1);
      verify(() => mockVaultService.setVaultEnabled(true)).called(1);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
   group('CalendarScreen Tests', () {
    // Tests moved to separate file
  });
  });
}
