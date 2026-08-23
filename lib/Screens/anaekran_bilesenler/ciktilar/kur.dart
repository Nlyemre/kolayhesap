import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamgiris.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Kursayfa extends StatefulWidget {
  final int sayfaId;
  final int grafiksayfaId;
  final List<List<List<num>>> sonListe;

  const Kursayfa({
    super.key,
    required this.sonListe,
    required this.sayfaId,
    required this.grafiksayfaId,
  });

  @override
  State<Kursayfa> createState() => _KursayfaState();
}

class _KursayfaState extends State<Kursayfa> {
  List<dynamic> _veri = [];

  @override
  void initState() {
    super.initState();

    _veri = [];
    _veriGuncelle();
  }

  Future<void> _veriGuncelle() async {
    final response = await http.get(
      Uri.parse('https://www.kolayhesappro.com/kur.php'),
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _veri = jsonDecode(response.body);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ZamGiris(
                  id: widget.sayfaId,
                  grafikid: widget.grafiksayfaId,
                  sayfa: 0,
                ),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.koyuMavi),

          title: const Text(
            "Ülke Para Birimi Karşılaştırma",

            textScaler: TextScaler.noScaling,
          ),
        ),
        body:
            _veri.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          String baslik = aylarYazi[index];
                          double maas = double.parse(
                            widget.sonListe[index][7][0].toString(),
                          );

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: CizgiliCerceve(
                                  golge: 5,
                                  backgroundColor: Renk.acikgri,
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 30,
                                          left: 15,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              textAlign: TextAlign.center,
                                              baslik,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Renk.koyuMavi,
                                              ),
                                              textScaler: TextScaler.noScaling,
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  textAlign: TextAlign.center,
                                                  "MAAŞ :  ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Renk.koyuMavi,
                                                  ),
                                                  textScaler:
                                                      TextScaler.noScaling,
                                                ),
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  "${maas.toStringAsFixed(2)} TL",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textScaler:
                                                      TextScaler.noScaling,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        color: Renk.cita,
                                        height: 1,
                                      ),
                                      if (maas != 0)
                                        _karsilastirkurkart(index, maas),
                                    ],
                                  ),
                                ),
                              ),
                              // Reklamı belirli aralıklarla göster
                              if (index % 3 == 0 &&
                                  index != 0) // Her üç öğede bir reklam göster
                                const RepaintBoundary(child: YerelReklamuc()),
                            ],
                          );
                        },
                      ),
                    ),
                    const RepaintBoundary(child: BannerReklamuc()),
                  ],
                ),
      ),
    );
  }

  Widget _karsilastirkurkart(int index, double maas) {
    final List<Widget> kartlar = List.generate(_veri.length - 1, (i) {
      final veriler = _veri[i];
      final isim = veriler['isim'] ?? 'Bilinmiyor';
      final fiyat = double.tryParse(veriler['fiyat'] ?? '0') ?? 1.0;
      final tutar = maas / fiyat;

      return Expanded(
        child: Column(
          children: [
            ListTile(
              title: Text(
                isim,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Renk.koyuMavi,
                ),
                textScaler: TextScaler.noScaling,
              ),
              subtitle: Text(
                NumberFormat("#,##0.00", "tr_TR").format(tutar),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ],
        ),
      );
    });

    final List<Widget> rows = [];
    for (int i = 0; i < kartlar.length; i += 2) {
      rows.add(
        Row(
          children: [
            if (i < kartlar.length) kartlar[i],
            if (i + 1 < kartlar.length) kartlar[i + 1],
          ],
        ),
      );
    }

    return Column(children: rows);
  }

  List<String> aylarYazi = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
}
