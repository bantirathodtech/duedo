import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'ad_gate_screen.dart';
import '../../services/haptic_service.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool _hasWatchedAd = false;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const InsightsScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    HapticService.selection();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final isPremium = homeState.settings?.isPremium ?? false;

    // Loading Guard: Wait for settings to load before deciding to show Ad Gate
    if (homeState.isLoading || homeState.settings == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    // Show Ad Gate if not premium and hasn't watched yet this session
    if (!isPremium && !_hasWatchedAd) {
      return AdGateScreen(
        onComplete: () {
          setState(() => _hasWatchedAd = true);
        },
        onPremiumPurchased: () {
          ref.read(homeViewModelProvider.notifier).togglePremium(true);
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _buildSideNav(context),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true, // Crucial for floating nav
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(), // Handle navigation via dock
            children: _screens,
          ),
          bottomNavigationBar: _buildFloatingDock(context),
        );
      },
    );
  }

  Widget _buildSideNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 100,
      margin: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      decoration: AppTheme.glassDecoration(context, blur: 20, opacity: 0.15).copyWith(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DockItem(icon: Icons.dashboard_rounded, label: 'Home', isSelected: _currentIndex == 0, onTap: () => _onItemTapped(0), isDark: isDark),
          const SizedBox(height: 32),
          _DockItem(icon: Icons.insights_rounded, label: 'Analysis', isSelected: _currentIndex == 1, onTap: () => _onItemTapped(1), isDark: isDark),
          const SizedBox(height: 32),
          _DockItem(icon: Icons.calendar_month_rounded, label: 'Schedule', isSelected: _currentIndex == 2, onTap: () => _onItemTapped(2), isDark: isDark),
          const SizedBox(height: 32),
          _DockItem(icon: Icons.person_rounded, label: 'Profile', isSelected: _currentIndex == 3, onTap: () => _onItemTapped(3), isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildFloatingDock(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding > 0 ? bottomPadding : 20),
      height: 70,
      decoration: AppTheme.glassDecoration(context, blur: 20, opacity: 0.15).copyWith(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DockItem(
              icon: Icons.dashboard_rounded,
              label: 'Overview',
              isSelected: _currentIndex == 0,
              onTap: () => _onItemTapped(0),
              isDark: isDark,
            ),
            _DockItem(
              icon: Icons.insights_rounded,
              label: 'Intelligence',
              isSelected: _currentIndex == 1,
              onTap: () => _onItemTapped(1),
              isDark: isDark,
            ),
            _DockItem(
              icon: Icons.calendar_month_rounded,
              label: 'Schedule',
              isSelected: _currentIndex == 2,
              onTap: () => _onItemTapped(2),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.primary;
    final inactiveColor = isDark ? Colors.white.withOpacity(0.4) : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
