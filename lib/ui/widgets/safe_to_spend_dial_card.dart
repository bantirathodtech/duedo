import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';
import 'glance_widget_preview.dart';

class SafeToSpendDialCard extends StatelessWidget {
  final SafeToSpendMetrics metrics;
  final NumberFormat format;

  const SafeToSpendDialCard({
    super.key,
    required this.metrics,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (metrics.status) {
      case SafeToSpendStatus.abundant:
        statusColor = const Color(0xFF10B981);
        statusLabel = 'ABUNDANT';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case SafeToSpendStatus.moderate:
        statusColor = const Color(0xFF38BDF8);
        statusLabel = 'HEALTHY';
        statusIcon = Icons.shield_outlined;
        break;
      case SafeToSpendStatus.restricted:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'TIGHT';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case SafeToSpendStatus.critical:
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'DEFICIT';
        statusIcon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111422) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SAFE-TO-SPEND TODAY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          letterSpacing: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Lock Screen Widget',
                    icon: Icon(
                      Icons.widgets_outlined,
                      size: 16,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                    onPressed: () {
                      HapticService.selection();
                      GlanceWidgetPreviewModal.show(
                        context,
                        safeToSpendAmount: metrics.dailyAmount,
                        cleanDayCompleted: true,
                        streakDays: 5,
                        ringsClosed: false,
                        currencyFormat: format,
                        isDark: isDark,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                    onPressed: () {
                      HapticService.selection();
                      _showExplanationModal(context, isDark);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Amount Hero
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    format.format(metrics.dailyAmount),
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ day',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Guilt-free daily allowance with all upcoming EMIs ring-fenced.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 16),

          // Two Stat Pill Pods
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16192A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNCOMMITTED POOL',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          format.format(metrics.monthlyRemainingPool),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 0.5, height: 28, color: Colors.white12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY DUE LOCKED',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          format.format(metrics.pendingObligationsThisMonth),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExplanationModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141724) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How Safe-to-Spend Works',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Traditional budgeting forces you to track every penny and feel guilty. Duedo does the opposite:\n\n'
              '1. We ring-fence 100% of your upcoming EMIs, rents, and bills (${format.format(metrics.pendingObligationsThisMonth)}).\n'
              '2. What is left (${format.format(metrics.monthlyRemainingPool)}) is divided evenly across the ${metrics.daysLeftInMonth} days remaining this month.\n\n'
              'As long as your daily spend stays under ${format.format(metrics.dailyAmount)}, you will never miss a payment and your freedom date stays protected.',
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Got It!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
