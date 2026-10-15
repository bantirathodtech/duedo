import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import '../widgets/sovereign_command_deck.dart';
import 'freedom_time_machine_screen.dart';
import '../widgets/vampire_slasher_modal.dart';
import '../widgets/leech_audit_modal.dart';
import '../widgets/banker_combat_modal.dart';
import '../widgets/quantum_simulator_modal.dart';
import '../widgets/sovereign_codex_modal.dart';

/// Full-Screen Sovereign Playbook Tab showcasing all 9 Pillars and Specialized Financial Centers.
class PlaybookScreen extends StatelessWidget {
  const PlaybookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/brand/primary_mark.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Sovereign Playbook',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '9 Pillars of Absolute Financial Freedom',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Readiness Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF10172D) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'System Readiness: All 9 Pillars Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '100% UNLOCKED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 1.0,
                              minHeight: 5,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Specialized Financial Centers Section Header
                    Text(
                      'SPECIALIZED CENTERS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white60 : Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SovereignCommandDeck(isDark: isDark),

                    const SizedBox(height: 24),

                    // 9 Pillars Timeline Header
                    Text(
                      'THE 9 PILLARS IN DETAIL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white60 : Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 9 Pillars Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final phases = _getPillars(ctx, isDark);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildPillarCard(ctx, phases[index], isDark),
                    );
                  },
                  childCount: 9,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard(BuildContext context, PhaseFeatureInfo phase, bool isDark) {
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

          Text(
            phase.humanBenefit,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticService.selection();
                phase.onLaunch();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(
                phase.buttonLabel,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: phase.accentColor.withValues(alpha: 0.15),
                foregroundColor: phase.accentColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: phase.accentColor.withValues(alpha: 0.4), width: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PhaseFeatureInfo> _getPillars(BuildContext context, bool isDark) {
    return [
      PhaseFeatureInfo(
        phaseNumber: 1,
        title: 'Smart Debt-Payoff Engine',
        subtitle: 'Snowball (Fast Wins) & Avalanche (Max Savings)',
        icon: '⚔️',
        accentColor: const Color(0xFF00D09C),
        humanBenefit: 'Eliminates debt paralysis by calculating the exact mathematical order that saves you the maximum interest.',
        bulletPoints: [
          'Snowball for fast psychological wins',
          'Avalanche for mathematically optimal interest savings',
          'Live countdown horizon and payoff acceleration',
        ],
        buttonLabel: 'View Strike Engine',
        onLaunch: () {},
      ),
      PhaseFeatureInfo(
        phaseNumber: 2,
        title: '1-Tap UPI Quick-Pay',
        subtitle: 'Instant Clearing via GPay, PhonePe or Cred',
        icon: '⚡',
        accentColor: const Color(0xFF38BDF8),
        humanBenefit: 'No logging into clumsy banking portals. Clear EMIs and micro-snowflakes directly via Google Pay, PhonePe, or Cred.',
        bulletPoints: [
          '1-Tap deep linking with auto-filled VPA & amounts',
          'Pre-resolves official billers for HDFC, ICICI, SBI, Axis',
          'Immediate celebratory victory haptics on payment',
        ],
        buttonLabel: 'Explore Payoff Cards',
        onLaunch: () {},
      ),
      PhaseFeatureInfo(
        phaseNumber: 3,
        title: 'Cashflow & Due-Date Calendar',
        subtitle: 'Visual Monthly Schedule & Deficit Forecast',
        icon: '📅',
        accentColor: const Color(0xFF818CF8),
        humanBenefit: 'Visualizes all upcoming EMIs, credit card cycles, and monthly essentials so surprise shortfalls never happen.',
        bulletPoints: [
          'Interactive month-by-month obligation tracking',
          'Proactive push reminders 1 day and 3 days before dues',
          'Zero data ever sold to third-party telemarketers',
        ],
        buttonLabel: 'Open Calendar',
        onLaunch: () {},
      ),
      PhaseFeatureInfo(
        phaseNumber: 4,
        title: 'Safe-to-Spend Daily Allowance',
        subtitle: 'Exact Guilt-Free Spending Runway For Today',
        icon: '🛡️',
        accentColor: const Color(0xFF10B981),
        humanBenefit: 'Tells you exactly how much money you can spend today without touching your debt commitments or rent reserves.',
        bulletPoints: [
          'Dynamic daily allowance calculation',
          'Unspent money rolls over into extra strike power',
          'Replaces budgeting spreadsheets with one clear number',
        ],
        buttonLabel: 'View Runway Dial',
        onLaunch: () {},
      ),
      PhaseFeatureInfo(
        phaseNumber: 5,
        title: 'Daily Streaks & Victory Trophies',
        subtitle: 'Missed-Day Protection & Cremation Ceremonies',
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FreedomTimeMachineScreen()));
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 6,
        title: 'Document Scanner & Sub Slasher',
        subtitle: 'Camera Sanction Intake & 70/20/10 Bonus Splitting',
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
          VampireSlasherModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 7,
        title: 'Couple Sync & Bank Fee Auditor',
        subtitle: 'Private Partner Goals & RBI Charge Disputes',
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
          LeechAuditModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 8,
        title: 'Credit Score Radar & Collector Combat AI',
        subtitle: 'CIBIL Optimization & Script Negotiation Practice',
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
          BankerCombatModal.show(context, isDark: isDark);
        },
      ),
      PhaseFeatureInfo(
        phaseNumber: 9,
        title: 'Future Timelines, Impulse Brake & Family Legacy',
        subtitle: 'Friend IOUs, 24h Cooling Chamber & Youth Wealth Trust',
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
          QuantumSimulatorModal.show(context, isDark: isDark);
        },
      ),
    ];
  }
}
