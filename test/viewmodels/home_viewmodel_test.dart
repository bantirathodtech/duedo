import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duedo/viewmodels/home_viewmodel.dart';
import 'package:duedo/repositories/obligation_repository.dart';
import 'package:duedo/services/milestone_service.dart';
import 'package:duedo/services/database.dart';
import 'package:duedo/services/notification_service.dart';
import 'package:duedo/models/app_enums.dart';

class MockObligationRepository extends Mock implements ObligationRepository {}
class MockMilestoneService extends Mock implements MilestoneService {}
class MockNotificationService extends Mock implements NotificationService {}

class FakeObligation extends Fake implements Obligation {}
class FakeUserSettingsCompanion extends Fake implements UserSettingsCompanion {}

void main() {
  late HomeViewModel viewModel;
  late MockObligationRepository mockRepository;
  late MockMilestoneService mockMilestoneService;
  late MockNotificationService mockNotificationService;
  
  late StreamController<List<Obligation>> obligationController;
  late StreamController<List<Payment>> paymentController;
  late StreamController<UserSetting?> settingsController;

  setUpAll(() {
    registerFallbackValue(FakeObligation());
    registerFallbackValue(FakeUserSettingsCompanion());
    registerFallbackValue(MilestoneType.debtDestroyer);
  });

  setUp(() {
    mockRepository = MockObligationRepository();
    mockMilestoneService = MockMilestoneService();
    mockNotificationService = MockNotificationService();

    obligationController = StreamController<List<Obligation>>.broadcast();
    paymentController = StreamController<List<Payment>>.broadcast();
    settingsController = StreamController<UserSetting?>.broadcast();

    when(() => mockRepository.getAllObligations()).thenAnswer((_) => obligationController.stream);
    when(() => mockRepository.getAllPaymentsStream()).thenAnswer((_) => paymentController.stream);
    when(() => mockRepository.getSettings()).thenAnswer((_) => settingsController.stream);
    when(() => mockRepository.getUrgency(any())).thenReturn('safe');
    when(() => mockMilestoneService.getMilestones()).thenAnswer((_) => Future.value([]));
    when(() => mockMilestoneService.unlockMilestone(any())).thenAnswer((_) => Future.value(false));
    when(() => mockNotificationService.showInstantAlert(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
    )).thenAnswer((_) => Future.value());
    when(() => mockRepository.updateSettings(any())).thenAnswer((_) => Future.value());

    final container = ProviderContainer(
      overrides: [
        obligationRepositoryProvider.overrideWithValue(mockRepository),
        milestoneServiceProvider.overrideWithValue(mockMilestoneService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
    addTearDown(container.dispose);

    viewModel = container.read(homeViewModelProvider.notifier);
  });

  tearDown(() {
    obligationController.close();
    paymentController.close();
    settingsController.close();
  });

  Obligation createObligation({
    int id = 1,
    String title = 'Test',
    ObligationType type = ObligationType.emi,
    double amount = 1000,
    bool isActive = true,
  }) {
    return Obligation(
      id: id,
      title: title,
      type: type,
      amount: amount,
      startDate: DateTime.now(),
      gracePeriodDays: 3,
      emiPaidMonths: 0,
      priority: PriorityLevel.medium,
      status: ObligationStatus.pending,
      category: 'Test',
      totalBalance: 5000,
      interestRate: 10,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      displayOrder: 0,
    );
  }

  group('Aggregates', () {
    test('should calculate totals correctly', () async {
      final emi = createObligation(id: 1, type: ObligationType.emi, amount: 1000);
      final rec = createObligation(id: 2, type: ObligationType.recurring, amount: 500);
      final one = createObligation(id: 3, type: ObligationType.oneTime, amount: 2000);
      
      obligationController.add([emi, rec, one]);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.totalMonthlyEMI, 1000);
      expect(viewModel.totalMonthlyRecurring, 500);
      expect(viewModel.totalOneTimeDue, 2000);
    });

    test('urgentItemsCount should work', () async {
      final urgent = createObligation(id: 1);
      final normal = createObligation(id: 2);
      
      when(() => mockRepository.getUrgency(any())).thenReturn('urgent');
      
      obligationController.add([urgent, normal]);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.urgentItemsCount, 2); // default mock always returns urgent now
    });
  });

  group('Record Payment and Streak', () {
    test('recordPayment should trigger repository and handle streak', () async {
      final debt = createObligation();
      final settings = UserSetting(
        id: 1,
        monthlyIncome: 5000,
        currency: '₹',
        notificationsEnabled: true,
        reminderDaysBefore: 3,
        paydayOfMonth: 1,
        projectionMonths: 1,
        themeMode: 'system',
        isPremium: false,
        paymentStreak: 5,
        lastPaymentDate: DateTime.now().subtract(const Duration(days: 31)),
        smsSyncEnabled: false,
      );

      settingsController.add(settings);
      obligationController.add([debt]);
      await Future.delayed(Duration.zero);

      when(() => mockRepository.markAsPaid(any(), any(), note: any(named: 'note'), isPartial: any(named: 'isPartial')))
          .thenAnswer((_) => Future.value());

      await viewModel.recordPayment(debt, 1000, note: 'Paid');

      verify(() => mockRepository.markAsPaid(any(), 1000, note: 'Paid', isPartial: true)).called(1);
      verify(() => mockRepository.updateSettings(any())).called(1);
    });
  });

  group('Settings and State', () {
    test('togglePremium should update repository', () async {
      await viewModel.togglePremium(true);
      verify(() => mockRepository.updateSettings(any())).called(1);
    });

    test('setProjectionMonths should update state and repo', () async {
      viewModel.setProjectionMonths(6);
      expect(viewModel.state.projectionMonths, 6);
      verify(() => mockRepository.updateSettings(any())).called(1);
    });
  });

  group('Projections and Logic', () {
    test('getMonthlyProjection should return correct months', () async {
      final debt = createObligation(type: ObligationType.emi, amount: 1000);
      obligationController.add([debt]);
      await Future.delayed(Duration.zero);
      
      final projection = viewModel.getMonthlyProjection(3);
      expect(projection.length, 3);
      expect(projection[0]['amount'], 1000);
    });

    test('getObligationsForDay should filter correctly', () async {
      final now = DateTime.now();
      final debt = createObligation(id: 1); // due today
      obligationController.add([debt]);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.getObligationsForDay(now).length, 1);
      expect(viewModel.getObligationsForDay(now.add(const Duration(days: 10))).length, 0);
    });
  });
}
