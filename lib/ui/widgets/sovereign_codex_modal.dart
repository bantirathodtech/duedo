import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import 'sovereign_command_deck.dart';
import '../screens/freedom_time_machine_screen.dart';
import 'vampire_slasher_modal.dart';
import 'leech_audit_modal.dart';
import 'banker_combat_modal.dart';
import 'quantum_simulator_modal.dart';

class PhaseFeatureInfo {
  final int phaseNumber;
  final String title;
  final String subtitle;
  final String icon;
  final Color accentColor;
  final String humanBenefit;
  final List<String> bulletPoints;
  final VoidCallback onLaunch;
  final String buttonLabel;

  const PhaseFeatureInfo({
    required this.phaseNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.humanBenefit,
    required this.bulletPoints,
    required this.onLaunch,
    this.buttonLabel = 'Experience Feature',
  });
}

/// The Interactive 9-Phase Sovereign Roadmap & Feature Codex.
/// Enables any user to effortlessly understand, explore, and launch all 9 phases in seconds.
class SovereignCodexModal extends StatelessWidget {
  final bool isDark;

  const SovereignCodexModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SovereignCodexModal(isDark: isDark),
    );
  }

  List<PhaseFeatureInfo> _getPhases(BuildContext context) {
    return [
      PhaseFeatureInfo(
        phaseNumber: 1,
        title: 'Tactical Payoff Engine',
        subtitle: 'Mathematical Snowball & Avalanche',
        icon: '⚔️',
        accentColor: const Color(0xFF00D09C),
        humanBenefit: 'Eliminates debt paralysis by calculating the exact mathematical order that saves you the maximum interest.',
        bulletPoints: [
          'Snowball for fast psychological wins',
          'Avalanche for mathematically optimal interest savings',
          'Live countdown horizon and payoff acceleration',
        ],
        buttonLabel: 'View Strike Engine',
        onLaunch: () => Navigator.pop(context),
      ),
      PhaseFeatureInfo(
        phaseNumber: 2,
        title: '1-Tap UPI Fast Slay',
        subtitle: 'Frictionless Instant Debt Clearing',
        icon: '⚡',
        accentColor: const Color(0xFF38BDF8),
        humanBenefit: 'No logging into clumsy banking portals. Clear EMIs and micro-snowflakes directly via Google Pay, PhonePe, or Cred.',
        bulletPoints: [
          '1-Tap deep linking with auto-filled VPA & amounts',
          'Pre-resolves official billers for HDFC, ICICI, SBI, Axis',
          'Immediate celebratory victory haptics on payment',
        ],
        buttonLabel: 'Explore Payoff Cards',
        onLaunch: () => Navigator.pop(context),
      ),
      PhaseFeatureInfo(
        phaseNumber: 3,
        title: 'Smart Sovereign Calendar',
        subtitle: 'Zero-Deficit Obligation Forecast',
        icon: '📅',
        accentColor: const Color(0xFF818CF8),
        humanBenefit: 'Visualizes all upcoming EMIs, credit card cycles, and monthly essentials so surprise shortfalls never happen.',
        bulletPoints: [
          'Interactive month-by-month obligation tracking',
          'Proactive push reminders 1 day and 3 days before dues',
          'Zero data ever sold to third-party telemarketers',
        ],
        buttonLabel: 'Open Calendar',
        onLaunch: () => Navigator.pop(context),
      ),
      PhaseFeatureInfo(
        phaseNumber: 4,
        title: 'Safe-to-Spend Runway Dial',
        subtitle: 'Guilt-Free Daily Allowance',
        icon: '🛡️',
        accentColor: const Color(0xFF10B981),
        humanBenefit: 'Tells you exactly how much money you can spend today without touching your debt commitments or rent reserves.',
        bulletPoints: [
          'Dynamic daily allowance calculation',
          'Unspent money rolls over into extra strike power',
          'Replaces budgeting spreadsheets with one clear number',
        ],
        buttonLabel: 'View Runway Dial',
        onLaunch: () => Navigator.pop(context),
      ),
      PhaseFeatureInfo(
        phaseNumber: 5,
        title: 'Streak Armor & Debt Cremation',
        subtitle: 'Retention Psychology & Permanent Trophies',
        icon: '🔥',
        accentColor: const Color(0xFFF59E0B),
        humanBenefit: 'Never punishes an honest slip-up. Auto-deploys a Streak Shield and celebrates paid loans with a 60FPS particle cremation.',
        bulletPoints: [
          'Streak Armor auto-deploys 2 banked shields',
          'Full-screen 60FPS Debt Cremation Ceremony',
          'Hall of Slain Debts permanent trophy museum',
          'Freedom Time Machine slider showing years shaved',
        ],
        buttonLabel: 'Open Time Machine',
        onLaunch: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FreedomTimeMachineScreen()));
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 6,
        title: 'Hyper-Automation & Windfall Fortress',
        subtitle: 'Zero-Friction Intake & Leak Slasher',
        icon: '📸',
        accentColor: const Color(0xFFEF4444),
        humanBenefit: 'Eliminates manual entry entirely. Snap a photo of a bank letter, slash streaming subscriptions, and partition bonuses.',
        bulletPoints: [
          '1-Snap OCR document scanner for bank sanction letters',
          'Vampire Slasher 1-tap subscription cancel drafts',
          'Windfall Fortress 70/20/10 automated bonus partitioner',
          'Quick Tile & Voice Slay command ("Slay ₹2,000")',
        ],
        buttonLabel: 'Launch Vampire Slasher',
        onLaunch: () {
          Navigator.pop(context);
          VampireSlasherModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 7,
        title: 'Ecosystem & Household Fortress',
        subtitle: 'Anti-Predatory Defense & Couple Sync',
        icon: '🔍',
        accentColor: const Color(0xFFF43F5E),
        humanBenefit: 'Detects illegal banking fees, lets couples sync finances without shame, and provides emergency breathing room during hardships.',
        bulletPoints: [
          'Leech Hunter audits hidden bank fees & generates RBI letters',
          'Stealth Duo Syndicate for couples with private balances',
          'Black Swan Crisis Defibrillator for emergency pause',
          'Wealth Inversion Flywheel auto-channels cleared EMIs into SIPs',
        ],
        buttonLabel: 'Audit Predatory Fees',
        onLaunch: () {
          Navigator.pop(context);
          LeechAuditModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 8,
        title: 'Cultural Mastery & Sovereign Power',
        subtitle: 'CIBIL Arbitrage, Combat AI & Local Bunker',
        icon: '🎯',
        accentColor: const Color(0xFF0284C7),
        humanBenefit: 'Gives the borrower regulatory teeth. Boosts credit score before statement dates, roleplays settlement calls, and encrypts data locally.',
        bulletPoints: [
          'Bureau Strike Clock optimizes credit utilization at 7%',
          'Freedom Wrapped annual viral story milestone generator',
          'Banker Combat AI roleplay simulator to negotiate waivers',
          'Sovereign Vault local AES-256 bunker with Dead-Man switch',
        ],
        buttonLabel: 'Try Banker Combat AI',
        onLaunch: () {
          Navigator.pop(context);
          BankerCombatModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 9,
        title: 'Quantum Multiverse & Junior Trust',
        subtitle: 'P2P Hand-Loans, Somatic Brake & Legacy',
        icon: '👑',
        accentColor: const Color(0xFF8B5CF6),
        humanBenefit: 'Tracks informal loans with dignity, stops late-night regret purchases with box-breathing, and trains kids in compounding wealth.',
        bulletPoints: [
          'Informal Hand-Loan Mesh with polite WhatsApp UPI nudges',
          'Quantum Life Simulator: 3 parallel multiverse timelines',
          'Midnight Cognitive Biometric Brake: Somatic box-breathing',
          'Junior Heritage Trust: Youth rings, chores & compounding fund',
        ],
        buttonLabel: 'Simulate Multiverse',
        onLaunch: () {
          Navigator.pop(context);
          QuantumSimulatorModal.show(context, isDark: isDark);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final phases = _getPhases(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080C18) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text('📜', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Sovereign Playbook',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '9 Pillars of Absolute Financial Freedom',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mastery Progress Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10172D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'System Readiness: All 9 Pillars Active',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '100% UNLOCKED',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Scrollable Timeline of All 9 Phases
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: phases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final p = phases[i];
                return _buildPhaseCard(ctx, p);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(BuildContext context, PhaseFeatureInfo phase) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1528) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: phase.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: phase.accentColor.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase Number & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: phase.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(phase.icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PILLAR ${phase.phaseNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: phase.accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      phase.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Plain English Benefit
          Text(
            phase.humanBenefit,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          // Bullet Points
          ...phase.bulletPoints.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: phase.accentColor, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Launch Action Button with Bouncing Physics
          BouncingWidget(
            onTap: phase.onLaunch,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    phase.accentColor,
                    phase.accentColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: phase.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    phase.buttonLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
