import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklamalti extends StatefulWidget {
  const YerelReklamalti({super.key});

  @override
  State<YerelReklamalti> createState() => _YerelReklamaltiState();
}

class _YerelReklamaltiState extends State<YerelReklamalti> {
  NativeAd? _yerelreklamalti;
  ValueNotifier<bool> yerelalti = ValueNotifier<bool>(false);

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

    _yerelreklamalti = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/6288155258"
              : "ca-app-pub-3309512680871363/5054371736",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklamalti = ad as NativeAd;
          yerelalti.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklamalti = null;
          yerelalti.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklamalti!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklamalti");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yerelalti,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklamalti != null) {
          return SizedBox(
            width: double.infinity,
            height: 120,
            child: AdWidget(ad: _yerelreklamalti!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklamalti?.dispose();
    _yerelreklamalti = null;
    yerelalti.dispose();
    super.dispose();
  }
}
