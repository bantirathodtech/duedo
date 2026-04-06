import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../../models/app_enums.dart';
import '../../services/financial_logic_service.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import 'add_obligation_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showSuccessAnimation = false;

  void _triggerSuccess() {
    setState(() => _showSuccessAnimation = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSuccessAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final currencyFormat = NumberFormat.simpleCurrency(
      name: state.settings?.currency ?? '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Premium Background Layer
          AppTheme.glassBackground(context),

          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header & Dashboard Summary
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(state, viewModel, currencyFormat),
                              const SizedBox(height: 32),
                              _buildSummaryGrid(viewModel, state, currencyFormat, isDark),
                              const SizedBox(height: 32),
                              _buildProjectionToggles(viewModel, state, isDark),
                              const SizedBox(height: 24),
                              _buildAlertCenter(viewModel),
                              const SizedBox(height: 40),
                              _buildListHeader(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      // Obligations List
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverReorderableList(
                          itemCount: state.obligations.length,
                          itemBuilder: (context, index) {
                            final sortedList = viewModel.sortedObligations;
                            if (index >= sortedList.length) return const SizedBox();
                            final obligation = sortedList[index];
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey('obligation_${obligation.id}'),
                              index: index,
                              child: _StaggeredEntry(
                                delay: 400 + (index * 100),
                                child: _buildObligationCard(context, obligation, currencyFormat, ref, index, isDark),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            HapticService.selection();
                            viewModel.reorderObligations(oldIndex, newIndex);
                          },
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),

          // Success Animation Overlay
          if (_showSuccessAnimation)
            _buildSuccessOverlay(),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }


  Widget _buildHeader(HomeState state, HomeViewModel viewModel, NumberFormat currencyFormat) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TOTAL INCOME', 
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_note_rounded, size: 14, color: Colors.grey.shade500),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currencyFormat.format(state.settings?.monthlyIncome ?? 0), 
                          style: GoogleFonts.outfit(
                            fontSize: 34, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 12),
                        _buildStreakBadge(state.settings?.paymentStreak ?? 0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                _FreedomCountdownRing(data: viewModel.freedomData),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.primary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakBadge(int streak) {
    if (streak == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fireplace_rounded, color: Colors.orange, size: 14),
          const SizedBox(width: 4),
          Text(
            '$streak MONTH STREAK',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryGrid(HomeViewModel viewModel, HomeState state, NumberFormat format, bool isDark) {
    final months = state.projectionMonths;
    final totalEmi = viewModel.totalMonthlyEMI * months;
    final totalOneTime = viewModel.totalOneTimeDue;
    final urgentCount = viewModel.urgentItemsCount;
    final pressureScore = (viewModel.pressureScore * 100).toInt();

    return Column(
      children: [
        _StaggeredEntry(
          delay: 100,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _EliteInteraction(
                  onTap: () {},
                  child: _buildMainStatCard(
                    'TOTAL COMMITMENT', 
                    format.format(totalEmi + totalOneTime),
                    AppTheme.auroraGradient,
                    isDark,
                    Icons.account_balance_wallet_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _EliteInteraction(
                  onTap: () {},
                  child: _buildSecondaryStatCard(
                    'URGENCY', 
                    urgentCount.toString(),
                    urgentCount > 0 ? AppTheme.danger : AppTheme.success,
                    isDark,
                    Icons.bolt_rounded,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _StaggeredEntry(
          delay: 200,
          child: Row(
            children: [
              Expanded(
                child: _buildSecondaryStatCard(
                  'EMI LOAD', 
                  format.format(totalEmi),
                  AppTheme.primary,
                  isDark,
                  Icons.repeat_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecondaryStatCard(
                  'FINANCIAL STRESS', 
                  '$pressureScore%',
                  _getPressureColor(viewModel.pressureLevel),
                  isDark,
                  Icons.speed_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatCard(String title, String value, LinearGradient gradient, bool isDark, IconData icon) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(context).copyWith(
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withOpacity(0.8),
            gradient.colors.last.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8), 
                    fontSize: 10, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.6), size: 20),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white, 
              fontSize: 28, 
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatCard(String title, String value, Color color, bool isDark, IconData icon) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade500, 
                    fontSize: 9, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color, 
              fontSize: 20, 
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionToggles(HomeViewModel viewModel, HomeState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _ProjectionChip(label: '1 Month', months: 1, current: state.projectionMonths, onTap: viewModel.setProjectionMonths, isDark: isDark),
          _ProjectionChip(label: '3 Months', months: 3, current: state.projectionMonths, onTap: viewModel.setProjectionMonths, isDark: isDark),
          _ProjectionChip(label: '6 Months', months: 6, current: state.projectionMonths, onTap: viewModel.setProjectionMonths, isDark: isDark),
          _ProjectionChip(label: '1 Year', months: 12, current: state.projectionMonths, onTap: viewModel.setProjectionMonths, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildAlertCenter(HomeViewModel viewModel) {
    final insights = viewModel.insights;
    if (insights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Action Center',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Enough for insight cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              final isCritical = insight.severity == InsightSeverity.critical;
              final isWarning = insight.severity == InsightSeverity.warning;

              final tint = isCritical ? AppTheme.danger : (isWarning ? Colors.orange : AppTheme.primary);
              final icon = isCritical ? Icons.warning_rounded : (isWarning ? Icons.error_outline_rounded : Icons.lightbulb_outline_rounded);
              
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration(context).copyWith(
                  border: Border.all(color: tint.withOpacity(0.3)),
                  gradient: LinearGradient(
                    colors: [tint.withOpacity(0.1), tint.withOpacity(0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 16, color: tint),
                        const SizedBox(width: 8),
                        Expanded(child: Text(insight.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: tint))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        insight.description, 
                        style: GoogleFonts.inter(fontSize: 11, height: 1.4, color: Colors.grey.shade400),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Obligations',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'DRAG TO SORT',
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildObligationCard(
      BuildContext context, Obligation obligation, NumberFormat format, WidgetRef ref, int index, bool isDark) {
    final priorityColor = _getPriorityColor(obligation.priority);
    final isEmi = obligation.type == ObligationType.emi;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _EliteInteraction(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => AddObligationScreen(obligation: obligation))
        ),
        child: Dismissible(
          key: ValueKey('dismiss_${obligation.id}'),
          direction: obligation.isActive ? DismissDirection.startToEnd : DismissDirection.none,
          background: _buildDismissBackground(),
          onDismissed: (direction) {
            _triggerSuccess();
            ref.read(homeViewModelProvider.notifier).recordPayment(obligation, obligation.amount);
          },
          child: Container(
            decoration: AppTheme.glassDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildIndexIcon(index, priorityColor, isEmi),
                      const SizedBox(width: 16),
                      Expanded(child: _buildObligationDetails(obligation)),
                      _buildAmountSection(obligation, format),
                    ],
                  ),
                  if (obligation.type == ObligationType.oneTime && obligation.isActive) ...[
                    const SizedBox(height: 16),
                    _buildPaymentProgress(ref.read(homeViewModelProvider.notifier).getTotalPaid(obligation.id), obligation.amount, isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndexIcon(int index, Color color, bool isEmi) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(isEmi ? Icons.repeat_rounded : Icons.calendar_today_rounded, color: color, size: 22),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObligationDetails(Obligation obligation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          obligation.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            decoration: obligation.isActive ? null : TextDecoration.lineThrough,
            color: obligation.isActive ? null : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${obligation.category.toUpperCase()} • ${_formatDateWindow(obligation)}',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildAmountSection(Obligation obligation, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          format.format(obligation.amount),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: obligation.isActive ? null : Colors.grey,
          ),
        ),
        const Icon(Icons.drag_indicator_rounded, size: 20, color: Colors.grey),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 32),
      decoration: BoxDecoration(
        color: AppTheme.success,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
    );
  }

  Widget _buildPaymentProgress(double paid, double total, bool isDark) {
    if (paid <= 0) return const SizedBox();
    final progress = (paid / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECTED ₹${paid.toInt()}',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateWindow(Obligation obligation) {
    final start = obligation.nextDueDate ?? obligation.startDate;
    if (obligation.gracePeriodDays == 0) {
      return DateFormat('MMM dd').format(start);
    }
    final end = start.add(Duration(days: obligation.gracePeriodDays));
    return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd').format(end)}';
  }

  Widget _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0), // Keep above floating dock
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddObligationScreen())),
        backgroundColor: AppTheme.primary,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('ADD NEW', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.9),
        child: Center(
          child: Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_m34959o6.json',
            repeat: false,
            onLoaded: (composition) => HapticService.success(),
          ),
        ),
      ),
    );
  }

  Color _getPressureColor(PressureLevel level) {
    switch (level) {
      case PressureLevel.safe: return AppTheme.success;
      case PressureLevel.warning: return AppTheme.warning;
      case PressureLevel.danger: return AppTheme.danger;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low: return AppTheme.success;
      case PriorityLevel.medium: return AppTheme.warning;
      case PriorityLevel.high: return AppTheme.danger;
    }
  }
}

class _FreedomCountdownRing extends StatelessWidget {
  final FreedomData data;

  const _FreedomCountdownRing({required this.data});

  @override
  Widget build(BuildContext context) {
    // We assume 1000 days is the "max" for the ring visualization
    const maxDays = 1000.0;
    final progress = (data.daysLeft / maxDays).clamp(0.0, 1.0);
    final color = Color.lerp(AppTheme.success, AppTheme.primary, progress) ?? AppTheme.primary;

    return Column(
      children: [
        SizedBox(
          width: 85,
          height: 85,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1.0 - progress),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutQuart,
                builder: (context, value, _) => CustomPaint(
                  size: const Size(85, 85),
                  painter: _GaugePainter(percentage: 1.0 - value, color: color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${data.daysLeft}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    'DAYS',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: color.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TO FREEDOM',
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  _GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Background track
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.5708, // -90 degrees
      6.28318 * (1 - percentage), // 360 degrees * remaining health
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class _EliteInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _EliteInteraction({required this.child, required this.onTap});

  @override
  State<_EliteInteraction> createState() => _EliteInteractionState();
}

class _EliteInteractionState extends State<_EliteInteraction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
        HapticService.selection();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _ProjectionChip extends StatelessWidget {
  final String label;
  final int months;
  final int current;
  final Function(int) onTap;
  final bool isDark;

  const _ProjectionChip({
    required this.label, 
    required this.months, 
    required this.current, 
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == months;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selection();
          onTap(months);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected && !isDark ? [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppTheme.primary : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredEntry extends StatelessWidget {
  final Widget child;
  final int delay;

  const _StaggeredEntry({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + delay),
          curve: Curves.easeOutQuint,
          child: Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
