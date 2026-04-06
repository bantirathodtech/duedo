import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import 'package:drift/drift.dart' as drift;
import '../../services/database.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Text(
                    'Duedo+',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'ULTIMATE FINANCIAL PROTECTION',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Benefit Cards
                  _buildBenefitRow(Icons.block_rounded, 'No More Ads', 'Focus on your money without 30s delays'),
                  _buildBenefitRow(Icons.bolt_rounded, 'Flash Intelligence', 'Real-time proactive liability detection'),
                  _buildBenefitRow(Icons.cloud_sync_rounded, 'Global Cloud Sync', 'Instant access on all your devices'),
                  
                  const SizedBox(height: 48),
                  
                  Text(
                    'Choose Your Shield',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pricing Tiers
                  _buildPricingCard(
                    context, 
                    ref,
                    title: 'Monthly', 
                    price: '50₹', 
                    subtitle: 'Billed monthly. Cancel anytime.',
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    context, 
                    ref,
                    title: 'Annually', 
                    price: '500₹', 
                    subtitle: 'Save 100₹ per year. Best for planners.',
                    isPopular: true,
                    color: AppTheme.primary.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    context, 
                    ref,
                    title: 'Lifetime', 
                    price: '5000₹', 
                    subtitle: 'All future features. One payment.',
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'Secured by Duedo encryption',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, 
    WidgetRef ref,
    {
    required String title,
    required String price,
    required String subtitle,
    required Color color,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.success();
        _handlePurchase(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPopular ? AppTheme.primary : Colors.white.withValues(alpha: 0.1),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MOST POPULAR',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isPopular ? AppTheme.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    // Update DB
    const companion = UserSettingsCompanion(
      id: drift.Value(1),
      isPremium: drift.Value(true),
    );
    await ref.read(homeViewModelProvider.notifier).updateSettings(companion);

    // Pop loading and screen
    if (context.mounted) {
      Navigator.pop(context); // Pop loading
      Navigator.pop(context); // Pop subscription screen
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to Duedo+! ads are now gone forever.', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        )
      );
    }
  }
}
