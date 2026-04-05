import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../services/financial_logic_service.dart';
import '../../services/notification_service.dart';
import '../../repositories/obligation_repository.dart';
import '../models/app_enums.dart';

class HomeState {
  final List<Obligation> obligations;
  final List<Payment> payments;
  final UserSetting? settings;
  final bool isLoading;
  final int projectionMonths;

  HomeState({
    this.obligations = const [],
    this.payments = const [],
    this.settings,
    this.isLoading = true,
    this.projectionMonths = 1,
  });

  HomeState copyWith({
    List<Obligation>? obligations,
    List<Payment>? payments,
    UserSetting? settings,
    bool? isLoading,
    int? projectionMonths,
  }) {
    return HomeState(
      obligations: obligations ?? this.obligations,
      payments: payments ?? this.payments,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      projectionMonths: projectionMonths ?? this.projectionMonths,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final ObligationRepository _repository;
  final _financialLogic = FinancialLogicService();
  final _notificationService = NotificationService();
  List<IntelligenceAlert> _lastAlerts = [];

  HomeViewModel(this._repository) : super(HomeState()) {
    _init();
  }

  void _init() {
    // Listen to obligations
    _repository.getAllObligations().listen((obs) {
      state = state.copyWith(obligations: obs, isLoading: false);
    });

    // Listen to payments
    _repository.getAllPaymentsStream().listen((payments) {
      state = state.copyWith(payments: payments);
    });

    // Listen to settings
    _repository.getSettings().listen((settings) {
      if (settings != null) {
        state = state.copyWith(
          settings: settings,
          projectionMonths: settings.projectionMonths,
        );
      }
    });
  }

  double get totalMonthlyEMI {
    return state.obligations
        .where((o) => o.type == ObligationType.emi && o.isActive)
        .fold(0, (sum, o) => sum + o.amount);
  }

  double get totalOneTimeDue {
    return state.obligations
        .where((o) => o.type == ObligationType.oneTime && o.isActive)
        .fold(0, (sum, o) => sum + o.amount);
  }

  int get urgentItemsCount {
    return state.obligations.where((o) {
      if (!o.isActive) return false;
      if (o.type == ObligationType.oneTime && o.priority == PriorityLevel.high) return true;
      final urgency = _repository.getUrgency(o);
      return urgency == 'urgent' || urgency == 'overdue';
    }).length;
  }

  double get pressureScore {
    final income = (state.settings?.monthlyIncome ?? 0) * state.projectionMonths;
    if (income == 0) return 0;
    final totalEmis = totalMonthlyEMI * state.projectionMonths;
    return (totalEmis + totalOneTimeDue) / income;
  }

  PressureLevel get pressureLevel {
    final score = pressureScore;
    if (score < 0.4) return PressureLevel.safe;
    if (score < 0.7) return PressureLevel.warning;
    return PressureLevel.danger;
  }

  double getTotalPaid(int obligationId) {
    return state.payments
        .where((p) => p.obligationId == obligationId)
        .fold(0.0, (sum, p) => sum + p.amountPaid);
  }

  Future<void> recordPayment(Obligation obligation, double amount, {String? note}) async {
    await _repository.markAsPaid(obligation, amount, note: note, isPartial: true);
    
    // Update streak logic
    final settings = state.settings;
    if (settings != null) {
      final now = DateTime.now();
      final lastDate = settings.lastPaymentDate;
      bool isNewMonth = lastDate == null || (now.year > lastDate.year || (now.year == lastDate.year && now.month > lastDate.month));
      
      if (isNewMonth) {
        await updateSettings(UserSettingsCompanion(
          id: const drift.Value(1),
          paymentStreak: drift.Value(settings.paymentStreak + 1),
          lastPaymentDate: drift.Value(now),
        ));
      }
    }
  }

  List<Obligation> get sortedObligations {
    final list = List<Obligation>.from(state.obligations);
    list.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      if (a.isActive && b.isActive) return a.displayOrder.compareTo(b.displayOrder);
      return (a.nextDueDate ?? a.startDate).compareTo(b.nextDueDate ?? b.startDate);
    });
    return list;
  }

  void setProjectionMonths(int months) {
    state = state.copyWith(projectionMonths: months);
    _repository.updateSettings(UserSettingsCompanion(
      id: const drift.Value(1),
      projectionMonths: drift.Value(months),
    ));
  }

  Future<void> reorderObligations(int oldIndex, int newIndex) async {
    final list = sortedObligations.where((o) => o.isActive).toList();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _repository.reorderObligations(list);
  }

  List<Obligation> getObligationsForDay(DateTime day) {
    return state.obligations.where((o) {
      final dueDate = o.nextDueDate ?? o.startDate;
      final endDate = dueDate.add(Duration(days: o.gracePeriodDays));
      final target = DateTime(day.year, day.month, day.day);
      final start = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
  }

  FreedomData get freedomData {
    return _financialLogic.calculateFreedomData(state.obligations);
  }

  List<IntelligenceAlert> get intelligenceAlerts {
    final income = state.settings?.monthlyIncome ?? 0;
    final alerts = _financialLogic.generateAIIntelligence(state.obligations, income);
    
    // Trigger notifications for new critical alerts
    for (final alert in alerts) {
      final isNew = !_lastAlerts.any((a) => a.title == alert.title && a.message == alert.message);
      if (isNew && alert.type == AlertType.warning) {
        _notificationService.showInstantAlert(
          id: alert.hashCode,
          title: 'Duedo AI: ${alert.title}',
          body: alert.message,
        );
      }
    }
    _lastAlerts = alerts;
    return alerts;
  }

  List<ActionableInsight> get insights {
    final settings = state.settings;
    if (settings == null) return [];
    return _financialLogic.generateInsights(state.obligations, settings.monthlyIncome, settings.paydayOfMonth);
  }

  Future<void> updateSettings(UserSettingsCompanion settings) async {
    await _repository.updateSettings(settings);
  }

  Future<void> togglePremium(bool value) async {
    await updateSettings(UserSettingsCompanion(
      id: const drift.Value(1),
      isPremium: drift.Value(value),
    ));
  }

  List<Map<String, dynamic>> getMonthlyProjection(int count) {
    final projection = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final monthDate = DateTime(now.year, now.month + i, 1);
      final monthName = DateFormat('MMM').format(monthDate);
      double total = 0;
      for (final ob in state.obligations) {
        if (!ob.isActive) continue;
        if (ob.type == ObligationType.emi) {
          final start = ob.startDate;
          final diffMonths = (monthDate.year - start.year) * 12 + monthDate.month - start.month;
          if (diffMonths >= 0 && (ob.emiDurationMonths == null || diffMonths < ob.emiDurationMonths!)) {
            total += ob.amount;
          }
        } else {
          final due = ob.nextDueDate ?? ob.startDate;
          if (due.year == monthDate.year && due.month == monthDate.month) total += ob.amount;
        }
      }
      projection.add({'month': monthName, 'amount': total});
    }
    return projection;
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref.watch(obligationRepositoryProvider));
});
