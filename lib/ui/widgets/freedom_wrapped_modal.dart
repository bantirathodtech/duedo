import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/haptic_service.dart';
import '../../services/freedom_wrapped_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class FreedomWrappedModal extends ConsumerStatefulWidget {
  final bool isDark;

  const FreedomWrappedModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FreedomWrappedModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<FreedomWrappedModal> createState() => _FreedomWrappedModalState();
}

class _FreedomWrappedModalState extends ConsumerState<FreedomWrappedModal> {
  int _currentSlide = 0;
  static const int _totalSlides = 4;

  void _nextSlide() {
    HapticService.selection();
    if (_currentSlide < _totalSlides - 1) {
      setState(() => _currentSlide++);
    } else {
      Navigator.pop(context);
    }
  }

  void _prevSlide() {
    HapticService.selection();
    if (_currentSlide > 0) {
      setState(() => _currentSlide--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(freedomWrappedProvider);
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF090710),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEC4899).withValues(alpha: 0.2),
              ),
            ),
          ),

          // Main Interactive Body
          GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.localPosition.dx < width * 0.3) {
                _prevSlide();
              } else {
                _nextSlide();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Segmented Story Progress Bar
                  Row(
                    children: List.generate(_totalSlides, (index) {
                      final isPassed = index <= _currentSlide;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 4,
                          decoration: BoxDecoration(
                            color: isPassed ? const Color(0xFFEC4899) : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🎬', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'DUEDO WRAPPED ${report.year}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Dynamic Slide Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSlideContent(_currentSlide, report, currency),
                  ),

                  const Spacer(),

                  // Bottom Action: Share to WhatsApp/Instagram
                  ElevatedButton.icon(
                    onPressed: () {
                      final caption = report.getViralShareCaption(currency);
                      Clipboard.setData(ClipboardData(text: caption));
                      HapticService.dopamineCascade();
                      ref.read(freedomLeagueProvider.notifier).awardPoints(100);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔥 Viral Story Caption Copied! Share to WhatsApp/Instagram Status (+100 pts)'),
                          backgroundColor: Color(0xFFEC4899),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'Share to WhatsApp / Instagram',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap left to go back • Tap right to advance',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent(int slideIndex, FreedomWrappedReport report, String currency) {
    switch (slideIndex) {
      case 0:
        return Column(
          key: const ValueKey('slide_0'),
          children: [
            const Text('🏆', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            Text(
              'THE BODY COUNT',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEC4899),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currency${NumberFormat('#,##,###').format(report.totalDebtSlain.round())}',
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'In ${report.year}, you pulverized predatory balances that keep ordinary consumers trapped for decades.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.4),
            ),
          ],
        );

      case 1:
        return Column(
          key: const ValueKey('slide_1'),
          children: [
            const Text('🩸', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            Text(
              'INTEREST DENIED TO BANKERS',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currency${NumberFormat('#,##,###').format(report.interestDestroyed.round())}',
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'That is cold hard money bankers calculated into their revenue models. You kept it in your family fortress instead.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.4),
            ),
          ],
        );

      case 2:
        return Column(
          key: const ValueKey('slide_2'),
          children: [
            const Text('🧊', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            Text(
              'COOLING VAULT MASTERY',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF38BDF8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${report.impulseCravingsResistedCount} Impulses',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Saved $currency${NumberFormat('#,##,###').format(report.impulseMoneyShielded.round())}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Dopamine was mastered. You waited 24 hours and chose sovereignty over fleeting micro-leaks.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.4),
            ),
          ],
        );

      case 3:
      default:
        return Container(
          key: const ValueKey('slide_3'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1136), Color(0xFF120722)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(report.warriorBadge, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'YOUR WARRIOR ARCHETYPE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFEC4899),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.warriorArchetype,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              _buildMetricRow('Life Freedom Bought Back', '${report.freedomDaysRestored} Days'),
              const SizedBox(height: 6),
              _buildMetricRow('Clean Spending Days', '${report.cleanDaysCompleted} Days'),
              const SizedBox(height: 6),
              _buildMetricRow('League Standing', report.leagueRankTier),
            ],
          ),
        );
    }
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        Text(value, style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
