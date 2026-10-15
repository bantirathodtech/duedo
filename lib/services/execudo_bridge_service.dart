import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final execudoBridgeServiceProvider = StateNotifierProvider<ExecudoBridgeNotifier, ExecudoBridgeState>((ref) {
  return ExecudoBridgeNotifier();
});

class ExecudoBridgeState {
  final bool isConnected;
  final int deepFocusStreakDays;
  final double impulseSavingsGenerated;
  final int completedFocusBlocks;
  final DateTime? lastSyncTime;

  const ExecudoBridgeState({
    this.isConnected = false,
    this.deepFocusStreakDays = 14,
    this.impulseSavingsGenerated = 3500.0,
    this.completedFocusBlocks = 42,
    this.lastSyncTime,
  });

  ExecudoBridgeState copyWith({
    bool? isConnected,
    int? deepFocusStreakDays,
    double? impulseSavingsGenerated,
    int? completedFocusBlocks,
    DateTime? lastSyncTime,
  }) {
    return ExecudoBridgeState(
      isConnected: isConnected ?? this.isConnected,
      deepFocusStreakDays: deepFocusStreakDays ?? this.deepFocusStreakDays,
      impulseSavingsGenerated: impulseSavingsGenerated ?? this.impulseSavingsGenerated,
      completedFocusBlocks: completedFocusBlocks ?? this.completedFocusBlocks,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class ExecudoBridgeNotifier extends StateNotifier<ExecudoBridgeState> {
  static const _prefConnected = 'execudo_bridge_connected';

  ExecudoBridgeNotifier() : super(const ExecudoBridgeState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final connected = prefs.getBool(_prefConnected) ?? false;
    state = state.copyWith(
      isConnected: connected,
      lastSyncTime: connected ? DateTime.now().subtract(const Duration(hours: 2)) : null,
    );
  }

  Future<void> setConnected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefConnected, value);
    state = state.copyWith(
      isConnected: value,
      lastSyncTime: value ? DateTime.now() : null,
    );
  }
}
