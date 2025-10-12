import 'dart:io';

import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YerelReklamdort extends StatefulWidget {
  const YerelReklamdort({super.key});

  @override
  State<YerelReklamdort> createState() => _YerelReklamdortState();
}

class _YerelReklamdortState extends State<YerelReklamdort> {
  NativeAd? _yerelreklamdort;
  ValueNotifier<bool> yereldort = ValueNotifier<bool>(false);

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

    _yerelreklamdort = NativeAd(
      adUnitId:
          Platform.isAndroid
              ? "ca-app-pub-3309512680871363/1345373898"
              : "ca-app-pub-3309512680871363/3519214277",
      request: request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _yerelreklamdort = ad as NativeAd;
          yereldort.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          if (!mounted) return;
          ad.dispose();
          _yerelreklamdort = null;
          yereldort.value = false;
        },
      ),
    );
    if (mounted) {
      await _yerelreklamdort!.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("reklamdort");
    }
    return ValueListenableBuilder<bool>(
      valueListenable: yereldort,
      builder: (context, isAdLoaded, child) {
        if (isAdLoaded && _yerelreklamdort != null) {
          return SizedBox(
            width: double.infinity,
            height: 120,
            child: AdWidget(ad: _yerelreklamdort!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _yerelreklamdort?.dispose();
    _yerelreklamdort = null;
    yereldort.dispose();
    super.dispose();
  }
}
