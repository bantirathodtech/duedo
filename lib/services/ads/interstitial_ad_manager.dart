import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';
import '../logger_service.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  void loadAd() {
    if (!AdMobService.isHealthy) return;

    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.log(
            'InterstitialAd failed to load: $error',
            category: LogCategory.warning,
            error: error,
          );
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd() {
    if (_isLoaded && _interstitialAd != null) {
      try {
        _interstitialAd!.show();
      } catch (e) {
        LoggerService.log(
          'Error showing InterstitialAd: $e',
          category: LogCategory.error,
          error: e,
        );
      } finally {
        _interstitialAd = null;
        _isLoaded = false;
      }
    } else {
      LoggerService.log('InterstitialAd not ready yet.', category: LogCategory.info);
      loadAd(); // Try loading again for next time
    }
  }

  void dispose() {
    final ad = _interstitialAd;
    _interstitialAd = null;
    Future.microtask(() => ad?.dispose());
  }
}
