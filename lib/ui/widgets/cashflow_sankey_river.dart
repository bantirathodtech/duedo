import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Interactive Cashflow "Sankey River" Visualizer
/// Transforms static numbers into a fluid, living stream of financial energy:
/// Income -> Compulsory EMIs (Red) + Essentials (Amber) + Safe-to-Spend (Emerald)
class CashflowSankeyRiver extends StatefulWidget {
  final double monthlyIncome;
  final double committedEMIs;
  final double committedRecurring;
  final double safeToSpendMonthly;
  final NumberFormat currencyFormat;
  final bool isDark;
  final int? selectedBranch;
  final ValueChanged<int?>? onBranchSelected;

  const CashflowSankeyRiver({
    super.key,
    required this.monthlyIncome,
    required this.committedEMIs,
    required this.committedRecurring,
    required this.safeToSpendMonthly,
    required this.currencyFormat,
    required this.isDark,
    this.selectedBranch,
    this.onBranchSelected,
  });

  @override
  State<CashflowSankeyRiver> createState() => _CashflowSankeyRiverState();
}

class _CashflowSankeyRiverState extends State<CashflowSankeyRiver> with SingleTickerProviderStateMixin {
  late AnimationController _flowController;
  int? _selectedBranch; // null = all, 0 = EMIs, 1 = Essentials, 2 = Safe

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.selectedBranch;
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CashflowSankeyRiver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBranch != oldWidget.selectedBranch) {
      setState(() {
        _selectedBranch = widget.selectedBranch;
      });
    }
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final income = math.max(1.0, widget.monthlyIncome);
    final emiPercent = (widget.committedEMIs / income).clamp(0.0, 1.0);
    final recurringPercent = (widget.committedRecurring / income).clamp(0.0, 1.0);
    final safePercent = (math.max(0.0, widget.safeToSpendMonthly) / income).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F1424) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? const Color(0xFF00D09C).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D09C), Color(0xFF0284C7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.waves_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cashflow Stream',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Fluid Allocation & Capital Bleed',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF00D09C),
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
                  setState(() => _selectedBranch = null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF192033) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedBranch == null ? 'LIVE FLOW' : 'RESET FOCUS',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Custom Painted Fluid River
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _flowController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 150),
                  painter: _SankeyRiverPainter(
                    flowProgress: _flowController.value,
                    emiRatio: emiPercent,
                    recurringRatio: recurringPercent,
                    safeRatio: safePercent,
                    selectedBranch: _selectedBranch,
                    isDark: widget.isDark,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Interactive Branch Tiles
          Row(
            children: [
              Expanded(
                child: _buildBranchPill(
                  index: 0,
                  label: 'Debt EMIs',
                  amount: widget.committedEMIs,
                  percent: (emiPercent * 100).toInt(),
                  color: const Color(0xFFF43F5E),
                  icon: Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBranchPill(
                  index: 1,
                  label: 'Essentials',
                  amount: widget.committedRecurring,
                  percent: (recurringPercent * 100).toInt(),
                  color: const Color(0xFFF59E0B),
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBranchPill(
                  index: 2,
                  label: 'Free Capital',
                  amount: math.max(0.0, widget.safeToSpendMonthly),
                  percent: (safePercent * 100).toInt(),
                  color: const Color(0xFF00D09C),
                  icon: Icons.bolt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchPill({
    required int index,
    required String label,
    required double amount,
    required int percent,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedBranch == index;
    final isDimmed = _selectedBranch != null && !isSelected;

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        final newSelection = _selectedBranch == index ? null : index;
        setState(() {
          _selectedBranch = newSelection;
        });
        widget.onBranchSelected?.call(newSelection);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isDimmed ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: widget.isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isSelected ? 0.9 : 0.25),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 13, color: color),
                  Text(
                    '$percent%',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.currencyFormat.format(amount),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SankeyRiverPainter extends CustomPainter {
  final double flowProgress;
  final double emiRatio;
  final double recurringRatio;
  final double safeRatio;
  final int? selectedBranch;
  final bool isDark;

  _SankeyRiverPainter({
    required this.flowProgress,
    required this.emiRatio,
    required this.recurringRatio,
    required this.safeRatio,
    required this.selectedBranch,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const startX = 24.0;
    final startY = size.height / 2;
    final endX = size.width - 24.0;

    // Left Node (Total Income Anchor)
    final rootHeight = size.height * 0.72;
    final rootTop = startY - rootHeight / 2;
    final rootBottom = startY + rootHeight / 2;

    // Outflow Right Anchors
    const branchSpacing = 16.0;
    final totalOutflowHeight = size.height - (branchSpacing * 2);
    
    // Normalized proportions
    final totalRatios = emiRatio + recurringRatio + safeRatio;
    final normEMI = totalRatios > 0 ? (emiRatio / totalRatios) : 0.33;
    final normRec = totalRatios > 0 ? (recurringRatio / totalRatios) : 0.33;
    final normSafe = totalRatios > 0 ? (safeRatio / totalRatios) : 0.34;

    final h1 = math.max(14.0, totalOutflowHeight * normSafe);       // Top: Free Capital (Green)
    final h2 = math.max(14.0, totalOutflowHeight * normRec);        // Mid: Essentials (Amber)
    final h3 = math.max(14.0, totalOutflowHeight * normEMI);        // Bottom: Debt EMIs (Red)

    final y1 = 10.0 + h1 / 2;
    final y2 = 10.0 + h1 + branchSpacing + h2 / 2;
    final y3 = 10.0 + h1 + branchSpacing + h2 + branchSpacing + h3 / 2;

    // Draw Stream 1: Free Capital (Green)
    _drawStream(
      canvas: canvas,
      startX: startX,
      startY: rootTop + (rootHeight * normSafe * 0.5),
      startThickness: rootHeight * normSafe,
      endX: endX,
      endY: y1,
      endThickness: h1,
      color: const Color(0xFF00D09C),
      isDimmed: selectedBranch != null && selectedBranch != 2,
    );

    // Draw Stream 2: Essentials (Amber)
    _drawStream(
      canvas: canvas,
      startX: startX,
      startY: rootTop + (rootHeight * normSafe) + (rootHeight * normRec * 0.5),
      startThickness: rootHeight * normRec,
      endX: endX,
      endY: y2,
      endThickness: h2,
      color: const Color(0xFFF59E0B),
      isDimmed: selectedBranch != null && selectedBranch != 1,
    );

    // Draw Stream 3: Debt EMIs (Rose Red)
    _drawStream(
      canvas: canvas,
      startX: startX,
      startY: rootBottom - (rootHeight * normEMI * 0.5),
      startThickness: rootHeight * normEMI,
      endX: endX,
      endY: y3,
      endThickness: h3,
      color: const Color(0xFFF43F5E),
      isDimmed: selectedBranch != null && selectedBranch != 0,
    );

    // Draw Input Trunk Pillar on Left
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D09C).withValues(alpha: 0.9),
          const Color(0xFF38BDF8).withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(startX - 10, rootTop, 10, rootHeight));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX - 8, rootTop, 8, rootHeight),
        const Radius.circular(4),
      ),
      trunkPaint,
    );
  }

  void _drawStream({
    required Canvas canvas,
    required double startX,
    required double startY,
    required double startThickness,
    required double endX,
    required double endY,
    required double endThickness,
    required Color color,
    required bool isDimmed,
  }) {
    final opacity = isDimmed ? 0.15 : 0.65;
    final path = Path();

    final halfStart = startThickness / 2;
    final halfEnd = endThickness / 2;

    final cp1X = startX + (endX - startX) * 0.45;
    final cp2X = startX + (endX - startX) * 0.55;

    // Top curve
    path.moveTo(startX, startY - halfStart);
    path.cubicTo(cp1X, startY - halfStart, cp2X, endY - halfEnd, endX, endY - halfEnd);
    // Right side
    path.lineTo(endX, endY + halfEnd);
    // Bottom curve backwards
    path.cubicTo(cp2X, endY + halfEnd, cp1X, startY + halfStart, startX, startY + halfStart);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: opacity * 0.7),
          color.withValues(alpha: opacity),
        ],
      ).createShader(Rect.fromLTRB(startX, 0, endX, 150))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Particle pulse along the center spline
    if (!isDimmed) {
      final pulseT = (flowProgress + (endY / 150.0)) % 1.0;
      final t = pulseT;
      // Evaluate cubic bezier center
      final cx = math.pow(1 - t, 3) * startX +
          3 * math.pow(1 - t, 2) * t * cp1X +
          3 * (1 - t) * math.pow(t, 2) * cp2X +
          math.pow(t, 3) * endX;
      final cy = math.pow(1 - t, 3) * startY +
          3 * math.pow(1 - t, 2) * t * startY +
          3 * (1 - t) * math.pow(t, 2) * endY +
          math.pow(t, 3) * endY;

      final particlePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
      canvas.drawCircle(Offset(cx.toDouble(), cy.toDouble()), 3.0, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SankeyRiverPainter oldDelegate) {
    return oldDelegate.flowProgress != flowProgress ||
        oldDelegate.selectedBranch != selectedBranch ||
        oldDelegate.emiRatio != emiRatio ||
        oldDelegate.safeRatio != safeRatio;
  }
}
