import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../services/slain_debt_trophy_service.dart';
import '../../services/haptic_service.dart';
import '../screens/hall_of_slain_debts_screen.dart';

class DebtCremationCeremonyModal extends StatefulWidget {
  final Obligation obligation;
  final NumberFormat currencyFormat;
  final SlainDebtTrophy trophy;

  const DebtCremationCeremonyModal({
    super.key,
    required this.obligation,
    required this.currencyFormat,
    required this.trophy,
  });

  static Future<void> show(
    BuildContext context, {
    required Obligation obligation,
    required NumberFormat currencyFormat,
    required SlainDebtTrophy trophy,
  }) {
    HapticService.dopamineCascade();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DebtCremationCeremonyModal(
        obligation: obligation,
        currencyFormat: currencyFormat,
        trophy: trophy,
      ),
    );
  }

  @override
  State<DebtCremationCeremonyModal> createState() => _DebtCremationCeremonyModalState();
}

class _DebtCremationCeremonyModalState extends State<DebtCremationCeremonyModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = widget.currencyFormat;
    final trophy = widget.trophy;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF260D05), Color(0xFF140702), Color(0xFF0D0301)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha: 0.25),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flame Medallion Hero
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFCC2B00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5722).withValues(alpha: 0.6),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 42)),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Text(
                  'DEBT CREMATED FOREVER',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFB923C),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trophy.title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Stats Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'PRINCIPAL CRUSHED',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white60,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                format.format(trophy.totalBalancePaid),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white12),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'INTEREST KILLED',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF97316),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                format.format(trophy.totalInterestDestroyed),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF97316),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Button: View in Hall of Slain Debts
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                    label: const Text('Add to Hall of Slain Debts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: const Color(0xFFF97316).withValues(alpha: 0.4),
                    ),
                    onPressed: () {
                      HapticService.selection();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HallOfSlainDebtsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close & Celebrate Later',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
