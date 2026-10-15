import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/windfall_allocator_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'upi_slay_modal.dart';

class WindfallFortressModal extends ConsumerStatefulWidget {
  final bool isDark;

  const WindfallFortressModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WindfallFortressModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<WindfallFortressModal> createState() => _WindfallFortressModalState();
}

class _WindfallFortressModalState extends ConsumerState<WindfallFortressModal> {
  final TextEditingController _amountController = TextEditingController(text: '50000');
  double _currentWindfall = 50000.0;

  final List<double> _quickAmounts = [15000, 30000, 50000, 100000, 200000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(double val) {
    HapticService.selection();
    setState(() {
      _currentWindfall = val;
      _amountController.text = val.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final service = ref.watch(windfallAllocatorServiceProvider);

    final plan = service.calculatePlan(
      windfallAmount: _currentWindfall,
      obligations: homeState.obligations,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141207) : const Color(0xFFFFFDF5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.35)),
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
                  color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🏰', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Windfall Fortress Allocator',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFCA8A04),
                      ),
                    ),
                    Text(
                      'Optimal 50/30/20 split for bonuses, tax refunds & payouts',
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

          // Windfall Input Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1A0C) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WINDFALL / BONUS RECEIVED',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
                  decoration: InputDecoration(
                    prefixText: '$currency ',
                    prefixStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (text) {
                    final parsed = double.tryParse(text) ?? 0.0;
                    setState(() {
                      _currentWindfall = parsed;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickAmounts.map((amt) {
                      final isSelected = _currentWindfall == amt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _updateAmount(amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEAB308)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$currency${NumberFormat.compact().format(amt)}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3-Bar Tri-Split Breakdown
          Expanded(
            child: ListView(
              children: [
                // 1. 50% Snowball Strike
                _buildSplitCard(
                  title: '50% SNOWBALL STRIKE',
                  amount: '$currency${NumberFormat('#,##,###').format(plan.strikeAmount)}',
                  description: plan.targetDebt != null
                      ? 'Targets ${plan.targetDebt!.title} (${plan.targetDebt!.interestRate}% APR). Chops off ~${plan.monthsSaved} months of EMI and destroys $currency${NumberFormat.compact().format(plan.interestSaved)} in interest!'
                      : 'Accelerates your overall debt payoff velocity by 50% of this lump sum.',
                  accentColor: const Color(0xFF6366F1),
                  icon: Icons.flash_on_rounded,
                  badgeText: plan.targetDebt != null ? 'High APR Target' : 'Debt Zero',
                  isDark: isDark,
                ),

                const SizedBox(height: 12),

                // 2. 30% Emergency Grace Armor
                _buildSplitCard(
                  title: '30% EMERGENCY GRACE ARMOR',
                  amount: '$currency${NumberFormat('#,##,###').format(plan.armorAmount)}',
                  description: 'Deposited into your sovereign cash reserve. Extends your crisis survival runway by +${plan.runwayDaysAdded} days.',
                  accentColor: const Color(0xFF10B981),
                  icon: Icons.shield_rounded,
                  badgeText: '+${plan.runwayDaysAdded} Days Runway',
                  isDark: isDark,
                ),

                const SizedBox(height: 12),

                // 3. 20% Guilt-Free Joy
                _buildSplitCard(
                  title: '20% GUILT-FREE CELEBRATION',
                  amount: '$currency${NumberFormat('#,##,###').format(plan.joyAmount)}',
                  description: 'Zero guilt. Spend on dining, tech, or family rewards without shame or financial anxiety.',
                  accentColor: const Color(0xFFEC4899),
                  icon: Icons.celebration_rounded,
                  badgeText: 'Pure Dopamine',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Action CTA
          if (plan.targetDebt != null && plan.strikeAmount > 0)
            ElevatedButton.icon(
              onPressed: () {
                HapticService.selection();
                Navigator.pop(context);
                UpiSlayModal.show(
                  context,
                  obligation: plan.targetDebt!,
                  currencyFormat: NumberFormat.simpleCurrency(name: currency, decimalDigits: 0),
                  isDark: isDark,
                );
              },
              icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
              label: Text(
                'Execute $currency${NumberFormat('#,##,###').format(plan.strikeAmount)} Strike via UPI',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
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

  Widget _buildSplitCard({
    required String title,
    required String amount,
    required String description,
    required Color accentColor,
    required IconData icon,
    required String badgeText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A0C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      amount,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
