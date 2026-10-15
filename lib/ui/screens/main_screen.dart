import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'playbook_screen.dart';
import '../../services/haptic_service.dart';
import '../widgets/sovereign_command_deck.dart';
import '../widgets/quick_strike_modal.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const PlaybookScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    HapticService.selection();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    // Loading Guard: Wait for settings to load
    if (homeState.isLoading || homeState.settings == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
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
          extendBody: false, // Anchored to bottom, no content overlap
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
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
          _DockItem(icon: Icons.grid_view_rounded, label: 'Overview', isSelected: _currentIndex == 0, onTap: () => _onItemTapped(0), isDark: isDark),
          const SizedBox(height: 28),
          _DockItem(icon: Icons.calendar_month_rounded, label: 'Schedule', isSelected: _currentIndex == 1, onTap: () => _onItemTapped(1), isDark: isDark),
          const SizedBox(height: 28),
          _CenterStrikeDockItem(onTap: () => QuickStrikeModal.show(context, isDark: isDark), isDark: isDark),
          const SizedBox(height: 28),
          _DockItem(icon: Icons.auto_graph_rounded, label: 'Intelligence', isSelected: _currentIndex == 2, onTap: () => _onItemTapped(2), isDark: isDark),
          const SizedBox(height: 28),
          _DockItem(icon: Icons.menu_book_rounded, label: 'Playbook', isSelected: _currentIndex == 3, onTap: () => _onItemTapped(3), isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildFloatingDock(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 68 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding, top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E15) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Slot 0: Overview
          Expanded(
            child: _DockItem(
              icon: Icons.grid_view_rounded,
              label: 'Overview',
              isSelected: _currentIndex == 0,
              onTap: () => _onItemTapped(0),
              isDark: isDark,
            ),
          ),

          // Slot 1: Schedule
          Expanded(
            child: _DockItem(
              icon: Icons.calendar_month_rounded,
              label: 'Schedule',
              isSelected: _currentIndex == 1,
              onTap: () => _onItemTapped(1),
              isDark: isDark,
            ),
          ),

          // Center Slot (Hero): Fast Action Center
          Expanded(
            child: _CenterStrikeDockItem(
              onTap: () => QuickStrikeModal.show(context, isDark: isDark),
              isDark: isDark,
            ),
          ),

          // Slot 2: Intelligence
          Expanded(
            child: _DockItem(
              icon: Icons.auto_graph_rounded,
              label: 'Intelligence',
              isSelected: _currentIndex == 2,
              onTap: () => _onItemTapped(2),
              isDark: isDark,
            ),
          ),

          // Slot 3: Playbook
          Expanded(
            child: _DockItem(
              icon: Icons.menu_book_rounded,
              label: 'Playbook',
              isSelected: _currentIndex == 3,
              onTap: () => _onItemTapped(3),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterStrikeDockItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CenterStrikeDockItem({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      scaleFactor: 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D09C), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D09C).withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Strike',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00D09C),
              letterSpacing: 0.2,
            ),
          ),
        ],
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
    const activeColor = AppTheme.primary;
    final inactiveColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);

    return BouncingWidget(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected 
                  ? activeColor.withValues(alpha: isDark ? 0.15 : 0.10) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
