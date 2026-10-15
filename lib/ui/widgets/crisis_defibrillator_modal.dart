import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/haptic_service.dart';
import '../../services/black_swan_crisis_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class CrisisDefibrillatorModal extends ConsumerStatefulWidget {
  final bool isDark;

  const CrisisDefibrillatorModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CrisisDefibrillatorModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<CrisisDefibrillatorModal> createState() => _CrisisDefibrillatorModalState();
}

class _CrisisDefibrillatorModalState extends ConsumerState<CrisisDefibrillatorModal> {
  CrisisReason _selectedReason = CrisisReason.medicalEmergency;
  final _survivalBudgetCtrl = TextEditingController(text: '18000');
  final _liquidBufferCtrl = TextEditingController(text: '45000');
  final _minimumEmiCtrl = TextEditingController(text: '8500');
  final _pausedSnowflakeCtrl = TextEditingController(text: '5000');

  @override
  void dispose() {
    _survivalBudgetCtrl.dispose();
    _liquidBufferCtrl.dispose();
    _minimumEmiCtrl.dispose();
    _pausedSnowflakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crisis = ref.watch(blackSwanCrisisProvider);
    final notifier = ref.read(blackSwanCrisisProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF071412) : const Color(0xFFF0FDF4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: crisis.isCrisisActive
              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
              : const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.2,
        ),
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
                  color: (crisis.isCrisisActive ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  crisis.isCrisisActive ? '🚨' : '🛡️',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRISIS DEFIBRILLATOR',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: crisis.isCrisisActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Emergency Triage & Forbearance Armor',
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

          const SizedBox(height: 16),

          Expanded(
            child: crisis.isCrisisActive
                ? _buildActiveCrisisView(crisis, notifier, currency)
                : _buildStandbyDeclarationView(notifier, currency),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCrisisView(
    BlackSwanCrisisState crisis,
    BlackSwanCrisisNotifier notifier,
    String currency,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Runway Vital Sign Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF2B0B0E), const Color(0xFF160608)]
                    : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SURVIVAL RUNWAY PROTECTED',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEF4444),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        crisis.reasonLabel,
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${crisis.runwayDaysRemaining} DAYS',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  '100% Cashflow diverted to Grace Shield survival pool',
                  style: GoogleFonts.inter(fontSize: 11, color: widget.isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Triage Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _buildTriageRow('Essential Food & Meds', '$currency${NumberFormat('#,##,###').format(crisis.monthlySurvivalBudget.round())}/mo'),
                const Divider(height: 16),
                _buildTriageRow('Bare Minimum Obligation Interest', '$currency${NumberFormat('#,##,###').format(crisis.bareMinimumEmiCommitment.round())}/mo'),
                const Divider(height: 16),
                _buildTriageRow('Paused Aggressive Snowflakes', '$currency${NumberFormat('#,##,###').format(crisis.pausedSnowflakePerMonth.round())}/mo (0 penalty)'),
                const Divider(height: 16),
                _buildTriageRow('Total Liquid Emergency Buffer', '$currency${NumberFormat('#,##,###').format(crisis.totalLiquidShieldBuffer.round())}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bank Moratorium Letter Action
          ElevatedButton.icon(
            onPressed: () => _showMoratoriumDialog(context, notifier),
            icon: const Icon(Icons.document_scanner, color: Colors.white),
            label: Text(
              'Draft Bank Moratorium Letter',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 12),

          // Resolve Crisis Button
          OutlinedButton.icon(
            onPressed: () async {
              await notifier.resolveCrisis();
              await ref.read(freedomLeagueProvider.notifier).awardPoints(250);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Crisis Weathered Without Debt Relapse! +250 League Points Awarded!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            label: Text(
              'Resolve Crisis & Restore Normal Slaying',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF10B981)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriageRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, color: widget.isDark ? Colors.white70 : Colors.black87)),
        Text(value, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildStandbyDeclarationView(BlackSwanCrisisNotifier notifier, String currency) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Standby Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: widget.isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEFIBRILLATOR ON STANDBY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'If an emergency hits, freeze debt demands instantly without losing streaks or freedom rank.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: widget.isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text('SELECT EMERGENCY TYPE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          DropdownButtonFormField<CrisisReason>(
            initialValue: _selectedReason,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: CrisisReason.values.map((r) {
              return DropdownMenuItem(
                value: r,
                child: Text(r.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),

          const SizedBox(height: 12),

          Text('MONTHLY SURVIVAL BURN (FOOD + MEDS)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(
            controller: _survivalBudgetCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '$currency ',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 12),

          Text('AVAILABLE LIQUID EMERGENCY BUFFER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(
            controller: _liquidBufferCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '$currency ',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 12),

          Text('MINIMUM LOAN EMI OUTGO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(
            controller: _minimumEmiCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '$currency ',
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: () async {
              final survival = double.tryParse(_survivalBudgetCtrl.text) ?? 18000.0;
              final buffer = double.tryParse(_liquidBufferCtrl.text) ?? 45000.0;
              final minEmi = double.tryParse(_minimumEmiCtrl.text) ?? 8500.0;
              final pausedSnow = double.tryParse(_pausedSnowflakeCtrl.text) ?? 5000.0;

              await notifier.declareCrisis(
                reason: _selectedReason,
                monthlySurvivalBudget: survival,
                liquidBuffer: buffer,
                minimumEmi: minEmi,
                pausedSnowflakes: pausedSnow,
              );
            },
            icon: const Icon(Icons.flash_on, color: Colors.white),
            label: Text(
              'Deploy Crisis Defibrillator',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoratoriumDialog(BuildContext context, BlackSwanCrisisNotifier notifier) {
    final letter = notifier.generateMoratoriumLetter(
      bankName: 'HDFC Bank',
      loanAccountNumber: 'LOAN-99214',
      borrowerName: 'Valued Borrower',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF101B1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RBI Hardship Moratorium Draft',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.black45 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    letter,
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
                      Clipboard.setData(ClipboardData(text: letter));
                      HapticService.selection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Moratorium Letter copied to clipboard!'),
                          backgroundColor: Color(0xFF2563EB),
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
                        path: 'loan.relief@hdfcbank.com',
                        query: 'subject=Hardship Relief Request&body=${Uri.encodeComponent(letter)}',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Open Mail'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
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
