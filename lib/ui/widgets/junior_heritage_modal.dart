import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/junior_heritage_service.dart';

class JuniorHeritageModal extends StatefulWidget {
  final bool isDark;

  const JuniorHeritageModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => JuniorHeritageModal(isDark: isDark),
    );
  }

  @override
  State<JuniorHeritageModal> createState() => _JuniorHeritageModalState();
}

class _JuniorHeritageModalState extends State<JuniorHeritageModal> {
  final _service = JuniorHeritageService();
  late String _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _selectedProfileId = _service.profiles.isNotEmpty ? _service.profiles.first.id : '';
  }

  JuniorProfile? get _selectedProfile {
    try {
      return _service.profiles.firstWhere((p) => p.id == _selectedProfileId);
    } catch (_) {
      return _service.profiles.isNotEmpty ? _service.profiles.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _selectedProfile;
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF071216) : const Color(0xFFF0FDF4),
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
                child: const Text('👑', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sovereign Heritage Trust',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Next-Gen Wealth Rings & Compounding Academy',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: widget.isDark ? Colors.white70 : Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Child Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _service.profiles.map((p) {
                final isSelected = p.id == _selectedProfileId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(p.avatar, style: const TextStyle(fontSize: 14)),
                    label: Text('${p.name} (Age ${p.age})'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: widget.isDark ? const Color(0xFF11221D) : Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF10B981) : (widget.isDark ? Colors.white12 : Colors.black12),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        HapticService.selection();
                        setState(() => _selectedProfileId = p.id);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          if (profile == null)
            const Center(child: Text('No junior profile found.'))
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Three Daily Wealth Rings
                  _buildWealthRingsCard(profile, currencyFmt),

                  const SizedBox(height: 14),

                  // Sovereign Compounding Vault
                  _buildCompoundingVaultCard(profile, currencyFmt),

                  const SizedBox(height: 14),

                  // Chores & Quests Section
                  _buildChoresSection(profile, currencyFmt),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWealthRingsCard(JuniorProfile profile, NumberFormat currencyFmt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0B1E19) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
              Text(
                'Daily Wealth Rings',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.ringStreakDays}d Ring Streak',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRingMetric(
                  label: 'SAVE',
                  emoji: '🌱',
                  color: const Color(0xFF10B981),
                  amount: currencyFmt.format(profile.totalSaved),
                  progress: profile.saveRingProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRingMetric(
                  label: 'SPEND',
                  emoji: '🛒',
                  color: const Color(0xFF3B82F6),
                  amount: currencyFmt.format(profile.totalSpent),
                  progress: profile.spendRingProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRingMetric(
                  label: 'GIVE',
                  emoji: '💖',
                  color: const Color(0xFFEC4899),
                  amount: currencyFmt.format(profile.totalGiven),
                  progress: profile.giveRingProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRingMetric({
    required String label,
    required String emoji,
    required Color color,
    required String amount,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundingVaultCard(JuniorProfile profile, NumberFormat currencyFmt) {
    // Project 10-year growth if ₹1,000/mo is invested
    final projectedTenYear = _service.projectCompoundGrowth(
      initialPrincipal: profile.compoundingFundBalance,
      monthlyContribution: 1000,
      years: 10,
      annualRate: 0.12,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [const Color(0xFF132F23), const Color(0xFF0F1C2D)]
              : [const Color(0xFFECFDF5), const Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Compounding Asset Trust (Index Fund)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vault Capital',
                    style: GoogleFonts.inter(fontSize: 11, color: widget.isDark ? Colors.white60 : Colors.black54),
                  ),
                  Text(
                    currencyFmt.format(profile.compoundingFundBalance),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Age ${profile.age + 10} Potential (12% CAGR)',
                    style: GoogleFonts.inter(fontSize: 11, color: widget.isDark ? Colors.white60 : Colors.black54),
                  ),
                  Text(
                    currencyFmt.format(projectedTenYear),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: profile.liquidBalance >= 100
                ? () {
                    HapticService.medium();
                    setState(() {
                      _service.transferToCompoundingFund(profile.id, 500);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✨ ₹500 transferred to ${profile.name}\'s Compounding Vault!'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.bolt, size: 16),
            label: Text(
              'Transfer ₹500 to Compounding Vault',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoresSection(JuniorProfile profile, NumberFormat currencyFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quests & Chores (${profile.chores.length})',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddChoreDialog(profile),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Quest'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...profile.chores.map((chore) => _buildChoreTile(profile, chore, currencyFmt)),
      ],
    );
  }

  Widget _buildChoreTile(JuniorProfile profile, ChoreItem chore, NumberFormat currencyFmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F1A17) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: chore.isVerifiedByParent
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : (chore.isCompleted ? Colors.amber.withValues(alpha: 0.3) : (widget.isDark ? Colors.white10 : Colors.black12)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            chore.isVerifiedByParent
                ? Icons.check_circle
                : (chore.isCompleted ? Icons.hourglass_top : Icons.radio_button_unchecked),
            color: chore.isVerifiedByParent
                ? const Color(0xFF10B981)
                : (chore.isCompleted ? Colors.amber : (widget.isDark ? Colors.white38 : Colors.black38)),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: chore.isVerifiedByParent ? TextDecoration.lineThrough : null,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  chore.isVerifiedByParent
                      ? 'Verified & Paid into Savings'
                      : (chore.isCompleted ? 'Awaiting Parent Verification' : 'Pending Completion'),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: chore.isVerifiedByParent
                        ? const Color(0xFF10B981)
                        : (chore.isCompleted ? Colors.amber : (widget.isDark ? Colors.white38 : Colors.black38)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${currencyFmt.format(chore.rewardAmount)}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
              if (!chore.isVerifiedByParent) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    HapticService.selection();
                    setState(() {
                      if (!chore.isCompleted) {
                        _service.markChoreDone(profile.id, chore.id);
                      } else {
                        _service.verifyAndPayoutChore(profile.id, chore.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: chore.isCompleted ? const Color(0xFF10B981) : Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chore.isCompleted ? 'Verify & Pay' : 'Mark Done',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: chore.isCompleted ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showAddChoreDialog(JuniorProfile profile) {
    final titleCtrl = TextEditingController();
    final rewardCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF11221D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Assign Quest to ${profile.name}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Quest / Chore Title',
                hintText: 'e.g. Clean bookshelf & catalog books',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rewardCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reward (₹)',
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
            onPressed: () {
              final title = titleCtrl.text.trim();
              final reward = double.tryParse(rewardCtrl.text.trim()) ?? 100;
              if (title.isNotEmpty) {
                setState(() {
                  _service.addChore(profile.id, title: title, reward: reward);
                });
                Navigator.pop(ctx);
                HapticService.medium();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
