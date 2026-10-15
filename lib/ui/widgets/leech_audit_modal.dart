import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/haptic_service.dart';
import '../../services/leech_hunter_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class LeechAuditModal extends ConsumerWidget {
  final bool isDark;

  const LeechAuditModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeechAuditModal(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final state = ref.watch(leechHunterServiceProvider);
    final notifier = ref.read(leechHunterServiceProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF140D07) : const Color(0xFFFFFBF5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREDATORY FEE HUNTER',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF59E0B),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Shadow Statement Audit & RBI Reversal Concierge',
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

          // Total Leached Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2E1505), const Color(0xFF1E0A02)]
                    : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'TOTAL LEACHED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEF4444),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${NumberFormat('#,##,###').format(state.totalLeachedAmount.round())}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      '${state.totalDaysDestroyed} days stolen',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent),
                    ),
                  ],
                ),
                Container(width: 1, height: 42, color: Colors.grey.withValues(alpha: 0.3)),
                Column(
                  children: [
                    Text(
                      'RECOVERED / WAIVED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${NumberFormat('#,##,###').format(state.totalRecoveredAmount.round())}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      '${state.waivedLeeches.length} leeches crushed',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scan or Add Statement Action Bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQuickAuditDialog(context, notifier),
                  icon: const Icon(Icons.document_scanner, size: 16, color: Color(0xFFF59E0B)),
                  label: Text(
                    'Audit New Statement',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // List Header
          Text(
            'DETECTED PREDATORY CHARGES (${state.leeches.length})',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 8),

          // Leeches List
          Expanded(
            child: state.leeches.isEmpty
                ? Center(
                    child: Text(
                      '🛡️ Clean statement! No predatory fees detected.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: state.leeches.length,
                    itemBuilder: (context, index) {
                      final leech = state.leeches[index];
                      final isWaived = leech.status == LeechStatus.waived;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (isWaived ? Colors.white.withValues(alpha: 0.03) : const Color(0xFF1E140C))
                              : (isWaived ? Colors.grey.shade100 : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWaived
                                ? Colors.green.withValues(alpha: 0.3)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isWaived ? '✅' : '⚠️',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        leech.feeLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : Colors.black87,
                                          decoration: isWaived ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      Text(
                                        '${leech.lender} • Ending ${leech.accountOrCardLast4}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$currency${leech.amount.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: isWaived ? Colors.green : const Color(0xFFEF4444),
                                      ),
                                    ),
                                    Text(
                                      'Stole ${leech.daysOfFreedomDestroyed}d freedom',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: isWaived ? Colors.green : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _viewDisputeLetter(context, leech, isDark),
                                  icon: const Icon(Icons.description, size: 14, color: Color(0xFFF59E0B)),
                                  label: Text(
                                    'RBI Dispute Letter',
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFF59E0B)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: isWaived
                                      ? null
                                      : () async {
                                          await notifier.markStatus(leech.id, LeechStatus.waived);
                                          await ref.read(freedomLeagueProvider.notifier).awardPoints(150);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '🎉 Charge Waived! Recovered $currency${leech.amount.toStringAsFixed(0)} & earned +150 League Points!',
                                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                ),
                                                backgroundColor: const Color(0xFF10B981),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.check_circle, size: 14, color: Colors.white),
                                  label: Text(
                                    isWaived ? 'Waived' : 'Mark Waived',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isWaived ? Colors.grey : const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
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

  void _showQuickAuditDialog(BuildContext context, LeechHunterNotifier notifier) {
    final textController = TextEditingController(
      text: '''HDFC Credit Card Statement Ending 4091
Finance Charge: ₹450.00
GST @ 18%: ₹81.00
Late Payment Fee: ₹750.00''',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A120B) : Colors.white,
        title: Text(
          'Quick Statement Leech Audit',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste excerpt or charges from your credit card/loan statement:',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 5,
              style: GoogleFonts.robotoMono(fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final found = await notifier.scanStatementText(
                textController.text,
                lender: 'HDFC Bank',
                last4: '4091',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🔍 Audit Complete: Detected ${found.length} predatory charges!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFFF59E0B),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            child: const Text('Run Leech Scan'),
          ),
        ],
      ),
    );
  }

  void _viewDisputeLetter(BuildContext context, LeechChargeItem leech, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C130D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RBI Dispute Draft',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Citing RBI Circular RBI/2023-24/53 for ₹${leech.amount.toStringAsFixed(0)} Reversal',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black45 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    leech.disputeLetter,
                    style: GoogleFonts.robotoMono(fontSize: 11, height: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: leech.disputeLetter));
                      HapticService.selection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 RBI Dispute Letter copied to clipboard!'),
                          backgroundColor: Color(0xFFF59E0B),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Letter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'grievance.redressal@bank.com',
                        query: 'subject=Dispute on ${leech.feeLabel}&body=${Uri.encodeComponent(leech.disputeLetter)}',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Open Mail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
