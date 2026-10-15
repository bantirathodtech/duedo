import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/slain_debt_trophy_service.dart';
import '../../services/haptic_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';

class HallOfSlainDebtsScreen extends ConsumerWidget {
  const HallOfSlainDebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trophies = ref.watch(slainDebtTrophyProvider);
    final homeState = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final format = NumberFormat.simpleCurrency(
      name: homeState.settings?.currency ?? '₹',
      decimalDigits: 0,
    );

    double totalCrushed = 0;
    double totalInterestKilled = 0;
    for (final t in trophies) {
      totalCrushed += t.totalBalancePaid;
      totalInterestKilled += t.totalInterestDestroyed;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E17) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Hall of Slain Debts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (trophies.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () {
                HapticService.selection();
                Share.share(
                  '🔥 I have cremated ${trophies.length} debts and destroyed ${format.format(totalInterestKilled)} in predatory bank interest using Duedo! Real financial sovereignty is earned.',
                );
              },
            ),
        ],
      ),
      body: trophies.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('⚔️', style: TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Trophy Case Awaits',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you pay off your first debt or EMI, its contract will be cremated here forever into a permanent gold medallion.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Grand Aggregated Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF261204), Color(0xFF140802)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'PERMANENT GLORY ARCHIVE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFB923C),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${trophies.length} SLAIN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFB923C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRINCIPAL CRUSHED',
                                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white54),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  format.format(totalCrushed),
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INTEREST PREVENTED',
                                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFFF97316)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  format.format(totalInterestKilled),
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFF97316),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Trophies List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    physics: const BouncingScrollPhysics(),
                    itemCount: trophies.length,
                    itemBuilder: (context, index) {
                      final trophy = trophies[index];
                      final dateStr = DateFormat('MMMM yyyy').format(trophy.dateSlain);

                      Color tierColor = const Color(0xFFFFD700);
                      String tierEmoji = '🥇';
                      if (trophy.medalTier == 'Diamond') {
                        tierColor = const Color(0xFF38BDF8);
                        tierEmoji = '💎';
                      } else if (trophy.medalTier == 'Silver') {
                        tierColor = const Color(0xFFCBD5E1);
                        tierEmoji = '🥈';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141724) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: tierColor.withValues(alpha: isDark ? 0.05 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Trophy Medallion
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tierColor.withValues(alpha: 0.15),
                                border: Border.all(color: tierColor, width: 1.5),
                              ),
                              child: Center(
                                child: Text(tierEmoji, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Trophy Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${trophy.medalTier.toUpperCase()} MEDALLION',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: tierColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    trophy.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Paid: ${format.format(trophy.totalBalancePaid)}',
                                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Saved: ${format.format(trophy.totalInterestDestroyed)}',
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
