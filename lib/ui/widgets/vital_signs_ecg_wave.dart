import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';

/// Financial Health "Vital Signs Wave" (ECG / Pulse of Freedom)
/// Renders a living, animated cardiovascular waveform representing financial health.
/// Green = Optimal (<30% DTI, 0 overdue), Amber = Stress, Crimson = Deficit Pulse.
class VitalSignsEcgWave extends StatefulWidget {
  final int healthScore;
  final bool hasOverdue;
  final double dti;
  final bool isDark;

  const VitalSignsEcgWave({
    super.key,
    required this.healthScore,
    required this.hasOverdue,
    required this.dti,
    required this.isDark,
  });

  @override
  State<VitalSignsEcgWave> createState() => _VitalSignsEcgWaveState();
}

class _VitalSignsEcgWaveState extends State<VitalSignsEcgWave> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Faster heartbeat when in danger, calm rhythmic when optimal
    final durationMs = widget.hasOverdue || widget.healthScore < 50
        ? 1000
        : (widget.healthScore < 75 ? 1400 : 2000);

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant VitalSignsEcgWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthScore != widget.healthScore || oldWidget.hasOverdue != widget.hasOverdue) {
      final durationMs = widget.hasOverdue || widget.healthScore < 50
          ? 1000
          : (widget.healthScore < 75 ? 1400 : 2000);
      _pulseController.duration = Duration(milliseconds: durationMs);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.hasOverdue || widget.healthScore < 50) {
      return const Color(0xFFEF4444); // Crimson Critical
    }
    if (widget.healthScore < 75 || widget.dti > 0.45) {
      return const Color(0xFFF59E0B); // Amber Tension
    }
    return const Color(0xFF00D09C); // Emerald Optimal
  }

  String get _statusLabel {
    if (widget.hasOverdue || widget.healthScore < 50) return 'CRITICAL PULSE';
    if (widget.healthScore < 75) return 'ELEVATED TENSION';
    return 'OPTIMAL VITALS';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        _showDiagnosticsModal(context, color);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: widget.isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            // Pulse Heart Icon
            Icon(Icons.monitor_heart_rounded, color: color, size: 16),
            const SizedBox(width: 8),

            // Animated ECG Wave Canvas
            Expanded(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 36),
                    painter: _EcgWavePainter(
                      progress: _pulseController.value,
                      color: color,
                      isAgitated: widget.hasOverdue || widget.healthScore < 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Health Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.healthScore}% $_statusLabel',
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnosticsModal(BuildContext context, Color statusColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF0F1424) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.monitor_heart_rounded, color: statusColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Financial Vital Signs Diagnostic',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Your financial cardiovascular wave measures real-time debt pressure against liquid monthly income. A calmer rhythm signifies greater psychological sovereignty.',
              style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            _buildMetricRow('Overall Health Score', '${widget.healthScore}/100', statusColor),
            const Divider(height: 16),
            _buildMetricRow('Debt-to-Income (DTI)', '${(widget.dti * 100).toStringAsFixed(1)}%', widget.dti > 0.4 ? Colors.red : Colors.green),
            const Divider(height: 16),
            _buildMetricRow('Overdue Critical Debt', widget.hasOverdue ? 'YES (1+ Overdue)' : 'NONE (Clean)', widget.hasOverdue ? Colors.red : Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _EcgWavePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final bool isAgitated;

  _EcgWavePainter({
    required this.progress,
    required this.color,
    required this.isAgitated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final path = Path();
    const pointCount = 60;
    final stepX = size.width / pointCount;

    path.moveTo(0, midY);

    for (int i = 0; i <= pointCount; i++) {
      final x = i * stepX;
      final normalizedX = i / pointCount;
      
      // Compute ECG pulse spike centered at progress
      final dist = (normalizedX - progress).abs();
      double yOffset = 0.0;

      if (dist < 0.12) {
        final localT = (normalizedX - (progress - 0.12)) / 0.24; // 0 to 1
        // Classic P-Q-R-S-T wave pattern
        if (localT > 0.2 && localT < 0.35) {
          yOffset = -size.height * 0.15; // P wave
        } else if (localT >= 0.35 && localT < 0.45) {
          yOffset = size.height * 0.2;  // Q dip
        } else if (localT >= 0.45 && localT < 0.6) {
          yOffset = -size.height * (isAgitated ? 0.48 : 0.42); // R peak
        } else if (localT >= 0.6 && localT < 0.72) {
          yOffset = size.height * (isAgitated ? 0.35 : 0.25);  // S dip
        } else if (localT >= 0.72 && localT < 0.9) {
          yOffset = -size.height * 0.18; // T wave
        }
      }

      path.lineTo(x, midY + yOffset);
    }

    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, wavePaint);

    // Glowing Lead Dot
    final dotX = progress * size.width;
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(Offset(dotX, midY), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isAgitated != isAgitated;
  }
}
