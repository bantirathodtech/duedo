import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final freedomPactServiceProvider = StateNotifierProvider<FreedomPactNotifier, FreedomPactState>((ref) {
  return FreedomPactNotifier();
});

class FreedomPactState {
  final String myPactCode;
  final bool isPaired;
  final String? partnerCode;
  final String partnerName;
  final double partnerTotalDebt;
  final double partnerSnowflakesSaved;
  final DateTime? lastSyncedAt;
  final bool isSyncing;

  const FreedomPactState({
    required this.myPactCode,
    this.isPaired = false,
    this.partnerCode,
    this.partnerName = 'Co-Borrower',
    this.partnerTotalDebt = 0.0,
    this.partnerSnowflakesSaved = 0.0,
    this.lastSyncedAt,
    this.isSyncing = false,
  });

  FreedomPactState copyWith({
    String? myPactCode,
    bool? isPaired,
    String? partnerCode,
    String? partnerName,
    double? partnerTotalDebt,
    double? partnerSnowflakesSaved,
    DateTime? lastSyncedAt,
    bool? isSyncing,
  }) {
    return FreedomPactState(
      myPactCode: myPactCode ?? this.myPactCode,
      isPaired: isPaired ?? this.isPaired,
      partnerCode: partnerCode ?? this.partnerCode,
      partnerName: partnerName ?? this.partnerName,
      partnerTotalDebt: partnerTotalDebt ?? this.partnerTotalDebt,
      partnerSnowflakesSaved: partnerSnowflakesSaved ?? this.partnerSnowflakesSaved,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class FreedomPactNotifier extends StateNotifier<FreedomPactState> {
  static const _prefMyCode = 'freedom_pact_my_code';
  static const _prefIsPaired = 'freedom_pact_is_paired';
  static const _prefPartnerCode = 'freedom_pact_partner_code';
  static const _prefPartnerName = 'freedom_pact_partner_name';
  static const _prefPartnerDebt = 'freedom_pact_partner_debt';
  static const _prefPartnerSnowflakes = 'freedom_pact_partner_snowflakes';

  FreedomPactNotifier() : super(const FreedomPactState(myPactCode: 'PACT-000000')) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? myCode = prefs.getString(_prefMyCode);
    if (myCode == null || myCode.isEmpty) {
      // Generate a 6-digit random pact code
      final random = Random();
      final num = 100000 + random.nextInt(900000);
      myCode = 'PACT-$num';
      await prefs.setString(_prefMyCode, myCode);
    }

    final isPaired = prefs.getBool(_prefIsPaired) ?? false;
    final partnerCode = prefs.getString(_prefPartnerCode);
    final partnerName = prefs.getString(_prefPartnerName) ?? 'Partner Device';
    final partnerDebt = prefs.getDouble(_prefPartnerDebt) ?? (isPaired ? 450000.0 : 0.0);
    final partnerSnowflakes = prefs.getDouble(_prefPartnerSnowflakes) ?? (isPaired ? 12500.0 : 0.0);

    state = state.copyWith(
      myPactCode: myCode,
      isPaired: isPaired,
      partnerCode: partnerCode,
      partnerName: partnerName,
      partnerTotalDebt: partnerDebt,
      partnerSnowflakesSaved: partnerSnowflakes,
      lastSyncedAt: isPaired ? DateTime.now().subtract(const Duration(minutes: 12)) : null,
    );
  }

  Future<bool> pairWithCode(String code, {String name = 'Partner Device'}) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty || cleanCode == state.myPactCode) {
      return false;
    }

    state = state.copyWith(isSyncing: true);

    // Simulate verification & Supabase sync handshake
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsPaired, true);
    await prefs.setString(_prefPartnerCode, cleanCode);
    await prefs.setString(_prefPartnerName, name);
    // Baseline co-borrower aggregate metrics
    await prefs.setDouble(_prefPartnerDebt, 385000.0);
    await prefs.setDouble(_prefPartnerSnowflakes, 8200.0);

    state = state.copyWith(
      isPaired: true,
      partnerCode: cleanCode,
      partnerName: name,
      partnerTotalDebt: 385000.0,
      partnerSnowflakesSaved: 8200.0,
      lastSyncedAt: DateTime.now(),
      isSyncing: false,
    );

    return true;
  }

  Future<void> syncNow() async {
    if (!state.isPaired) return;
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isSyncing: false,
      lastSyncedAt: DateTime.now(),
    );
  }

  Future<void> unlinkPact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefIsPaired);
    await prefs.remove(_prefPartnerCode);
    await prefs.remove(_prefPartnerName);
    await prefs.remove(_prefPartnerDebt);
    await prefs.remove(_prefPartnerSnowflakes);

    state = FreedomPactState(
      myPactCode: state.myPactCode,
      isPaired: false,
      partnerCode: null,
      partnerName: 'Co-Borrower',
      partnerTotalDebt: 0.0,
      partnerSnowflakesSaved: 0.0,
      lastSyncedAt: null,
      isSyncing: false,
    );
  }
}
