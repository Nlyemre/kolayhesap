import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:app/Screens/anaekran_bilesenler/abonelik/abonelik_satis.dart';
import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/girisreklam.dart';
import 'package:app/firebase_options.dart';
import 'package:app/tema.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class AboneMi {
  static bool isReklamsiz = false;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {},
  );
}

Future<void> initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 1. Firebase başlatma (iOS için ilk sırada)
  await initializeFirebase();

  // 2. Sistem ayarları
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Intl.defaultLocale = 'tr_TR';

  try {
    await Adapty().activate(
      configuration:
          AdaptyConfiguration(
              apiKey: 'public_live_4Y47cYP6.gglB8fZ0mrlszGRfSXNP',
            )
            ..withObserverMode(false)
            ..withLogLevel(AdaptyLogLevel.verbose),
    );
    // Uygulama açıldığında abonelik durumunu kontrol et
    await AbonelikYoneticisi.kontrolEt();
    AboneMi.isReklamsiz = AbonelikYoneticisi.reklamsizMi;
  } catch (e) {
    if (kDebugMode) print("Adapty başlatma hatası: $e");
    if (kDebugMode) print(AboneMi.isReklamsiz);
  }

  // 3. Bildirimler
  await _initializeNotifications();

  // 4. Reklamlar
  await MobileAds.instance.initialize();
  unawaited(_initializeAds());

  runApp(const MyApp());
}

Future<void> _initializeAds() async {
  if (!AboneMi.isReklamsiz) {
    await GirisReklam().loadInterstitialAd();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {},
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
    });
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_default_channel',
            'Firebase Bildirimleri',
            channelDescription: 'Firebase tarafından gönderilen bildirimler',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kolay Hesap app",
      debugShowCheckedModeBanner: false,
      theme: Tema.normalTema,
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
        routeObserver,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: SafeArea(top: false, child: child!),
        );
      },
      home: const Anasayfa(pozisyon: 0, tarihyenile: ''),
    );
  }
}
