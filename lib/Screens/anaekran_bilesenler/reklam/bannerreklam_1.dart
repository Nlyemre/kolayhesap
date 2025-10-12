import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerReklam extends StatefulWidget {
  const BannerReklam({super.key});

  @override
  State<BannerReklam> createState() => _BannerReklamState();
}

class _BannerReklamState extends State<BannerReklam> {
  BannerAd? bannerAd;
  ValueNotifier<bool> isBannerAdLoadedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AboneMi.isReklamsiz) {
        loadBannerAd();
      }
    });
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    bannerAd = null;
    isBannerAdLoadedNotifier.dispose();
    super.dispose();
  }

  void loadBannerAd() async {
    if (!mounted) return;

    final Size screenSize = MediaQuery.of(context).size;
    final int width = screenSize.width.truncate();

    final AnchoredAdaptiveBannerAdSize? adaptiveSize =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          width,
        );

    if (adaptiveSize == null) {
      return;
    }

    final AdRequest request;
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      request = AdRequest(
        nonPersonalizedAds: status != TrackingStatus.authorized,
      );
    } else {
      request = const AdRequest();
    }

    bannerAd = BannerAd(
      adUnitId:
          Platform.isAndroid
              ? 'ca-app-pub-3309512680871363/3097585715'
              : 'ca-app-pub-3309512680871363/4018446722',
      size: adaptiveSize,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) return;
          bannerAd = ad as BannerAd;
          isBannerAdLoadedNotifier.value = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (!mounted) return;
          ad.dispose();
          bannerAd = null;
          isBannerAdLoadedNotifier.value = false;
        },
      ),
    );

    bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isBannerAdLoadedNotifier,
      builder: (context, isLoaded, child) {
        if (isLoaded && bannerAd != null) {
          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
