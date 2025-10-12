import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerReklamuc extends StatefulWidget {
  const BannerReklamuc({super.key});

  @override
  State<BannerReklamuc> createState() => _BannerReklamucWidgetState();
}

class _BannerReklamucWidgetState extends State<BannerReklamuc> {
  BannerAd? banneruc;
  ValueNotifier<bool> dinleBanneruc = ValueNotifier<bool>(false);

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
    banneruc?.dispose();
    banneruc = null;
    dinleBanneruc.dispose();
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

    banneruc = BannerAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/5759280445"
              : "ca-app-pub-3309512680871363/7237681948",
      size: adaptiveSize,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          banneruc = ad as BannerAd;
          dinleBanneruc.value = true;
        },
        onAdFailedToLoad: (ad, err) {
          if (!mounted) return;
          ad.dispose();
          banneruc = null;
          dinleBanneruc.value = false;
        },
      ),
    );

    banneruc!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("reklambanner3");
    return ValueListenableBuilder<bool>(
      valueListenable: dinleBanneruc,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && banneruc != null) {
          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: banneruc!.size.width.toDouble(),
              height: banneruc!.size.height.toDouble(),
              child: AdWidget(ad: banneruc!),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
