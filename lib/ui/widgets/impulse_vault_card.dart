import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/impulse_vault_service.dart';
import '../../services/persona_voice_service.dart';
import '../theme/app_theme.dart';

class ImpulseVaultCard extends ConsumerWidget {
  final bool isDark;
  final bool isSavage;
  final NumberFormat currencyFormat;
  final Function(double amount)? onPrepayResistedAmount;

  const ImpulseVaultCard({
    super.key,
    required this.isDark,
    this.isSavage = false,
    required this.currencyFormat,
    this.onPrepayResistedAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(impulseVaultServiceProvider);
    final vaultNotifier = ref.read(impulseVaultServiceProvider.notifier);
    final activeItems = vaultState.activeCoolingItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0x26EC4899) : const Color(0x1FEC4899),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Shield Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '24H IMPULSE VAULT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showAddImpulseSheet(context, vaultNotifier, ref),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: Color(0xFFEC4899)),
                      const SizedBox(width: 4),
                      Text(
                        'Cool An Urge',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Shielded Savings & Days Restored Badge
          if (vaultState.totalShielded > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D09C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D09C).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF00D09C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Protected ${currencyFormat.format(vaultState.totalShielded)} (${vaultState.totalDaysSaved} freedom days saved)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00D09C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Active Cooling Items List or Empty Encouragement
          if (activeItems.isEmpty) ...[
            Text(
              'Tempted by an unbudgeted purchase? Put it in the 24-Hour Cooling Chamber. 80% of purchase desires vanish overnight.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                height: 1.4,
              ),
            ),
          ] else ...[
            Column(
              children: activeItems.map((item) {
                final remaining = item.remainingTime;
                final hours = remaining.inHours;
                final minutes = remaining.inMinutes % 60;
                final isDone = item.isCooledDown;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141724) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFEC4899)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currencyFormat.format(item.amount)} • ${isDone ? "Cooled Down!" : "$hours h $minutes m left"}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDone ? const Color(0xFF00D09C) : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          vaultNotifier.markResisted(item.id);
                          onPrepayResistedAmount?.call(item.amount);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Resisted!',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddImpulseSheet(BuildContext context, ImpulseVaultNotifier notifier, WidgetRef ref) {
    HapticService.selection();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final persona = ref.read(personaVoiceServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
          final estimatedDays = (enteredAmount / 350).round().clamp(1, 90);
          final estimatedInterest = (enteredAmount * 0.22);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F111D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark ? const Color(0x33EC4899) : const Color(0x1FEC4899),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_clock_rounded, color: Color(0xFFEC4899), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24-Hour Cooling Vault',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Translate spontaneous urge into freedom runway',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Title Field
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'What are you tempted to buy?',
                      hintText: 'e.g. Wireless headphones, Takeout dinner',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF141724) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount Field
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Price (${currencyFormat.currencySymbol})',
                      hintText: 'e.g. 2499',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF141724) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Real-time Freedom Cost Simulator
                  if (enteredAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEC4899)),
                              const SizedBox(width: 6),
                              Text(
                                'REAL FREEDOM COST',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFFEC4899),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buying this delays your debt freedom by ~$estimatedDays days and bleeds ${currencyFormat.format(estimatedInterest)} in future compound interest.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        if (title.isNotEmpty && amount > 0) {
                          notifier.shieldImpulse(title: title, amount: amount);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF0F111D),
                              content: Text(
                                persona.getImpulseCoolingPrompt(isSavage, title, amount),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Lock In 24H Vault',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
