import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/database.dart';
import '../../services/debt_negotiation_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

class DebtNegotiationModal extends StatefulWidget {
  final Obligation obligation;
  final int paymentStreak;
  final bool isDark;

  const DebtNegotiationModal({
    super.key,
    required this.obligation,
    this.paymentStreak = 0,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required Obligation obligation,
    int paymentStreak = 0,
    required bool isDark,
  }) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DebtNegotiationModal(
        obligation: obligation,
        paymentStreak: paymentStreak,
        isDark: isDark,
      ),
    );
  }

  @override
  State<DebtNegotiationModal> createState() => _DebtNegotiationModalState();
}

class _DebtNegotiationModalState extends State<DebtNegotiationModal> {
  int _selectedScriptIndex = 0;
  late List<DebtNegotiationScript> _scripts;

  @override
  void initState() {
    super.initState();
    _scripts = DebtNegotiationService.generateScripts(
      obligation: widget.obligation,
      paymentStreak: widget.paymentStreak,
    );
  }

  Future<void> _callHelpline(String number) async {
    HapticService.selection();
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: number));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Helpline number $number copied to clipboard.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: number));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final currentScript = _scripts[_selectedScriptIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI BANK NEGOTIATOR',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFB7185),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'RBI Legal Power Scripts',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Script Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_scripts.length, (index) {
                final s = _scripts[index];
                final isSelected = _selectedScriptIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s.title),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticService.selection();
                        setState(() => _selectedScriptIndex = index);
                      }
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark ? const Color(0xFF1B1E2E) : const Color(0xFFF1F5F9),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Strategy & Legal Grounding Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Color(0xFF38BDF8), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        currentScript.rbiReference,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  currentScript.strategyHook,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Teleprompter Script Card (Expanded)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141726) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'TELEPROMPTER (READ TO BANK AGENT)',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentScript.teleprompterScript,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Copy Script & Call Helpline
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Script'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      HapticService.selection();
                      await Clipboard.setData(ClipboardData(text: currentScript.teleprompterScript));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Script copied to clipboard! Ready to paste or read.'),
                            backgroundColor: const Color(0xFF1E2235),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('Call Bank'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _callHelpline(currentScript.customerCareNumber),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
