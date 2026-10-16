import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/database.dart';
import '../../services/financial_logic_service.dart';
import '../theme/app_theme.dart';

/// Interactive Debt Burn-Down Velocity Arc & Snowflake Throttle
/// Displays the burn velocity of active debts and provides a live continuous
/// throttle slider that physically bends the debt-free trajectory in real time.
class DebtVelocityRadar extends StatefulWidget {
  final List<Obligation> activeDebts;
  final double monthlyIncome;
  final double currentExtraPayment;
  final NumberFormat currencyFormat;
  final bool isDark;
  final ValueChanged<double> onExtraPaymentChanged;
  final VoidCallback onThrowSnowflake;

  const DebtVelocityRadar({
    super.key,
    required this.activeDebts,
    required this.monthlyIncome,
    required this.currentExtraPayment,
    required this.currencyFormat,
    required this.isDark,
    required this.onExtraPaymentChanged,
    required this.onThrowSnowflake,
  });

  @override
  State<DebtVelocityRadar> createState() => _DebtVelocityRadarState();
}

class _DebtVelocityRadarState extends State<DebtVelocityRadar> with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  final _logic = FinancialLogicService();

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeDebts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Identify highest APR debt (the flame bleeder)
    Obligation highestAprDebt = widget.activeDebts.first;
    double maxApr = 0.0;
    double totalBalance = 0.0;

    for (final d in widget.activeDebts) {
      totalBalance += d.amount;
      if (d.interestRate > maxApr) {
        maxApr = d.interestRate;
        highestAprDebt = d;
      }
    }

    // Calculate baseline vs accelerated freedom horizons
    final baselineData = _logic.calculateFreedomData(widget.activeDebts, widget.monthlyIncome, extraMonthlyPayment: 0.0);
    final throttledData = _logic.calculateFreedomData(widget.activeDebts, widget.monthlyIncome, extraMonthlyPayment: widget.currentExtraPayment);

    final savedDays = math.max(0, baselineData.daysLeft - throttledData.daysLeft);
    final savedMonths = (savedDays / 30.4).round();

    // Approximate interest arbitrage saved
    final avgApr = maxApr > 0 ? maxApr : 16.0;
    final estimatedInterestSaved = (widget.currentExtraPayment * (savedDays / 365.0) * (avgApr / 100.0) * 1.8).clamp(0.0, totalBalance * 0.4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F1424) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: widget.isDark ? 0.06 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debt Burn Velocity',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Live Payoff Throttle & Trajectory',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF38BDF8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticService.selection();
                  widget.onThrowSnowflake();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ac_unit_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'STRIKE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Highest Bleeder Flag
          if (maxApr > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: widget.isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primary Target: ${highestAprDebt.title} (${highestAprDebt.interestRate.toStringAsFixed(1)}% APR)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Animated Velocity Arc Canvas
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _sparkController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _VelocityArcPainter(
                    sparkProgress: _sparkController.value,
                    throttleRatio: (widget.currentExtraPayment / 10000.0).clamp(0.0, 1.0),
                    isDark: widget.isDark,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Throttle Impact Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREEDOM HORIZON',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: widget.isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM yyyy').format(throttledData.targetDate),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00D09C),
                    ),
                  ),
                ],
              ),
              if (savedMonths > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09C).withValues(alpha: widget.isDark ? 0.15 : 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00D09C).withValues(alpha: 0.35),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    '⚡ $savedMonths Months Shaved Off',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00D09C),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Draggable Continuous Throttle Slider
          Row(
            children: [
              Text(
                'Baseline',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF38BDF8),
                    inactiveTrackColor: widget.isDark ? Colors.white12 : Colors.black12,
                    thumbColor: const Color(0xFF38BDF8),
                    overlayColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                  ),
                  child: Slider(
                    value: widget.currentExtraPayment.clamp(0.0, 10000.0),
                    min: 0.0,
                    max: 10000.0,
                    divisions: 20,
                    onChanged: (val) {
                      HapticService.selection();
                      widget.onExtraPaymentChanged(val);
                    },
                  ),
                ),
              ),
              Text(
                '+${widget.currencyFormat.format(widget.currentExtraPayment)}/mo',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: widget.currentExtraPayment > 0
                      ? const Color(0xFF38BDF8)
                      : (widget.isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),

          if (estimatedInterestSaved > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                '💰 Estimated Interest Arbitrage Saved: ~${widget.currencyFormat.format(estimatedInterestSaved)}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VelocityArcPainter extends CustomPainter {
  final double sparkProgress;
  final double throttleRatio; // 0.0 to 1.0
  final bool isDark;

  _VelocityArcPainter({
    required this.sparkProgress,
    required this.throttleRatio,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(10, size.height * 0.15);
    final end = Offset(size.width - 10, size.height * 0.85);

    // Baseline Curve (Without Throttle)
    final baselineControl = Offset(size.width * 0.6, size.height * 0.18);
    final baselinePath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(baselineControl.dx, baselineControl.dy, end.dx, end.dy);

    final baselinePaint = Paint()
      ..color = (isDark ? Colors.white24 : Colors.black12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(baselinePath, baselinePaint);

    // Accelerated Pulled-Down Curve (Bends with throttleRatio)
    final pullFactor = throttleRatio * (size.height * 0.45);
    final throttledControl = Offset(
      size.width * 0.45 - (throttleRatio * 20),
      size.height * 0.45 + pullFactor,
    );

    final throttledPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(throttledControl.dx, throttledControl.dy, end.dx, end.dy);

    final acceleratedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF38BDF8),
          Color(0xFF00D09C),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(throttledPath, acceleratedPaint);

    // Glowing Traveling Spark along throttled trajectory
    final t = sparkProgress;
    final sparkX = math.pow(1 - t, 2) * start.dx + 2 * (1 - t) * t * throttledControl.dx + math.pow(t, 2) * end.dx;
    final sparkY = math.pow(1 - t, 2) * start.dy + 2 * (1 - t) * t * throttledControl.dy + math.pow(t, 2) * end.dy;

    final sparkCenter = Offset(sparkX.toDouble(), sparkY.toDouble());

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00D09C).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(sparkCenter, 8.0, glowPaint);

    // Inner spark
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(sparkCenter, 3.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _VelocityArcPainter oldDelegate) {
    return oldDelegate.sparkProgress != sparkProgress ||
        oldDelegate.throttleRatio != throttleRatio ||
        oldDelegate.isDark != isDark;
  }
}
