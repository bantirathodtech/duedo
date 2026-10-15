import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:drift/drift.dart' as drift;
import '../../services/ads/ad_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../../models/app_enums.dart';
import '../../services/financial_logic_service.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../widgets/snowball_curve_chart.dart';
import 'milestones_screen.dart';
import 'add_obligation_screen.dart';
import 'settings_screen.dart';
import '../../services/ads/interstitial_ad_manager.dart';
import '../../services/logger_service.dart';
import '../../services/notification_service.dart';
import '../../services/daily_rings_service.dart';
import '../../services/persona_voice_service.dart';
import '../widgets/daily_freedom_rings_widget.dart';
import '../widgets/impulse_vault_card.dart';
import '../widgets/safe_to_spend_dial_card.dart';
import '../widgets/payday_blitz_modal.dart';
import '../../services/freedom_league_service.dart';
import 'freedom_league_screen.dart';
import '../../services/streak_armor_service.dart';
import '../widgets/relapse_rescue_modal.dart';
import '../widgets/voice_slay_modal.dart';
import '../widgets/crisis_defibrillator_modal.dart';
import '../../services/black_swan_crisis_service.dart';
import '../widgets/sovereign_command_deck.dart';
import '../widgets/sovereign_codex_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showSuccessAnimation = false;
  int _selectedTab = 0; // 0: Debts & EMIs, 1: Monthly Essentials
  double _extraAccelerator = 0.0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  late InterstitialAdManager _interstitialAdManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
    _interstitialAdManager = InterstitialAdManager()..loadAd();
  }

  Future<void> _loadBannerAd() async {
    if (!AdMobService.isHealthy) return;

    final adSize = await AdMobService.getAdaptiveAdSize(context);
    
    if (!mounted) return;
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId!,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          LoggerService.log(
            'BannerAd failed to load: $error',
            category: LogCategory.warning,
            error: error,
          );
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    final banner = _bannerAd;
    _bannerAd = null;
    Future.microtask(() => banner?.dispose());
    _interstitialAdManager.dispose();
    super.dispose();
  }

  void _triggerSuccess() {
    setState(() => _showSuccessAnimation = true);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _showSuccessAnimation = false);
    });
  }

  Obligation? _getSpotlightObligation(List<Obligation> obligations) {
    final active = obligations.where((o) => o.isActive && o.status != ObligationStatus.paid).toList();
    if (active.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Any overdue? Overdue gets immediate critical spotlight
    final overdue = active.where((o) {
      final start = o.nextDueDate ?? o.endDate ?? o.startDate;
      final deadline = start.add(Duration(days: o.gracePeriodDays));
      final normDeadline = DateTime(deadline.year, deadline.month, deadline.day);
      return today.isAfter(normDeadline);
    }).toList();

    if (overdue.isNotEmpty) {
      overdue.sort((a, b) {
        final da = (a.nextDueDate ?? a.startDate);
        final db = (b.nextDueDate ?? b.startDate);
        return da.compareTo(db);
      });
      return overdue.first;
    }

    // 2. Otherwise sort by nearest upcoming deadline
    active.sort((a, b) {
      final da = (a.nextDueDate ?? a.startDate);
      final db = (b.nextDueDate ?? b.startDate);
      return da.compareTo(db);
    });
    return active.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger success animation when a new milestone is unlocked
    ref.listen(homeViewModelProvider.select((s) => s.hasNewlyUnlockedMilestone), (previous, next) {
      if (next == true) {
        _triggerSuccess();
        viewModel.clearNewlyUnlockedMilestone();
      }
    });

    final currencyFormat = NumberFormat.simpleCurrency(
      name: state.settings?.currency ?? '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Luxury Background Layer
          AppTheme.glassBackground(context),

          state.isLoading
              ? _buildSkeletonDashboard(isDark)
              : RefreshIndicator(
                  color: AppTheme.primary,
                  backgroundColor: isDark ? const Color(0xFF141722) : Colors.white,
                  onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header & Dashboard Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopStatusBar(state, viewModel, isDark),
                              const SizedBox(height: 18),
                              _buildMasterCommandHero(viewModel, state, currencyFormat, isDark),
                              const SizedBox(height: 18),
                              _buildDailyFreedomRings(viewModel, state, isDark),
                              const SizedBox(height: 18),
                              _buildSafeToSpendSection(viewModel, currencyFormat),
                              const SizedBox(height: 18),
                              SovereignCommandDeck(isDark: isDark),
                              const SizedBox(height: 18),
                              _buildUpNextSpotlight(viewModel, state, currencyFormat, isDark),
                              const SizedBox(height: 18),
                              _buildImpulseVaultSection(viewModel, state, currencyFormat, isDark),
                              const SizedBox(height: 18),
                              _buildCrisisBanner(isDark),
                              _buildAlertCenter(viewModel),
                              if (_selectedTab == 0 && _getFilteredObligations(viewModel).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _buildPayoffAcceleratorSection(viewModel, state, currencyFormat, isDark),
                              ],
                              const SizedBox(height: 24),
                              _buildListHeader(viewModel, isDark),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // Reorderable Obligations List
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: _getFilteredObligations(viewModel).isEmpty 
                          ? SliverToBoxAdapter(
                              child: _buildEmptyState(isDark),
                            )
                          : SliverReorderableList(
                              itemCount: _getFilteredObligations(viewModel).length,
                              itemBuilder: (context, index) {
                                final filteredList = _getFilteredObligations(viewModel);
                                if (index >= filteredList.length) return const SizedBox();
                                final obligation = filteredList[index];
                                return ReorderableDelayedDragStartListener(
                                  key: ValueKey('obligation_${obligation.id}'),
                                  index: index,
                                  child: _StaggeredEntry(
                                    delay: 200 + (index * 60),
                                    child: _buildObligationCard(context, obligation, currencyFormat, ref, index, isDark),
                                  ),
                                );
                              },
                              onReorder: (oldIndex, newIndex) {
                                HapticService.selection();
                                viewModel.reorderObligations(
                                  oldIndex, 
                                  newIndex, 
                                  filteredList: _getFilteredObligations(viewModel),
                                );
                              },
                            ),
                      ),
                      
                      // Banner Ad for non-premium tier
                      if (_isBannerAdLoaded && !state.settings!.isPremium)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                                Container(
                                  alignment: Alignment.center,
                                  width: _bannerAd!.size.width.toDouble(),
                                  height: _bannerAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),

          // 60FPS Confetti & Settlement Celebration
          if (_showSuccessAnimation)
            _buildSuccessOverlay(),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildTopStatusBar(HomeState state, HomeViewModel viewModel, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Monogram & Health Pill
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141722) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DUEDO',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BouncingWidget(
                  onTap: () => SovereignCodexModal.show(context, isDark: isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                            : [const Color(0xFFEEF2FF), const Color(0xFFF1F5F9)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 4),
                        Text(
                          '9 PHASES',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF818CF8),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildHealthScorePill(viewModel.healthScore, isDark),
                const SizedBox(width: 8),
                _buildStreakBadge(state.settings?.paymentStreak ?? 0, isDark),
                const SizedBox(width: 8),
                _buildLeagueBadge(isDark),
                const SizedBox(width: 8),
                _buildStreakArmorPill(isDark),
                const SizedBox(width: 8),
                _buildPaydayBlitzPill(viewModel, state, isDark),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Voice Slay Action with Pulsing Gradient & Spring Physics
        BouncingWidget(
          onTap: () {
            VoiceSlayModal.show(context, isDark: isDark);
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Settings Shortcut with Spring Physics & Frosted Styling
        BouncingWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 18,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMasterCommandHero(
    HomeViewModel viewModel, 
    HomeState state, 
    NumberFormat currencyFormat, 
    bool isDark,
  ) {
    final months = state.projectionMonths;
    final totalEmi = viewModel.totalMonthlyEMI * months;
    final totalOneTime = viewModel.totalOneTimeDue;
    final grandTotal = totalEmi + totalOneTime;
    final income = state.settings?.monthlyIncome ?? 0;
    final pressureScore = (viewModel.pressureScore * 100).toInt();
    final freedomData = viewModel.freedomData;

    return _StaggeredEntry(
      delay: 50,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C0E17) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? const Color(0x3300D09C) : const Color(0x1F00D09C),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.03),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.04),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Control Row: Tag + Projection Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      Flexible(
                        child: Text(
                          'TOTAL COMMITMENT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
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
                _buildProjectionPillBar(viewModel, state, isDark),
              ],
            ),
            const SizedBox(height: 14),

            // Center: Giant Rolling Amount + Dual-Orbit Freedom Dial
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _AnimatedRollNumber(
                          value: grandTotal,
                          format: currencyFormat,
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 13,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              freedomData.daysLeft > 0
                                  ? 'Horizon: ${DateFormat('MMM yyyy').format(freedomData.targetDate)}'
                                  : 'Debt-Free Horizon Achieved',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _FreedomCountdownRing(data: freedomData),
              ],
            ),
            const SizedBox(height: 20),

            // Bottom Sub-Metrics Strip (EMI Load, Income, Pressure)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141724) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMicroStat(
                      'MONTHLY EMI',
                      currencyFormat.format(totalEmi),
                      AppTheme.primary,
                      isDark,
                      icon: Icons.repeat_rounded,
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showQuickIncomeSheet(context, viewModel, income, currencyFormat, isDark),
                      child: _buildMicroStat(
                        'TOTAL INCOME',
                        currencyFormat.format(income),
                        const Color(0xFF38BDF8),
                        isDark,
                        icon: Icons.edit_outlined,
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  Expanded(
                    child: _buildMicroStat(
                      'STRESS INDEX',
                      '$pressureScore%',
                      _getPressureColor(viewModel.pressureLevel),
                      isDark,
                      icon: Icons.speed_rounded,
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.bleedMetrics.hourlyBleed > 0.05) ...[
              const SizedBox(height: 12),
              _buildInterestVampireStrip(
                viewModel.bleedMetrics,
                currencyFormat,
                isDark,
                state.settings?.isSavageMode ?? false,
                () => _showSnowflakeModal(context, viewModel, state, currencyFormat, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFreedomRings(HomeViewModel viewModel, HomeState state, bool isDark) {
    final isSavage = state.settings?.isSavageMode ?? false;
    final currencyFormat = NumberFormat.simpleCurrency(name: state.settings?.currency ?? '₹', decimalDigits: 0);
    return _StaggeredEntry(
      delay: 75,
      child: DailyFreedomRingsWidget(
        isDark: isDark,
        isSavage: isSavage,
        onSnowflakeTap: () => _showSnowflakeModal(context, viewModel, state, currencyFormat, isDark),
      ),
    );
  }

  Widget _buildSafeToSpendSection(HomeViewModel viewModel, NumberFormat currencyFormat) {
    return _StaggeredEntry(
      delay: 85,
      child: SafeToSpendDialCard(
        metrics: viewModel.safeToSpendMetrics,
        format: currencyFormat,
      ),
    );
  }

  Widget _buildImpulseVaultSection(HomeViewModel viewModel, HomeState state, NumberFormat currencyFormat, bool isDark) {
    final isSavage = state.settings?.isSavageMode ?? false;
    return _StaggeredEntry(
      delay: 110,
      child: ImpulseVaultCard(
        isDark: isDark,
        isSavage: isSavage,
        currencyFormat: currencyFormat,
        onPrepayResistedAmount: (resistedAmount) {
          _showSnowflakeModal(context, viewModel, state, currencyFormat, isDark, initialAmount: resistedAmount);
        },
      ),
    );
  }

  Widget _buildInterestVampireStrip(
    InterestBleedMetrics bleed,
    NumberFormat currencyFormat,
    bool isDark,
    bool isSavage,
    VoidCallback onSlay,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: Color(0xFFEF4444), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'INTEREST VAMPIRE BLEED',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Bleeding ~${currencyFormat.format(bleed.hourlyBleed.round() > 0 ? bleed.hourlyBleed : 1)}/hr (${currencyFormat.format(bleed.dailyBleed.toInt())}/day) to lenders',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSlay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Slay',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroStat(String label, String value, Color color, bool isDark, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 3),
              Icon(icon, size: 9, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
            ],
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionPillBar(HomeViewModel viewModel, HomeState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _miniProjectionChip('1M', 1, state.projectionMonths, viewModel.setProjectionMonths, isDark),
          _miniProjectionChip('3M', 3, state.projectionMonths, viewModel.setProjectionMonths, isDark),
          _miniProjectionChip('6M', 6, state.projectionMonths, viewModel.setProjectionMonths, isDark),
          _miniProjectionChip('1Y', 12, state.projectionMonths, viewModel.setProjectionMonths, isDark),
        ],
      ),
    );
  }

  Widget _miniProjectionChip(String label, int months, int current, Function(int) onTap, bool isDark) {
    final isSelected = current == months;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap(months);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF202538) : Colors.white) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected 
                ? AppTheme.primary 
                : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          ),
        ),
      ),
    );
  }

  Widget _buildUpNextSpotlight(
    HomeViewModel viewModel, 
    HomeState state, 
    NumberFormat currencyFormat, 
    bool isDark,
  ) {
    final spotlight = _getSpotlightObligation(state.obligations);

    if (spotlight == null) {
      return _StaggeredEntry(
        delay: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10131E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CYCLE COMPLETE • ZERO PENDING',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All commitments are settled. Your streak is protected!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isOverdue = spotlight.status == ObligationStatus.overdue;
    final dueDate = spotlight.nextDueDate ?? spotlight.startDate;
    final daysDiff = dueDate.difference(DateTime.now()).inDays;
    
    Color statusColor;
    String statusBadge;
    if (isOverdue || daysDiff < 0) {
      statusColor = AppTheme.danger;
      statusBadge = 'OVERDUE BY ${daysDiff.abs()}D';
    } else if (daysDiff == 0) {
      statusColor = AppTheme.warning;
      statusBadge = 'DUE TODAY';
    } else if (daysDiff <= 3) {
      statusColor = AppTheme.warning;
      statusBadge = 'DUE IN ${daysDiff}D';
    } else {
      statusColor = AppTheme.primary;
      statusBadge = 'UP NEXT IN ${daysDiff}D';
    }

    final catColor = _getCategoryColor(spotlight.category);
    final catIcon = _getCategoryIcon(spotlight.category);

    return _StaggeredEntry(
      delay: 100,
      child: _EliteInteraction(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddObligationScreen(obligation: spotlight)),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10131E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isDark ? 0.12 : 0.05),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: statusColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              statusBadge,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        spotlight.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDateWindow(spotlight),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: catColor.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Icon(catIcon, color: catColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spotlight.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(spotlight.amount),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      _triggerSuccess();
                      viewModel.recordPayment(spotlight, spotlight.amount);
                      if (!ref.read(homeViewModelProvider).settings!.isPremium) {
                        _interstitialAdManager.showAd();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '1-TAP SETTLE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoffAcceleratorSection(
    HomeViewModel viewModel, 
    HomeState state, 
    NumberFormat currencyFormat, 
    bool isDark,
  ) {
    final acceleratedData = viewModel.getFreedomDataWithAcceleration(_extraAccelerator);
    final baselineDays = viewModel.freedomData.daysLeft;
    final acceleratedDays = acceleratedData.daysLeft;
    final savedDays = (baselineDays - acceleratedDays).clamp(0, 9999);
    final savedMonths = (savedDays / 30).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SnowballCurveChart(
          monthlyBalances: acceleratedData.monthlyBalances,
          monthlyWealth: acceleratedData.monthlyWealth,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        // Interactive Freedom Accelerator Controller
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E1019) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: AppTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'FREEDOM ACCELERATOR',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Pin Live Countdown to Lock Screen',
                        child: GestureDetector(
                          onTap: () async {
                            HapticService.selection();
                            final freedomData = viewModel.freedomData;
                            final days = freedomData.daysLeft;
                            final activeDebts = state.obligations.where((o) => o.isActive).toList();
                            final totalDebt = activeDebts.fold<double>(0.0, (sum, o) => sum + (o.totalBalance > 0 ? o.totalBalance : o.amount));
                            final upNext = activeDebts.isNotEmpty ? activeDebts.first.title : null;
                            await ref.read(notificationServiceProvider).showFreedomClockTicker(
                              daysToDebtFreedom: days,
                              totalDebtRemaining: totalDebt,
                              currency: currencyFormat.currencySymbol,
                              nextUrgentDebt: upNext,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Freedom Countdown Ticker active on Lock Screen! ⏳'),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.push_pin_outlined, color: Colors.white70, size: 14),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showSnowflakeModal(context, viewModel, state, currencyFormat, isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
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
                                'THROW SNOWFLAKE',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAcceleratorChip(0, 'Baseline', isDark),
                  const SizedBox(width: 8),
                  _buildAcceleratorChip(1000, '+₹1K', isDark),
                  const SizedBox(width: 8),
                  _buildAcceleratorChip(2500, '+₹2.5K', isDark),
                  const SizedBox(width: 8),
                  _buildAcceleratorChip(5000, '+₹5K', isDark),
                ],
              ),
              if (_extraAccelerator > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paying +${currencyFormat.format(_extraAccelerator)}/mo frees you $savedMonths months earlier by ${DateFormat('MMM yyyy').format(acceleratedData.targetDate)}!',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceleratorChip(double extra, String label, bool isDark) {
    final isSelected = _extraAccelerator == extra;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.selection();
          setState(() => _extraAccelerator = extra);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primary.withValues(alpha: isDark ? 0.20 : 0.12)
                : (isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: isSelected ? 1.0 : 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected 
                    ? AppTheme.primary 
                    : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnowflakeModal(
    BuildContext context, 
    HomeViewModel viewModel, 
    HomeState state, 
    NumberFormat currencyFormat, 
    bool isDark, {
    double? initialAmount,
  }) {
    final activeDebts = state.obligations.where((o) => o.isActive && o.status != ObligationStatus.paid).toList();

    if (activeDebts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 No active debt obligations found! You have already achieved zero debt.'),
          backgroundColor: AppTheme.success,
        ),
      );
      return;
    }

    Obligation selectedDebt = activeDebts.first;
    double amount = initialAmount ?? 500.0;
    final textController = TextEditingController(text: amount.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF10131E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final impact = viewModel.previewSnowflake(selectedDebt, amount);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF38BDF8), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Throw a Debt Snowflake',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Micro-savings injection engine',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'TARGET OBLIGATION',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        width: 0.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Obligation>(
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF161925) : Colors.white,
                        value: selectedDebt,
                        items: activeDebts.map((d) {
                          return DropdownMenuItem<Obligation>(
                            value: d,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    d.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(d.amount),
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedDebt = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'MICRO-PAYMENT AMOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [200.0, 500.0, 1000.0, 2000.0].map((v) {
                      final isSel = (amount - v).abs() < 1;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            setModalState(() {
                              amount = v;
                              textController.text = v.toInt().toString();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.25 : 0.15)
                                  : (isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? const Color(0xFF38BDF8) : Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${currencyFormat.currencySymbol}${v.toInt()}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                  color: isSel ? const Color(0xFF38BDF8) : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixText: '${currencyFormat.currencySymbol} ',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      if (parsed > 0) {
                        setModalState(() => amount = parsed);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.12 : 0.08),
                          AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FUTURE INTEREST KILLED',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF38BDF8),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '~${currencyFormat.format(impact.interestSaved.toInt())}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                            Container(width: 0.5, height: 32, color: Colors.white12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'FREEDOM ACCELERATION',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${impact.daysSaved} Days Earlier',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          impact.motivationalHook,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (amount > 0) {
                          HapticService.selection();
                          Navigator.pop(ctx);
                          final impact = await viewModel.applySnowflake(selectedDebt, amount);
                          _triggerSuccess();
                          ref.read(dailyRingsServiceProvider.notifier).recordSnowflake();

                          final isSavage = state.settings?.isSavageMode ?? false;
                          final persona = ref.read(personaVoiceServiceProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF0F111D),
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  persona.getSnowflakeWinQuote(isSavage, impact.interestSaved, impact.daysSaved),
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          }

                          if (!ref.read(homeViewModelProvider).settings!.isPremium) {
                            _interstitialAdManager.showAd();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'LAUNCH SNOWFLAKE STRIKE (${currencyFormat.format(amount)})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQuickIncomeSheet(BuildContext context, HomeViewModel viewModel, double currentIncome, NumberFormat format, bool isDark) {
    final controller = TextEditingController(text: currentIncome > 0 ? currentIncome.toInt().toString() : '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF10121B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Income Inflow',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Powers your debt-to-income ratio, stress index, and debt-free date calculation.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  prefixText: '${format.currencySymbol} ',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF161925) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final val = double.tryParse(controller.text);
                    if (val != null && val >= 0) {
                      HapticService.selection();
                      viewModel.updateSettings(UserSettingsCompanion(
                        id: const drift.Value(1),
                        monthlyIncome: drift.Value(val),
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'UPDATE INFLOW',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthScorePill(int score, bool isDark) {
    Color color = AppTheme.danger;
    String label = "DANGER";
    if (score >= 700) {
      color = AppTheme.success;
      label = "EXCELLENT";
    } else if (score >= 400) {
      color = AppTheme.warning;
      label = "FAIR";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$score $label',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(int streak, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MilestonesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.25), 
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppTheme.accent, size: 12),
            const SizedBox(width: 4),
            Text(
              '$streak MO STREAK',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaydayBlitzPill(HomeViewModel viewModel, HomeState state, bool isDark) {
    final isPayday = viewModel.isTodayPayday;
    final accentColor = isPayday ? const Color(0xFF10B981) : const Color(0xFF8B5CF6);

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        final currencyFormat = NumberFormat.simpleCurrency(name: state.settings?.currency ?? '₹', decimalDigits: 0);
        PaydayBlitzModal.show(
          context,
          plan: viewModel.paydayBlitzPlan,
          currencyFormat: currencyFormat,
          isDark: isDark,
          onInjectSnowflake: (amount) async {
            await ref.read(dailyRingsServiceProvider.notifier).recordSnowflake();
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: isPayday ? 0.45 : 0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPayday ? Icons.bolt_rounded : Icons.cyclone_rounded,
              color: accentColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              isPayday ? 'PAYDAY ACTIVE' : 'PAYDAY BLITZ',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueBadge(bool isDark) {
    final league = ref.watch(freedomLeagueProvider);
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FreedomLeagueScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD946EF).withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD946EF).withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(league.currentTier.trophyEmoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              'RANK #${league.userRank}',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD946EF),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakArmorPill(bool isDark) {
    final armor = ref.watch(streakArmorProvider);
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        RelapseRescueModal.show(context, isDark: isDark);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: armor.isArmorDeployed
              ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.1)
              : const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: armor.isArmorDeployed
                ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                : const Color(0xFF3B82F6).withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              armor.isArmorDeployed ? 'RESCUE QUEST' : '${armor.shieldsBanked} SHIELD',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: armor.isArmorDeployed ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisBanner(bool isDark) {
    final crisis = ref.watch(blackSwanCrisisProvider);
    if (!crisis.isCrisisActive) return const SizedBox();

    return GestureDetector(
      onTap: () => CrisisDefibrillatorModal.show(context, isDark: isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF3B0B10), const Color(0xFF220609)]
                : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Text('🚨', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CRISIS DEFIBRILLATOR DEPLOYED',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFEF4444),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${crisis.runwayDaysRemaining} Days of Survival Runway Protected. Snowflakes paused with zero streak penalty.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCenter(HomeViewModel viewModel) {
    final insights = viewModel.insights;
    if (insights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Action Center',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              final isCritical = insight.severity == InsightSeverity.critical;
              final isWarning = insight.severity == InsightSeverity.warning;

              final tint = isCritical ? AppTheme.danger : (isWarning ? Colors.orange : AppTheme.primary);
              final icon = isCritical ? Icons.warning_rounded : (isWarning ? Icons.error_outline_rounded : Icons.lightbulb_outline_rounded);
              
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration(context).copyWith(
                  border: Border.all(color: tint.withValues(alpha: 0.3)),
                  gradient: LinearGradient(
                    colors: [tint.withValues(alpha: 0.1), tint.withValues(alpha: 0.02)],
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
                        Expanded(
                          child: Text(
                            insight.title, 
                            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: tint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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

  List<Obligation> _getFilteredObligations(HomeViewModel viewModel) {
    final sorted = viewModel.sortedObligations;
    if (_selectedTab == 0) {
      return sorted.where((o) => o.type == ObligationType.oneTime).toList();
    } else {
      return sorted.where((o) => o.type != ObligationType.oneTime).toList();
    }
  }

  Widget _buildListHeader(HomeViewModel viewModel, bool isDark) {
    final oneTimeCount = viewModel.sortedObligations.where((o) => o.type == ObligationType.oneTime).length;
    final recurringCount = viewModel.sortedObligations.where((o) => o.type != ObligationType.oneTime).length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Obligations Ledger',
                      style: GoogleFonts.outfit(
                        fontSize: 19, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_selectedTab == 0 ? oneTimeCount : recurringCount}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161924) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 0.5,
                ),
              ),
              child: Text(
                'DRAG TO SORT',
                style: GoogleFonts.inter(
                  fontSize: 9, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Segmented pill bar
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12141D) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTabItem(0, 'DEBTS & GOALS ($oneTimeCount)', Icons.track_changes_rounded, isDark)),
              Expanded(child: _buildTabItem(1, 'MONTHLY PAYS ($recurringCount)', Icons.repeat_rounded, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() => _selectedTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF1E2230) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 13, 
              color: isSelected 
                  ? AppTheme.primary 
                  : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.3,
                  color: isSelected 
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObligationCard(
      BuildContext context, Obligation obligation, NumberFormat format, WidgetRef ref, int index, bool isDark) {
    final priorityColor = _getPriorityColor(obligation.priority);
    final catColor = _getCategoryColor(obligation.category);
    final catIcon = _getCategoryIcon(obligation.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            
            if (!ref.read(homeViewModelProvider).settings!.isPremium) {
              _interstitialAdManager.showAd();
            }
          },
          child: Container(
            decoration: AppTheme.glassDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: catColor.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            catIcon,
                            color: catColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              obligation.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                decoration: obligation.isActive ? null : TextDecoration.lineThrough,
                                color: obligation.isActive 
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    obligation.category.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDateWindow(obligation),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildAmountSection(obligation, format),
                    ],
                  ),
                  if (obligation.type == ObligationType.oneTime && obligation.isActive) ...[
                    const SizedBox(height: 14),
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

  Widget _buildEmptyState(bool isDark) {
    final isDebts = _selectedTab == 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebts ? Icons.track_changes_rounded : Icons.repeat_rounded,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isDebts ? 'No Active Goals or Debts' : 'No Monthly Essentials',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isDebts 
              ? 'Clear slate! Tap + below to log an obligation and begin tracking.' 
              : 'Add your recurring monthly commitments like Rent, SIP, or Subscriptions.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(Obligation obligation, NumberFormat format) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          format.format(obligation.amount),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: obligation.isActive 
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : Colors.grey.shade600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          obligation.isActive ? 'SWIPE TO PAY' : 'SETTLED',
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: obligation.isActive 
                ? (isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.3))
                : AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09C), Color(0xFF059669)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'MARK PAID & SETTLE',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProgress(double paid, double total, bool isDark) {
    if (paid <= 0) return const SizedBox();
    final progress = (paid / total).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161924) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAID: ₹${NumberFormat('#,##,###').format(paid.toInt())}',
                style: GoogleFonts.inter(
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: AppTheme.primary,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.outfit(
                  fontSize: 11, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: isDark ? const Color(0xFF222634) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                );
              },
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
      padding: const EdgeInsets.only(bottom: 80.0),
      child: _EliteInteraction(
        onTap: () {
          HapticService.selection();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddObligationScreen()));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'ADD NEW',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: Container(
          color: Colors.black.withValues(alpha: isDark ? 0.85 : 0.70),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 36),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12141D) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 36,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: AppTheme.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'OBLIGATION SETTLED',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment successfully recorded.\nYour freedom trajectory just accelerated!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bills': return Icons.receipt_long_rounded;
      case 'emi': return Icons.account_balance_rounded;
      case 'rent': return Icons.home_rounded;
      case 'investment': return Icons.trending_up_rounded;
      case 'entertainment': return Icons.movie_filter_rounded;
      case 'health': return Icons.health_and_safety_rounded;
      case 'subscription': return Icons.subscriptions_rounded;
      case 'grocery': return Icons.shopping_basket_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'travel': return Icons.flight_takeoff_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'bills': return const Color(0xFF06B6D4);
      case 'emi': return const Color(0xFF8B5CF6);
      case 'rent': return const Color(0xFF10B981);
      case 'investment': return const Color(0xFF00D09C);
      case 'entertainment': return const Color(0xFFD946EF);
      case 'health': return const Color(0xFFF43F5E);
      case 'subscription': return const Color(0xFF6366F1);
      case 'grocery': return const Color(0xFFF59E0B);
      case 'shopping': return const Color(0xFF0EA5E9);
      case 'travel': return const Color(0xFFF97316);
      default: return AppTheme.primary;
    }
  }

  Widget _buildSkeletonDashboard(bool isDark) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: _ShimmerContainer(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _skeletonBox(width: 130, height: 32, radius: 20, isDark: isDark),
                _skeletonBox(width: 38, height: 38, radius: 12, isDark: isDark),
              ],
            ),
            const SizedBox(height: 20),
            _skeletonBox(width: double.infinity, height: 160, radius: 26, isDark: isDark),
            const SizedBox(height: 20),
            _skeletonBox(width: double.infinity, height: 84, radius: 22, isDark: isDark),
            const SizedBox(height: 20),
            _skeletonBox(width: double.infinity, height: 180, radius: 22, isDark: isDark),
            const SizedBox(height: 20),
            _skeletonBox(width: double.infinity, height: 44, radius: 14, isDark: isDark),
            const SizedBox(height: 16),
            _skeletonBox(width: double.infinity, height: 80, radius: 20, isDark: isDark),
            const SizedBox(height: 12),
            _skeletonBox(width: double.infinity, height: 80, radius: 20, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox({required double width, required double height, required double radius, required bool isDark}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141722) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _FreedomCountdownRing extends StatelessWidget {
  final FreedomData data;

  const _FreedomCountdownRing({required this.data});

  @override
  Widget build(BuildContext context) {
    const maxDays = 1000.0;
    final progress = (data.daysLeft / maxDays).clamp(0.0, 1.0);
    final color = Color.lerp(AppTheme.success, AppTheme.primary, progress) ?? AppTheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1.0 - progress),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutQuart,
                builder: (context, value, _) => CustomPaint(
                  size: const Size(88, 88),
                  painter: _GaugePainter(percentage: 1.0 - value, color: color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.daysLeft > 0 ? '${data.daysLeft}' : 'FREE',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    data.daysLeft > 0 ? 'DAYS' : 'DEBT-FREE',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: color.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'TO FREEDOM',
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: color.withValues(alpha: 0.8),
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
    const strokeWidth = 7.0;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
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
      6.28318 * (1 - percentage), // 360 degrees * remaining
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
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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

class _StaggeredEntry extends StatelessWidget {
  final Widget child;
  final int delay;

  const _StaggeredEntry({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AnimatedRollNumber extends StatelessWidget {
  final double value;
  final NumberFormat format;
  final TextStyle style;

  const _AnimatedRollNumber({
    required this.value,
    required this.format,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('roll_$value'),
      tween: Tween<double>(begin: value * 0.85, end: value),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          format.format(animatedValue),
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class _ShimmerContainer extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _ShimmerContainer({required this.child, required this.isDark});

  @override
  State<_ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<_ShimmerContainer> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}
