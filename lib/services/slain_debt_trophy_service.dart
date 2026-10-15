import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database.dart';
import 'haptic_service.dart';

class SlainDebtTrophy {
  final int obligationId;
  final String title;
  final double totalBalancePaid;
  final double totalInterestDestroyed;
  final DateTime dateSlain;
  final String category;
  final String medalTier; // Diamond, Gold, Silver

  const SlainDebtTrophy({
    required this.obligationId,
    required this.title,
    required this.totalBalancePaid,
    required this.totalInterestDestroyed,
    required this.dateSlain,
    required this.category,
    required this.medalTier,
  });

  Map<String, dynamic> toJson() => {
        'obligationId': obligationId,
        'title': title,
        'totalBalancePaid': totalBalancePaid,
        'totalInterestDestroyed': totalInterestDestroyed,
        'dateSlain': dateSlain.toIso8601String(),
        'category': category,
        'medalTier': medalTier,
      };

  factory SlainDebtTrophy.fromJson(Map<String, dynamic> json) => SlainDebtTrophy(
        obligationId: json['obligationId'] as int,
        title: json['title'] as String,
        totalBalancePaid: (json['totalBalancePaid'] as num).toDouble(),
        totalInterestDestroyed: (json['totalInterestDestroyed'] as num).toDouble(),
        dateSlain: DateTime.parse(json['dateSlain'] as String),
        category: json['category'] as String,
        medalTier: json['medalTier'] as String,
      );
}

final slainDebtTrophyProvider =
    StateNotifierProvider<SlainDebtTrophyNotifier, List<SlainDebtTrophy>>((ref) {
  return SlainDebtTrophyNotifier();
});

class SlainDebtTrophyNotifier extends StateNotifier<List<SlainDebtTrophy>> {
  static const String _prefKey = 'duedo_slain_debt_trophies';

  SlainDebtTrophyNotifier() : super([]) {
    _loadTrophies();
  }

  Future<void> _loadTrophies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List decoded = jsonDecode(jsonString);
        state = decoded.map((item) => SlainDebtTrophy.fromJson(item)).toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<SlainDebtTrophy> registerSlainDebt(Obligation ob) async {
    final balance = ob.totalBalance > 0 ? ob.totalBalance : (ob.amount * 12.0);
    final rate = ob.interestRate > 0 ? ob.interestRate : 12.0;
    final interestDestroyed = balance * (rate / 100.0) * 1.5;

    String tier = 'Silver';
    if (balance >= 200000) {
      tier = 'Diamond';
    } else if (balance >= 50000) {
      tier = 'Gold';
    }

    final trophy = SlainDebtTrophy(
      obligationId: ob.id,
      title: ob.title,
      totalBalancePaid: balance,
      totalInterestDestroyed: interestDestroyed,
      dateSlain: DateTime.now(),
      category: ob.category,
      medalTier: tier,
    );

    state = [trophy, ...state.where((t) => t.obligationId != ob.id)];

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((t) => t.toJson()).toList());
    await prefs.setString(_prefKey, encoded);

    HapticService.dopamineCascade();
    return trophy;
  }
}
