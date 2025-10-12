import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerReklamiki extends StatefulWidget {
  const BannerReklamiki({super.key});

  @override
  State<BannerReklamiki> createState() => _BannerReklamikiWidgetState();
}

class _BannerReklamikiWidgetState extends State<BannerReklamiki> {
  BannerAd? banneriki;
  ValueNotifier<bool> dinleBanneriki = ValueNotifier<bool>(false);

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
    banneriki?.dispose();
    banneriki = null;
    dinleBanneriki.dispose();
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

    banneriki = BannerAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/5513536733"
              : "ca-app-pub-3309512680871363/9568331818",
      size: adaptiveSize,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          banneriki = ad as BannerAd;
          dinleBanneriki.value = true;
        },
        onAdFailedToLoad: (ad, err) {
          if (!mounted) return;
          ad.dispose();
          banneriki = null;
          dinleBanneriki.value = false;
        },
      ),
    );

    banneriki!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("reklambanner2");
    return ValueListenableBuilder<bool>(
      valueListenable: dinleBanneriki,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && banneriki != null) {
          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: banneriki!.size.width.toDouble(),
              height: banneriki!.size.height.toDouble(),
              child: AdWidget(ad: banneriki!),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
