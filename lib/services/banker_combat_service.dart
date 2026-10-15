import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class CombatDialogueOption {
  final String dialogue;
  final int scoreDelta;
  final String feedback;
  final String rbiLegalCitation;
  final bool isHardballCounter;

  const CombatDialogueOption({
    required this.dialogue,
    required this.scoreDelta,
    required this.feedback,
    required this.rbiLegalCitation,
    required this.isHardballCounter,
  });
}

class CombatScenario {
  final String id;
  final String title;
  final String opponentName;
  final String opponentRole;
  final String avatarEmoji;
  final String initialPrompt;
  final List<CombatDialogueOption> options;

  const CombatScenario({
    required this.id,
    required this.title,
    required this.opponentName,
    required this.opponentRole,
    required this.avatarEmoji,
    required this.initialPrompt,
    required this.options,
  });
}

class BankerCombatState {
  final int totalCombatScore;
  final int drillsMasteredCount;
  final String? activeScenarioId;
  final CombatDialogueOption? lastSelectedOption;

  const BankerCombatState({
    this.totalCombatScore = 0,
    this.drillsMasteredCount = 0,
    this.activeScenarioId,
    this.lastSelectedOption,
  });

  BankerCombatState copyWith({
    int? totalCombatScore,
    int? drillsMasteredCount,
    String? activeScenarioId,
    CombatDialogueOption? lastSelectedOption,
  }) {
    return BankerCombatState(
      totalCombatScore: totalCombatScore ?? this.totalCombatScore,
      drillsMasteredCount: drillsMasteredCount ?? this.drillsMasteredCount,
      activeScenarioId: activeScenarioId ?? this.activeScenarioId,
      lastSelectedOption: lastSelectedOption ?? this.lastSelectedOption,
    );
  }
}

final bankerCombatProvider =
    StateNotifierProvider<BankerCombatNotifier, BankerCombatState>((ref) {
  return BankerCombatNotifier();
});

class BankerCombatNotifier extends StateNotifier<BankerCombatState> {
  static const String _prefKey = 'duedo_banker_combat_score_v1';

  BankerCombatNotifier() : super(const BankerCombatState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt(_prefKey) ?? 200;
    state = state.copyWith(totalCombatScore: score);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, state.totalCombatScore);
  }

  List<CombatScenario> get scenarios => [
    const CombatScenario(
      id: 'recovery-harassment',
      title: 'Harassing Telecaller Defense',
      opponentName: 'Vikram',
      opponentRole: 'Third-Party Recovery Agent',
      avatarEmoji: '👔',
      initialPrompt:
          '"You missed your EMI by 12 days! If you don\'t transfer right now, I will contact your employer and family members today!"',
      options: [
        CombatDialogueOption(
          dialogue: '"Please don\'t do that sir, I will arrange some money by tomorrow somehow..."',
          scoreDelta: -50,
          feedback: '❌ Timid surrender! Shows weakness and invites further aggressive badgering.',
          rbiLegalCitation: 'None',
          isHardballCounter: false,
        ),
        CombatDialogueOption(
          dialogue:
              '"This call is being recorded. Under RBI Master Circular on Recovery Agents Sec 2(b), contacting third parties, family, or employers is a punishable regulatory offense. State your Employee ID and Agency Name immediately so I can lodge an Ombudsman complaint."',
          scoreDelta: 150,
          feedback:
              '⚔️ Devastating counter! Calling out third-party disclosure violations under RBI mandates triggers immediate agent liability.',
          rbiLegalCitation: 'RBI Master Circular DOR.ORG.REC.65/21.04.158/2022-23 Sec 2(b)',
          isHardballCounter: true,
        ),
        CombatDialogueOption(
          dialogue: '"I will pay next week, stop disturbing me during work hours."',
          scoreDelta: 25,
          feedback: '⚠️ Neutral response. Defers the call without neutralizing harassment tactics.',
          rbiLegalCitation: 'None',
          isHardballCounter: false,
        ),
      ],
    ),
    const CombatScenario(
      id: 'fee-waiver-standoff',
      title: 'Annual Card Fee Waiver Standoff',
      opponentName: 'Sneha',
      opponentRole: 'Bank Card Retention Officer',
      avatarEmoji: '👩‍💼',
      initialPrompt:
          '"Sir, the ₹1,500 Annual Fee is system-generated and non-negotiable. We can only give you 500 reward points as a courtesy."',
      options: [
        CombatDialogueOption(
          dialogue: '"Okay, please credit the 500 reward points then."',
          scoreDelta: -20,
          feedback: '❌ Capitulation! Bank retained 100% of their fee revenue.',
          rbiLegalCitation: 'None',
          isHardballCounter: false,
        ),
        CombatDialogueOption(
          dialogue:
              '"I have spent over ₹1.8 Lakhs on this card this year with 100% on-time payments. Reverse the entire ₹1,500 fee right now or process immediate card cancellation and issue my No Dues NOC today."',
          scoreDelta: 120,
          feedback:
              '🎯 Textbook retention pivot! Banks incur huge CAC to acquire cardholders; threatening closure forces retention waiver.',
          rbiLegalCitation: 'RBI Master Direction - Credit Card and Debit Card Issuance Directions 2022',
          isHardballCounter: true,
        ),
      ],
    ),
    const CombatScenario(
      id: 'haircut-settlement',
      title: 'Lump-Sum Haircut Settlement',
      opponentName: 'Amitabh',
      opponentRole: 'Special Settlements Manager',
      avatarEmoji: '🧑‍💼',
      initialPrompt:
          '"Total outstanding with interest and penal fees is ₹1,80,000. We can close this account if you pay ₹1,40,000 within 48 hours."',
      options: [
        CombatDialogueOption(
          dialogue:
              '"The original principal was ₹90,000; the rest is compounding penal interest. I have ₹75,000 in immediate liquid funds today. If you accept ₹75,000 as Full & Final Settlement with a written NOC stating Account Closed (not Settled), I will wire it today. Otherwise, I will enter formal RBI insolvency arbitration."',
          scoreDelta: 160,
          feedback:
              '🏆 Flawless One-Time Settlement strike! Insisting on "Account Closed" NOC protects your credit bureau history from the toxic "Settled" mark.',
          rbiLegalCitation: 'RBI Prudential Framework for Resolution of Stressed Assets',
          isHardballCounter: true,
        ),
        CombatDialogueOption(
          dialogue: '"Can you do ₹1,20,000 instead of ₹1,40,000?"',
          scoreDelta: 10,
          feedback: '⚠️ Weak negotiation. Still paying inflated penal interest and leaves NOC status vulnerable.',
          rbiLegalCitation: 'None',
          isHardballCounter: false,
        ),
      ],
    ),
  ];

  Future<void> executeDialogueOption({
    required String scenarioId,
    required CombatDialogueOption option,
  }) async {
    if (option.isHardballCounter) {
      HapticService.dopamineCascade();
    } else {
      HapticService.savageThud();
    }

    final newScore = (state.totalCombatScore + option.scoreDelta).clamp(0, 5000);
    final cleared = option.isHardballCounter ? state.drillsMasteredCount + 1 : state.drillsMasteredCount;

    state = state.copyWith(
      totalCombatScore: newScore,
      drillsMasteredCount: cleared,
      activeScenarioId: scenarioId,
      lastSelectedOption: option,
    );

    await _save();
  }

  void resetFeedback() {
    state = state.copyWith(lastSelectedOption: null);
  }
}
