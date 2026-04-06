import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/vault_service.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';

final vaultAuthenticatedProvider = StateProvider<bool>((ref) => false);

class VaultGate extends ConsumerStatefulWidget {
  final Widget child;
  const VaultGate({super.key, required this.child});

  @override
  ConsumerState<VaultGate> createState() => _VaultGateState();
}

class _VaultGateState extends ConsumerState<VaultGate> {
  bool _vaultEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVaultStatus();
  }

  Future<void> _checkVaultStatus() async {
    final vaultService = ref.read(vaultServiceProvider);
    final enabled = await vaultService.isVaultEnabled();
    if (mounted) {
      setState(() {
        _vaultEnabled = enabled;
        _isLoading = false;
      });
      if (enabled) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    final vaultService = ref.read(vaultServiceProvider);
    final success = await vaultService.authenticate();
    if (success) {
      ref.read(vaultAuthenticatedProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(vaultAuthenticatedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_vaultEnabled || isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      body: Stack(
        children: [
          widget.child, // The background is the app itself
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_person_rounded, size: 64, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'DUEDO VAULT',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your financial data is secured',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          HapticService.heavy();
                          _authenticate();
                        },
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text('AUTHENTICATE'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
