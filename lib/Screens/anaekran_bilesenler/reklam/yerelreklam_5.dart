import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklambes extends StatefulWidget {
  const YerelReklambes({super.key});

  @override
  State<YerelReklambes> createState() => _YerelReklambesState();
}

class _YerelReklambesState extends State<YerelReklambes> {
  NativeAd? _yerelreklambes;
  ValueNotifier<bool> yerelbes = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AboneMi.isReklamsiz) {
        loadNativeAd();
      }
    });
  }

  void loadNativeAd() async {
    if (!mounted) return;
    final AdRequest request;
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      request = AdRequest(
        nonPersonalizedAds: status != TrackingStatus.authorized,
      );
    } else {
      request = const AdRequest();
    }

    _yerelreklambes = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/6792617943"
              : "ca-app-pub-3309512680871363/7395253178",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklambes = ad as NativeAd;
          yerelbes.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklambes = null;
          yerelbes.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklambes!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklambes");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yerelbes,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklambes != null) {
          return SizedBox(
            width: double.infinity,
            height: 120,
            child: AdWidget(ad: _yerelreklambes!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklambes?.dispose();
    _yerelreklambes = null;
    yerelbes.dispose();
    super.dispose();
  }
}
