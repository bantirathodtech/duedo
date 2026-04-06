import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duedo/ui/screens/add_obligation_screen.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/milestone_service.dart';
import 'package:duedo/services/notification_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/models/app_enums.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}
class MockMilestoneService extends Mock implements MilestoneService {}
class MockNotificationService extends Mock implements NotificationService {}

class FakeObligation extends Fake implements Obligation {}
class FakeObligationsCompanion extends Fake implements ObligationsCompanion {}

void main() {
  late MockObligationRepository mockRepository;
  late MockMilestoneService mockMilestoneService;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(FakeObligation());
    registerFallbackValue(FakeObligationsCompanion());
  });

  setUp(() {
    mockRepository = MockObligationRepository();
    mockMilestoneService = MockMilestoneService();
    mockNotificationService = MockNotificationService();

    when(() => mockRepository.getAllObligations()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getAllPaymentsStream()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getSettings()).thenAnswer((_) => Stream.value(null));
    when(() => mockMilestoneService.getMilestones()).thenAnswer((_) => Future.value([]));
    when(() => mockRepository.createObligation(any())).thenAnswer((_) => Future.value(1));
    when(() => mockRepository.updateObligation(any())).thenAnswer((_) => Future.value(true));
    when(() => mockRepository.getUrgency(any())).thenReturn('safe');
    when(() => mockRepository.getPaymentsStream(any())).thenAnswer((_) => Stream.value([]));
  });

  Widget createTestWidget({Obligation? obligation}) {
    return ProviderScope(
      overrides: [
        obligationRepositoryProvider.overrideWithValue(mockRepository),
        milestoneServiceProvider.overrideWithValue(mockMilestoneService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: MaterialApp(
        home: AddObligationScreen(obligation: obligation),
      ),
    );
  }

  group('AddObligationScreen Tests', () {
    testWidgets('should update existing obligation on edit', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final existing = Obligation(
        id: 1,
        title: 'Old Title',
        type: ObligationType.oneTime,
        amount: 1000,
        startDate: now,
        gracePeriodDays: 3,
        emiPaidMonths: 0,
        priority: PriorityLevel.medium,
        status: ObligationStatus.pending,
        category: 'Essentials',
        totalBalance: 1000,
        interestRate: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        displayOrder: 0,
      );

      await tester.pumpWidget(createTestWidget(obligation: existing));
      await tester.pumpAndSettle();

      expect(find.text('Edit Obligation'), findsOneWidget);
      
      // Change title
      await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New Title');
      await tester.pumpAndSettle();
      
      // Tap Update
      final submitBtn = find.byType(ElevatedButton);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn, warnIfMissed: false);
      
      // Repeated pump to ensure async logic completes
      for(int i=0; i<10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      verify(() => mockRepository.updateObligation(any())).called(1);
    });
  });
}
