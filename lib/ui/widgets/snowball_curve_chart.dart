import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SnowballCurveChart extends StatelessWidget {
  final List<double> monthlyBalances;
  final List<double> monthlyWealth;
  final bool isDark;

  const SnowballCurveChart({
    super.key,
    required this.monthlyBalances,
    this.monthlyWealth = const [],
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyBalances.isEmpty) return const SizedBox();

    final maxBalance = monthlyBalances.fold(0.0, (m, b) => b > m ? b : m);
    final maxWealth = monthlyWealth.fold(0.0, (m, b) => b > m ? b : m);
    final overallMax = maxBalance > maxWealth ? maxBalance : maxWealth;

    final debtSpots = <FlSpot>[];
    for (int i = 0; i < monthlyBalances.length; i++) {
      debtSpots.add(FlSpot(i.toDouble(), monthlyBalances[i]));
    }

    final wealthSpots = <FlSpot>[];
    for (int i = 0; i < monthlyWealth.length; i++) {
      wealthSpots.add(FlSpot(i.toDouble(), monthlyWealth[i]));
    }

    return Container(
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FREEDOM TRAJECTORY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(monthlyBalances.length > monthlyWealth.length ? monthlyBalances.length : monthlyWealth.length) - 1}M SIMULATION',
                  style: GoogleFonts.inter(
                    fontSize: 9, 
                    fontWeight: FontWeight.w800, 
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendItem(color: AppTheme.primary, label: 'Debt Amortization', isDark: isDark),
              const SizedBox(width: 16),
              _LegendItem(color: const Color(0xFF00E676), label: 'Wealth Accumulation', isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (monthlyBalances.length > monthlyWealth.length ? monthlyBalances.length : monthlyWealth.length).toDouble() - 1,
                minY: 0,
                maxY: overallMax * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: debtSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                          AppTheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  if (wealthSpots.isNotEmpty)
                    LineChartBarData(
                      spots: wealthSpots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF00E676),
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF00E676).withValues(alpha: isDark ? 0.20 : 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({required this.color, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
