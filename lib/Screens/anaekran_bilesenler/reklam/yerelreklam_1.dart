import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklam extends StatefulWidget {
  const YerelReklam({super.key});

  @override
  State<YerelReklam> createState() => _YerelReklamState();
}

class _YerelReklamState extends State<YerelReklam> {
  NativeAd? _yerelreklam;
  ValueNotifier<bool> yerel = ValueNotifier<bool>(false);

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

    _yerelreklam = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/6303130680"
              : "ca-app-pub-3309512680871363/8196825882",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklam = ad as NativeAd;
          yerel.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklam = null;
          yerel.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklam!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklambir");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yerel,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklam != null) {
          return SizedBox(
            width: double.infinity,
            height: 360,
            child: AdWidget(ad: _yerelreklam!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklam?.dispose();
    _yerelreklam = null;
    yerel.dispose();
    super.dispose();
  }
}
