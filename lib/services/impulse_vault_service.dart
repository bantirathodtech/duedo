import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

final impulseVaultServiceProvider = StateNotifierProvider<ImpulseVaultNotifier, ImpulseVaultState>((ref) {
  return ImpulseVaultNotifier();
});

enum ImpulseStatus { cooling, resisted, bought }

class ImpulseVaultItem {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final int coolingDurationHours;
  final ImpulseStatus status;
  final double interestPrevented;
  final int freedomDaysRestored;

  ImpulseVaultItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.coolingDurationHours = 24,
    this.status = ImpulseStatus.cooling,
    required this.interestPrevented,
    required this.freedomDaysRestored,
  });

  DateTime get expiresAt => createdAt.add(Duration(hours: coolingDurationHours));

  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isCooledDown => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
    'coolingDurationHours': coolingDurationHours,
    'status': status.name,
    'interestPrevented': interestPrevented,
    'freedomDaysRestored': freedomDaysRestored,
  };

  factory ImpulseVaultItem.fromJson(Map<String, dynamic> json) {
    return ImpulseVaultItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      coolingDurationHours: json['coolingDurationHours'] as int? ?? 24,
      status: ImpulseStatus.values.firstWhere(
        (e) => e.name == json['status'], 
        orElse: () => ImpulseStatus.cooling,
      ),
      interestPrevented: (json['interestPrevented'] as num).toDouble(),
      freedomDaysRestored: json['freedomDaysRestored'] as int? ?? 1,
    );
  }

  ImpulseVaultItem copyWith({
    ImpulseStatus? status,
  }) {
    return ImpulseVaultItem(
      id: id,
      title: title,
      amount: amount,
      createdAt: createdAt,
      coolingDurationHours: coolingDurationHours,
      status: status ?? this.status,
      interestPrevented: interestPrevented,
      freedomDaysRestored: freedomDaysRestored,
    );
  }
}

class ImpulseVaultState {
  final List<ImpulseVaultItem> items;
  final double totalShielded;
  final double totalInterestPrevented;
  final int totalDaysSaved;

  const ImpulseVaultState({
    this.items = const [],
    this.totalShielded = 0.0,
    this.totalInterestPrevented = 0.0,
    this.totalDaysSaved = 0,
  });

  List<ImpulseVaultItem> get activeCoolingItems =>
      items.where((i) => i.status == ImpulseStatus.cooling).toList();

  List<ImpulseVaultItem> get resistedItems =>
      items.where((i) => i.status == ImpulseStatus.resisted).toList();

  ImpulseVaultState copyWith({
    List<ImpulseVaultItem>? items,
    double? totalShielded,
    double? totalInterestPrevented,
    int? totalDaysSaved,
  }) {
    return ImpulseVaultState(
      items: items ?? this.items,
      totalShielded: totalShielded ?? this.totalShielded,
      totalInterestPrevented: totalInterestPrevented ?? this.totalInterestPrevented,
      totalDaysSaved: totalDaysSaved ?? this.totalDaysSaved,
    );
  }
}

class ImpulseVaultNotifier extends StateNotifier<ImpulseVaultState> {
  static const _prefKey = 'duedo_impulse_vault_items_v1';

  ImpulseVaultNotifier() : super(const ImpulseVaultState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = list.map((e) => ImpulseVaultItem.fromJson(e as Map<String, dynamic>)).toList();
        _updateMetrics(items);
      } catch (_) {}
    }
  }

  void _updateMetrics(List<ImpulseVaultItem> items) {
    double shielded = 0.0;
    double interest = 0.0;
    int days = 0;

    for (final item in items) {
      if (item.status == ImpulseStatus.resisted) {
        shielded += item.amount;
        interest += item.interestPrevented;
        days += item.freedomDaysRestored;
      }
    }

    state = state.copyWith(
      items: items,
      totalShielded: shielded,
      totalInterestPrevented: interest,
      totalDaysSaved: days,
    );
  }

  Future<ImpulseVaultItem> shieldImpulse({
    required String title,
    required double amount,
    double annualInterestRate = 14.5,
    double dailyDebtBurn = 400.0,
  }) async {
    HapticService.savageThud();

    // 2-year compound estimate if this money went to debt instead
    final estimatedInterestKilled = amount * (annualInterestRate / 100) * 1.8;
    final estimatedDaysSaved = dailyDebtBurn > 0 
        ? (amount / dailyDebtBurn).round().clamp(1, 90) 
        : (amount / 350).round().clamp(1, 90);

    final item = ImpulseVaultItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      amount: amount,
      createdAt: DateTime.now(),
      coolingDurationHours: 24,
      status: ImpulseStatus.cooling,
      interestPrevented: estimatedInterestKilled,
      freedomDaysRestored: estimatedDaysSaved,
    );

    final updated = [item, ...state.items];
    _updateMetrics(updated);
    await _save();
    return item;
  }

  Future<void> markResisted(String id) async {
    HapticService.victoryPop();
    final updated = state.items.map((i) {
      if (i.id == id) {
        return i.copyWith(status: ImpulseStatus.resisted);
      }
      return i;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }

  Future<void> markBought(String id) async {
    HapticService.subtleClick();
    final updated = state.items.map((i) {
      if (i.id == id) {
        return i.copyWith(status: ImpulseStatus.bought);
      }
      return i;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }

  Future<void> deleteItem(String id) async {
    final updated = state.items.where((i) => i.id != id).toList();
    _updateMetrics(updated);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, jsonStr);
  }
}
