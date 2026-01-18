import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/ciktilar/drivekayit.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ayarlarsifirlama extends StatefulWidget {
  const Ayarlarsifirlama({super.key});

  @override
  State<Ayarlarsifirlama> createState() => _AyarlarsifirlamaState();
}

class _AyarlarsifirlamaState extends State<Ayarlarsifirlama> {
  @override
  void initState() {
    super.initState();

    checkInternet().then((isConnected) {
      if (!isConnected) {
        _internetYokDialog();
      }
    });
  }

  void _kayitSil() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Kaydet.jetonharictemizleme(prefs);
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
            "Tüm Verileri Sıfırla",

            textScaler: TextScaler.noScaling,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: _ortaalan(),
              ),
            ),
            const RepaintBoundary(child: BannerReklam()),
          ],
        ),
      ),
    );
  }

  Widget _ortaalan() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Material(
            color: Colors.white,
            child: SizedBox(
              height: 200,
              child: Image.asset('assets/images/r525.png'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "  Uygulamada ki tüm kayıtlı verileri (mesailer, izinler, kidem giriş verileri, işsizlik maaş giriş verileri, maaş hesaplama verileri vb.) sıfırlayarak kullanıcıların uygulama deneyimlerini temiz bir başlangıç ile yenilemelerine olanak tanır. Bu işlem, genellikle uygulamanın ayarları veya kullanıcı verileri ile ilgili değişiklikler yapmak istendiğinde kullanılır.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                      Mesaj.altmesaj(
                        context,
                        "Veriler Başarıyla Silindi",
                        Colors.green,
                      );
                      _kayitSil();
                    },
                    child: Renk.buton('Tüm Verileri Sıfırla', 45),
                  ),
                ),
              ],
            ),
          ),
          const RepaintBoundary(child: YerelReklamiki()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
