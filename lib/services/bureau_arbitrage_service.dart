import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class CreditCardBureauWindow {
  final String cardId;
  final String cardTitle;
  final String lender;
  final double creditLimit;
  final double currentBalance;
  final int statementCutoffDayOfMonth;
  final double targetOptimalUtilizationPct; // Default 7.0%

  const CreditCardBureauWindow({
    required this.cardId,
    required this.cardTitle,
    required this.lender,
    required this.creditLimit,
    required this.currentBalance,
    required this.statementCutoffDayOfMonth,
    this.targetOptimalUtilizationPct = 7.0,
  });

  double get currentUtilizationPct => creditLimit > 0
      ? (currentBalance / creditLimit) * 100
      : 0.0;

  DateTime get nextCutoffDate {
    final now = DateTime.now();
    DateTime cutoff = DateTime(now.year, now.month, statementCutoffDayOfMonth);
    if (cutoff.isBefore(now)) {
      cutoff = DateTime(now.year, now.month + 1, statementCutoffDayOfMonth);
    }
    return cutoff;
  }

  int get daysUntilCutoff {
    final now = DateTime.now();
    final diff = nextCutoffDate.difference(now).inDays;
    return max(0, diff);
  }

  /// The Bureau Strike Window is open within 48 hours (<= 2 days) of the statement cutoff
  bool get isStrikeWindowOpen => daysUntilCutoff <= 2;

  double get targetReportedBalance =>
      double.parse((creditLimit * (targetOptimalUtilizationPct / 100)).toStringAsFixed(2));

  double get recommendedArbitrageStrikeAmount =>
      max(0.0, currentBalance - targetReportedBalance);

  /// Estimated CIBIL / Experian boost when dropping high utilization down to optimal sweet spot
  int get estimatedScoreBoostPoints {
    if (currentUtilizationPct >= 70) return 45;
    if (currentUtilizationPct >= 50) return 35;
    if (currentUtilizationPct >= 30) return 20;
    if (currentUtilizationPct > 10) return 10;
    return 5;
  }

  CreditCardBureauWindow copyWith({
    double? currentBalance,
    double? creditLimit,
    int? statementCutoffDayOfMonth,
  }) {
    return CreditCardBureauWindow(
      cardId: cardId,
      cardTitle: cardTitle,
      lender: lender,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      statementCutoffDayOfMonth: statementCutoffDayOfMonth ?? this.statementCutoffDayOfMonth,
      targetOptimalUtilizationPct: targetOptimalUtilizationPct,
    );
  }

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'cardTitle': cardTitle,
    'lender': lender,
    'creditLimit': creditLimit,
    'currentBalance': currentBalance,
    'statementCutoffDayOfMonth': statementCutoffDayOfMonth,
    'targetOptimalUtilizationPct': targetOptimalUtilizationPct,
  };

  factory CreditCardBureauWindow.fromJson(Map<String, dynamic> json) {
    return CreditCardBureauWindow(
      cardId: json['cardId'] as String,
      cardTitle: json['cardTitle'] as String,
      lender: json['lender'] as String? ?? 'Bank',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 100000.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      statementCutoffDayOfMonth: json['statementCutoffDayOfMonth'] as int? ?? 18,
      targetOptimalUtilizationPct: (json['targetOptimalUtilizationPct'] as num?)?.toDouble() ?? 7.0,
    );
  }
}

class BureauArbitrageState {
  final List<CreditCardBureauWindow> cards;
  final int totalPotentialScoreBoost;
  final double totalArbitrageStrikesRecommended;

  const BureauArbitrageState({
    this.cards = const [],
    this.totalPotentialScoreBoost = 0,
    this.totalArbitrageStrikesRecommended = 0.0,
  });

  List<CreditCardBureauWindow> get openWindowCards =>
      cards.where((c) => c.isStrikeWindowOpen && c.recommendedArbitrageStrikeAmount > 0).toList();

  BureauArbitrageState copyWith({
    List<CreditCardBureauWindow>? cards,
    int? totalPotentialScoreBoost,
    double? totalArbitrageStrikesRecommended,
  }) {
    return BureauArbitrageState(
      cards: cards ?? this.cards,
      totalPotentialScoreBoost: totalPotentialScoreBoost ?? this.totalPotentialScoreBoost,
      totalArbitrageStrikesRecommended:
          totalArbitrageStrikesRecommended ?? this.totalArbitrageStrikesRecommended,
    );
  }
}

final bureauArbitrageProvider =
    StateNotifierProvider<BureauArbitrageNotifier, BureauArbitrageState>((ref) {
  return BureauArbitrageNotifier();
});

class BureauArbitrageNotifier extends StateNotifier<BureauArbitrageState> {
  static const String _prefKey = 'duedo_bureau_arbitrage_cards_v1';

  BureauArbitrageNotifier() : super(const BureauArbitrageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = list.map((e) => CreditCardBureauWindow.fromJson(e as Map<String, dynamic>)).toList();
        _updateMetrics(items);
        return;
      } catch (_) {}
    }
    // Default demo seeds for major Indian cardholders
    final now = DateTime.now();
    final seeds = [
      CreditCardBureauWindow(
        cardId: 'card-hdfc-1',
        cardTitle: 'HDFC Regalia Gold',
        lender: 'HDFC Bank',
        creditLimit: 250000.0,
        currentBalance: 98000.0, // 39.2% utilization
        statementCutoffDayOfMonth: (now.day + 1 > 28) ? 1 : now.day + 1, // Strike window open!
      ),
      CreditCardBureauWindow(
        cardId: 'card-icici-2',
        cardTitle: 'ICICI Amazon Pay',
        lender: 'ICICI Bank',
        creditLimit: 120000.0,
        currentBalance: 58000.0, // 48.3% utilization
        statementCutoffDayOfMonth: (now.day + 5 > 28) ? 5 : now.day + 5,
      ),
    ];
    _updateMetrics(seeds);
  }

  void _updateMetrics(List<CreditCardBureauWindow> cards) {
    int scoreBoost = 0;
    double strikesTotal = 0.0;

    for (final c in cards) {
      if (c.recommendedArbitrageStrikeAmount > 0) {
        scoreBoost += c.estimatedScoreBoostPoints;
        strikesTotal += c.recommendedArbitrageStrikeAmount;
      }
    }

    state = state.copyWith(
      cards: cards,
      totalPotentialScoreBoost: scoreBoost,
      totalArbitrageStrikesRecommended: strikesTotal,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.cards.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, jsonStr);
  }

  Future<void> recordArbitrageSlay({required String cardId, required double strikeAmount}) async {
    HapticService.dopamineCascade();

    final updated = state.cards.map((c) {
      if (c.cardId == cardId) {
        final newBal = max(0.0, c.currentBalance - strikeAmount);
        return c.copyWith(currentBalance: newBal);
      }
      return c;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }

  Future<void> updateCardCutoff({
    required String cardId,
    required int cutoffDay,
    double? creditLimit,
    double? currentBalance,
  }) async {
    HapticService.selection();

    final updated = state.cards.map((c) {
      if (c.cardId == cardId) {
        return c.copyWith(
          statementCutoffDayOfMonth: cutoffDay.clamp(1, 28),
          creditLimit: creditLimit,
          currentBalance: currentBalance,
        );
      }
      return c;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }
}
