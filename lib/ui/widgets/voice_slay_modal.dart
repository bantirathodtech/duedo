import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/voice_slay_service.dart';
import '../../services/daily_rings_service.dart';
import '../../services/freedom_league_service.dart';
import '../../services/impulse_vault_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'upi_slay_modal.dart';

class VoiceSlayModal extends ConsumerStatefulWidget {
  final bool isDark;

  const VoiceSlayModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceSlayModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<VoiceSlayModal> createState() => _VoiceSlayModalState();
}

class _VoiceSlayModalState extends ConsumerState<VoiceSlayModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  VoiceSlayIntent? _resolvedIntent;
  late AnimationController _pulseController;

  final List<String> _sampleVoiceCommands = [
    'Slayed 500 on HDFC Card',
    'Spent 350 on dinner',
    'Vault 4000 sneakers',
    'How much is safe today?',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChange(String text) {
    if (text.trim().isEmpty) {
      setState(() => _resolvedIntent = null);
      return;
    }

    final homeState = ref.read(homeViewModelProvider);
    final voiceService = ref.read(voiceSlayServiceProvider);
    final intent = voiceService.parseVoiceCommand(text, homeState.obligations);

    setState(() {
      _resolvedIntent = intent;
    });
  }

  Future<void> _executeIntent() async {
    final intent = _resolvedIntent;
    if (intent == null) return;

    final homeState = ref.read(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';

    switch (intent.type) {
      case VoiceIntentType.paymentSnowflake:
        if (intent.matchedObligation != null) {
          HapticService.selection();
          Navigator.pop(context);
          UpiSlayModal.show(
            context,
            obligation: intent.matchedObligation!,
            currencyFormat: NumberFormat.simpleCurrency(name: currency, decimalDigits: 0),
            isDark: widget.isDark,
          );
        }
        break;

      case VoiceIntentType.expenseSpent:
        HapticService.dopamineCascade();
        await ref.read(dailyRingsServiceProvider.notifier).recordCheckIn();
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '💸 Deducted $currency${intent.amount.toStringAsFixed(0)} (${intent.target}) from Safe-to-Spend.',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case VoiceIntentType.vaultImpulse:
        HapticService.dopamineCascade();
        await ref.read(impulseVaultServiceProvider.notifier).shieldImpulse(
          title: intent.target ?? 'Impulse Item',
          amount: intent.amount > 0 ? intent.amount : 1500.0,
        );
        await ref.read(freedomLeagueProvider.notifier).awardPoints(100);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🧊 Locked "${intent.target}" ($currency${intent.amount.toStringAsFixed(0)}) in the 24h Cooling Vault! (+100 pts)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF38BDF8),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case VoiceIntentType.queryStatus:
        HapticService.victoryPop();
        if (!mounted) return;
        Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final intent = _resolvedIntent;
    final currency = ref.watch(homeViewModelProvider).settings?.currency ?? '₹';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1222) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(
                        alpha: 0.15 + (_pulseController.value * 0.15),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(
                            alpha: 0.2 * _pulseController.value,
                          ),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF6366F1), size: 24),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Slay & Quick Ingestion',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Speak or type: zero-friction expense & snowflake logging',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
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

          // Quick Voice Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sampleVoiceCommands.map((phrase) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: isDark ? const Color(0xFF1B1E38) : const Color(0xFFF1F5F9),
                    label: Text(
                      '"$phrase"',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      HapticService.selection();
                      _inputController.text = phrase;
                      _onTextChange(phrase);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Speech input field
          TextField(
            controller: _inputController,
            onChanged: _onTextChange,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'e.g. "Slayed 500 on HDFC" or "Spent 350 for dinner"',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.mic, color: Color(0xFF6366F1)),
              filled: true,
              fillColor: isDark ? const Color(0xFF181C33) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Resolved Intent Card
          Expanded(
            child: intent != null
                ? Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181C33) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getIntentColor(intent.type).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _getIntentLabel(intent.type),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: _getIntentColor(intent.type),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              intent.amount > 0 ? '$currency${intent.amount.toStringAsFixed(0)}' : 'Status Query',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _getIntentColor(intent.type),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          intent.confirmationMessage,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        if (intent.matchedObligation != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_rounded, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Matched: ${intent.matchedObligation!.title} (${intent.matchedObligation!.interestRate}% APR)',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.graphic_eq_rounded, color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Say or type any financial action',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'NLP engine parses debt slays, expenses & impulse vaulting',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),

          // Execute CTA
          if (intent != null)
            ElevatedButton.icon(
              onPressed: _executeIntent,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: Text(
                'Confirm & Execute Action',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getIntentColor(intent.type),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  Color _getIntentColor(VoiceIntentType type) {
    switch (type) {
      case VoiceIntentType.paymentSnowflake:
        return const Color(0xFF6366F1);
      case VoiceIntentType.expenseSpent:
        return const Color(0xFFF43F5E);
      case VoiceIntentType.vaultImpulse:
        return const Color(0xFF38BDF8);
      case VoiceIntentType.queryStatus:
        return const Color(0xFF10B981);
    }
  }

  String _getIntentLabel(VoiceIntentType type) {
    switch (type) {
      case VoiceIntentType.paymentSnowflake:
        return '⚔️ SNOWBALL SLAY INTENT';
      case VoiceIntentType.expenseSpent:
        return '💸 EXPENSE LOGGED';
      case VoiceIntentType.vaultImpulse:
        return '🧊 IMPULSE VAULTED';
      case VoiceIntentType.queryStatus:
        return '🔍 STATUS INQUIRY';
    }
  }
}
