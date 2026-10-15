import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import '../screens/add_obligation_screen.dart';
import 'document_scanner_modal.dart';
import 'voice_slay_modal.dart';
import 'vampire_slasher_modal.dart';
import 'sovereign_command_deck.dart';

/// Interactive Fast-Action Center Sheet triggered by the bottom dock's center Hero button.
class QuickStrikeModal extends StatelessWidget {
  final bool isDark;

  const QuickStrikeModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickStrikeModal(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFF00D09C).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09C).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D09C).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/brand/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Strike Center',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Instant actions to slay debts and stop leaks',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF00D09C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white60 : Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action 1: Add New Debt or EMI
          _buildActionTile(
            context,
            icon: '➕',
            title: 'Add New Debt or EMI',
            subtitle: 'Log a credit card, personal loan, or vehicle EMI',
            accentColor: const Color(0xFF00D09C),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddObligationScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          // Action 2: 1-Snap Document Scanner
          _buildActionTile(
            context,
            icon: '📸',
            title: '1-Snap Sanction Scanner',
            subtitle: 'Extract loan balance, EMI & APR directly from camera photo',
            accentColor: const Color(0xFF38BDF8),
            onTap: () {
              Navigator.pop(context);
              DocumentScannerModal.show(context, isDark: isDark);
            },
          ),
          const SizedBox(height: 10),

          // Action 3: Voice Slay Command
          _buildActionTile(
            context,
            icon: '🎙️',
            title: 'Voice Slay Command',
            subtitle: 'Say "Slay ₹2,000 on HDFC" or "Logged coffee ₹150"',
            accentColor: const Color(0xFF818CF8),
            onTap: () {
              Navigator.pop(context);
              VoiceSlayModal.show(context, isDark: isDark);
            },
          ),
          const SizedBox(height: 10),

          // Action 4: Vampire Slasher
          _buildActionTile(
            context,
            icon: '🧛',
            title: 'Vampire Subscription Slasher',
            subtitle: 'Slash forgotten streaming apps & generate 1-tap cancel emails',
            accentColor: const Color(0xFFEF4444),
            onTap: () {
              Navigator.pop(context);
              VampireSlasherModal.show(context, isDark: isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111728) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 14),
          ],
        ),
      ),
    );
  }
}
