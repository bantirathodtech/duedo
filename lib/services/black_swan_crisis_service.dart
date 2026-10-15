import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

enum CrisisReason {
  medicalEmergency,
  jobLoss,
  businessShock,
  familyEmergency,
  other,
}

class BlackSwanCrisisState {
  final bool isCrisisActive;
  final DateTime? declaredDate;
  final CrisisReason reason;
  final double monthlySurvivalBudget;
  final double totalLiquidShieldBuffer;
  final double bareMinimumEmiCommitment;
  final double pausedSnowflakePerMonth;
  final int runwayDaysRemaining;
  final bool moratoriumLetterDrafted;

  const BlackSwanCrisisState({
    this.isCrisisActive = false,
    this.declaredDate,
    this.reason = CrisisReason.medicalEmergency,
    this.monthlySurvivalBudget = 18000.0,
    this.totalLiquidShieldBuffer = 45000.0,
    this.bareMinimumEmiCommitment = 8500.0,
    this.pausedSnowflakePerMonth = 5000.0,
    this.runwayDaysRemaining = 51,
    this.moratoriumLetterDrafted = false,
  });

  String get reasonLabel {
    switch (reason) {
      case CrisisReason.medicalEmergency:
        return 'Medical Emergency';
      case CrisisReason.jobLoss:
        return 'Sudden Job Loss / Transition';
      case CrisisReason.businessShock:
        return 'Business / Freelance Cashflow Shock';
      case CrisisReason.familyEmergency:
        return 'Critical Family Crisis';
      case CrisisReason.other:
        return 'Emergency Liquidity Crunch';
    }
  }

  double get monthlyTriageBurn => monthlySurvivalBudget + bareMinimumEmiCommitment;

  Map<String, dynamic> toJson() => {
    'isCrisisActive': isCrisisActive,
    'declaredDate': declaredDate?.toIso8601String(),
    'reason': reason.name,
    'monthlySurvivalBudget': monthlySurvivalBudget,
    'totalLiquidShieldBuffer': totalLiquidShieldBuffer,
    'bareMinimumEmiCommitment': bareMinimumEmiCommitment,
    'pausedSnowflakePerMonth': pausedSnowflakePerMonth,
    'runwayDaysRemaining': runwayDaysRemaining,
    'moratoriumLetterDrafted': moratoriumLetterDrafted,
  };

  factory BlackSwanCrisisState.fromJson(Map<String, dynamic> json) {
    return BlackSwanCrisisState(
      isCrisisActive: json['isCrisisActive'] as bool? ?? false,
      declaredDate: json['declaredDate'] != null ? DateTime.parse(json['declaredDate'] as String) : null,
      reason: CrisisReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => CrisisReason.medicalEmergency,
      ),
      monthlySurvivalBudget: (json['monthlySurvivalBudget'] as num?)?.toDouble() ?? 18000.0,
      totalLiquidShieldBuffer: (json['totalLiquidShieldBuffer'] as num?)?.toDouble() ?? 45000.0,
      bareMinimumEmiCommitment: (json['bareMinimumEmiCommitment'] as num?)?.toDouble() ?? 8500.0,
      pausedSnowflakePerMonth: (json['pausedSnowflakePerMonth'] as num?)?.toDouble() ?? 5000.0,
      runwayDaysRemaining: json['runwayDaysRemaining'] as int? ?? 51,
      moratoriumLetterDrafted: json['moratoriumLetterDrafted'] as bool? ?? false,
    );
  }

  BlackSwanCrisisState copyWith({
    bool? isCrisisActive,
    DateTime? declaredDate,
    CrisisReason? reason,
    double? monthlySurvivalBudget,
    double? totalLiquidShieldBuffer,
    double? bareMinimumEmiCommitment,
    double? pausedSnowflakePerMonth,
    int? runwayDaysRemaining,
    bool? moratoriumLetterDrafted,
  }) {
    return BlackSwanCrisisState(
      isCrisisActive: isCrisisActive ?? this.isCrisisActive,
      declaredDate: declaredDate ?? this.declaredDate,
      reason: reason ?? this.reason,
      monthlySurvivalBudget: monthlySurvivalBudget ?? this.monthlySurvivalBudget,
      totalLiquidShieldBuffer: totalLiquidShieldBuffer ?? this.totalLiquidShieldBuffer,
      bareMinimumEmiCommitment: bareMinimumEmiCommitment ?? this.bareMinimumEmiCommitment,
      pausedSnowflakePerMonth: pausedSnowflakePerMonth ?? this.pausedSnowflakePerMonth,
      runwayDaysRemaining: runwayDaysRemaining ?? this.runwayDaysRemaining,
      moratoriumLetterDrafted: moratoriumLetterDrafted ?? this.moratoriumLetterDrafted,
    );
  }
}

