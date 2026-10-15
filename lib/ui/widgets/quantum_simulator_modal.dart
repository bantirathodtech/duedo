import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/quantum_life_simulator_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class QuantumSimulatorModal extends ConsumerStatefulWidget {
  final bool isDark;

  const QuantumSimulatorModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuantumSimulatorModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<QuantumSimulatorModal> createState() => _QuantumSimulatorModalState();
}

class _QuantumSimulatorModalState extends ConsumerState<QuantumSimulatorModal> {
  double _userAge = 29;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final state = ref.watch(quantumLifeSimulatorProvider);
    final notifier = ref.read(quantumLifeSimulatorProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF070B19) : const Color(0xFFF5F7FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35)),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔮', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUANTUM LIFE SIMULATOR',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6366F1),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Parallel Multiverse Timeline War-Room',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: widget.isDark ? Colors.white54 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Age Slider Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Text(
                  'Current Age: ${_userAge.toInt()} yrs',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: _userAge,
                    min: 20,
                    max: 60,
                    divisions: 40,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) {
                      setState(() => _userAge = val);
                      notifier.simulateTimelines(
                        monthlyIncome: state.monthlyIncome,
                        totalDebt: state.totalDebt,
                        currentMonthlyEmi: state.currentMonthlyEmi,
                        currentAge: val.toInt(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '3 PARALLEL MULTIVERSE REALITIES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white54 : Colors.black45,
            ),
          ),

          const SizedBox(height: 8),

          // 3 Timelines List
          Expanded(
            child: ListView.builder(
              itemCount: state.timelines.length,
              itemBuilder: (context, index) {
                final t = state.timelines[index];
                final color = Color(t.colorHex);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(t.icon, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    t.subtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: widget.isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Debt Free: Age ${t.debtFreeAge}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Colors.white10),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL INTEREST PAID',
                                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              Text(
                                '$currency${NumberFormat.compact().format(t.totalInterestPaid)}',
                                style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PROJECTED NET WORTH (10 YR)',
                                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              Text(
                                '$currency${NumberFormat.compact().format(t.projectedNetWorth10Yr)}',
                                style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Lock in Timeline Gamma
          ElevatedButton.icon(
            onPressed: () {
              ref.read(freedomLeagueProvider.notifier).awardPoints(200);
              HapticService.dopamineCascade();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚡ Quantum Trajectory Synced! Timeline Gamma locked as primary target (+200 pts)!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              'Lock In Timeline Gamma (Aggressive Blitz)',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
