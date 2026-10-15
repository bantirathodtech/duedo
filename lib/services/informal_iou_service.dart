import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'haptic_service.dart';

enum IouDirection {
  lentByMe,      // Money I gave to someone (they owe me)
  borrowedByMe,  // Money I took from someone (I owe them)
}

class InformalIouItem {
  final String id;
  final String personName;
  final String phoneNumber;
  final IouDirection direction;
  final double originalAmount;
  final double settledAmount;
  final DateTime createdDate;
  final DateTime? targetSettleDate;
  final String note;
  final bool isFullySettled;

  const InformalIouItem({
    required this.id,
    required this.personName,
    required this.phoneNumber,
    required this.direction,
    required this.originalAmount,
    this.settledAmount = 0.0,
    required this.createdDate,
    this.targetSettleDate,
    this.note = '',
    this.isFullySettled = false,
  });

  double get remainingBalance => (originalAmount - settledAmount).clamp(0.0, double.infinity);

  double get progressRatio => originalAmount > 0
      ? (settledAmount / originalAmount).clamp(0.0, 1.0)
      : 1.0;

  String getDignifiedWhatsAppNudge(String myUpiVpa, String currency) {
    final amtFormatted = '$currency${NumberFormat('#,##,###').format(remainingBalance.round())}';
    if (direction == IouDirection.lentByMe) {
      return '''
Hey ${personName.trim()}! Hope you are doing great. 😊
Just reconciling my monthly accounts and commitments on Duedo. 
Whenever convenient for you, you can settle the friendly balance of $amtFormatted via this 1-tap UPI link:
upi://pay?pa=$myUpiVpa&pn=Friend&am=${remainingBalance.toStringAsFixed(0)}&tn=Duedo_Friendly_Settle

No stress or rush at all! Even a partial micro-settle works anytime. Wishing you a great week! 🙌
'''.trim();
    } else {
      return '''
Hey ${personName.trim()}! 
Just wanted to confirm that I have budgeted $amtFormatted towards our hand-loan on Duedo.
I am on track to clear this soon. Thank you so much for your trust and patience! 🙏
'''.trim();
    }
  }

  InformalIouItem copyWith({
    double? settledAmount,
    bool? isFullySettled,
    DateTime? targetSettleDate,
    String? note,
  }) {
    return InformalIouItem(
      id: id,
      personName: personName,
      phoneNumber: phoneNumber,
      direction: direction,
      originalAmount: originalAmount,
      settledAmount: settledAmount ?? this.settledAmount,
      createdDate: createdDate,
      targetSettleDate: targetSettleDate ?? this.targetSettleDate,
      note: note ?? this.note,
      isFullySettled: isFullySettled ?? this.isFullySettled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'phoneNumber': phoneNumber,
    'direction': direction.name,
    'originalAmount': originalAmount,
    'settledAmount': settledAmount,
    'createdDate': createdDate.toIso8601String(),
    'targetSettleDate': targetSettleDate?.toIso8601String(),
    'note': note,
    'isFullySettled': isFullySettled,
  };

  factory InformalIouItem.fromJson(Map<String, dynamic> json) {
    return InformalIouItem(
      id: json['id'] as String,
      personName: json['personName'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      direction: IouDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => IouDirection.lentByMe,
      ),
      originalAmount: (json['originalAmount'] as num).toDouble(),
      settledAmount: (json['settledAmount'] as num?)?.toDouble() ?? 0.0,
      createdDate: DateTime.parse(json['createdDate'] as String),
      targetSettleDate: json['targetSettleDate'] != null
          ? DateTime.parse(json['targetSettleDate'] as String)
          : null,
      note: json['note'] as String? ?? '',
      isFullySettled: json['isFullySettled'] as bool? ?? false,
    );
  }
}

class InformalIouState {
  final List<InformalIouItem> items;
  final double totalLentOutstanding;
  final double totalBorrowedOutstanding;
  final int activeCount;

