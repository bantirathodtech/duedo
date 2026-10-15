import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/bureau_arbitrage_service.dart';
import '../../services/freedom_league_service.dart';
import '../../services/upi_payment_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class BureauStrikeModal extends ConsumerWidget {
  final bool isDark;

  const BureauStrikeModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BureauStrikeModal(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final state = ref.watch(bureauArbitrageProvider);
    final notifier = ref.read(bureauArbitrageProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070F19) : const Color(0xFFF0F9FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35)),
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
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUREAU STRIKE CLOCK',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0284C7),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'CIBIL Statement Date Arbitrage Concierge',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Total Potential Boost Hero Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0C2740), const Color(0xFF071727)]
                    : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'POTENTIAL CIBIL BOOST',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${state.totalPotentialScoreBoost} PTS',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'via statement arbitrage',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.green),
                    ),
                  ],
                ),
                Container(width: 1, height: 42, color: Colors.grey.withValues(alpha: 0.3)),
                Column(
                  children: [
                    Text(
                      'RECOMMENDED STRIKE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0284C7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${NumberFormat('#,##,###').format(state.totalArbitrageStrikesRecommended.round())}',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'to hit optimal 7% sweet spot',
                      style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Invisibility Cloak Explanation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bureau Invisibility Cloak: Bureaus record the balance on Statement Date, NOT Due Date. Paying early locks your score.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'ACTIVE CREDIT CARDS & STRIKE WINDOWS (${state.cards.length})',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: state.cards.length,
              itemBuilder: (context, index) {
                final card = state.cards[index];
                final isWindowOpen = card.isStrikeWindowOpen;
                final util = card.currentUtilizationPct;
                final isOptimal = util <= 10.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isWindowOpen
                          ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isWindowOpen ? 1.2 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.cardTitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${card.lender} • Limit: $currency${NumberFormat('#,##,###').format(card.creditLimit.round())}',
                                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isWindowOpen ? const Color(0xFF0284C7) : Colors.grey)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isWindowOpen ? 'STRIKE WINDOW OPEN' : '${card.daysUntilCutoff}d to Cutoff',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isWindowOpen ? const Color(0xFF0284C7) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Utilization meter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reported Utilization: ${util.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isOptimal ? Colors.green : (util > 40 ? Colors.redAccent : Colors.amber),
                            ),
                          ),
                          Text(
                            'Sweet Spot: 7.0%',
                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (util / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOptimal ? const Color(0xFF10B981) : (util > 40 ? const Color(0xFFEF4444) : Colors.amber),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Button
                      if (card.recommendedArbitrageStrikeAmount > 0)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Slay $currency${NumberFormat('#,##,###').format(card.recommendedArbitrageStrikeAmount.round())} now to lock +${card.estimatedScoreBoostPoints} pts',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _executeArbitrageStrike(context, card, notifier, ref, currency),
                              icon: const Icon(Icons.flash_on, size: 14, color: Colors.white),
                              label: const Text('Arbitrage Slay'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '✅ Optimal 7% utilization achieved! Bureau will report perfect tier.',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.green),
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

  void _executeArbitrageStrike(
    BuildContext context,
    CreditCardBureauWindow card,
    BureauArbitrageNotifier notifier,
    WidgetRef ref,
    String currency,
  ) async {
    final amt = card.recommendedArbitrageStrikeAmount;

    // Launch UPI Deep Link with card biller VPA
    await UpiPaymentService.launchUpiPayment(
      vpa: UpiPaymentService.getVpaForLender(card.lender),
      payeeName: card.cardTitle,
      amount: amt,
      transactionNote: 'Duedo_Bureau_Arbitrage',
    );

    await notifier.recordArbitrageSlay(cardId: card.cardId, strikeAmount: amt);
    await ref.read(freedomLeagueProvider.notifier).awardPoints(150);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎯 Slayed $currency${amt.toStringAsFixed(0)} on ${card.cardTitle}! Invisibility cloak deployed (+150 pts)!'),
          backgroundColor: const Color(0xFF0284C7),
        ),
      );
    }
  }
}
