import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklamiki extends StatefulWidget {
  const YerelReklamiki({super.key});

  @override
  State<YerelReklamiki> createState() => _YerelReklamikiState();
}

class _YerelReklamikiState extends State<YerelReklamiki> {
  NativeAd? _yerelreklamiki;
  ValueNotifier<bool> yereliki = ValueNotifier<bool>(false);

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

    _yerelreklamiki = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/1345373898"
              : "ca-app-pub-3309512680871363/3519214277",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklamiki = ad as NativeAd;
          yereliki.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklamiki = null;
          yereliki.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklamiki!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklamiki");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yereliki,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklamiki != null) {
          return SizedBox(
            width: double.infinity,
            height: 360,
            child: AdWidget(ad: _yerelreklamiki!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklamiki?.dispose();
    _yerelreklamiki = null;
    yereliki.dispose();
    super.dispose();
  }
}
