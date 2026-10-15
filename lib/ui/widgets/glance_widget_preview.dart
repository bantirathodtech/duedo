import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/glance_widget_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

class GlanceWidgetPreviewModal extends StatefulWidget {
  final double safeToSpendAmount;
  final bool cleanDayCompleted;
  final int streakDays;
  final bool ringsClosed;
  final NumberFormat currencyFormat;
  final bool isDark;

  const GlanceWidgetPreviewModal({
    super.key,
    required this.safeToSpendAmount,
    required this.cleanDayCompleted,
    required this.streakDays,
    required this.ringsClosed,
    required this.currencyFormat,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required double safeToSpendAmount,
    required bool cleanDayCompleted,
    required int streakDays,
    required bool ringsClosed,
    required NumberFormat currencyFormat,
    required bool isDark,
  }) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlanceWidgetPreviewModal(
        safeToSpendAmount: safeToSpendAmount,
        cleanDayCompleted: cleanDayCompleted,
        streakDays: streakDays,
        ringsClosed: ringsClosed,
        currencyFormat: currencyFormat,
        isDark: isDark,
      ),
    );
  }

  @override
  State<GlanceWidgetPreviewModal> createState() => _GlanceWidgetPreviewModalState();
}

class _GlanceWidgetPreviewModalState extends State<GlanceWidgetPreviewModal> {
  bool _isSynced = false;

  Future<void> _syncWidget() async {
    setState(() => _isSynced = true);
    HapticService.dopamineCascade();
    await GlanceWidgetService.syncGlanceData(
      safeToSpend: widget.safeToSpendAmount,
      cleanDay: widget.cleanDayCompleted,
      streak: widget.streakDays,
      ringsClosed: widget.ringsClosed,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ambient widget updated! Lock screen synced.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2235),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final format = widget.currencyFormat;
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm').format(now);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.widgets_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMBIENT GLANCE ENGINE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF60A5FA),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Lock Screen Live Widget',
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
          const SizedBox(height: 14),

          Text(
            'Keep your daily discipline visible without ever opening the app. Check your phone 150 times a day with instant financial clarity.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Simulated Phone Lock Screen Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clock & Date
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: GoogleFonts.outfit(fontSize: 54, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // The Duedo Glance Widget Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        // Left: Safe to Spend Hero
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'SAFE TO SPEND',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF34D399),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                format.format(widget.safeToSpendAmount),
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Guilt-free today',
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),

                        // Right: Rings & Streak
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.streakDays}D',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFF97316),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.cleanDayCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    widget.ringsClosed ? Icons.check_circle_rounded : Icons.cyclone_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(_isSynced ? Icons.check_rounded : Icons.sync_rounded, size: 20),
              label: Text(
                _isSynced ? 'Lock Screen Synced!' : 'Sync Ambient Lock Screen Now',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              onPressed: _syncWidget,
            ),
          ),
        ],
      ),
    );
  }
}
