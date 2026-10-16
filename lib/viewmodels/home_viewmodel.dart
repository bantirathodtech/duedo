import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../services/financial_logic_service.dart';
import '../../services/notification_service.dart';
import '../../repositories/obligation_repository.dart';
import '../models/app_enums.dart';
import '../../services/milestone_service.dart';

class HomeState {
  final List<Obligation> obligations;
  final List<Payment> payments;
  final UserSetting? settings;
  final bool isLoading;
  final int projectionMonths;
  final double totalMonthlyRecurring;
  final List<Milestone> milestones;
  final bool hasNewlyUnlockedMilestone;

  HomeState({
    this.obligations = const [],
    this.payments = const [],
    this.settings,
    this.isLoading = true,
    this.projectionMonths = 1,
    this.totalMonthlyRecurring = 0,
    this.milestones = const [],
    this.hasNewlyUnlockedMilestone = false,
  });

  HomeState copyWith({
    List<Obligation>? obligations,
    List<Payment>? payments,
    UserSetting? settings,
    bool? isLoading,
    int? projectionMonths,
    double? totalMonthlyRecurring,
    List<Milestone>? milestones,
    bool? hasNewlyUnlockedMilestone,
  }) {
    return HomeState(
      obligations: obligations ?? this.obligations,
      payments: payments ?? this.payments,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      projectionMonths: projectionMonths ?? this.projectionMonths,
      totalMonthlyRecurring: totalMonthlyRecurring ?? this.totalMonthlyRecurring,
      milestones: milestones ?? this.milestones,
      hasNewlyUnlockedMilestone: hasNewlyUnlockedMilestone ?? this.hasNewlyUnlockedMilestone,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final ObligationRepository _repository;
  final MilestoneService _milestoneService;
  final NotificationService _notificationService;
  final _financialLogic = FinancialLogicService();
  List<IntelligenceAlert> _lastAlerts = [];
  
  final List<StreamSubscription> _subscriptions = [];

  HomeViewModel(this._repository, this._milestoneService, this._notificationService) : super(HomeState()) {
    _init();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _init() {
    // Listen to obligations
    _subscriptions.add(_repository.getAllObligations().listen((obs) {
      final recurring = obs
          .where((o) => o.type == ObligationType.recurring && o.isActive)
          .fold(0.0, (sum, o) => sum + o.amount);
          
      state = state.copyWith(
        obligations: obs, 
        totalMonthlyRecurring: recurring,
        isLoading: false
      );
      _checkMilestones();
    }));

    // Listen to payments
    _subscriptions.add(_repository.getAllPaymentsStream().listen((payments) {
      state = state.copyWith(payments: payments);
      _checkMilestones();
    }));

    // Listen to settings
    _subscriptions.add(_repository.getSettings().listen((settings) {
      if (settings != null) {
        state = state.copyWith(
          settings: settings,
          projectionMonths: settings.projectionMonths,
        );
        _checkMilestones();
      }
    }));

    _loadMilestones();
    _updateAlerts();
  }

  void _updateAlerts() {
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
  }

  Future<void> _loadMilestones() async {
    final ms = await _milestoneService.getMilestones();
    state = state.copyWith(milestones: ms);
  }

  Future<void> _checkMilestones() async {
    bool newlyUnlocked = false;

    // 1. Debt Destroyer (At least one paid obligation)
    if (state.obligations.any((o) => o.status == ObligationStatus.paid)) {
      if (await _milestoneService.unlockMilestone(MilestoneType.debtDestroyer)) newlyUnlocked = true;
    }

    // 2. Cashflow King (Disposable > 50% of income)
    final income = state.settings?.monthlyIncome ?? 0;
    if (income > 0) {
      final freeCash = income - totalMonthlyRecurring;
      if (freeCash > (income * 0.5)) {
        if (await _milestoneService.unlockMilestone(MilestoneType.cashflowKing)) newlyUnlocked = true;
      }
    }

    // 3. Freedom Seeker (Date < 365 days)
    if (freedomData.daysLeft > 0 && freedomData.daysLeft < 365) {
      if (await _milestoneService.unlockMilestone(MilestoneType.freedomSeeker)) newlyUnlocked = true;
    }

    // 4. Consistency Master (Streak >= 3) - Lowering for demo/start
    if ((state.settings?.paymentStreak ?? 0) >= 3) {
       if (await _milestoneService.unlockMilestone(MilestoneType.consistencyMaster)) newlyUnlocked = true;
    }

    // 5. The Sovereign Member (Net Worth Inversion: Total Paid >= 50% of Total Obligation Load)
    final totalRemaining = freedomData.totalRemainingBalance;
    final totalPaid = state.payments.fold(0.0, (sum, p) => sum + p.amountPaid);
    final totalLoad = totalRemaining + totalPaid;
    if (totalPaid > 0 && totalLoad > 0 && (totalPaid / totalLoad) >= 0.5) {
      if (await _milestoneService.unlockMilestone(MilestoneType.sovereignMember)) newlyUnlocked = true;
    }

    if (newlyUnlocked) {
      state = state.copyWith(hasNewlyUnlockedMilestone: true);
      _loadMilestones();
      
      _notificationService.showInstantAlert(
        id: 999,
        title: '🏆 Achievement Unlocked!',
        body: 'You\'ve earned a new financial milestone badge. Check your profile!',
      );
    }
  }

  void clearNewlyUnlockedMilestone() {
    state = state.copyWith(hasNewlyUnlockedMilestone: false);
  }

  double get totalMonthlyEMI {
    return state.obligations
        .where((o) => o.type == ObligationType.emi && o.isActive)
        .fold(0, (sum, o) => sum + o.amount);
  }

  double get totalMonthlyRecurring {
    return state.obligations
        .where((o) => o.type == ObligationType.recurring && o.isActive)
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
    return _financialLogic.calculatePressureLevel(state.obligations, state.settings?.monthlyIncome ?? 0);
  }

  int get healthScore {
    final rawIncome = (state.settings?.monthlyIncome ?? 0);
    final freeCashFlow = rawIncome - totalMonthlyRecurring;
    final dti = freeCashFlow > 0 ? (totalMonthlyEMI / freeCashFlow) : (totalMonthlyEMI > 0 ? 1.0 : 0.0);
    return _financialLogic.calculateHealthScore(dti, state.settings?.paymentStreak ?? 0);
  }

  List<GamificationBadge> get gamificationBadges {
    return _financialLogic.calculateBadges(state.obligations);
  }

  Map<String, double> get taxSavings {
    return _financialLogic.calculateTaxSavings(state.obligations);
  }

  String get financialRank {
    return _financialLogic.calculateFinancialRank(healthScore);
  }

  String get anonymousUserId {
    final rawId = state.settings?.id.toString() ?? '1';
    return 'DUEDO-${rawId.padLeft(6, '0')}';
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
        // PERFECTION: Check if the streak was broken
        // If the gap is > 1 month, reset to 1. Else increment.
        bool isConsecutive = lastDate != null && 
            ((now.year == lastDate.year && now.month == lastDate.month + 1) || 
             (now.year == lastDate.year + 1 && now.month == 1 && lastDate.month == 12));
        
        int newStreak = isConsecutive ? (settings.paymentStreak + 1) : 1;
        if (lastDate == null) newStreak = 1;

        await updateSettings(UserSettingsCompanion(
          id: const drift.Value(1),
          paymentStreak: drift.Value(newStreak),
          lastPaymentDate: drift.Value(now),
        ));
      }
    }
  }

  SnowflakeImpact previewSnowflake(Obligation debt, double amount) {
    return _financialLogic.calculateSnowflakeImpact(debt, amount);
  }

  Future<SnowflakeImpact> applySnowflake(Obligation debt, double amount) async {
    final impact = _financialLogic.calculateSnowflakeImpact(debt, amount);
    await recordPayment(debt, amount, note: 'Debt Snowflake Injection');
    return impact;
  }

  InterestBleedMetrics get bleedMetrics {
    return _financialLogic.calculateInterestBleed(state.obligations);
  }

  CrisisStressTestResult runCrisisStressTest({double emergencyFund = 0.0}) {
    return _financialLogic.calculateCrisisStressTest(
      state.obligations,
      state.settings?.monthlyIncome ?? 0,
      emergencyFund,
    );
  }

  List<ArbitrageOpportunity> get arbitrageOpportunities {
    return _financialLogic.detectArbitrageOpportunities(state.obligations);
  }

  SafeToSpendMetrics get safeToSpendMetrics {
    return _financialLogic.calculateSafeToSpend(
      obligations: state.obligations,
      monthlyIncome: state.settings?.monthlyIncome ?? 0,
    );
  }

  List<GhostSubscriptionInsight> get ghostSubscriptions {
    return _financialLogic.detectGhostSubscriptions(state.obligations);
  }

  PaydayBlitzPlan get paydayBlitzPlan {
    return _financialLogic.calculatePaydayBlitz(
      monthlyIncome: state.settings?.monthlyIncome ?? 0,
      obligations: state.obligations,
    );
  }

  bool get isTodayPayday {
    final payday = state.settings?.paydayOfMonth ?? 1;
    return DateTime.now().day == payday;
  }

  FreedomTapeMetrics getFreedomTapeMetrics(double totalShieldedFromVault, int currentStreak) {
    return _financialLogic.calculateFreedomTapeMetrics(
      obligations: state.obligations,
      totalShieldedFromVault: totalShieldedFromVault,
      currentStreak: currentStreak,
      monthlyIncome: state.settings?.monthlyIncome ?? 0,
    );
  }

  GraceShieldPlan calculateGraceShield(double availableEmergencyCash) {
    return _financialLogic.calculateGraceShield(
      obligations: state.obligations,
      availableEmergencyCash: availableEmergencyCash,
    );
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

  Future<void> reorderObligations(int oldIndex, int newIndex, {List<Obligation>? filteredList}) async {
    final masterList = sortedObligations.where((o) => o.isActive).toList();
    final itemsToReorder = filteredList ?? masterList;
    
    if (newIndex > oldIndex) newIndex -= 1;
    final item = itemsToReorder.removeAt(oldIndex);
    itemsToReorder.insert(newIndex, item);

    // Reconstruct the master list by merging the newly ordered filtered items 
    // back into the positions occupied by the filtered items in the master list.
    if (filteredList != null) {
      final filteredIds = filteredList.map((o) => o.id).toSet();
      int filteredIdx = 0;
      final newList = <Obligation>[];
      
      for (var original in masterList) {
        if (filteredIds.contains(original.id)) {
          newList.add(itemsToReorder[filteredIdx++]);
        } else {
          newList.add(original);
        }
      }
      await _repository.reorderObligations(newList);
    } else {
      await _repository.reorderObligations(itemsToReorder);
    }
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
    return _financialLogic.calculateFreedomData(state.obligations, state.settings?.monthlyIncome ?? 0);
  }

  FreedomData getFreedomDataWithAcceleration(double extraMonthlyPayment) {
    return _financialLogic.calculateFreedomData(
      state.obligations, 
      state.settings?.monthlyIncome ?? 0,
      extraMonthlyPayment: extraMonthlyPayment,
    );
  }

  List<IntelligenceAlert> get intelligenceAlerts {
    _updateAlerts();
    return _lastAlerts;
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

  /// Seeds realistic test fleet across all instruments
  Future<void> seedDemoFleet() async {
    state = state.copyWith(isLoading: true);
    await _repository.seedDemoData(force: true);
    state = state.copyWith(isLoading: false);
  }

  /// Purges all obligations and payments
  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true);
    await _repository.clearAllData();
    state = state.copyWith(isLoading: false);
  }

  /// Adds a new debt or commitment
  Future<int> addObligation(ObligationsCompanion obligation) async {
    return await _repository.createObligation(obligation);
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    ref.watch(obligationRepositoryProvider),
    ref.watch(milestoneServiceProvider),
    ref.watch(notificationServiceProvider),
  );
});
