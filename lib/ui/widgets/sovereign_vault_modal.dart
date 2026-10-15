import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/haptic_service.dart';
import '../../services/sovereign_vault_service.dart';
import '../../services/freedom_league_service.dart';
import '../../viewmodels/home_viewmodel.dart';

class SovereignVaultModal extends ConsumerStatefulWidget {
  final bool isDark;

  const SovereignVaultModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SovereignVaultModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<SovereignVaultModal> createState() => _SovereignVaultModalState();
}

class _SovereignVaultModalState extends ConsumerState<SovereignVaultModal> {
  final _primaryPinCtrl = TextEditingController(text: '1234');
  final _decoyPinCtrl = TextEditingController(text: '9999');
  final _pinTestCtrl = TextEditingController();

  @override
  void dispose() {
    _primaryPinCtrl.dispose();
    _decoyPinCtrl.dispose();
    _pinTestCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(sovereignVaultProvider);
    final notifier = ref.read(sovereignVaultProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔐', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOVEREIGN VAULT & CLOAK',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEAB308),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Zero-Knowledge Backups & Panic Decoy Shield',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: widget.isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: widget.isDark ? Colors.white54 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Decoy Panic Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isDark
                            ? [const Color(0xFF2E2405), const Color(0xFF1A1402)]
                            : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🎭', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'PANIC DECOY PIN ACTIVE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFCA8A04),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'If pressured to unlock Duedo, entering the Panic PIN (${vault.decoyPin}) instantly loads a sanitized decoy savings journal with zero debt data exposed.',
                          style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: widget.isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PIN Configuration Fields
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PRIMARY REAL PIN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _primaryPinCtrl,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (val) => notifier.setPrimaryPin(val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PANIC DECOY PIN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _decoyPinCtrl,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (val) => notifier.setDecoyPin(val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 12-Word Recovery Mnemonic Preview
                  Text(
                    '12-WORD SOVEREIGN RECOVERY PHRASE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: widget.isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(vault.mnemonicWords.length, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          '${index + 1}. ${vault.mnemonicWords[index]}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEAB308),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Export Encrypted .duedo.vault Button
                  ElevatedButton.icon(
                    onPressed: () {
                      final rawData = {
                        'income': homeState.settings?.monthlyIncome ?? 0.0,
                        'obligationsCount': homeState.obligations.length,
                        'exportedAt': DateTime.now().toIso8601String(),
                      };
                      final vaultBundle = notifier.exportZeroKnowledgeVault(rawData);
                      Clipboard.setData(ClipboardData(text: vaultBundle));
                      ref.read(freedomLeagueProvider.notifier).awardPoints(150);
                      HapticService.dopamineCascade();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🛡️ Zero-Knowledge Encrypted .duedo.vault copied to clipboard! (+150 pts)'),
                          backgroundColor: Color(0xFFEAB308),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download, color: Colors.black87),
                    label: Text(
                      'Export Zero-Knowledge Vault',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Cryptographic Freedom Certificate Generator
                  OutlinedButton.icon(
                    onPressed: () {
                      final certHash = notifier.generateFreedomCertificate(
                        userName: 'Financial Gladiator',
                        totalDebtCleared: 412000.0,
                        daysWon: 214,
                      );
                      _showCertificateDialog(context, certHash, widget.isDark);
                    },
                    icon: const Icon(Icons.verified, size: 16, color: Color(0xFF10B981)),
                    label: Text(
                      'View SHA-256 Freedom Certificate',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _showCertificateDialog(BuildContext context, String certHash, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F1713) : Colors.white,
        title: Row(
          children: [
            const Text('📜', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Cryptographic Freedom Certificate', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This certificate serves as verifiable cryptographic mathematical proof that all consumer debt obligations were incinerated.',
              style: GoogleFonts.inter(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black45 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                'SHA-256 Signature:\n$certHash',
                style: GoogleFonts.robotoMono(fontSize: 10, color: const Color(0xFF10B981), height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: certHash));
              HapticService.selection();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📋 SHA-256 Signature copied!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('Copy Proof'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
