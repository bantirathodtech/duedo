import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import '../../services/midnight_brake_service.dart';
import '../../services/impulse_vault_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class MidnightBrakeModal extends ConsumerStatefulWidget {
  final bool isDark;

  const MidnightBrakeModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MidnightBrakeModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<MidnightBrakeModal> createState() => _MidnightBrakeModalState();
}

class _MidnightBrakeModalState extends ConsumerState<MidnightBrakeModal> with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController(text: '5499');
  late AnimationController _animCtrl;
  String _breathPhase = 'Inhale deeply...';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _breathPhase = 'Exhale slowly...');
          _animCtrl.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _breathPhase = 'Inhale deeply...');
          _animCtrl.forward();
        }
      });
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final income = homeState.settings?.monthlyIncome ?? 85000.0;

    final amt = double.tryParse(_amountCtrl.text) ?? 5499.0;
    final hourlyWage = income > 0 ? (income / 160) : 500.0;
    final lifeHours = amt / (hourlyWage > 0 ? hourlyWage : 500.0);
    final daysDelay = (amt / 400.0).round().clamp(1, 90);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0A0714) : const Color(0xFFFAF5FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35)),
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
                  color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🌙', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MIDNIGHT BIOMETRIC BRAKE',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFA855F7),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Circadian Impulse & Regret Interceptor',
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

          const SizedBox(height: 14),

          // Intercepted Impulse Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tempting Night Expense',
                    prefixText: '$currency ',
                    filled: true,
                    fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Life Energy Equivalence Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF230D35), const Color(0xFF130620)]
                    : [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Text(
                  'LIFE ENERGY SACRIFICE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA855F7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${lifeHours.toStringAsFixed(1)} HOURS',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  'of your direct labor at $currency${hourlyWage.toStringAsFixed(0)}/hr',
                  style: GoogleFonts.inter(fontSize: 11, color: widget.isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⏳', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Pushes Debt Freedom Day back by $daysDelay Days',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Somatic Reset Box Breathing Widget
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, child) {
                      final scale = 0.85 + (_animCtrl.value * 0.3);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFA855F7), Color(0xFF6B21A8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                                blurRadius: 20 * scale,
                                spreadRadius: 4 * scale,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🫁', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _breathPhase,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                  Text(
                    'Reset your prefrontal cortex before confirming',
                    style: GoogleFonts.inter(fontSize: 11, color: widget.isDark ? Colors.white54 : Colors.black45),
                  ),
                ],
              ),
            ),
          ),

          // Choices
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    HapticService.dopamineCascade();
                    ref.read(midnightBrakeProvider.notifier).interceptImpulse(
                      amount: amt,
                      monthlyIncome: income,
                    );
                    ref.read(midnightBrakeProvider.notifier).markSomaticResetComplete();
                    await ref.read(impulseVaultServiceProvider.notifier).shieldImpulse(
                      title: 'Night Impulse ($currency${amt.toStringAsFixed(0)})',
                      amount: amt,
                    );
                    await ref.read(freedomLeagueProvider.notifier).awardPoints(150);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🧊 Sent to 24h Cooling Vault! Saved ${lifeHours.toStringAsFixed(1)}h of your life (+150 pts)!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.ac_unit, color: Colors.white),
                  label: const Text('Lock in 24h Vault'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  HapticService.selection();
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
