import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/daily_rings_service.dart';
import '../../services/haptic_service.dart';
import '../../services/persona_voice_service.dart';
import '../theme/app_theme.dart';

class DailyFreedomRingsWidget extends ConsumerWidget {
  final bool isDark;
  final bool isSavage;
  final VoidCallback? onSnowflakeTap;

  const DailyFreedomRingsWidget({
    super.key,
    required this.isDark,
    this.isSavage = false,
    this.onSnowflakeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ringsState = ref.watch(dailyRingsServiceProvider);
    final ringsNotifier = ref.read(dailyRingsServiceProvider.notifier);
    final persona = ref.read(personaVoiceServiceProvider);

    final allClosed = ringsState.ringsClosedToday ||
        (ringsState.cleanDayCompleted && ringsState.snowflakeCompleted && ringsState.checkInCompleted);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: allClosed
              ? const Color(0xFFFFB800).withValues(alpha: 0.4)
              : (isDark ? const Color(0x2638BDF8) : const Color(0x1F38BDF8)),
          width: allClosed ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (allClosed ? const Color(0xFFFFB800) : const Color(0xFF38BDF8))
                .withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Streak Badge
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
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        size: 16,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'DAILY FREEDOM RINGS',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF3D00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${ringsState.currentStreak}D STREAK',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Core Body: The Concentric Rings Painter + Interactive Quest Items
          Row(
            children: [
              // Concentric 3-Ring Visual Dial
              GestureDetector(
                onTap: () => _showRingsDetailSheet(context, ringsState, ringsNotifier, persona),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(96, 96),
                        painter: _ConcentricRingsPainter(
                          cleanProgress: ringsState.cleanProgress,
                          snowflakeProgress: ringsState.snowflakeProgress,
                          checkInProgress: ringsState.checkInProgress,
                          isDark: isDark,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allClosed ? Icons.emoji_events_rounded : Icons.lock_clock_rounded,
                            size: 22,
                            color: allClosed ? const Color(0xFFFFD700) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          Text(
                            '${(ringsState.overallProgress * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 3 Daily Quests Checklist
              Expanded(
                child: Column(
                  children: [
                    _buildQuestRow(
                      title: 'Clean Day (No Impulse)',
                      isDone: ringsState.cleanDayCompleted,
                      color: const Color(0xFF00D09C),
                      onTap: () => ringsNotifier.toggleCleanDay(),
                    ),
                    const SizedBox(height: 8),
                    _buildQuestRow(
                      title: 'Snowflake Slay',
                      isDone: ringsState.snowflakeCompleted,
                      color: const Color(0xFFA855F7),
                      onTap: onSnowflakeTap ?? () => ringsNotifier.recordSnowflake(),
                    ),
                    const SizedBox(height: 8),
                    _buildQuestRow(
                      title: 'Daily Review',
                      isDone: ringsState.checkInCompleted,
                      color: const Color(0xFF38BDF8),
                      onTap: () => ringsNotifier.recordCheckIn(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Motivational Persona Micro-Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141726) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSavage ? Icons.bolt_rounded : Icons.spa_rounded,
                  size: 14,
                  color: isSavage ? const Color(0xFFFF4D4D) : const Color(0xFF00D09C),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allClosed
                        ? persona.getRingsCompleteCelebration(isSavage, ringsState.currentStreak)
                        : (isSavage
                            ? 'Close all 3 rings today to defend your freedom streak.'
                            : 'Three mindful daily actions build lasting abundance.'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestRow({
    required String title,
    required bool isDone,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isDone ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? color : (isDark ? Colors.white24 : Colors.black26),
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                color: isDone
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                decoration: isDone ? TextDecoration.none : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRingsDetailSheet(
    BuildContext context,
    DailyRingsState state,
    DailyRingsNotifier notifier,
    PersonaVoiceService persona,
  ) {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F111D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? const Color(0x3338BDF8) : const Color(0x1F38BDF8),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Freedom Quests',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🔥 ${state.currentStreak} Day Streak',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Closing your rings daily rewires your dopamine response from impulse spending to wealth freedom.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
            const SizedBox(height: 20),
            _buildInteractiveQuestCard(
              title: 'Clean Day (No Unplanned Spending)',
              subtitle: state.cleanDayCompleted ? 'Completed today! No impulse swipes.' : 'Tap to mark today as an impulse-free day.',
              isDone: state.cleanDayCompleted,
              color: const Color(0xFF00D09C),
              onTap: () {
                notifier.toggleCleanDay();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildInteractiveQuestCard(
              title: 'Snowflake Slay (Micro-Prepayment)',
              subtitle: state.snowflakeCompleted ? 'Slayed today! Future compound interest killed.' : 'Chipped in ₹100+ to accelerate your freedom date.',
              isDone: state.snowflakeCompleted,
              color: const Color(0xFFA855F7),
              onTap: () {
                Navigator.pop(ctx);
                onSnowflakeTap?.call();
              },
            ),
            const SizedBox(height: 10),
            _buildInteractiveQuestCard(
              title: 'Daily Financial Consciousness',
              subtitle: 'Reviewed your obligations and maintained clear visibility.',
              isDone: state.checkInCompleted,
              color: const Color(0xFF38BDF8),
              onTap: () {
                notifier.recordCheckIn();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveQuestCard({
    required String title,
    required String subtitle,
    required bool isDone,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone ? color.withValues(alpha: 0.12) : (isDark ? const Color(0xFF141724) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? color.withValues(alpha: 0.4) : (isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDone ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle_outlined,
              size: 16,
              color: isDone ? Colors.white : color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.transparent : color,
              foregroundColor: isDone ? color : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isDone ? BorderSide(color: color.withValues(alpha: 0.5)) : BorderSide.none,
              ),
            ),
            child: Text(
              isDone ? 'Undo' : 'Mark',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double cleanProgress;
  final double snowflakeProgress;
  final double checkInProgress;
  final bool isDark;

  _ConcentricRingsPainter({
    required this.cleanProgress,
    required this.snowflakeProgress,
    required this.checkInProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 7.0;
    const startAngle = -math.pi / 2;

    // Track 1: Outer Ring - Clean Day (Emerald)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: (size.width / 2) - strokeWidth,
      strokeWidth: strokeWidth,
      progress: cleanProgress,
      color: const Color(0xFF00D09C),
      startAngle: startAngle,
    );

    // Track 2: Middle Ring - Snowflake Slay (Purple)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: (size.width / 2) - (strokeWidth * 2.3),
      strokeWidth: strokeWidth,
      progress: snowflakeProgress,
      color: const Color(0xFFA855F7),
      startAngle: startAngle,
    );

    // Track 3: Inner Ring - Daily Review (Cyan)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: (size.width / 2) - (strokeWidth * 3.6),
      strokeWidth: strokeWidth,
      progress: checkInProgress,
      color: const Color(0xFF38BDF8),
      startAngle: startAngle,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double progress,
    required Color color,
    required double startAngle,
  }) {
    final bgPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.15 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.cleanProgress != cleanProgress ||
        oldDelegate.snowflakeProgress != snowflakeProgress ||
        oldDelegate.checkInProgress != checkInProgress ||
        oldDelegate.isDark != isDark;
  }
}
