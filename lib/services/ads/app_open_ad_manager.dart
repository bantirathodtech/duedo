import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';
import '../logger_service.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;
  bool _isWebViewBroken = false;

  /// Load an [AppOpenAd].
  void loadAd() {
    // Don't retry if WebView engine is known to be broken on this device
    if (_isWebViewBroken) return;

    AppOpenAd.load(
      adUnitId: AdMobService.appOpenAdUnitId ?? '',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          LoggerService.log(
            'AppOpenAd failed to load: $error',
            category: LogCategory.warning,
            error: error,
          );
          if (error.message.contains('JavascriptEngine')) {
            _isWebViewBroken = true;
            LoggerService.log(
              '[DUEDO_AUDIT:ADS] WebView JavascriptEngine unavailable. '
              'Ads disabled for this session. User should update Android System WebView.',
              category: LogCategory.error,
            );
          }
        },
      ),
    );
  }


  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null && _appOpenLoadTime != null && 
           DateTime.now().difference(_appOpenLoadTime!).inHours < 4;
  }

  /// Shows the ad if one is available and not already showing.
  void showAdIfAvailable() {
    if (!isAdAvailable) {
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
    );
    try {
      _appOpenAd!.show();
    } catch (e) {
      LoggerService.log(
        '[DUEDO_AUDIT:ADS] AppOpenAd.show() failed: $e',
        category: LogCategory.error,
        error: e,
      );
      _isShowingAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
    }
  }
}
