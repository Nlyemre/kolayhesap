import 'dart:async';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anagiris.dart';
import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfadort.dart';
import 'package:app/Screens/anaekran_bilesenler/ayarlar/ayarlaralt.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/kazanclar_ana.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/girisreklam.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/yanmenu_bilesenleri/altin.dart';
import 'package:app/Screens/yanmenu_bilesenleri/doviz.dart';
import 'package:app/Screens/yanmenu_bilesenleri/eczane.dart';
import 'package:app/Screens/yanmenu_bilesenleri/emtia.dart';
import 'package:app/Screens/yanmenu_bilesenleri/enflasyon.dart';
import 'package:app/Screens/yanmenu_bilesenleri/gizlilik.dart';
import 'package:app/Screens/yanmenu_bilesenleri/hava.dart';
import 'package:app/Screens/yanmenu_bilesenleri/kripto.dart';
import 'package:app/Screens/yanmenu_bilesenleri/sondakika.dart';
import 'package:app/Screens/yanmenu_bilesenleri/teknoloji_al.dart';
import 'package:app/main.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Anasayfa extends StatefulWidget {
  final int pozisyon;
  final String tarihyenile;

  const Anasayfa({
    required this.pozisyon,
    required this.tarihyenile,
    super.key,
  });

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late CircularBottomNavigationController _navigationController;
  late ValueNotifier<int> _selectedIndex;
  final InAppReview _inAppReview = InAppReview.instance;
  int degerlendirmeSayisi = 0;
  bool degerlendirmeKontrol = false;
  String googlePlayId = "com.kolayhesap.app";
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    _selectedIndex = ValueNotifier<int>(widget.pozisyon);
    _navigationController = CircularBottomNavigationController(widget.pozisyon);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    _prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _izinIste(),
      Future.delayed(
        const Duration(seconds: 5),
      ).then((_) => _degerlendirmeKontrolEt()),
      _checkInternetConnection(),
    ]);
  }

  Future<void> _checkInternetConnection() async {
    final isConnected = await _checkInternet();
    if (!mounted) return;
    if (!isConnected) {
      _internetYokDialog();
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _internetYokDialog() {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'İnternet Bağlantı Hatası',
      content: 'Lütfen internet bağlantısını sağlayıp tekrar giriş yapınız',
      buttonText: 'Kapat',
      onButtonPressed: () async {
        Navigator.of(context).pop();
        await Future.delayed(const Duration(milliseconds: 300));
        SystemNavigator.pop();
      },
    );
  }

  Future<void> _izinIste() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      // Bildirim izni
      final notificationStatus =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (notificationStatus.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // ATT izni kontrolü (SharedPreferences olmadan)
      final attStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (attStatus == TrackingStatus.notDetermined) {
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Sistem dialogu için bekle
        if (mounted) {
          await _izinDialog(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _selectedIndex.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
        } else if (_selectedIndex.value != 0) {
          _selectedIndex.value = 0;
          _navigationController.value = 0;
        } else {
          _cikisBilgilendirme(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AnasayfaAppBar(scaffoldKey: _scaffoldKey),
        drawer: const AppDrawer(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _BodyContent(
              selectedIndex: _selectedIndex,
              navigationController: _navigationController,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNav(
                controller: _navigationController,
                selectedIndex: _selectedIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cikisBilgilendirme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            "Uygulamadan Çıkmak İstiyor musunuz?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Hayır'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
                child: const Text('Evet'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _izinDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bilgilendirme;',
                  style: TextStyle(
                    fontSize: 18,
                    color: Renk.pastelKoyuMavi,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uygulamamızı ücretsiz sunabilmek için reklam gösteriyoruz. Size daha alakalı reklamlar sunabilmemiz adına verilerinizi kullanmak istiyoruz.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Devam Et butonuna bastığınızda, iOS sizden bu konuda izin isteyecektir.Bu izni verip vermemek tamamen sizin kararınız.Seçiminizi daha sonra uygulama ayarlarından değiştirebilirsiniz.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                      ),
                      child: const Text('Devam Et'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showNativeATTDialog();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  static Future<void> _showNativeATTDialog() async {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  Future<void> _degerlendirmeKontrolEt() async {
    degerlendirmeKontrol = _prefs.getBool('degerlendir') ?? false;

    if (!degerlendirmeKontrol) {
      degerlendirmeSayisi = (_prefs.getInt('degerlendirme_sayi') ?? 0) + 1;
      await _prefs.setInt('degerlendirme_sayi', degerlendirmeSayisi);

      if (degerlendirmeSayisi >= 25) {
        await _degerlendirmeGoster();
      }
    }
  }

  Future<void> _degerlendirmeKaydet() async {
    await _prefs.setBool('degerlendir', true);
    await _prefs.setInt('degerlendirme_sayi', 0);
    degerlendirmeKontrol = true;
  }

  Future<void> _degerlendirmeGoster() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await _degerlendirmeKaydet();
    } else {
      await _magazayaGit();
    }
  }

  Future<void> _magazayaGit() async {
    await _inAppReview.openStoreListing(appStoreId: googlePlayId);
    await _degerlendirmeKaydet();
  }
}

class AnasayfaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AnasayfaAppBar({super.key, required this.scaffoldKey});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // FlexibleSpaceBar bağımlılığını kaldır
      flexibleSpace: null,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Color.fromARGB(255, 100, 100, 100),
          size: 27,
        ),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            !AboneMi.isReklamsiz ? "Kolay Hesap" : "Kolay Hesap Pro",
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Image(
              image: AssetImage('assets/images/logo96.png'),
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      // Kaydırma bildirimlerini engelle
      notificationPredicate: (notification) => false,
    );
  }
}

class _BodyContent extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;
  final CircularBottomNavigationController navigationController;

  const _BodyContent({
    required this.selectedIndex,
    required this.navigationController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, value, child) {
        switch (value) {
          case 0:
            return const AnaGirisSayfasi();
          case 1:
            return Anagrafik(
              navigationController: navigationController,
              pozisyon: 1,
            );
          case 2:
            return const Ayarlar();
          case 3:
            return const Altdort();
          default:
            return const AnaGirisSayfasi();
        }
      },
    );
  }
}

class BottomNav extends StatelessWidget {
  final CircularBottomNavigationController controller;
  final ValueNotifier<int> selectedIndex;

  const BottomNav({
    super.key,
    required this.controller,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    double barHeight = Platform.isAndroid ? 60 : 70;

    return CircularBottomNavigation(
      normalIconColor: const Color.fromARGB(255, 119, 119, 119),
      tabItems,
      controller: controller,
      barHeight: barHeight,
      barBackgroundColor: Colors.white,
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (selectedPos) {
        if (selectedPos != null && selectedPos != selectedIndex.value) {
          selectedIndex.value = selectedPos;
          controller.value = selectedPos;
        }
      },
    );
  }

  static final List<TabItem> tabItems = [
    TabItem(Icons.home, "Anasayfa", const Color.fromARGB(255, 255, 105, 180)),
    TabItem(
      Icons.newspaper,
      "Kazançlarım",
      const Color.fromARGB(224, 255, 153, 0),
    ),
    TabItem(Icons.settings, "Ayarlar", const Color.fromARGB(217, 244, 67, 54)),
    TabItem(
      Icons.tag_sharp,
      "Destek Ol",
      const Color.fromARGB(230, 0, 187, 212),
    ),
  ];
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const AssetImage logo = AssetImage('assets/images/LOGOO.png');
  static const AssetImage notlarim = AssetImage('assets/images/NOTLARIM.png');
  static const AssetImage tekno = AssetImage('assets/images/TEKNO.png');
  static const AssetImage enflasyon = AssetImage('assets/images/ENFLASYON.png');
  static const AssetImage altin = AssetImage('assets/images/ALTIN.png');
  static const AssetImage sanal = AssetImage('assets/images/SANAL.png');
  static const AssetImage eczane = AssetImage('assets/images/ECZANE.png');
  static const AssetImage hava = AssetImage('assets/images/HAVAA.png');
  static const AssetImage ger = AssetImage('assets/images/GER.png');

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          _buildLogoItem(logo),
          _buildKard(
            context,
            'Son Dakika Haber',
            notlarim,
            () => const SonDakika(),
          ),
          _buildKard(
            context,
            'Teknoloji Haber',
            tekno,
            () => const Teknoloji(),
          ),
          _buildKard(context, 'Enflasyon', enflasyon, () => const Enflasyon()),
          _buildKard(
            context,
            'Döviz Fiyatları',
            altin,
            () => const DovizSayfasi(),
          ),
          _buildKard(
            context,
            'Altın Fiyatları',
            altin,
            () => const AltinSayfasi(),
          ),
          _buildKard(
            context,
            'Kripto Fiyatları',
            sanal,
            () => const KriptoSayfasi(),
          ),
          _buildKard(
            context,
            'Emtia Fiyatları',
            sanal,
            () => const EmtiaSayfasi(),
          ),
          _buildKard(context, 'Nöbetçi Eczane', eczane, () => const Eczane()),
          _buildKard(context, 'Hava Durumu', hava, () => const Hava()),
          const SizedBox(height: 20),
          _buildWebInfo(),
          _buildVersionInfo(),
          _buildPrivacyPolicy(context),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildLogoItem(AssetImage image) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: SizedBox(
        height: 70,
        child: Image(image: image, fit: BoxFit.fitHeight),
      ),
    );
  }

  Widget _buildKard(
    BuildContext context,
    String title,
    AssetImage image,
    Widget Function() targetScreenBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 9, right: 9, top: 7),
      child: CizgiliCerceve(
        golge: 5,
        child: ListTile(
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Renk.cita,
          ),
          leading: Image(image: image, height: 30, fit: BoxFit.fitHeight),
          title: Text(title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetScreenBuilder()),
            ).then((_) {
              if (GirisReklam().isAdReady) {
                Future.delayed(const Duration(seconds: 1), () {
                  GirisReklam().showInterstitialAd();
                });
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildWebInfo() {
    return const SizedBox(
      height: 30,
      child: Center(
        child: Text(
          'www.kolayhesappro.com',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return const Text(
      'Version 2.9.6',
      style: TextStyle(fontSize: 10.0),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Gizlilik()),
            ),
        child: const Text(
          'Gizlilik Politikası',
          style: TextStyle(fontSize: 13.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 40,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Image(image: ger, height: 40),
          ),
        ),
      ),
    );
  }
}
