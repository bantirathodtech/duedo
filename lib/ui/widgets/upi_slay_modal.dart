import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../services/upi_payment_service.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

class UpiSlayModal extends StatefulWidget {
  final Obligation obligation;
  final NumberFormat currencyFormat;
  final bool isDark;
  final Future<void> Function(double amount)? onPaymentExecuted;

  const UpiSlayModal({
    super.key,
    required this.obligation,
    required this.currencyFormat,
    required this.isDark,
    this.onPaymentExecuted,
  });

  static Future<void> show(
    BuildContext context, {
    required Obligation obligation,
    required NumberFormat currencyFormat,
    required bool isDark,
    Future<void> Function(double amount)? onPaymentExecuted,
  }) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpiSlayModal(
        obligation: obligation,
        currencyFormat: currencyFormat,
        isDark: isDark,
        onPaymentExecuted: onPaymentExecuted,
      ),
    );
  }

  @override
  State<UpiSlayModal> createState() => _UpiSlayModalState();
}

class _UpiSlayModalState extends State<UpiSlayModal> {
  late double _selectedAmount;
  late TextEditingController _vpaController;
  final _logicService = FinancialLogicService();
  bool _isLaunching = false;

  final List<double> _quickAmounts = [200, 500, 1000, 2500];

  @override
  void initState() {
    super.initState();
    _selectedAmount = 500.0;
    final defaultVpa = UpiPaymentService.inferVpa(widget.obligation.title, widget.obligation.category);
    _vpaController = TextEditingController(text: defaultVpa);
  }

  @override
  void dispose() {
    _vpaController.dispose();
    super.dispose();
  }

  Future<void> _executeSlay() async {
    setState(() => _isLaunching = true);

    final vpa = _vpaController.text.trim().isEmpty 
        ? 'biller@upi' 
        : _vpaController.text.trim();

    final result = await UpiPaymentService.launchUpiPayment(
      vpa: vpa,
      payeeName: widget.obligation.title,
      amount: _selectedAmount,
      transactionNote: 'Duedo ${widget.obligation.title} Slay',
    );

    if (mounted) {
      setState(() => _isLaunching = false);
      if (result.status == UpiLaunchStatus.success) {
        if (widget.onPaymentExecuted != null) {
          await widget.onPaymentExecuted!(_selectedAmount);
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Snowflake strike recorded! You destroyed future vampire interest.',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Fallback dialog with copied VPA
        await UpiPaymentService.copyUpiDetailsToClipboard(
          vpa: vpa,
          amount: _selectedAmount,
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: widget.isDark ? const Color(0xFF1E2235) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.content_copy_rounded, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text('VPA Copied', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              content: Text(
                'UPI intent could not be auto-opened directly on this device. Payee VPA ($vpa) and amount (${widget.currencyFormat.format(_selectedAmount)}) are copied to your clipboard. Paste in GPay/PhonePe to complete.',
                style: GoogleFonts.inter(fontSize: 13, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (widget.onPaymentExecuted != null) {
                      widget.onPaymentExecuted!(_selectedAmount);
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Mark Slayed', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final format = widget.currencyFormat;
    final ob = widget.obligation;
    final impact = _logicService.calculateSnowflakeImpact(ob, _selectedAmount);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10121E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1-TAP UPI DEBT SLAYER',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFA78BFA),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      ob.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (ob.interestRate > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${ob.interestRate}% APR',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.danger,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Impact Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAVINGS: ${format.format(impact.interestSaved)} VAMPIRE INTEREST',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Reclaims ~${impact.daysSaved} days of financial freedom instantly.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick Amount Selectors
          Text(
            'SELECT SNOWFLAKE STRIKE AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _quickAmounts.map((amt) {
              final isSelected = _selectedAmount == amt;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      setState(() => _selectedAmount = amt);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark ? const Color(0xFF191D2C) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          format.format(amt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Payee VPA Field
          TextField(
            controller: _vpaController,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Biller / Payee UPI ID (VPA)',
              labelStyle: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: AppTheme.primary),
              filled: true,
              fillColor: isDark ? const Color(0xFF151824) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: _isLaunching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch_rounded, size: 20),
              label: Text(
                _isLaunching ? 'Opening UPI App...' : 'Slay ${format.format(_selectedAmount)} Now',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
              onPressed: _isLaunching ? null : _executeSlay,
            ),
          ),
        ],
      ),
    );
  }
}
