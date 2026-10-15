import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/freedom_league_service.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';

class FreedomLeagueScreen extends ConsumerWidget {
  const FreedomLeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final league = ref.watch(freedomLeagueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E17) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Freedom Arena',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Tier Hero Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF311042), Color(0xFF1E112A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD946EF).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD946EF).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD946EF), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      league.currentTier.trophyEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            league.currentTier.displayName.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF472B6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${league.daysRemainingInSeason}d left',
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rank #${league.userRank} • ${league.userPoints} pts',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        league.userRank <= 3
                            ? '🔥 In Promotion Zone! Advance next Sunday.'
                            : '⚡ Need ${(league.cohort.first.points - league.userPoints).clamp(0, 9999)} pts to reach #1.',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Promotion Zone Marker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.arrow_upward_rounded, color: Color(0xFF10B981), size: 14),
                const SizedBox(width: 6),
                Text(
                  'PROMOTION ZONE (TOP 3 ADVANCE)',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Cohort Leaderboard List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: league.cohort.length,
              itemBuilder: (context, index) {
                final member = league.cohort[index];
                final rank = index + 1;
                final isUser = member.isUser;
                final isPromoted = rank <= 3;
                final isDemoted = rank >= (league.cohort.length - 2);

                Color rankColor = isDark ? Colors.white70 : Colors.black87;
                if (rank == 1) rankColor = const Color(0xFFFFD700);
                if (rank == 2) rankColor = const Color(0xFFE2E8F0);
                if (rank == 3) rankColor = const Color(0xFFCD7F32);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF))
                        : (isDark ? const Color(0xFF141724) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUser
                          ? AppTheme.primary
                          : (isPromoted
                              ? const Color(0xFF10B981).withValues(alpha: 0.25)
                              : (isDemoted
                                  ? AppTheme.danger.withValues(alpha: 0.2)
                                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight))),
                      width: isUser ? 1.5 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank Number
                      SizedBox(
                        width: 26,
                        child: Text(
                          '$rank',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: rankColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(member.avatarEmoji, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & Streak
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
                                color: isUser
                                    ? AppTheme.primary
                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${member.streakDays}d streak',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Points
                      Text(
                        '${member.points} pts',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isUser ? AppTheme.primary : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10121E) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Earn Points: Close Rings (+50 pts)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  HapticService.selection();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
