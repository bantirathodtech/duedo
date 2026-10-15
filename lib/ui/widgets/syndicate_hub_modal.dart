import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/household_syndicate_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class SyndicateHubModal extends ConsumerStatefulWidget {
  final bool isDark;

  const SyndicateHubModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SyndicateHubModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<SyndicateHubModal> createState() => _SyndicateHubModalState();
}

class _SyndicateHubModalState extends ConsumerState<SyndicateHubModal> {
  final _partnerCodeCtrl = TextEditingController();
  final _partnerNameCtrl = TextEditingController(text: 'Partner');
  final _jointTargetCtrl = TextEditingController(text: 'Family Primary Loan');
  final _strikeAmountCtrl = TextEditingController(text: '1000');

  @override
  void dispose() {
    _partnerCodeCtrl.dispose();
    _partnerNameCtrl.dispose();
    _jointTargetCtrl.dispose();
    _strikeAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syndicate = ref.watch(householdSyndicateProvider);
    final notifier = ref.read(householdSyndicateProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F0B18) : const Color(0xFFFAF7FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35)),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🛡️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOUSEHOLD SYNDICATE',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF8B5CF6),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Stealth Split & Joint Debt Warfare',
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

          const SizedBox(height: 12),

          // Stealth Split Privacy Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: widget.isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stealth Split Active: Private purchases remain hidden. Only shared debt slaying is pooled.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: syndicate.isConnected
                ? _buildConnectedSyndicateView(syndicate, notifier, currency)
                : _buildUnpairedSetupView(syndicate, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedSyndicateView(
    SyndicateProfile syndicate,
    HouseholdSyndicateNotifier notifier,
    String currency,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Joint Victory Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF1E1035), const Color(0xFF120824)]
                    : [const Color(0xFFEDE9FE), const Color(0xFFDDD6FE)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      syndicate.jointTargetTitle.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8B5CF6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${syndicate.duoStreakWeeks}w Duo Streak (2x pts)',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$currency${NumberFormat('#,##,###').format(syndicate.totalCombinedStrikes.round())} / $currency${NumberFormat('#,##,###').format(syndicate.jointTargetAmount.round())}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: syndicate.progressRatio,
                    minHeight: 10,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'You: ${syndicate.userContributionPercent.toStringAsFixed(0)}% ($currency${NumberFormat('#,##,###').format(syndicate.userContributedTotal.round())})',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF06B6D4)),
                    ),
                    Text(
                      '${syndicate.partnerName}: ${syndicate.partnerContributionPercent.toStringAsFixed(0)}% ($currency${NumberFormat('#,##,###').format(syndicate.partnerContributedTotal.round())})',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA855F7)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Collective Freedom Trophy Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLLECTIVE TIME RESTORED',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      Text(
                        '${syndicate.collectiveFreedomDaysSaved} Days of Debt Life Decapitated',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Duo Check-In Cards
          Text(
            'WEEKLY DISCIPLINE CHECK-IN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCheckInTile(
                  name: 'You',
                  isClean: syndicate.userCleanThisWeek,
                  onTap: () => notifier.toggleWeeklyClean(isUser: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCheckInTile(
                  name: syndicate.partnerName,
                  isClean: syndicate.partnerCleanThisWeek,
                  onTap: () => notifier.toggleWeeklyClean(isUser: false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Joint Slay Button
          ElevatedButton.icon(
            onPressed: () => _showJointStrikeDialog(context, notifier, currency),
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: Text(
              'Log Syndicate Strike',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          const SizedBox(height: 12),

          // Unlink button
          Center(
            child: TextButton(
              onPressed: () async {
                await notifier.unlinkSyndicate();
              },
              child: Text(
                'Unlink Syndicate',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInTile({
    required String name,
    required bool isClean,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isClean
              ? const Color(0xFF10B981).withValues(alpha: widget.isDark ? 0.15 : 0.1)
              : Colors.red.withValues(alpha: widget.isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isClean ? const Color(0xFF10B981) : Colors.redAccent,
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(isClean ? '🛡️' : '⚠️', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              isClean ? 'Clean Week' : 'Needs Rescue',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isClean ? const Color(0xFF10B981) : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpairedSetupView(SyndicateProfile syndicate, HouseholdSyndicateNotifier notifier) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Your Code Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'YOUR SYNDICATE CODE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  syndicate.syndicateCode,
                  style: GoogleFonts.robotoMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: syndicate.syndicateCode));
                    HapticService.selection();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📋 Syndicate Code copied! Send it to your partner.'),
                        backgroundColor: Color(0xFF8B5CF6),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Share Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'PAIR WITH PARTNER CODE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _partnerCodeCtrl,
            decoration: InputDecoration(
              hintText: 'e.g. DUEDO-SYN-1234',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _partnerNameCtrl,
            decoration: InputDecoration(
              labelText: 'Partner Name / Alias',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _jointTargetCtrl,
            decoration: InputDecoration(
              labelText: 'Shared Debt Target Name',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () async {
              final ok = await notifier.pairWithPartner(
                partnerCode: _partnerCodeCtrl.text,
                partnerName: _partnerNameCtrl.text,
                jointTarget: _jointTargetCtrl.text,
              );
              if (ok) {
                await ref.read(freedomLeagueProvider.notifier).awardPoints(200);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚔️ Household Syndicate Linked! +200 League Points & 2x Multiplier Active!'),
                      backgroundColor: Color(0xFF8B5CF6),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ Invalid code or cannot pair with own code.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.link, color: Colors.white),
            label: Text(
              'Link Household Syndicate',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showJointStrikeDialog(
    BuildContext context,
    HouseholdSyndicateNotifier notifier,
    String currency,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF160F24) : Colors.white,
        title: Text('Log Syndicate Slay', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter strike amount to credit to joint target:', style: GoogleFonts.inter(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: _strikeAmountCtrl,
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
              final amt = double.tryParse(_strikeAmountCtrl.text) ?? 500.0;
              Navigator.pop(ctx);
              await notifier.recordJointStrike(amount: amt, isUserStrike: true);
              await ref.read(freedomLeagueProvider.notifier).awardPoints(100);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('💥 Slayed $currency${amt.toStringAsFixed(0)} on Joint Target! (+100 pts)'),
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Log Strike'),
          ),
        ],
      ),
    );
  }
}
