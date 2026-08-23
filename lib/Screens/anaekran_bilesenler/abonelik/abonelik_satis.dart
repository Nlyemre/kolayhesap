import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/main.dart'; // AppState için
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Color arkaPlanRengi = const Color(0xFFF6F8FF);
final TextStyle aciklamaStil = const TextStyle(
  fontSize: 16,
  height: 1.4,
  color: Colors.black87,
);

Widget anaKart({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Renk.koyuMavi, width: 1),
      boxShadow: [
        BoxShadow(
          color: Renk.koyuMavi.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
    child: child,
  );
}

GestureDetector ozellikliButon({
  required VoidCallback onPressed,
  required String text,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 55,
      decoration: const BoxDecoration(
        gradient: Renk.gradient,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

Widget yuvarlakIcon(IconData icon, {Color renk = Renk.koyuMavi}) {
  return Container(
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: Renk.gradient,
    ),
    padding: const EdgeInsets.all(24),
    child: Icon(icon, color: Colors.white, size: 72),
  );
}

class AbonelikYoneticisi {
  static const String paywallId = 'reklamsiz_kullanim'; // Paywall ID'si
  static const String productId = 'reklamsiz_kullanim_aylik'; // Yalnızca aylık
  static bool _reklamsizMi = false;

  static bool get reklamsizMi => _reklamsizMi;
  static set reklamsizMi(bool value) {
    _reklamsizMi = value;
    AboneMi.isReklamsiz = value;
  }

  static Future<void> kontrolEt() async {
    try {
      final profil = await Adapty().getProfile();
      final seviye = profil.accessLevels['reklamsiz'];
      reklamsizMi = seviye != null && seviye.isActive;
    } catch (e) {
      if (kDebugMode) print("Abonelik kontrol hatası: $e");
    }
  }

  static Future<void> satinAl() async {
    try {
      final flow = await Adapty().getFlow(placementId: paywallId);
      final urunler = await Adapty().getPaywallProducts(flow: flow);
      final urun = urunler.firstWhere(
        (e) => e.vendorProductId == productId,
        orElse: () => throw Exception('Ürün bulunamadı'),
      );

      await Adapty().makePurchase(product: urun);
      final profil = await Adapty().getProfile();
      final seviye = profil.accessLevels['reklamsiz'];
      reklamsizMi = seviye != null && seviye.isActive;
    } catch (e) {
      if (kDebugMode) print("Satın alma hatası: $e");
      rethrow;
    }
  }

  static Future<void> geriYukle() async {
    try {
      await Adapty().restorePurchases();
      final profil = await Adapty().getProfile();
      final seviye = profil.accessLevels['reklamsiz'];
      reklamsizMi = seviye != null && seviye.isActive;
    } catch (e) {
      if (kDebugMode) print("Geri yükleme hatası: $e");
      rethrow;
    }
  }
}

class SatinAlmaSayfasi extends StatefulWidget {
  const SatinAlmaSayfasi({super.key});

  @override
  State<SatinAlmaSayfasi> createState() => _SatinAlmaSayfasiState();
}

class _SatinAlmaSayfasiState extends State<SatinAlmaSayfasi> {
  bool yukleniyor = false;
  String mesaj = '';
  bool sozlesmeKabulEdildi = false;

  Future<void> satinAl() async {
    if (!sozlesmeKabulEdildi) {
      setState(() {
        mesaj =
            'Lütfen Kullanıcı Sözleşmesi ve Gizlilik Politikası’nı kabul edin.';
      });
      return;
    }

    setState(() {
      yukleniyor = true;
      mesaj = '';
    });

    try {
      await AbonelikYoneticisi.satinAl();
      if (AbonelikYoneticisi.reklamsizMi) {
        setState(() {
          mesaj = 'Satın alma işlemi başarılı! Keyfini çıkarın 😊';
        });
      }
    } on AdaptyError catch (adaptyError) {
      if (adaptyError.code == AdaptyErrorCode.paymentCancelled) {
        setState(() {
          mesaj = 'Satın alma işlemi iptal edildi.';
        });
      } else {
        setState(() {
          mesaj = 'Satın alma işlemi sırasında bir hata oluştu';
        });
      }
    } catch (e) {
      setState(() {
        mesaj =
            'Satın alma işlemi sırasında bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  void geri() {
    if (AbonelikYoneticisi.reklamsizMi) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Anasayfa(pozisyon: 0, tarihyenile: ""),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          geri();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Renk.koyuMavi, onPressed: geri),
          iconTheme: const IconThemeData(color: Renk.koyuMavi),
          title: const Text('Abonelik Satın Al'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: anaKart(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  yuvarlakIcon(Icons.workspace_premium_rounded),
                  const SizedBox(height: 30),
                  const Text(
                    'Özel Üyelik ile Reklamsız Deneyim',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Renk.koyuMavi,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sadece 49,90 ₺/ay karşılığında tüm reklamları kaldır, '
                    'özel içeriklere erişim sağla ve uygulamayı kesintisiz kullan.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 280,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Renk.koyuMavi, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Renk.koyuMavi.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RichText(
                        text: const TextSpan(
                          text: '₺',
                          style: TextStyle(
                            fontSize: 28,
                            color: Renk.koyuMavi,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '49',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Renk.koyuMavi,
                              ),
                            ),
                            TextSpan(
                              text: ',90',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Renk.koyuMavi,
                              ),
                            ),
                            TextSpan(
                              text: ' / Ay',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: sozlesmeKabulEdildi,
                        onChanged: (value) {
                          setState(() {
                            sozlesmeKabulEdildi = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _kullanicisozlesmesi();
                          },
                          child: const Text(
                            'Kullanıcı Sözleşmesi ve Gizlilik Politikası’nı kabul ediyorum.',
                            style: TextStyle(
                              color: Renk.koyuMavi,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  yukleniyor
                      ? const CircularProgressIndicator()
                      : ozellikliButon(onPressed: satinAl, text: 'Satın Al'),
                  if (mesaj.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      mesaj,
                      style: TextStyle(
                        color:
                            AbonelikYoneticisi.reklamsizMi
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _kullanicisozlesmesi() async {
    await AcilanPencere.show(
      context: context,
      title: 'Bilgilendirme',
      height: 0.85,
      content: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            yuvarlakIcon(Icons.description_rounded),
            const SizedBox(height: 30),
            const Text(
              'Kullanıcı Sözleşmesi ve Gizlilik Politikası',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Renk.koyuMavi,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Lütfen aşağıdaki bağlantılardan Kullanıcı Sözleşmesi ve Gizlilik Politikası’nı inceleyin.',
              style: aciklamaStil,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ozellikliButon(
              onPressed: () async {
                final url = Uri.parse(
                  Platform.isIOS
                      ? 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'
                      : 'https://www.kolayhesappro.com/kullanici-sozlesmesi',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  Mesaj.altmesaj(
                    // ignore: use_build_context_synchronously
                    context,
                    'Sayfa açılamadı',
                    Colors.red,
                  );
                }
              },
              text: 'Kullanıcı Sözleşmesi',
            ),
            const SizedBox(height: 16),
            ozellikliButon(
              onPressed: () async {
                final url = Uri.parse(
                  'https://www.kolayhesappro.com/gizlilik-politikasi',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  Mesaj.altmesaj(
                    // ignore: use_build_context_synchronously
                    context,
                    'Sayfa açılamadı',
                    Colors.red,
                  );
                }
              },
              text: 'Gizlilik Politikası',
            ),
          ],
        ),
      ),
    );
  }
}

class AbonelikIptalSayfasi extends StatelessWidget {
  const AbonelikIptalSayfasi({super.key});

  Future<void> iptalSayfasiniAc(BuildContext context) async {
    final iosUrl = 'https://apps.apple.com/account/subscriptions';
    final androidUrl = 'https://play.google.com/store/account/subscriptions';

    final Uri url = Uri.parse(Platform.isIOS ? iosUrl : androidUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Mesaj.altmesaj(
        // ignore: use_build_context_synchronously
        context,
        'İptal sayfası açılamadı',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Renk.koyuMavi),
        title: const Text('Abonelik İptal'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: anaKart(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                yuvarlakIcon(Icons.cancel_rounded, renk: Colors.redAccent),
                const SizedBox(height: 30),
                Text(
                  'Aboneliğinizi iptal etmek isterseniz, aşağıdaki butona basarak '
                  'cihazınıza uygun abonelik yönetim sayfasına yönlendirileceksiniz.',
                  style: aciklamaStil,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ozellikliButon(
                  onPressed: () => iptalSayfasiniAc(context),
                  text: 'Aboneliği İptal Et',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AbonelikGeriYuklemeSayfasi extends StatefulWidget {
  const AbonelikGeriYuklemeSayfasi({super.key});

  @override
  State<AbonelikGeriYuklemeSayfasi> createState() =>
      _AbonelikGeriYuklemeSayfasiState();
}

class _AbonelikGeriYuklemeSayfasiState
    extends State<AbonelikGeriYuklemeSayfasi> {
  bool yukleniyor = false;
  String mesaj = '';

  Future<void> geriYukle() async {
    setState(() {
      yukleniyor = true;
      mesaj = '';
    });
    try {
      await AbonelikYoneticisi.geriYukle();
      if (AbonelikYoneticisi.reklamsizMi) {
        setState(() {
          mesaj = 'Abonelikler başarıyla geri yüklendi.';
        });
      } else {
        setState(() {
          mesaj = 'Abonelik Bulunamadı.';
        });
      }
    } catch (e) {
      setState(() {
        mesaj = 'Geri yükleme başarısız: $e';
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Renk.koyuMavi),
        title: const Text('Abonelik Geri Yükleme'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: anaKart(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                yuvarlakIcon(Icons.restore_rounded),
                const SizedBox(height: 30),
                Text(
                  'Cihaz değişikliği veya uygulama yeniden yükleme durumunda, '
                  'aboneliklerinizi geri yüklemek için aşağıdaki butona tıklayın.',
                  style: aciklamaStil,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                yukleniyor
                    ? const CircularProgressIndicator()
                    : ozellikliButon(
                      onPressed: geriYukle,
                      text: 'Abonelikleri Geri Yükle',
                    ),
                if (mesaj.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    mesaj,
                    style: TextStyle(
                      color:
                          AbonelikYoneticisi.reklamsizMi
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