  const InformalIouState({
    this.items = const [],
    this.totalLentOutstanding = 0.0,
    this.totalBorrowedOutstanding = 0.0,
    this.activeCount = 0,
  });

  InformalIouState copyWith({
    List<InformalIouItem>? items,
    double? totalLentOutstanding,
    double? totalBorrowedOutstanding,
    int? activeCount,
  }) {
    return InformalIouState(
      items: items ?? this.items,
      totalLentOutstanding: totalLentOutstanding ?? this.totalLentOutstanding,
      totalBorrowedOutstanding: totalBorrowedOutstanding ?? this.totalBorrowedOutstanding,
      activeCount: activeCount ?? this.activeCount,
    );
  }
}

final informalIouProvider =
    StateNotifierProvider<InformalIouNotifier, InformalIouState>((ref) {
  return InformalIouNotifier();
});

class InformalIouNotifier extends StateNotifier<InformalIouState> {
  static const String _prefKey = 'duedo_informal_iou_items_v1';

  InformalIouNotifier() : super(const InformalIouState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = list.map((e) => InformalIouItem.fromJson(e as Map<String, dynamic>)).toList();
        _updateMetrics(items);
        return;
      } catch (_) {}
    }
    // Seed sample hand-loans for initial discovery
    final seeds = [
      InformalIouItem(
        id: 'iou-1',
        personName: 'Rohan Sharma',
        phoneNumber: '+919876543210',
        direction: IouDirection.lentByMe,
        originalAmount: 15000.0,
        settledAmount: 5000.0,
        createdDate: DateTime.now().subtract(const Duration(days: 20)),
        note: 'College laptop emergency support',
      ),
      InformalIouItem(
        id: 'iou-2',
        personName: 'Uncle Suresh',
        phoneNumber: '+919123456780',
        direction: IouDirection.borrowedByMe,
        originalAmount: 50000.0,
        settledAmount: 20000.0,
        createdDate: DateTime.now().subtract(const Duration(days: 45)),
        note: 'Family business bridging loan',
      ),
    ];
    _updateMetrics(seeds);
  }

  void _updateMetrics(List<InformalIouItem> items) {
    double lent = 0.0;
    double borrowed = 0.0;
    int active = 0;

    for (final i in items) {
      if (!i.isFullySettled) {
        active++;
        if (i.direction == IouDirection.lentByMe) {
          lent += i.remainingBalance;
        } else {
          borrowed += i.remainingBalance;
        }
      }
    }

    state = state.copyWith(
      items: items,
      totalLentOutstanding: lent,
      totalBorrowedOutstanding: borrowed,
      activeCount: active,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, jsonStr);
  }

  Future<void> addIou({
    required String personName,
    required String phoneNumber,
    required IouDirection direction,
    required double amount,
    String note = '',
    DateTime? targetDate,
  }) async {
    HapticService.selection();

    final newItem = InformalIouItem(
      id: 'iou-${DateTime.now().millisecondsSinceEpoch}',
      personName: personName.trim(),
      phoneNumber: phoneNumber.trim(),
      direction: direction,
      originalAmount: amount,
      settledAmount: 0.0,
      createdDate: DateTime.now(),
      targetSettleDate: targetDate,
      note: note.trim(),
    );

    final updated = [newItem, ...state.items];
    _updateMetrics(updated);
    await _save();
  }

  Future<void> recordPartialSettle({
    required String iouId,
    required double paymentAmount,
  }) async {
    HapticService.dopamineCascade();

    final updated = state.items.map((i) {
      if (i.id == iouId) {
        final newSettled = i.settledAmount + paymentAmount;
        final isClosed = newSettled >= i.originalAmount - 0.01;
        return i.copyWith(
          settledAmount: newSettled,
          isFullySettled: isClosed,
        );
      }
      return i;
    }).toList();

    _updateMetrics(updated);
    await _save();
  }

  Future<void> deleteIou(String iouId) async {
    HapticService.selection();
    final updated = state.items.where((i) => i.id != iouId).toList();
    _updateMetrics(updated);
    await _save();
  }
}
