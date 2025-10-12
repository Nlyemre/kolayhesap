import 'dart:async';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/abonelik/abonelik_satis.dart';
import 'package:app/Screens/anaekran_bilesenler/ayarlar/uzaksunucual.dart';
import 'package:app/Screens/anaekran_bilesenler/ayarlar/uzaksunucukayit.dart';
import 'package:app/Screens/anaekran_bilesenler/ayarlar/verilerisifirla.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_5.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  return true; // Gerekli kaydırma işlemleri
                }
                return false; // Diğer bildirimleri (Overscroll, vb.) durdur
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // Stabil kaydırma
                child: Column(
                  children: [
                    _buildSectionHeader("Sunucu İşlemleri"),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Column(
                        children: [
                          _verisifirlama(),
                          Dekor.cizgi15,
                          _sunucukayit(),
                          Dekor.cizgi15,
                          _sunucual(),
                          const RepaintBoundary(child: YerelReklambes()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildSectionHeader("İzin Onayları"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Column(
                        children: [
                          _bildirimonayi(),
                          if (Platform.isAndroid) Dekor.cizgi15,
                          if (Platform.isAndroid) _alarmmonayi(),
                          const RepaintBoundary(child: YerelReklamalti()),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildSectionHeader("Abonelik İşlemleri"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Column(
                        children: [
                          _aboneol(),
                          Dekor.cizgi15,
                          _abonecagir(),
                          Dekor.cizgi15,
                          _aboneiptal(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Renk.koyuMavi.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Renk.koyuMavi,
          ),
        ),
      ),
    );
  }

  Widget _verisifirlama() {
    return GestureDetector(
      onTap: () {
        if (!AboneMi.isReklamsiz) {
          Future.delayed(const Duration(milliseconds: 300), () {
            // ignore: use_build_context_synchronously
            AbonelikDialog.abonegit(context);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Ayarlarsifirlama()),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Tüm Kayitli Verileri Sifirla",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sunucukayit() {
    return GestureDetector(
      onTap: () {
        if (!AboneMi.isReklamsiz) {
          Future.delayed(const Duration(milliseconds: 300), () {
            // ignore: use_build_context_synchronously
            AbonelikDialog.abonegit(context);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SunucuKayit()),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Verileri Uzak Sunucuya Kaydet",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sunucual() {
    return GestureDetector(
      onTap: () {
        if (!AboneMi.isReklamsiz) {
          Future.delayed(const Duration(milliseconds: 300), () {
            // ignore: use_build_context_synchronously
            AbonelikDialog.abonegit(context);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SunucuAl()),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Verileri Uzak Sunucudan Al",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _bildirimonayi() {
    return GestureDetector(
      onTap: () {
        openNotificationSettings();
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Bildirim Onayı",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  static const MethodChannel platform = MethodChannel('notification_settings');

  // Bildirim ayarlarına yönlendiren metot
  Future<void> openNotificationSettings() async {
    try {
      // platform üzerinden method channel'ı çağırıyoruz.
      await platform.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      Mesaj.altmesaj(
        // ignore: use_build_context_synchronously
        context,
        "Bildirim ayarlarını açılamadı: '${e.message}'.",
        Colors.red,
      );
    }
  }

  Future<void> _alarmAyarlariniAc() async {
    try {
      // Ayarlar ekranını aç
      await platform.invokeMethod('openAlarmPermissionSettings');
      // Kullanıcı ayarlardan döndükten sonra izni kontrol et
      await Future.delayed(const Duration(seconds: 1));
      final hasPermission = await _checkAlarmPermission();
      if (!hasPermission && mounted) {
        Mesaj.altmesaj(
          context,
          "Alarm izni kapatıldı. Bildirimler çalışmayabilir. Lütfen izni tekrar açın.",
          Colors.red,
        );
      } else if (hasPermission && mounted) {
        Mesaj.altmesaj(
          context,
          "Alarm izni açık. Bildirimler çalışacak.",
          Colors.green,
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        Mesaj.altmesaj(
          context,
          "Alarm ayarları açılamadı: ${e.message}",
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Mesaj.altmesaj(context, "Bilinmeyen hata: $e", Colors.red);
      }
    }
  }

  Future<bool> _checkAlarmPermission() async {
    return await platform.invokeMethod('checkAlarmPermission');
  }

  Widget _alarmmonayi() {
    return GestureDetector(
      onTap: () {
        _alarmAyarlariniAc();
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Yapılacaklar Listesi Alarm Onayı",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboneol() {
    return GestureDetector(
      onTap: () async {
        // SatinAlmaSayfasi'na git ve sonucu bekle
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SatinAlmaSayfasi()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Aylık Abonelik Al",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _abonecagir() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AbonelikGeriYuklemeSayfasi(),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Aboneliği Çağır",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboneiptal() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AbonelikIptalSayfasi()),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Aboneliği İptal Et",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Renk.cita, size: 20),
          ],
        ),
      ),
    );
  }
}
