import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklamuc extends StatefulWidget {
  const YerelReklamuc({super.key});

  @override
  State<YerelReklamuc> createState() => _YerelReklamucState();
}

class _YerelReklamucState extends State<YerelReklamuc> {
  NativeAd? _yerelreklamuc;
  ValueNotifier<bool> yereluc = ValueNotifier<bool>(false);

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

    _yerelreklamuc = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/8993616742"
              : "ca-app-pub-3309512680871363/4228375229",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklamuc = ad as NativeAd;
          yereluc.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklamuc = null;
          yereluc.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklamuc!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklamuc");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yereluc,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklamuc != null) {
          return SizedBox(
            width: double.infinity,
            height: 360,
            child: AdWidget(ad: _yerelreklamuc!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklamuc?.dispose();
    _yerelreklamuc = null;
    yereluc.dispose();
    super.dispose();
  }
}
