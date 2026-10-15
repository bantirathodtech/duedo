import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duedo/main.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/milestone_service.dart';
import 'package:duedo/services/notification_service.dart';
import 'package:duedo/services/vault_service.dart';
import 'package:duedo/services/sms_sync_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}
class MockMilestoneService extends Mock implements MilestoneService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockVaultService extends Mock implements VaultService {}
class MockSmsSyncService extends Mock implements SmsSyncService {}
class MockSupabaseService extends Mock implements SupabaseService {}
class FakeUserSettingsCompanion extends Fake implements UserSettingsCompanion {}

void main() {
  setUpAll(() {
    registerFallbackValue(MilestoneType.debtDestroyer);
    registerFallbackValue(FakeUserSettingsCompanion());
  });

  late MockObligationRepository mockRepository;
  late MockMilestoneService mockMilestoneService;
  late MockNotificationService mockNotificationService;
  late MockVaultService mockVaultService;
  late MockSmsSyncService mockSmsSyncService;
  late MockSupabaseService mockSupabaseService;

  setUpAll(() {
    registerFallbackValue(MilestoneType.debtDestroyer);
    registerFallbackValue(FakeUserSettingsCompanion());
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockRepository = MockObligationRepository();
    mockMilestoneService = MockMilestoneService();
    mockNotificationService = MockNotificationService();
    mockVaultService = MockVaultService();
    mockSmsSyncService = MockSmsSyncService();
    mockSupabaseService = MockSupabaseService();

    const defaultSettings = UserSetting(
      id: 1,
      monthlyIncome: 5000.0,
      currency: 'USD',
      notificationsEnabled: true,
      reminderDaysBefore: 1,
      paydayOfMonth: 1,
      projectionMonths: 1,
      themeMode: 'system',
      isPremium: true,
      paymentStreak: 0,
      smsSyncEnabled: false,
      isSavageMode: false,
    );

    when(() => mockRepository.init()).thenAnswer((_) => Future.value());
    when(() => mockRepository.getAllObligations()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getAllPaymentsStream()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getSettings()).thenAnswer((_) => Stream.value(defaultSettings));
    when(() => mockRepository.updateSettings(any())).thenAnswer((_) => Future.value());
    
    when(() => mockMilestoneService.getMilestones()).thenAnswer((_) => Future.value([]));
    when(() => mockMilestoneService.unlockMilestone(any())).thenAnswer((_) => Future.value(false));
    
    when(() => mockNotificationService.init()).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.requestPermissions()).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.scheduleDailyVibe(isSavage: any(named: 'isSavage'))).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.scheduleWeeklyReview(isSavage: any(named: 'isSavage'))).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.scheduleMonthlyReview(isSavage: any(named: 'isSavage'))).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.schedulePaydayReminder(any(), isSavage: any(named: 'isSavage'))).thenAnswer((_) => Future.value());
    when(() => mockNotificationService.scheduleGhostingReminder()).thenAnswer((_) => Future.value());
    
    when(() => mockVaultService.isVaultEnabled()).thenAnswer((_) => Future.value(false));
    
    when(() => mockSmsSyncService.init()).thenAnswer((_) => Future.value());
    when(() => mockSupabaseService.initialize()).thenAnswer((_) => Future.value());
  });

  testWidgets('MainScreen smoke test', (WidgetTester tester) async {
    // Set a larger surface size to ensure everything is visible
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          obligationRepositoryProvider.overrideWithValue(mockRepository),
          milestoneServiceProvider.overrideWithValue(mockMilestoneService),
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          vaultServiceProvider.overrideWithValue(mockVaultService),
          smsSyncServiceProvider.overrideWithValue(mockSmsSyncService),
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        ],
        child: const MyApp(),
      ),
    );

    // Get past the staggered AppInitializer phases and deferred service timers (Ironman startup)
    // We need to advance time by at least 15 seconds to clear deferred timers (SecurityCheck, SmsSync)
    for (int i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    // Clear loading state and animations
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify core screen is mounted
    final totalCommitmentFinder = find.text('TOTAL COMMITMENT', skipOffstage: false);
    expect(totalCommitmentFinder, findsOneWidget);
  });
}