final blackSwanCrisisProvider =
    StateNotifierProvider<BlackSwanCrisisNotifier, BlackSwanCrisisState>((ref) {
  return BlackSwanCrisisNotifier();
});

class BlackSwanCrisisNotifier extends StateNotifier<BlackSwanCrisisState> {
  static const String _prefKey = 'duedo_black_swan_crisis_state_v1';

  BlackSwanCrisisNotifier() : super(const BlackSwanCrisisState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = BlackSwanCrisisState.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.toJson());
    await prefs.setString(_prefKey, jsonStr);
  }

  Future<void> declareCrisis({
    required CrisisReason reason,
    required double monthlySurvivalBudget,
    required double liquidBuffer,
    required double minimumEmi,
    required double pausedSnowflakes,
  }) async {
    HapticService.savageThud();

    final dailyBurn = (monthlySurvivalBudget + minimumEmi) / 30;
    final runwayDays = dailyBurn > 0 ? (liquidBuffer / dailyBurn).round().clamp(1, 720) : 30;

    state = state.copyWith(
      isCrisisActive: true,
      declaredDate: DateTime.now(),
      reason: reason,
      monthlySurvivalBudget: monthlySurvivalBudget,
      totalLiquidShieldBuffer: liquidBuffer,
      bareMinimumEmiCommitment: minimumEmi,
      pausedSnowflakePerMonth: pausedSnowflakes,
      runwayDaysRemaining: runwayDays,
      moratoriumLetterDrafted: false,
    );

    await _save();
  }

  Future<void> resolveCrisis() async {
    HapticService.dopamineCascade();

    state = state.copyWith(
      isCrisisActive: false,
      moratoriumLetterDrafted: false,
    );

    await _save();
  }

  String generateMoratoriumLetter({
    required String bankName,
    required String loanAccountNumber,
    required String borrowerName,
    int requestedMonths = 3,
  }) {
    state = state.copyWith(moratoriumLetterDrafted: true);
    _save();

    return '''
To: Branch Head / Credit Operations, $bankName
Subject: Formal Request for Temporary Hardship Moratorium & Loan Restructuring (Loan A/c: $loanAccountNumber)

Dear Sir/Madam,

I am writing to formally notify you of an unforeseen emergency liquidity event (${state.reasonLabel}) impacting my immediate household cash flow. 

I have maintained an impeccable debt repayment track record with $bankName to date. However, to avert default and protect both borrower and lender interests under the Reserve Bank of India (RBI) Regulatory Framework on Resolution of Stressed Assets and Hardship Relief Guidelines, I formally request:

1. A temporary moratorium of $requestedMonths months on the principal/EMI repayment for Loan Account $loanAccountNumber.
2. In the alternative, an extension of loan tenure by $requestedMonths months with capitalization of interest, thereby reducing immediate monthly outgo to sustainable survival levels.
3. A waiver of all penal interest and bounce charges during this interim restructuring window.

I reaffirm my total commitment to liquidating this obligation in full once emergency cashflow normalizes. I request your empathetic consideration of this restructuring proposal within 14 working days.

Yours sincerely,
$borrowerName
Loan Account Holder ($bankName A/c $loanAccountNumber)
Protected by Duedo Crisis Defibrillator
'''.trim();
  }
}
