import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/wealth_inversion_service.dart';
import '../../services/freedom_league_service.dart';
import '../../services/upi_payment_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class WealthFlywheelModal extends ConsumerWidget {
  final bool isDark;

  const WealthFlywheelModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WealthFlywheelModal(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final wealth = ref.watch(wealthInversionProvider);
    final notifier = ref.read(wealthInversionProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F140D) : const Color(0xFFF7FDF4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🚀', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEALTH INVERSION FLYWHEEL',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Post-Debt Compounding Acceleration Engine',
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

          const SizedBox(height: 16),

          // Total Wealth Accumulated Radiant Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF142E1B), const Color(0xFF0A180E)]
                    : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'ACCUMULATED SOVEREIGN WEALTH',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$currency${NumberFormat('#,##,###').format(wealth.totalWealthAccumulated.round())}',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Redirecting $currency${NumberFormat('#,##,###').format(wealth.previousMonthlyEmiRedirected.round())}/mo from dead EMIs to Compounding Wealth',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compounding Growth Milestones Carousel
          Text(
            '12% CAGR COMPOUNDING TRAJECTORY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildProjectionPill('5 YEARS', wealth.projectedWealth5Yr, currency, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProjectionPill('10 YEARS', wealth.projectedWealth10Yr, currency, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProjectionPill('15 YEARS', wealth.projectedWealth15Yr, currency, isDark),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active Wealth Buckets
          Text(
            'WEALTH ALLOCATION BUCKETS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: wealth.buckets.length,
              itemBuilder: (context, index) {
                final bucket = wealth.buckets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Text(bucket.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bucket.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${bucket.percentageShare.toStringAsFixed(0)}% Split • $currency${NumberFormat('#,##,###').format(bucket.allocatedMonthly.round())}/mo • ${bucket.expectedCagr}% CAGR',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showInvestDialog(context, bucket, notifier, ref, currency),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          '+ Invest',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
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

  Widget _buildProjectionPill(String years, double amount, String currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            years,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currency${NumberFormat.compact().format(amount)}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showInvestDialog(
    BuildContext context,
    WealthBucket bucket,
    WealthInversionNotifier notifier,
    WidgetRef ref,
    String currency,
  ) {
    final amtCtrl = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111E13) : Colors.white,
        title: Text('Invest in ${bucket.title}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter amount to allocate into compounding bucket:', style: GoogleFonts.inter(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '$currency ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amtCtrl.text) ?? 1000.0;
              Navigator.pop(ctx);
              await notifier.logWealthStrike(bucketId: bucket.id, amount: amt);
              await ref.read(freedomLeagueProvider.notifier).awardPoints(150);

              // Launch UPI Deep Link
              await UpiPaymentService.launchUpiPayment(
                vpa: 'invest@upi',
                payeeName: bucket.title,
                amount: amt,
                transactionNote: 'Duedo_Wealth_Inversion',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🌱 Added $currency${amt.toStringAsFixed(0)} to ${bucket.title}! Compounding ignited! (+150 pts)'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Strike Wealth'),
          ),
        ],
      ),
    );
  }
}
