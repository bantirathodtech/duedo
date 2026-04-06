import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duedo/ui/screens/calendar_screen.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';
import 'package:table_calendar/table_calendar.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}

void main() {
  late MockObligationRepository mockRepository;

  setUp(() {
    mockRepository = MockObligationRepository();

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
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        obligationRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: CalendarScreen(),
      ),
    );
  }

  group('CalendarScreen Tests', () {
    testWidgets('should render TableCalendar and initial empty state', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is TableCalendar), findsOneWidget);
      expect(find.text('Clear Schedule'), findsOneWidget);
    });

    testWidgets('should show events when a day with obligations is selected', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      
      final now = DateTime.now();
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
      when(() => mockRepository.getSettings()).thenAnswer((_) => Stream.value(settings));
      
      final obligation = Obligation(
        id: 1,
        title: 'Monthly Rent',
        type: ObligationType.emi,
        amount: 25000,
        startDate: now,
        gracePeriodDays: 0,
        emiPaidMonths: 0,
        priority: PriorityLevel.high,
        status: ObligationStatus.pending,
        category: 'Fixed',
        totalBalance: 25000,
        interestRate: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        displayOrder: 0,
      );

      when(() => mockRepository.getAllObligations()).thenAnswer((_) => Stream.value([obligation]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if event is displayed in list (since current day is selected by default)
      expect(find.text('Monthly Rent'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
    });
  });
}
