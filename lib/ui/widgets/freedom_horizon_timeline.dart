import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/database.dart';
import '../../models/app_enums.dart';
import '../theme/app_theme.dart';
import '../screens/add_obligation_screen.dart';

/// Interactive "Freedom Horizon" Domino & Fortress Target Timeline
/// Transforms static date lists into an empowering chronological domino progression,
/// leading step-by-step toward the final Sovereign Zero-Debt Day.
class FreedomHorizonTimeline extends StatelessWidget {
  final List<Obligation> obligations;
  final NumberFormat currencyFormat;
  final bool isDark;

  const FreedomHorizonTimeline({
    super.key,
    required this.obligations,
    required this.currencyFormat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Sort active debts by payoff priority order
    final activeDebts = obligations
        .where((o) => o.isActive && o.status != ObligationStatus.paid && (o.type == ObligationType.emi || o.type == ObligationType.oneTime))
        .toList();

    activeDebts.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (activeDebts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1424) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D09C).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Absolute Freedom Horizon Reached',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'All debt fortresses have been completely conquered.',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.timeline_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Freedom Horizon Targets',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeDebts.length} TARGETS',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF818CF8),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Domino Tape
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activeDebts.length + 1, // +1 for the Final Freedom Day Fortress
            itemBuilder: (context, index) {
              if (index == activeDebts.length) {
                // Final Zero Debt Fortress Goal
                return _buildFinalFreedomDomino(context);
              }

              final debt = activeDebts[index];
              return _buildDebtTargetDomino(context, debt, index + 1, index == 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDebtTargetDomino(BuildContext context, Obligation debt, int rank, bool isNextTarget) {
    final targetDate = debt.endDate ?? debt.nextDueDate ?? DateTime.now().add(const Duration(days: 90));

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddObligationScreen(obligation: debt)),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF11172A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isNextTarget
                ? const Color(0xFFF43F5E).withValues(alpha: 0.7)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: isNextTarget ? 1.5 : 0.8,
          ),
          boxShadow: isNextTarget
              ? [
                  BoxShadow(
                    color: const Color(0xFFF43F5E).withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isNextTarget
                        ? const Color(0xFFF43F5E).withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isNextTarget ? '🎯 ACTIVE' : '#$rank',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: isNextTarget ? const Color(0xFFF43F5E) : Colors.grey,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    debt.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(debt.amount),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isNextTarget ? const Color(0xFFF43F5E) : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.flag_rounded, size: 11, color: Color(0xFF38BDF8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Slay: ${DateFormat('MMM yyyy').format(targetDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF38BDF8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalFreedomDomino(BuildContext context) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF063327), const Color(0xFF0A1F19)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00D09C).withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🏁 FREEDOM',
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00D09C),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Text('👑', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zero Debt Day',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF064E3B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '100% Free',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00D09C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.lock_open_rounded, size: 11, color: Color(0xFF00D09C)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Total Sovereign Life',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00D09C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
