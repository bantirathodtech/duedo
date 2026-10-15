import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/insights_viewmodel.dart';
import '../../services/optimization_engine.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ad_service.dart';
import '../widgets/freedom_tape_modal.dart';
import '../widgets/upi_slay_modal.dart';
import '../widgets/debt_negotiation_modal.dart';
import '../../services/daily_rings_service.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  void initState() {
    super.initState();
    // IRONMAN: Defer ad loading to after the first frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNativeAd();
    });
  }

  void _loadNativeAd() {
    if (!AdMobService.isHealthy) return;
    
    final adUnitId = AdMobService.nativeAdUnitId;
    if (adUnitId == null) return;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample', // This is usually ignored if using templates
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('$NativeAd failed to load: $error');
          Future.microtask(() => ad.dispose());
        },
      ),
      request: const AdRequest(),
      // Using Native Templates (Requires google_mobile_ads 3.0.0+)
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.transparent,
        cornerRadius: 15.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppTheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final insightsState = ref.watch(insightsViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final insightsViewModel = ref.read(insightsViewModelProvider.notifier);
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
                  _buildSectionHeader('Automator Strategy'),
                  const SizedBox(height: 16),
                  _buildStrategyPanel(insightsState, insightsViewModel, currencyFormat, context),
                  const SizedBox(height: 24),
                  _buildNativeAd(),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Simulation Sandbox'),
                  const SizedBox(height: 16),
                  _buildSandboxPanel(insightsState, insightsViewModel, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('High-APR Arbitrage Radar'),
                  const SizedBox(height: 16),
                  _buildRefinanceArbitrageSection(state, viewModel, currencyFormat, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('👻 Ghost Bill Hunter'),
                  const SizedBox(height: 16),
                  _buildGhostBillHunterSection(viewModel, currencyFormat, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('🚨 Crisis Stress-Test (Survival Runway)'),
                  const SizedBox(height: 16),
                  _buildCrisisStressTestCard(viewModel, currencyFormat, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('🛡️ Emergency Credit Armor'),
                  const SizedBox(height: 16),
                  _buildEmergencyGraceShieldSection(state, viewModel, currencyFormat, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('🎬 Monthly Freedom Tape'),
                  const SizedBox(height: 16),
                  _buildFreedomTapeBanner(state, viewModel, currencyFormat, context),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Milestone Achievements'),
                  const SizedBox(height: 16),
                  _buildMilestonesLocker(viewModel, context),
                  const SizedBox(height: 32),

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
                  _buildSectionHeader('🇮🇳 Tax Shield (Advisory)'),
                  const SizedBox(height: 16),
                  _buildTaxIntelligenceSection(viewModel, currencyFormat, context),
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
        color: AppTheme.primary.withValues(alpha: 0.8),
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
                    badgeWidget: _buildBadge('${total > 0 ? ((emiTotal / total) * 100).toInt() : 0}%', AppTheme.primary),
                    badgePositionPercentageOffset: 1.5,
                  ),
                  PieChartSectionData(
                    color: AppTheme.secondary,
                    value: oneTimeTotal,
                    title: '',
                    radius: 25,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    badgeWidget: _buildBadge('${total > 0 ? ((oneTimeTotal / total) * 100).toInt() : 0}%', AppTheme.secondary),
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
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)],
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
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text, 
                style: GoogleFonts.inter(
                  fontSize: 10, 
                  color: Colors.grey.shade500, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
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
        Expanded(
          child: Text(
            label, 
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value, 
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color),
          ),
        ),
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
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBT-FREE DATE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('MMMM yyyy').format(data.debtFreeDate),
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
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
                    AppTheme.primary.withValues(alpha: 0.3),
                    AppTheme.primary.withValues(alpha: 0.0),
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
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black.withValues(alpha: 0.8),
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

  // --- Sandbox & Automator Custom UI Widgets --- //

  Widget _buildStrategyPanel(InsightsState state, InsightsViewModel viewModel, NumberFormat format, BuildContext context) {
    bool isAvalanche = state.strategy == RepaymentStrategy.avalanche;
    double interestSaved = state.savingsDelta?['interestSaved'] ?? 0.0;
    int monthsSaved = state.savingsDelta?['monthsSaved'] ?? 0;

    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                     HapticService.selection();
                     viewModel.setStrategy(RepaymentStrategy.snowball);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isAvalanche ? AppTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: !isAvalanche ? AppTheme.primary : Colors.white10),
                    ),
                    child: Center(child: Text('SNOWBALL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: !isAvalanche ? AppTheme.primary : Colors.grey))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                     HapticService.selection();
                     viewModel.setStrategy(RepaymentStrategy.avalanche);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isAvalanche ? AppTheme.secondary.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isAvalanche ? AppTheme.secondary : Colors.white10),
                    ),
                    child: Center(child: Text('AVALANCHE', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: isAvalanche ? AppTheme.secondary : Colors.grey))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (interestSaved > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppTheme.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Optimized strategy saves theoretically up to ${format.format(interestSaved)} and $monthsSaved months.',
                      style: GoogleFonts.inter(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSandboxPanel(InsightsState state, InsightsViewModel viewModel, BuildContext context) {
    int percentage = ((state.incomeMultiplier - 1.0) * 100).round();
    String sign = percentage > 0 ? '+' : '';
    
    DateTime? simDate = state.simulatedFreedomData?.debtFreeDate;
    
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Income Scaling', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.grey))),
              Text('$sign$percentage%', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: state.incomeMultiplier,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (val) {
                // If not premium, snap back to 1.0 logic is already in ViewModel but UI needs to look smooth. 
                viewModel.setIncomeMultiplier(val);
              },
            ),
          ),
          const Divider(height: 32, color: Colors.white10),
          Text('Simulated Freedom Date', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            simDate != null ? DateFormat('MMMM yyyy').format(simDate) : 'Unknown',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          if (!state.isPremium) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Duedo+ Pro required for full simulation', style: GoogleFonts.inter(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
  Widget _buildTaxIntelligenceSection(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final savings = viewModel.taxSavings;
    final total = savings['total'] ?? 0;
    
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(context),
        child: const Center(
          child: Text(
            'Categorize recurring items (80C, 80D) in Settings to see tax advisory.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESTIMATED TAX SHIELD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        format.format(total),
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.security_rounded, color: AppTheme.success, size: 32),
            ],
          ),
          const SizedBox(height: 24),
          _buildTaxRow('80C (Capped)', format.format(savings['80C'] ?? 0), 150000 > 0 ? (savings['80C'] ?? 0) / 150000 : 0),
          const SizedBox(height: 16),
          _buildTaxRow('80D (Health)', format.format(savings['80D'] ?? 0), 25000 > 0 ? (savings['80D'] ?? 0) / 25000 : 0),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400))),
            Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success.withValues(alpha: 0.7)),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesLocker(HomeViewModel viewModel, BuildContext context) {
    final badges = viewModel.gamificationBadges;
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: badges.map((badge) {
          final color = badge.isUnlocked ? AppTheme.primary : Colors.grey.shade800;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(badge.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_rounded, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(badge.title, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: badge.isUnlocked ? Colors.white : Colors.grey)),
                      const SizedBox(height: 4),
                      Text(badge.description, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNativeAd() {
    if (_nativeAdIsLoaded && _nativeAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: AppTheme.glassDecoration(context).copyWith(
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'AD', 
                      style: GoogleFonts.inter(
                        fontSize: 8, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SUPPORTING FREE ACCESS',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 320,
                minHeight: 90,
                maxWidth: 400,
                maxHeight: 200,
              ),
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        ),
      );
    }
    
    return _buildNativeAdPlaceholder(context);
  }

  Widget _buildNativeAdPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(context).copyWith(
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.15), AppTheme.secondary.withValues(alpha: 0.05)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AD: UNLOCK PRO INSIGHTS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.primary)),
                    const SizedBox(height: 4),
                    Text('Get unlimited simulations and tax optimization.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                 HapticService.selection();
                 // Trigger IAP or move to settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Upgrade Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisStressTestCard(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final result = viewModel.runCrisisStressTest();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    String statusLabel;
    if (result.runwayDays >= 90) {
      statusColor = AppTheme.success;
      statusLabel = 'SHIELDED • 90+ DAYS RUNWAY';
    } else if (result.runwayDays >= 30) {
      statusColor = AppTheme.warning;
      statusLabel = 'VULNERABLE • ${result.runwayDays} DAYS RUNWAY';
    } else {
      statusColor = AppTheme.danger;
      statusLabel = 'CRITICAL • ${result.runwayDays} DAYS RUNWAY';
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10131E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.emergency_rounded, color: Colors.grey, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${result.runwayDays} DAYS',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Survival runway if all income suddenly drops to zero.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY SURVIVAL BURN',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        format.format(result.monthlySurvivalBurn),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        'FREEZE SAVINGS POTENTIAL',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        format.format(result.discretionarySavingsPotential),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (result.triagePlan.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'TRIAGE SURVIVAL ACTION PLAN',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: result.triagePlan.take(4).map((item) {
                Color itemColor = item.priorityLevel == 1 
                    ? const Color(0xFF38BDF8) 
                    : (item.priorityLevel == 2 ? AppTheme.warning : AppTheme.danger);
                String tag = item.priorityLevel == 1 ? 'FREEZE' : (item.priorityLevel == 2 ? 'GRACE DELAY' : 'SACRED CORE');

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141724) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: itemColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: itemColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.actionRecommendation,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        format.format(item.monthlyAmount),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefinanceArbitrageSection(HomeState state, HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final opportunities = viewModel.arbitrageOpportunities;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (opportunities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded, color: AppTheme.success, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ZERO HIGH-APR DEBT DETECTED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All your obligations are below 18% APR. Your debt structure is in prime health.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: opportunities.map((opp) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13111C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5722).withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5722).withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'HIGH-APR RADAR',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF5722),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            opp.obligation.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${opp.currentApr.toStringAsFixed(1)}% APR',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Refinancing to benchmark 11.5% prime rate unlocks immediate cashflow arbitrage:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1829) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MONTHLY CASH SAVED',
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
                              '+${format.format(opp.monthlySavings)}/mo',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.success,
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
                            'TOTAL INTEREST KILLED',
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
                              format.format(opp.totalInterestSaved),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFF5722),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  HapticService.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Consolidating ${opp.obligation.title} from ${opp.currentApr}% to ${opp.targetApr}% saves ${format.format(opp.totalInterestSaved)} total interest and accelerates freedom by ${opp.monthsAccelerated} months!',
                      ),
                      backgroundColor: const Color(0xFF1E2235),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFFF5722)),
                        const SizedBox(width: 6),
                        Text(
                          '${opp.monthsAccelerated} MONTHS FREEDOM ACCELERATION',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF5722),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.bolt_rounded, size: 14),
                        label: const Text('1-Tap UPI Slay', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          UpiSlayModal.show(
                            context,
                            obligation: opp.obligation,
                            currencyFormat: format,
                            isDark: isDark,
                            onPaymentExecuted: (amount) async {
                              await ref.read(dailyRingsServiceProvider.notifier).recordSnowflake();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.record_voice_over_rounded, size: 14),
                        label: const Text('AI Call Script', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFB7185),
                          side: const BorderSide(color: Color(0xFFE11D48), width: 0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          DebtNegotiationModal.show(
                            context,
                            obligation: opp.obligation,
                            paymentStreak: state.settings?.paymentStreak ?? 0,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGhostBillHunterSection(HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final leaks = viewModel.ghostSubscriptions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (leaks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ZERO SUBSCRIPTION LEAKAGE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF38BDF8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No overlapping streaming services or dormant low-priority bills detected.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: leaks.map((leak) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131524) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF9333EA).withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9333EA).withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LEAKAGE RADAR',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFC084FC),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            leak.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${format.format(leak.monthlyLeak)}/mo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC084FC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                leak.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B192C) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppTheme.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '5-YEAR RECLAIMED WEALTH (IF INVESTED)',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            format.format(leak.fiveYearOpportunityCost),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  HapticService.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Audit checklist: Review and prune ${leak.suspectObligations.map((o) => o.title).join(', ')} to reclaim ${format.format(leak.monthlyLeak)}/mo!',
                      ),
                      backgroundColor: const Color(0xFF1E2235),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.content_cut_rounded, size: 14, color: Color(0xFFC084FC)),
                        const SizedBox(width: 6),
                        Text(
                          'SLASH & RECLAIM CASHFLOW',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFC084FC),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFreedomTapeBanner(HomeState state, HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFA855F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY FREEDOM TAPE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFC084FC),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your 30-Day Victory Story',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'See how much vampire interest you killed, impulses shielded, and freedom days advanced this month.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Play Freedom Tape & Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final metrics = viewModel.getFreedomTapeMetrics(12500, state.settings?.paymentStreak ?? 0);
                FreedomTapeModal.show(context, metrics: metrics, currencyFormat: format, isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyGraceShieldSection(HomeState state, HomeViewModel viewModel, NumberFormat format, BuildContext context) {
    final rawIncome = state.settings?.monthlyIncome ?? 0;
    final availableCash = rawIncome > 0 ? (rawIncome * 0.3) : 10000.0;
    final plan = viewModel.calculateGraceShield(availableCash);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    if (plan.securityStatus.contains('ARMORED')) {
      statusColor = AppTheme.success;
    } else if (plan.securityStatus.contains('DEFENDED')) {
      statusColor = const Color(0xFF38BDF8);
    } else {
      statusColor = AppTheme.danger;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10131E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security_rounded, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      plan.securityStatus,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_moon_rounded, color: Colors.grey, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Credit Score Armor Triage',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'If cashflow drops, Duedo routes emergency liquidity to zero-grace debts first to shield your credit report.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 16),
          if (plan.deferredObligations.isNotEmpty) ...[
            Text(
              'DEFERRAL BUFFER WINDOWS',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Column(
              children: plan.deferredObligations.take(3).map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.safeBufferDays}d BUFFER',
                          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.obligation.title,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                            ),
                            Text(
                              item.defenseAction,
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        format.format(item.obligation.amount),
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% of upcoming obligations are covered by your emergency cash buffer. Your credit score is fully armored.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600),
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
}
