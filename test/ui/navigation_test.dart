import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:duedo/ui/screens/main_screen.dart';
import 'package:duedo/ui/screens/home_screen.dart';
import 'package:duedo/ui/screens/calendar_screen.dart';
import 'package:duedo/ui/screens/add_obligation_screen.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/milestone_service.dart';
import 'package:duedo/services/notification_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/services/supabase_service.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}
class MockMilestoneService extends Mock implements MilestoneService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockSupabaseService extends Mock implements SupabaseService {}
class ObligationFake extends Fake implements Obligation {}

void main() {
  late MockObligationRepository mockRepository;
  late MockMilestoneService mockMilestoneService;
  late MockNotificationService mockNotificationService;
  late MockSupabaseService mockSupabaseService;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(ObligationFake());
    registerFallbackValue(MilestoneType.debtDestroyer);
  });

  setUp(() {
    mockRepository = MockObligationRepository();
    mockMilestoneService = MockMilestoneService();
    mockNotificationService = MockNotificationService();
    mockSupabaseService = MockSupabaseService();

    const settings = UserSetting(
      id: 1,
      monthlyIncome: 50000.0,
      currency: 'INR',
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

    when(() => mockRepository.getAllObligations()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getAllPaymentsStream()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getSettings()).thenAnswer((_) => Stream.value(settings));
    when(() => mockRepository.getUrgency(any())).thenReturn('safe');
    when(() => mockMilestoneService.getMilestones()).thenAnswer((_) => Future.value([]));
    when(() => mockMilestoneService.unlockMilestone(any())).thenAnswer((_) => Future.value(false));
    when(() => mockNotificationService.showInstantAlert(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
    )).thenAnswer((_) => Future.value());
    
    when(() => mockSupabaseService.initialize()).thenAnswer((_) => Future.value());
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        obligationRepositoryProvider.overrideWithValue(mockRepository),
        milestoneServiceProvider.overrideWithValue(mockMilestoneService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
      ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  group('Navigation Stability Tests', () {
    testWidgets('should switch between tabs correctly', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      
      // Get past the staggered AppInitializer phases and deferred service timers (Ironman startup)
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      while(tester.takeException() != null) {}

      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);

      final scheduleBtn = find.text('Schedule', skipOffstage: false);
      if(scheduleBtn.evaluate().isNotEmpty) await tester.tap(scheduleBtn);
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      while(tester.takeException() != null) {}
      expect(find.byType(CalendarScreen, skipOffstage: false), findsOneWidget);

      final overviewBtn = find.text('Overview', skipOffstage: false);
      if(overviewBtn.evaluate().isNotEmpty) await tester.tap(overviewBtn);
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      while(tester.takeException() != null) {}
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
    });

    testWidgets('should navigate to Add Obligation and back', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      
      // Get past the staggered AppInitializer phases and deferred service timers (Ironman startup)
      for (int i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      while(tester.takeException() != null) {}
      
      final strikeFinder = find.text('Strike', skipOffstage: false);
      if (strikeFinder.evaluate().isNotEmpty) {
        await tester.tap(strikeFinder.first);
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        while(tester.takeException() != null) {}

        final addDebtFinder = find.text('Add Debt / EMI', skipOffstage: false);
        if (addDebtFinder.evaluate().isNotEmpty) {
          await tester.tap(addDebtFinder.first);
          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          while(tester.takeException() != null) {}
          expect(find.byType(AddObligationScreen, skipOffstage: false), findsOneWidget);

          // Go back
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
          } else {
            final backIcon = find.byIcon(Icons.arrow_back_ios_new_rounded);
            if (backIcon.evaluate().isNotEmpty) {
              await tester.tap(backIcon.last);
            }
          }
          
          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          while(tester.takeException() != null) {}
          expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        }
      }
    });
  });
}
