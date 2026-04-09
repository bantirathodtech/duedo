import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adServiceProvider = Provider((ref) => AdMobService());

class AdMobService {
  static String? get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292~9520288098'; // Production ID
    }
    return null;
  }

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/7479256140'; // Production ID
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // Android Test ID
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/7096112767'; // Production ID
    }
    return 'ca-app-pub-3940256099942544/5224354917'; // Android Test ID
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/1628794557'; // Production ID
    }
    return 'ca-app-pub-3940256099942544/1033173712'; // Android Test ID
  }

  static String? get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/3302735235'; // Production ID
    }
    return 'ca-app-pub-3940256099942544/3419835294'; // Android Test ID
  }

  static String? get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/5378234236'; // Production ID
    }
    return 'ca-app-pub-3940256099942544/2247696110'; // Android Test ID
  }

  static bool isHealthy = true;

  // Readiness gate — screens await this before loading any ad.
  static final Completer<void> _initCompleter = Completer<void>();
  static bool _isInitialized = false;

  /// Returns a Future that completes once MobileAds SDK is initialized.
  /// Safe to call multiple times; returns immediately if already done.
  static Future<void> ensureInitialized() {
    if (_isInitialized) return Future.value();
    return _initCompleter.future;
  }

  static Future<AdSize> getAdaptiveAdSize(BuildContext context) async {
    final AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );
    return size ?? AdSize.banner;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) => print('Ad loaded: ${ad.adUnitId}'),
    onAdFailedToLoad: (ad, error) {
      // Use microtask to ensure we don't dispose while the native side is still processing
      Future.microtask(() => ad.dispose());
      print('Ad Load Failure (${ad.adUnitId}): $error');
      if (error.message.contains('JavascriptEngine')) {
        isHealthy = false;
        print('[DUEDO_AUDIT:ADS] CRITICAL: WebView JavascriptEngine unavailable on this device. '
            'All ad operations suspended. Recommend user updates Android System WebView.');
      }
    },
    onAdOpened: (ad) => print('Ad opened: ${ad.adUnitId}'),
    onAdClosed: (ad) => print('Ad closed: ${ad.adUnitId}'),
  );

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      
      // Add the specific test device ID found in the logs to ensure test ads load correctly
      final RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: ['48B6B1CDD6B77643C4E9A3FCF6A34A2D'],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);
      _isInitialized = true;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    } catch (e) {
      isHealthy = false;
      _isInitialized = true; // Mark done even on failure so callers don't hang.
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      print('[DUEDO_AUDIT:ADS] MobileAds.initialize() failed: $e');
    }
  }
}
