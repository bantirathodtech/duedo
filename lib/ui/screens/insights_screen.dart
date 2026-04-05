import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/financial_logic_service.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final currencyFormat = NumberFormat.simpleCurrency(
      name: state.settings?.currency ?? '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Financial Intelligence',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AppTheme.glassBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Obligation Mix'),
                  const SizedBox(height: 16),
                  _buildChartSection(viewModel, currencyFormat, context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('6-Month Projection'),
                  const SizedBox(height: 16),
                  _buildMonthlyLoadHistory(viewModel, currencyFormat, context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('AI Action Engine'),
                  const SizedBox(height: 16),
                  _buildAIIntelligenceSection(viewModel, context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Freedom Progress'),
                  const SizedBox(height: 16),
                  _buildFreedomProgressSection(viewModel, currencyFormat, context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Detailed Breakdown'),
                  const SizedBox(height: 16),
                  _buildBreakdownSection(viewModel, currencyFormat, context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: AppTheme.primary.withOpacity(0.8),
      ),
    );
  }

  Widget _buildChartSection(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final emiTotal = viewModel.totalMonthlyEMI;
    final oneTimeTotal = viewModel.totalOneTimeDue;
    final total = emiTotal + oneTimeTotal;

    if (total == 0) {
      return Container(
        width: double.infinity,
        decoration: AppTheme.glassDecoration(context),
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Text('Add obligations to see analysis', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: AppTheme.primary,
                    value: emiTotal,
                    title: '',
                    radius: 25,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    badgeWidget: _buildBadge('${((emiTotal / total) * 100).toInt()}%', AppTheme.primary),
                    badgePositionPercentageOffset: 1.5,
                  ),
                  PieChartSectionData(
                    color: AppTheme.secondary,
                    value: oneTimeTotal,
                    title: '',
                    radius: 25,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    badgeWidget: _buildBadge('${((oneTimeTotal / total) * 100).toInt()}%', AppTheme.secondary),
                    badgePositionPercentageOffset: 1.5,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicator(AppTheme.primary, 'Monthly EMI', format.format(emiTotal)),
              _buildIndicator(AppTheme.secondary, 'One-time', format.format(oneTimeTotal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildIndicator(Color color, String text, String amount) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10, 
              height: 10, 
              decoration: BoxDecoration(
                color: color, 
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text, 
              style: GoogleFonts.inter(
                fontSize: 10, 
                color: Colors.grey.shade500, 
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount, 
          style: GoogleFonts.outfit(
            fontSize: 20, 
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailRow('Fixed EMIs', format.format(viewModel.totalMonthlyEMI), AppTheme.primary),
          const Divider(height: 32, color: Colors.white10),
          _buildDetailRow('One-time Due', format.format(viewModel.totalOneTimeDue), AppTheme.secondary),
          const Divider(height: 32, color: Colors.white10),
          _buildDetailRow('Total Exposure', format.format(viewModel.totalMonthlyEMI + viewModel.totalOneTimeDue), Colors.white, isBold: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAIIntelligenceSection(HomeViewModel viewModel, BuildContext context) {
    final alerts = viewModel.intelligenceAlerts;
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(context),
        child: const Center(child: Text('AI is analyzing your patterns...', style: TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      children: alerts.map((alert) {
        final isRefinance = alert.type == AlertType.refinance;
        final color = isRefinance ? AppTheme.primary : AppTheme.warning;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(context).copyWith(
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_getAlertIcon(alert.type), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style: GoogleFonts.inter(height: 1.5, color: Colors.grey.shade300, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildAIActionButton(_getAlertActionLabel(alert.type), color),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.warning: return Icons.warning_rounded;
      case AlertType.success: return Icons.check_circle_rounded;
      case AlertType.refinance: return Icons.analytics_rounded;
      case AlertType.info: return Icons.info_rounded;
      default: return Icons.lightbulb_outline_rounded;
    }
  }

  String _getAlertActionLabel(AlertType type) {
    switch (type) {
      case AlertType.refinance: return 'Calculate Savings';
      case AlertType.warning: return 'View Breakdown';
      default: return 'Learn More';
    }
  }

  Widget _buildAIActionButton(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildFreedomProgressSection(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final data = viewModel.freedomData;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DEBT-FREE DATE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM yyyy').format(data.debtFreeDate),
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${data.daysLeft} DAYS LEFT',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProjectionToggles(viewModel, context),
        ],
      ),
    );
  }

  Widget _buildProjectionToggles(HomeViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTIMATED TOTAL OUTSTANDING',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'The AI calculates your freedom date based on current interest rates and repayment speed.',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildMonthlyLoadHistory(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final projection = viewModel.getMonthlyProjection(6);
    
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      decoration: AppTheme.glassDecoration(context),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: projection.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['amount'] as double)).toList(),
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppTheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.3),
                    AppTheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < projection.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        projection[index]['month'],
                        style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    format.format(spot.y),
                    GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
