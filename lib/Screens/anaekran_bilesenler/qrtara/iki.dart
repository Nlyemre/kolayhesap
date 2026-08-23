import 'dart:async';
import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/qrtara/bir.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Tarama extends StatefulWidget {
  const Tarama({super.key});

  @override
  State<Tarama> createState() => _TaramaState();
}

class _TaramaState extends State<Tarama> {
  final GlobalKey<ScaffoldState> _uyariMesajQr = GlobalKey<ScaffoldState>();
  final MobileScannerController controller = MobileScannerController();
  Barcode? _barcode;

  String _url = '';

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      _url = '';
    } else {
      _url = value.displayValue ?? 'Geçersiz Kod.';
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _url,
        overflow: TextOverflow.fade,
        style: const TextStyle(color: Color.fromARGB(255, 86, 85, 85)),
        textAlign: TextAlign.start, // Ekranın ortasında yazdırmak için
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _qrCagir();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
        if (_barcode != null) {
          controller.stop();
        }
      });
    }
  }

  void geri() {
    if (_barcode != null) {
      _barcode = null;
    }
    controller.stop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrGiris()),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        geri();
      },
      child: Scaffold(
        key: _uyariMesajQr,
        appBar: AppBar(
          leading: const BackButton(color: Renk.koyuMavi),

          title: const Text("Qr Kod Tarama"),
        ),
        body: Stack(
          children: [
            MobileScanner(controller: controller, onDetect: _handleBarcode),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Center(child: _buildBarcode(_barcode))],
                    ),
                  ),
                  SizedBox(height: 60, child: Center(child: _butonlar())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _aramaTemizle() {
    if (_barcode != null) {
      _barcode = null; // Tarama sonucu temizle
    }
    controller.start(); // Kamera taramasını başlat
  }

  Widget _butonlar() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (null == _barcode) {
                    Mesaj.altmesaj(
                      context,
                      'Tarama Sonucu Bulunamadı',
                      Colors.red,
                    );
                  } else {
                    _launchURL(Uri.parse(_url.toString()));
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(width: 1.5, color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text(
                      "Url Git",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 86, 85, 85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _url = '';
                    Text(
                      _url,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 86, 85, 85),
                      ),
                      textAlign:
                          TextAlign.start, // Ekranın ortasında yazdırmak için
                    );
                  });
                  _aramaTemizle();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(width: 1.5, color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text(
                      "Tekrar Tara",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 86, 85, 85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_barcode == null) {
                    Mesaj.altmesaj(
                      context,
                      'Kaydedilecek Tarama Sonucu Bulunamadı',
                      Colors.red,
                    );
                  } else {
                    _izinEkleDialog();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(width: 1.5, color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text(
                      "Kaydet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 86, 85, 85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final _qrAdTextKontrol = TextEditingController();
  String _ad = "";

  void _izinEkleDialog() {
    AcilanPencere.show(
      context: context,
      title: 'Qr Kod Başlık Belirle',
      height: 0.9,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              MetinKutusu(
                controller: _qrAdTextKontrol,
                labelText: "Qr Kod Başlık",
                hintText: 'Lokanta Menü',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  if (value.isNotEmpty) {}
                },
                clearButtonVisible: true,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Renk.buton('İptal', 45),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_qrAdTextKontrol.text == "") {
                          Mesaj.altmesaj(
                            context,
                            'Kayit İçin Başlık Giriniz.',
                            Colors.red,
                          );
                        } else {
                          setState(() {
                            _ad = _qrAdTextKontrol.text;
                            _qrKayit();
                          });
                        }
                      },
                      child: Renk.buton('Kaydet', 45),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 10),
                child: Text(
                  textAlign: TextAlign.center,
                  'Sistemimize kaydetmek üzere olduğunuz QR kod için bir başlık oluşturmanız gerekmektedir. Bu başlık, QR kodunuzu daha sonra kolayca bulabilmeniz ve tanımlayabilmeniz için büyük önem taşımaktadır.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              const RepaintBoundary(child: YerelReklamiki()),
            ],
          ),
        ),
      ),
    );
  }

  List<String> qrAdListe = [];
  List<String> qrUrlListe = [];

  Future<void> _qrCagir() async {
    final prefs = await SharedPreferences.getInstance();

    String qrAdJsonCagir = prefs.getString('qrAd') ?? '[]';
    String qrUrlJsonCagir = prefs.getString('qrUrl') ?? '[]';

    qrAdListe = [];
    for (var item in jsonDecode(qrAdJsonCagir)) {
      qrAdListe.add(item.toString());
    }
    qrUrlListe = [];
    for (var item in jsonDecode(qrUrlJsonCagir)) {
      qrUrlListe.add(item.toString());
    }
  }

  Future<void> _qrKayit() async {
    final prefs = await SharedPreferences.getInstance();
    qrAdListe.add(_ad.toString());
    qrUrlListe.add(_url.toString());

    String qrAdJsonKayit = jsonEncode(qrAdListe);
    String qrUrlJsonKayit = jsonEncode(qrUrlListe);

    await prefs.setString('qrAd', qrAdJsonKayit);
    await prefs.setString('qrUrl', qrUrlJsonKayit);

    geri();
  }
}
