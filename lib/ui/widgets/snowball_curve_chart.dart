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
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PATH TO FREEDOM',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(monthlyBalances.length > monthlyWealth.length ? monthlyBalances.length : monthlyWealth.length) - 1} MONTHS PROJECTION',
                  style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendItem(color: AppTheme.primary, label: 'Debt Path', isDark: isDark),
              const SizedBox(width: 16),
              _LegendItem(color: const Color(0xFF00E676), label: 'Wealth Flip', isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
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
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.5)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.primary.withValues(alpha: 0.15), AppTheme.primary.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                  if (wealthSpots.isNotEmpty)
                    LineChartBarData(
                      spots: wealthSpots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [const Color(0xFF00E676).withValues(alpha: 0.1), Colors.transparent],
                        ),
                      ),
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOutBack,
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
