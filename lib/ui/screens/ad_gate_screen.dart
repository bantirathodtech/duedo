import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdGateScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPremiumPurchased;

  const AdGateScreen({
    super.key,
    required this.onComplete,
    required this.onPremiumPurchased,
  });

  @override
  State<AdGateScreen> createState() => _AdGateScreenState();
}

class _AdGateScreenState extends State<AdGateScreen> {
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Frosted Glass Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Premium Icon / Animation
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 60, color: AppTheme.primary),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Supporting Duedo',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Your financial bodyguard is warming up.\nWatch this short message to support our development.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Countdown Logic
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _secondsLeft / 30,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                        Text(
                          '$_secondsLeft',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Action Buttons
                    AnimatedOpacity(
                      opacity: _secondsLeft == 0 ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 500),
                      child: ElevatedButton(
                        onPressed: _secondsLeft == 0 ? widget.onComplete : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _secondsLeft == 0 ? 'Continue to Dashboard' : 'Wait... $_secondsLeft s',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR GO PRO', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                      ],
                    ),
  
                    const SizedBox(height: 24),
  
                    _buildSubscriptionOption(
                      context,
                      title: 'Monthly Pro',
                      price: '₹50',
                      onTap: () => _handleSubscription(context),
                    ),
                    const SizedBox(height: 12),
                    _buildSubscriptionOption(
                      context,
                      title: 'Annual Pro',
                      price: '₹500',
                      isBestValue: true,
                      onTap: () => _handleSubscription(context),
                    ),
                    const SizedBox(height: 12),
                    _buildSubscriptionOption(
                      context,
                      title: 'Lifetime Pro',
                      price: '₹5000',
                      onTap: () => _handleSubscription(context),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(BuildContext context, {required String title, required String price, bool isBestValue = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBestValue ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isBestValue ? AppTheme.primary : Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.stars_rounded, color: isBestValue ? Colors.amber : Colors.white70, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                if (isBestValue)
                   Text('Best Value Savings', style: GoogleFonts.inter(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Text(price, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context) {
    // In a real app, this triggers IAP. For now, we simulate success.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Go Pro?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('This would trigger real App Store / Play Store purchase flow.', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPremiumPurchased();
              widget.onComplete(); 
            }, 
            child: const Text('Simulate Buy'),
          ),
        ],
      ),
    );
  }
}
