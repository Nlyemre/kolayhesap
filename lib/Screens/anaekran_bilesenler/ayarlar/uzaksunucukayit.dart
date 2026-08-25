import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/ciktilar/drivekayit.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SunucuKayit extends StatefulWidget {
  const SunucuKayit({super.key});

  @override
  State<SunucuKayit> createState() => _SunucuKayitState();
}

class _SunucuKayitState extends State<SunucuKayit> {
  @override
  void initState() {
    super.initState();

    checkInternet().then((isConnected) {
      if (!isConnected) {
        _internetYokDialog();
      }
    });
  }

  Future<bool> checkInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true; // İnternet var
      } else {
        return false; // İnternete erişim yok
      }
    } catch (e) {
      return false; // Hata veya internet bağlantısı yok
    }
  }

  void _internetYokDialog() {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'İnternet Bağlantı Hatası',
      content: 'Lütfen internet bağlantısını sağlayıp tekrar giriş yapınız',
      buttonText: 'Kapat',
      onButtonPressed: () async {
        Navigator.of(context).pop(); // Dialog'u kapat
        await Future.delayed(const Duration(milliseconds: 300));
        SystemNavigator.pop(); // Uygulamayı kapat
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Anasayfa(pozisyon: 2, tarihyenile: ""),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.pastelKoyuMavi),

          title: const Text(
            "Uzak Sunucuya Kayıt",

            textScaler: TextScaler.noScaling,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: _ortaalan(),
                ),
              ),
            ),
            const RepaintBoundary(child: BannerReklamiki()),
          ],
        ),
      ),
    );
  }

  Widget _ortaalan() {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: SizedBox(
            height: 200,
            child: Image.asset('assets/images/r518.png'),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "  Google Drive veya Uzak sunucuya veri kaydetme, uygulamada kullandığınız bilgileri merkezi bir sistemde depolamak için kullanılan bir yöntemdir. Bu, verilerin her zaman erişilebilir olmasını, yedeklenmesini, telefon değişikliğinde bilgilerinizi kaybetmeden geri almanızı ve dilediğiniz kişilerle verilerinizin paylaşılmasını sağlar.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    verileriKaydet();
                  },
                  child: Renk.buton('Verileri Kaydet', 45),
                ),
              ),
            ],
          ),
        ),
        const RepaintBoundary(child: YerelReklam()),
        const SizedBox(height: 40),
      ],
    );
  }

  void verileriKaydet() {
    Kaydet.kaydetJson((message) {
      Mesaj.altmesaj(context, message, Colors.green);
    });
  }
}
