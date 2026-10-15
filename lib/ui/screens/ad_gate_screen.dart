import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ads/ad_service.dart';
import '../../services/haptic_service.dart';
import '../../services/logger_service.dart';
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
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _adCompleted = false;
  bool _isCheckingFirstRun = true;
  bool _adLoadFailed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // IRONMAN: Defer all heavy work to after the first frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRun();
    });
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasOpenedBefore = prefs.getBool('has_opened_before') ?? false;

    if (!hasOpenedBefore) {
      await prefs.setBool('has_opened_before', true);
      // It's the first run, skip the ad gate entirely
      if (mounted) widget.onComplete();
    } else {
      if (mounted) {
        setState(() => _isCheckingFirstRun = false);
      }
      // Start ad loading AFTER first-run check completes
      _waitForSdkAndLoadAd();
    }
  }

  /// Waits for the AdMob SDK to be ready, THEN loads the rewarded ad.
  /// Applies a 15-second safety timeout so the user never gets stuck.
  Future<void> _waitForSdkAndLoadAd() async {
    // Safety timeout — if SDK still isn't ready in 15s, let user bypass.
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_isAdLoaded && !_adCompleted) {
        setState(() => _adLoadFailed = true);
      }
    });

    // Wait for the deferred AdMobService.initialize() to complete
    await AdMobService.ensureInitialized();
    if (!mounted) return;

    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (!AdMobService.isHealthy) {
      LoggerService.log(
        '[DUEDO_AUDIT:ADS] Skipping rewarded ad load — WebView engine unavailable.',
        category: LogCategory.warning,
      );
      if (mounted) setState(() => _adLoadFailed = true);
      return;
    }

    RewardedAd.load(
      adUnitId: AdMobService.rewardedAdUnitId!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _timeoutTimer?.cancel();
          if (mounted) {
            setState(() {
              _rewardedAd = ad;
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          LoggerService.log(
            'RewardedAd failed to load: $error',
            category: LogCategory.warning,
            error: error,
          );
          _timeoutTimer?.cancel();
          if (mounted) {
            setState(() => _adLoadFailed = true);
          }
        },
      ),
    );
  }


  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          Future.microtask(() => ad.dispose());
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          Future.microtask(() => ad.dispose());
          _loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          HapticService.success();
          if (mounted) {
            setState(() => _adCompleted = true);
          }
        },
      );
      _rewardedAd = null;
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    Future.microtask(() => _rewardedAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstRun) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  AppTheme.primary.withValues(alpha: 0.1),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo - Enforced Circular Cover
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/app_logo.png',
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.shield_moon_rounded, color: AppTheme.primary, size: 80),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'PREMIUM ACCESS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppTheme.primary,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'DUEDO',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Watch a quick ad to support free access,\nor upgrade to Pro for an ad-free experience.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Mandatory Ad Section
                        if (!_adCompleted) 
                          _isAdLoaded 
                            ? _buildMandatoryAdUI()
                            : _buildLoadingState()
                        else
                          _buildSuccessState(),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Subscription section - 3 Plans in a row (No SingleChildScrollView)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'UNBLOCK ALL PRO FEATURES',
                        style: GoogleFonts.inter(
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          color: AppTheme.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactProOption(
                              'Monthly', 
                              '₹50', 
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactProOption(
                              'Annual', 
                              '₹500', 
                              isAccent: true,
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactProOption(
                              'Lifetime', 
                              '₹5000',
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryAdUI() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            HapticService.heavy();
            _showRewardedAd();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 10,
            shadowColor: AppTheme.primary.withValues(alpha: 0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill_rounded, size: 28),
              const SizedBox(width: 12),
              Text(
                'LOAD PREMIUM AD (30S)',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'CONTINUE TO APP BLOCKED UNTIL AD ENDS',
          style: GoogleFonts.inter(
            fontSize: 9, 
            fontWeight: FontWeight.bold, 
            color: Colors.white24,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
              const SizedBox(width: 10),
              Text(
                'AD COMPLETED SUCCESSFULLY',
                style: GoogleFonts.inter(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONTINUE TO APP',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 1),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        if (!_adLoadFailed) ...[
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PREPARING AD EXPERIENCE...',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 2),
          ),
        ],
        if (_adLoadFailed) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'AD UNAVAILABLE ON THIS DEVICE',
                    style: GoogleFonts.inter(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE TO APP',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactProOption(String title, String price, {bool isAccent = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isAccent ? AppTheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAccent ? AppTheme.primary : Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              title, 
              style: GoogleFonts.inter(color: isAccent ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              price, 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
        title: Text('Duedo Pro', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Upgrade to remove all ads and unlock premium financial projection tools.', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPremiumPurchased();
              widget.onComplete(); 
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Simulate Buy'),
          ),
        ],
      ),
    );
  }
}
