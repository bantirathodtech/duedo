import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/milestone_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../widgets/milestone_share_modal.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalRemaining = viewModel.freedomData.totalRemainingBalance;
    final totalPaid = state.payments.fold(0.0, (sum, p) => sum + p.amountPaid);
    final totalLoad = totalRemaining + totalPaid;
    final freedomPct = totalLoad > 0 ? (totalPaid / totalLoad).clamp(0.0, 1.0) : 0.0;
    final streak = state.settings?.paymentStreak ?? 3;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'YOUR ACHIEVEMENTS',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 40)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial Rank',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getRankTitle(state.milestones.where((m) => m.unlockedAt != null).length),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'MILESTONE BADGES',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final milestone = state.milestones[index];
                  final isUnlocked = milestone.unlockedAt != null;
                  
                  return _BadgeCard(
                    milestone: milestone,
                    isUnlocked: isUnlocked,
                    isDark: isDark,
                    streakDays: streak,
                    freedomPercentage: freedomPct,
                  );
                },
                childCount: state.milestones.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _getRankTitle(int count) {
    if (count == 0) return 'Recruit';
    if (count == 1) return 'Strategist';
    if (count == 2) return 'Warrior';
    if (count == 3) return 'Master';
    return 'Financial Legend';
  }
}

class _BadgeCard extends StatelessWidget {
  final Milestone milestone;
  final bool isUnlocked;
  final bool isDark;
  final int streakDays;
  final double freedomPercentage;

  const _BadgeCard({
    required this.milestone,
    required this.isUnlocked,
    required this.isDark,
    required this.streakDays,
    required this.freedomPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          MilestoneShareModal.show(
            context,
            milestone: milestone,
            streakDays: streakDays,
            freedomPercentage: freedomPercentage,
            isDark: isDark,
          );
        } else {
          HapticService.selection();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🔒 Keep going to unlock "${milestone.title}"!'),
              backgroundColor: isDark ? const Color(0xFF141724) : Colors.black87,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: isUnlocked 
          ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white)
          : (isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked 
            ? AppTheme.primary.withValues(alpha: 0.3) 
            : Colors.transparent,
          width: 2,
        ),
        boxShadow: isUnlocked && !isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: isUnlocked 
              ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
              : const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
            child: Text(
              milestone.icon,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            milestone.title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked 
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, y').format(milestone.unlockedAt!),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey),
          ],
        ],
      ),
    ),
    );
  }
}
