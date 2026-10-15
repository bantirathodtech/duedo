import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

class PaydayBlitzModal extends StatefulWidget {
  final PaydayBlitzPlan plan;
  final NumberFormat currencyFormat;
  final bool isDark;
  final Future<void> Function(double snowflakeAmount)? onInjectSnowflake;

  const PaydayBlitzModal({
    super.key,
    required this.plan,
    required this.currencyFormat,
    required this.isDark,
    this.onInjectSnowflake,
  });

  static Future<void> show(
    BuildContext context, {
    required PaydayBlitzPlan plan,
    required NumberFormat currencyFormat,
    required bool isDark,
    Future<void> Function(double snowflakeAmount)? onInjectSnowflake,
  }) {
    HapticService.dopamineCascade();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaydayBlitzModal(
        plan: plan,
        currencyFormat: currencyFormat,
        isDark: isDark,
        onInjectSnowflake: onInjectSnowflake,
      ),
    );
  }

  @override
  State<PaydayBlitzModal> createState() => _PaydayBlitzModalState();
}

class _PaydayBlitzModalState extends State<PaydayBlitzModal> {
  int _currentStep = 0;
  bool _isInjecting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final format = widget.currencyFormat;
    final plan = widget.plan;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10121E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Tag & Stepper Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFFFD700)),
                    const SizedBox(width: 4),
                    Text(
                      'PAYDAY BLITZ RITUAL',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of 3',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Step Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3.0,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Body Step
          Expanded(
            child: _buildStepContent(plan, format, isDark),
          ),

          // Action Navigation Buttons
          _buildBottomActionButtons(plan, isDark),
        ],
      ),
    );
  }

  Widget _buildStepContent(PaydayBlitzPlan plan, NumberFormat format, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1SalaryIn(plan, format, isDark);
      case 1:
        return _buildStep2RingFence(plan, format, isDark);
      case 2:
      default:
        return _buildStep3SnowflakeAndFinish(plan, format, isDark);
    }
  }

  Widget _buildStep1SalaryIn(PaydayBlitzPlan plan, NumberFormat format, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary In. Let\'s Make You Richer.',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Before lifestyle creep takes a cut, 60 seconds of discipline secures your entire month.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Salary Pod
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161928) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET IN-HAND CREDITED',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  format.format(plan.monthlyIncome),
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppTheme.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${format.format(plan.totalLockedDues)} must be ring-fenced immediately to protect upcoming dues.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2RingFence(PaydayBlitzPlan plan, NumberFormat format, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dues Ring-Fenced & Protected',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This money is sacred. We lock it away so you never miss a payment.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          ),
        ),
        const SizedBox(height: 16),

        // Locked Dues Breakdown
        Expanded(
          child: ListView.builder(
            itemCount: plan.lockedObligations.length,
            itemBuilder: (ctx, idx) {
              final ob = plan.lockedObligations[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          ob.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      format.format(ob.amount),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep3SnowflakeAndFinish(PaydayBlitzPlan plan, NumberFormat format, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Declare Sovereign Safe-to-Spend',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your monthly cashflow blueprint is locked. Spend with zero anxiety.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 20),

          // Daily Safe-to-Spend Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16192A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR GUILT-FREE ALLOWANCE',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.success,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      format.format(plan.newDailySafeToSpend),
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('/ day', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Spend up to this amount every single day without touching your debt payoff timeline.',
                  style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Optional Snowflake Booster
          if (plan.targetDebt != null && plan.recommendedSnowflake > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFA855F7), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OPTIONAL FREEDOM KICK',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFA855F7)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Route ${format.format(plan.recommendedSnowflake)} to ${plan.targetDebt!.title} to pull freedom ${plan.daysAccelerated} days closer.',
                          style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(PaydayBlitzPlan plan, bool isDark) {
    if (_currentStep < 2) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            HapticService.selection();
            setState(() => _currentStep += 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _currentStep == 0 ? 'Lock Dues & Proceed' : 'Calculate Daily Safe-to-Spend',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (plan.targetDebt != null && plan.recommendedSnowflake > 0) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch_rounded, size: 16),
              label: Text('Inject ${widget.currencyFormat.format(plan.recommendedSnowflake)} Snowflake & Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isInjecting
                  ? null
                  : () async {
                      setState(() => _isInjecting = true);
                      HapticService.dopamineCascade();
                      if (widget.onInjectSnowflake != null) {
                        await widget.onInjectSnowflake!(plan.recommendedSnowflake);
                      }
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 Payday Blitz completed! Debt freedom accelerated by ${plan.daysAccelerated} days!'),
                            backgroundColor: const Color(0xFF1E2235),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              HapticService.dopamineCascade();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('👑 Payday Sovereign Activated! Spend safe & stay disciplined.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black87,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Finish Payday Ritual'),
          ),
        ),
      ],
    );
  }
}
