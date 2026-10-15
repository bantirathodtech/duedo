import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/haptic_service.dart';
import '../../services/informal_iou_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class InformalIouModal extends ConsumerStatefulWidget {
  final bool isDark;

  const InformalIouModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InformalIouModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<InformalIouModal> createState() => _InformalIouModalState();
}

class _InformalIouModalState extends ConsumerState<InformalIouModal> {
  int _tabIndex = 0; // 0: Lent by Me, 1: Borrowed by Me

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final state = ref.watch(informalIouProvider);
    final notifier = ref.read(informalIouProvider.notifier);

    final filteredItems = state.items.where((i) {
      if (_tabIndex == 0) {
        return i.direction == IouDirection.lentByMe;
      } else {
        return i.direction == IouDirection.borrowedByMe;
      }
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0C1318) : const Color(0xFFF0FDF4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.35)),
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
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🤝', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMAL HAND-LOAN MESH',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF14B8A6),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Zero-Awkwardness P2P IOU Concierge',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: widget.isDark ? Colors.white54 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Balance Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF0E2A27), const Color(0xFF071816)]
                    : [const Color(0xFFCCFBF1), const Color(0xFF99F6E4)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'YOU LENT OUT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF14B8A6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${NumberFormat('#,##,###').format(state.totalLentOutstanding.round())}',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF14B8A6),
                      ),
                    ),
                    Text('owed to you', style: GoogleFonts.inter(fontSize: 10, color: Colors.teal)),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
                Column(
                  children: [
                    Text(
                      'YOU BORROWED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF43F5E),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency${NumberFormat('#,##,###').format(state.totalBorrowedOutstanding.round())}',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF43F5E),
                      ),
                    ),
                    Text('you owe to others', style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tab Filter & Add Action
          Row(
            children: [
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Lent by Me')),
                    ButtonSegment(value: 1, label: Text('Borrowed')),
                  ],
                  selected: {_tabIndex},
                  onSelectionChanged: (set) {
                    HapticService.selection();
                    setState(() => _tabIndex = set.first);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showAddIouDialog(context, notifier, currency),
                icon: const Icon(Icons.add_circle, color: Color(0xFF14B8A6), size: 30),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // List of Hand-Loans
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No informal hand-loans recorded.',
                      style: GoogleFonts.inter(color: widget.isDark ? Colors.white54 : Colors.black45),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: item.isFullySettled
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.08),
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
                                        item.personName,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: widget.isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      if (item.note.isNotEmpty)
                                        Text(
                                          item.note,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: widget.isDark ? Colors.white54 : Colors.black45,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$currency${NumberFormat('#,##,###').format(item.remainingBalance.round())}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: item.isFullySettled
                                            ? Colors.green
                                            : (item.direction == IouDirection.lentByMe
                                                ? const Color(0xFF14B8A6)
                                                : const Color(0xFFF43F5E)),
                                      ),
                                    ),
                                    Text(
                                      'of $currency${NumberFormat('#,##,###').format(item.originalAmount.round())}',
                                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: item.progressRatio,
                                minHeight: 6,
                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item.isFullySettled ? Colors.green : const Color(0xFF14B8A6),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Action Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!item.isFullySettled && item.direction == IouDirection.lentByMe) ...[
                                  OutlinedButton.icon(
                                    onPressed: () => _sendDignifiedNudge(context, item, currency),
                                    icon: const Icon(Icons.chat, size: 14, color: Color(0xFF14B8A6)),
                                    label: const Text('Dignified Nudge'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF14B8A6),
                                      side: const BorderSide(color: Color(0xFF14B8A6)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                ElevatedButton(
                                  onPressed: item.isFullySettled
                                      ? null
                                      : () => _showPartialSettleDialog(context, item, notifier, currency),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF14B8A6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    item.isFullySettled ? 'Settled' : 'Partial Settle',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
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

  void _sendDignifiedNudge(BuildContext context, InformalIouItem item, String currency) async {
    final nudgeText = item.getDignifiedWhatsAppNudge('duedo.settle@upi', currency);
    Clipboard.setData(ClipboardData(text: nudgeText));
    HapticService.selection();

    final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(nudgeText)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Dignified WhatsApp Nudge copied to clipboard! Paste in chat.'),
            backgroundColor: Color(0xFF14B8A6),
          ),
        );
      }
    }
  }

  void _showPartialSettleDialog(
    BuildContext context,
    InformalIouItem item,
    InformalIouNotifier notifier,
    String currency,
  ) {
    final amtCtrl = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF101B1E) : Colors.white,
        title: Text('Record Partial Settle', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter amount settled towards ${item.personName}:', style: GoogleFonts.inter(fontSize: 12)),
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
              final amt = double.tryParse(amtCtrl.text) ?? 500.0;
              Navigator.pop(ctx);
              await notifier.recordPartialSettle(iouId: item.id, paymentAmount: amt);
              await ref.read(freedomLeagueProvider.notifier).awardPoints(100);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Settle recorded: $currency${amt.toStringAsFixed(0)}! (+100 pts)'),
                    backgroundColor: const Color(0xFF14B8A6),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B8A6)),
            child: const Text('Save Settle'),
          ),
        ],
      ),
    );
  }

  void _showAddIouDialog(BuildContext context, InformalIouNotifier notifier, String currency) {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var direction = IouDirection.lentByMe;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF101B1E) : Colors.white,
          title: Text('Add Hand-Loan / IOU', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<IouDirection>(
                  initialValue: direction,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: IouDirection.lentByMe, child: Text('I Lent Money (They owe me)')),
                    DropdownMenuItem(value: IouDirection.borrowedByMe, child: Text('I Borrowed Money (I owe them)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => direction = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Person Name / Contact',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '$currency ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Purpose / Note (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amtCtrl.text) ?? 0.0;
                if (nameCtrl.text.trim().isNotEmpty && amt > 0) {
                  Navigator.pop(ctx);
                  await notifier.addIou(
                    personName: nameCtrl.text,
                    phoneNumber: '',
                    direction: direction,
                    amount: amt,
                    note: noteCtrl.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B8A6)),
              child: const Text('Add IOU'),
            ),
          ],
        ),
      ),
    );
  }
}
