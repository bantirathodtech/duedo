import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/optimization_engine.dart';
import '../../services/simulation_service.dart';
import '../../services/financial_logic_service.dart';
import 'home_viewmodel.dart';

final insightsViewModelProvider = StateNotifierProvider<InsightsViewModel, InsightsState>((ref) {
  final homeState = ref.watch(homeViewModelProvider);
  return InsightsViewModel(homeState);
});

class InsightsState {
  final double incomeMultiplier;
  final RepaymentStrategy strategy;
  final FreedomData? simulatedFreedomData;
  final Map<String, dynamic>? savingsDelta;
  final bool isPremium;

  InsightsState({
    this.incomeMultiplier = 1.0,
    this.strategy = RepaymentStrategy.snowball,
    this.simulatedFreedomData,
    this.savingsDelta,
    this.isPremium = false,
  });

  InsightsState copyWith({
    double? incomeMultiplier,
    RepaymentStrategy? strategy,
    FreedomData? simulatedFreedomData,
    Map<String, dynamic>? savingsDelta,
    bool? isPremium,
  }) {
    return InsightsState(
      incomeMultiplier: incomeMultiplier ?? this.incomeMultiplier,
      strategy: strategy ?? this.strategy,
      simulatedFreedomData: simulatedFreedomData ?? this.simulatedFreedomData,
      savingsDelta: savingsDelta ?? this.savingsDelta,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class InsightsViewModel extends StateNotifier<InsightsState> {
  final HomeState _homeState;

  InsightsViewModel(this._homeState) : super(InsightsState()) {
    _initializeData();
  }

  void _initializeData() {
    state = state.copyWith(isPremium: _homeState.settings?.isPremium ?? false);
    _runEngines();
  }

  void setIncomeMultiplier(double multiplier) {
    if (!state.isPremium && multiplier != 1.0) return; // Feature gate: Pro only
    state = state.copyWith(incomeMultiplier: multiplier);
    _runEngines();
  }

  void setStrategy(RepaymentStrategy newStrategy) {
    state = state.copyWith(strategy: newStrategy);
    _runEngines();
  }

  void _runEngines() {
    if (_homeState.settings == null) return;
    
    final baseIncome = _homeState.settings!.monthlyIncome;
    final obligations = _homeState.obligations;

    // 1. Run Simulation (Sandbox)
    final simData = SimulationService.runSimulation(
      baseIncome: baseIncome,
      incomeModifier: state.incomeMultiplier,
      debts: obligations,
    );

    // 2. Run Optimization (Automator)
    final capacity = baseIncome * 0.20; // Simulated capacity
    final delta = OptimizationEngine.calculateDelta(obligations, capacity);

    state = state.copyWith(
      simulatedFreedomData: simData,
      savingsDelta: delta,
    );
  }
}
