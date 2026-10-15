import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';

class FreedomTapeModal extends StatefulWidget {
  final FreedomTapeMetrics metrics;
  final NumberFormat currencyFormat;
  final bool isDark;

  const FreedomTapeModal({
    super.key,
    required this.metrics,
    required this.currencyFormat,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required FreedomTapeMetrics metrics,
    required NumberFormat currencyFormat,
    required bool isDark,
  }) {
    HapticService.dopamineCascade();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FreedomTapeModal(
        metrics: metrics,
        currencyFormat: currencyFormat,
        isDark: isDark,
      ),
    );
  }

  @override
  State<FreedomTapeModal> createState() => _FreedomTapeModalState();
}

class _FreedomTapeModalState extends State<FreedomTapeModal> {
  int _activeSlide = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.metrics;
    final format = widget.currencyFormat;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0F18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Story Progress Ticks (Instagram/Spotify Wrapped style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _activeSlide ? const Color(0xFFFFD700) : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Story Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) {
                HapticService.selection();
                setState(() => _activeSlide = idx);
              },
              children: [
                _buildSlide1InterestKilled(metrics, format),
                _buildSlide2VaultShield(metrics, format),
                _buildSlide3StreakFreedom(metrics),
                _buildSlide4ShareCard(metrics, format),
              ],
            ),
          ),

          // Bottom Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeSlide > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.white54)),
                  )
                else
                  const SizedBox(width: 48),

                if (_activeSlide < 3)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share to Story'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      HapticService.selection();
                      Share.share(
                        '🎬 My Duedo Monthly Freedom Tape:\n'
                        '• Reclaimed ${metrics.freedomDaysGained} days of pure life freedom\n'
                        '• Slayed ${format.format(metrics.totalInterestKilled)} in compound interest\n'
                        '• ${metrics.streakDays}-day unbroken discipline streak\n\n'
                        'Track your debt freedom on Duedo!',
                        subject: 'My Monthly Freedom Tape',
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide1InterestKilled(FreedomTapeMetrics metrics, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: Colors.redAccent, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Vampire Bleed Slayed',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'This month, your aggressive snowflake prepayments and clean days killed',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            format.format(metrics.totalInterestKilled),
            style: GoogleFonts.outfit(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF5252),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'in pure compound bank interest.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2VaultShield(FreedomTapeMetrics metrics, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'The Impulse Shield',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'By pausing 24 hours in the Cooling Vault, you successfully protected',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            format.format(metrics.totalShieldedFromVault),
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'from emotional shopping leakage.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3StreakFreedom(FreedomTapeMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9100).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF9100), size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Discipline Velocity',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Your unbroken streak pulled your debt-free target date closer by',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            '+${metrics.freedomDaysGained} DAYS',
            style: GoogleFonts.outfit(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF9100),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Projected Debt Free Horizon: ${metrics.projectedDebtFreeYear}',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide4ShareCard(FreedomTapeMetrics metrics, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Luxury Shareable Card Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1D2D), Color(0xFF111422)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DUEDO FREEDOM TAPE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      metrics.monthName,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${metrics.freedomDaysGained} Days Reclaimed',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Killed ${format.format(metrics.totalInterestKilled)} compound interest with an unbroken ${metrics.streakDays}-day discipline streak.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('STREAK', '🔥 ${metrics.streakDays}d'),
                      _buildMiniStat('STATUS', '👑 Sovereign'),
                      _buildMiniStat('HORIZON', '${metrics.projectedDebtFreeYear}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🔒 100% Privacy Preserved: Private bank balances are never displayed.',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}
