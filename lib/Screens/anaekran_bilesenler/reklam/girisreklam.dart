import 'dart:async';
import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

class GirisReklam {
  static final GirisReklam _instance = GirisReklam._internal();
  factory GirisReklam() => _instance;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  DateTime? _lastAdShownTime;
  bool _isLoading = false;

  bool get isAdReady => _isAdReady;

  GirisReklam._internal();

  Future<void> loadInterstitialAd({bool forceReload = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      if (!forceReload &&
          _lastAdShownTime != null &&
          DateTime.now().difference(_lastAdShownTime!) <
              const Duration(minutes: 5)) {
        return;
      }

      final AdRequest request;
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        request = AdRequest(
          nonPersonalizedAds: status != TrackingStatus.authorized,
        );
      } else {
        request = const AdRequest();
      }

      await InterstitialAd.load(
        adUnitId:
            Platform.isAndroid
                ? "ca-app-pub-3309512680871363/4706868558"
                : "ca-app-pub-3309512680871363/1631417532",
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isAdReady = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isAdReady = false;
            _scheduleReloadAfterDelay(); // Hata olduğunda 5 dk sonra yeniden yükle
          },
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  void showInterstitialAd() {
    if (!AboneMi.isReklamsiz && _isAdReady && _interstitialAd != null) {
      _lastAdShownTime = DateTime.now();
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdReady = false;
          _scheduleReloadAfterDelay(); // Reklam kapatıldığında 5 dk sonra yeniden yükle
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdReady = false;
          _scheduleReloadAfterDelay(); // Gösterim hatasında 5 dk sonra yeniden yükle
        },
      );
    } else {
      _scheduleReloadAfterDelay(); // Reklam boşsa 5 dk sonra yeniden yükle
    }
  }

  void _scheduleReloadAfterDelay() {
    Future.delayed(const Duration(minutes: 5), () async {
      await loadInterstitialAd();
    });
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _lastAdShownTime = null;
  }
}
