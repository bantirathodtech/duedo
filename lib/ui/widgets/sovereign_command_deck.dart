import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import 'vampire_slasher_modal.dart';
import 'leech_audit_modal.dart';
import 'bureau_strike_modal.dart';
import 'banker_combat_modal.dart';
import 'document_scanner_modal.dart';
import 'informal_iou_modal.dart';
import 'syndicate_hub_modal.dart';
import 'junior_heritage_modal.dart';
import 'quantum_simulator_modal.dart';
import '../screens/freedom_time_machine_screen.dart';
import 'freedom_wrapped_modal.dart';
import '../screens/hall_of_slain_debts_screen.dart';
import 'sovereign_vault_modal.dart';
import 'windfall_fortress_modal.dart';
import 'wealth_flywheel_modal.dart';
import 'crisis_defibrillator_modal.dart';
import 'midnight_brake_modal.dart';

/// Interactive physics spring bounce wrapper for touchable cards.
class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;

  const BouncingWidget({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.96,
  });

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticService.selection();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Dynamic Context-Aware Copilot Banner that changes based on time or active conditions.
class DynamicContextBanner extends StatelessWidget {
  final bool isDark;

  const DynamicContextBanner({super.key, required this.isDark});

  bool get _isNightRiskWindow {
    final hour = DateTime.now().hour;
    return hour >= 22 || hour < 5;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNightRiskWindow) {
      return BouncingWidget(
        onTap: () => MidnightBrakeModal.show(context, isDark: isDark),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Text('🌙', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Nocturnal Risk Window Active',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC084FC),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Midnight Cognitive Brake is armed. Tap to engage Somatic Reset.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
            ],
          ),
        ),
      );
    }

    // Default daytime gladiator banner
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1523) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.25) : const Color(0xFF6366F1).withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('⚡', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Specialized Financial Centers',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Tools for debt defense, family coordination, future planning & security',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The 4-Hub Sovereign Command Deck (The Arsenal, The Alliance, Future Lab, The Vault).
class SovereignCommandDeck extends StatelessWidget {
  final bool isDark;

  const SovereignCommandDeck({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicContextBanner(isDark: isDark),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                context,
                title: 'The Arsenal',
                subtitle: 'Stop Leaks & Fees',
                emoji: '⚔️',
                badgeText: '5 Tools',
                gradientColors: isDark
                    ? [const Color(0xFF261019), const Color(0xFF160A13)]
                    : [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)],
                accentColor: const Color(0xFFF43F5E),
                onTap: () => _showArsenalSheet(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHubCard(
                context,
                title: 'The Alliance',
                subtitle: 'Family & Friend IOUs',
                emoji: '🤝',
                badgeText: '3 Systems',
                gradientColors: isDark
                    ? [const Color(0xFF0A231C), const Color(0xFF061813)]
                    : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                accentColor: const Color(0xFF10B981),
                onTap: () => _showAllianceSheet(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                context,
                title: 'Future Lab',
                subtitle: 'Timelines & Scenarios',
                emoji: '🔮',
                badgeText: '4 Simulators',
                gradientColors: isDark
                    ? [const Color(0xFF151936), const Color(0xFF0C0F22)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                accentColor: const Color(0xFF6366F1),
                onTap: () => _showWarRoomSheet(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHubCard(
                context,
                title: 'The Vault',
                subtitle: 'Security & Emergency',
                emoji: '🔐',
                badgeText: '4 Defenses',
                gradientColors: isDark
                    ? [const Color(0xFF261E0E), const Color(0xFF171207)]
                    : [const Color(0xFFFEFCE8), const Color(0xFFFEF9C3)],
                accentColor: const Color(0xFFF59E0B),
                onTap: () => _showVaultSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
    required String badgeText,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. THE ARSENAL SHEET ---
  void _showArsenalSheet(BuildContext context) {
    _showCommandSheet(
      context,
      title: 'The Combat Arsenal',
      subtitle: 'Weapons against predatory charges & banking leaks',
      emoji: '⚔️',
      accentColor: const Color(0xFFF43F5E),
      tiles: [
        _SheetTileData(
          icon: '🧛',
          title: 'Vampire Slasher',
          subtitle: 'Audit hidden subscriptions & cancel in 1 tap',
          onTap: () => VampireSlasherModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🔍',
          title: 'Leech Hunter & Predatory Fees',
          subtitle: 'Detect illegal GST/charges & generate RBI letters',
          onTap: () => LeechAuditModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🎯',
          title: 'Bureau Strike Clock',
          subtitle: 'Utilization arbitrage before statement cutoffs',
          onTap: () => BureauStrikeModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🥊',
          title: 'Banker Combat Simulator',
          subtitle: 'AI agent roleplay to negotiate interest & waivers',
          onTap: () => BankerCombatModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '📸',
          title: '1-Snap Document Scanner',
          subtitle: 'OCR scanner to extract EMIs from sanction letters',
          onTap: () => DocumentScannerModal.show(context, isDark: isDark),
        ),
      ],
    );
  }

  // --- 2. THE ALLIANCE SHEET ---
  void _showAllianceSheet(BuildContext context) {
    _showCommandSheet(
      context,
      title: 'The Sovereign Alliance',
      subtitle: 'P2P hand-loans, household partnerships & junior trusts',
      emoji: '🤝',
      accentColor: const Color(0xFF10B981),
      tiles: [
        _SheetTileData(
          icon: '🤝',
          title: 'Informal Hand-Loan Mesh',
          subtitle: 'Dignified P2P IOUs & polite WhatsApp reminders',
          onTap: () => InformalIouModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🛡️',
          title: 'Stealth Duo Syndicate',
          subtitle: 'Couple synchronization with zero financial shame',
          onTap: () => SyndicateHubModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '👑',
          title: 'Junior Heritage Trust',
          subtitle: 'Youth daily rings, verified chores & compounding vault',
          onTap: () => JuniorHeritageModal.show(context, isDark: isDark),
        ),
      ],
    );
  }

  // --- 3. THE FUTURE LAB SHEET ---
  void _showWarRoomSheet(BuildContext context) {
    _showCommandSheet(
      context,
      title: 'The Future Planning Lab',
      subtitle: 'Simulate your future, project debt-free timelines & see milestones',
      emoji: '🔮',
      accentColor: const Color(0xFF6366F1),
      tiles: [
        _SheetTileData(
          icon: '🔮',
          title: 'Future Life Simulator',
          subtitle: 'Compare 3 financial trajectories (Balanced, Home-Loan, or Debt-Sprint)',
          onTap: () => QuantumSimulatorModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '⏳',
          title: 'Freedom Time Machine',
          subtitle: 'Interactive slider showing years shaved per strike',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FreedomTimeMachineScreen()),
          ),
        ),
        _SheetTileData(
          icon: '🎬',
          title: 'Freedom Wrapped (Annual)',
          subtitle: 'Spotify-style story cards of your warrior milestones',
          onTap: () => FreedomWrappedModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🏆',
          title: 'Hall of Slain Debts',
          subtitle: 'Permanent trophy case of extinguished obligations',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HallOfSlainDebtsScreen()),
          ),
        ),
      ],
    );
  }

  // --- 4. THE VAULT SHEET ---
  void _showVaultSheet(BuildContext context) {
    _showCommandSheet(
      context,
      title: 'The Sovereign Vault',
      subtitle: 'Cryptographic security, windfall defenses & crisis recovery',
      emoji: '🔐',
      accentColor: const Color(0xFFF59E0B),
      tiles: [
        _SheetTileData(
          icon: '🔐',
          title: 'Sovereign Bunker & Dead-Man Switch',
          subtitle: 'AES-256 local encrypted vault with emergency trustee',
          onTap: () => SovereignVaultModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '💰',
          title: 'Windfall Fortress',
          subtitle: 'Automated 70/20/10 bonus & windfall partitioner',
          onTap: () => WindfallFortressModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🔄',
          title: 'Wealth Inversion Flywheel',
          subtitle: 'Channel cleared EMIs directly into compounding SIPs',
          onTap: () => WealthFlywheelModal.show(context, isDark: isDark),
        ),
        _SheetTileData(
          icon: '🚨',
          title: 'Black Swan Crisis Defibrillator',
          subtitle: 'Freeze aggressive targets & generate hardship letter',
          onTap: () => CrisisDefibrillatorModal.show(context, isDark: isDark),
        ),
      ],
    );
  }

  void _showCommandSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
    required Color accentColor,
    required List<_SheetTileData> tiles,
  }) {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090D1A) : const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: tiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final t = tiles[i];
                  return BouncingWidget(
                    onTap: () {
                      Navigator.pop(ctx);
                      t.onTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF11172A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(t.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.subtitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 20, color: Colors.white38),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTileData {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
