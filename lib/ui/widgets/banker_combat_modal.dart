import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import '../../services/banker_combat_service.dart';
import '../../services/freedom_league_service.dart';

class BankerCombatModal extends ConsumerStatefulWidget {
  final bool isDark;

  const BankerCombatModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BankerCombatModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<BankerCombatModal> createState() => _BankerCombatModalState();
}

class _BankerCombatModalState extends ConsumerState<BankerCombatModal> {
  int _activeScenarioIndex = 0;

  @override
  Widget build(BuildContext context) {
    final combat = ref.watch(bankerCombatProvider);
    final notifier = ref.read(bankerCombatProvider.notifier);
    final scenarios = notifier.scenarios;
    final currentScenario = scenarios[_activeScenarioIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF14070A) : const Color(0xFFFFF7F8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🥊', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BANKER COMBAT SIMULATOR',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF43F5E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Collection Defense & Settlement Drills',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${combat.totalCombatScore} PTS',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF43F5E),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.close, color: widget.isDark ? Colors.white54 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Scenario Selector Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final isSelected = index == _activeScenarioIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      scenarios[index].title,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFF43F5E),
                    backgroundColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                    onSelected: (val) {
                      if (val) {
                        HapticService.selection();
                        setState(() {
                          _activeScenarioIndex = index;
                          notifier.resetFeedback();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Opponent Card & Dialogue Prompt
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF2E0C13), const Color(0xFF1B070B)]
                    : [const Color(0xFFFFE4E6), const Color(0xFFFECDD3)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(currentScenario.avatarEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentScenario.opponentName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF43F5E),
                            ),
                          ),
                          Text(
                            currentScenario.opponentRole,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: widget.isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentScenario.initialPrompt,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'CHOOSE YOUR TACTICAL COUNTER:',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white54 : Colors.black45,
            ),
          ),

          const SizedBox(height: 8),

          // Options List
          Expanded(
            child: ListView.builder(
              itemCount: currentScenario.options.length,
              itemBuilder: (context, index) {
                final opt = currentScenario.options[index];
                return GestureDetector(
                  onTap: () async {
                    await notifier.executeDialogueOption(
                      scenarioId: currentScenario.id,
                      option: opt,
                    );
                    if (opt.isHardballCounter) {
                      await ref.read(freedomLeagueProvider.notifier).awardPoints(150);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: opt == combat.lastSelectedOption
                            ? (opt.isHardballCounter ? const Color(0xFF10B981) : Colors.redAccent)
                            : Colors.white.withValues(alpha: 0.1),
                        width: opt == combat.lastSelectedOption ? 1.5 : 0.8,
                      ),
                    ),
                    child: Text(
                      opt.dialogue,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Feedback Card if option selected
          if (combat.lastSelectedOption != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: combat.lastSelectedOption!.isHardballCounter
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: combat.lastSelectedOption!.isHardballCounter
                      ? const Color(0xFF10B981)
                      : Colors.redAccent,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        combat.lastSelectedOption!.feedback,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: combat.lastSelectedOption!.isHardballCounter
                              ? const Color(0xFF10B981)
                              : Colors.redAccent,
                        ),
                      ),
                      if (combat.lastSelectedOption!.rbiLegalCitation != 'None')
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.copy, size: 16, color: Color(0xFF10B981)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: combat.lastSelectedOption!.dialogue));
                            HapticService.selection();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📋 Legal Counter Script copied to clipboard!'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  if (combat.lastSelectedOption!.rbiLegalCitation != 'None') ...[
                    const SizedBox(height: 6),
                    Text(
                      'Legal Citation: ${combat.lastSelectedOption!.rbiLegalCitation}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: widget.isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
