import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class KarsilastirmaDetay extends StatefulWidget {
  final String aydetay0;
  final String aydetay1;
  final String aydetay2;
  final int aysayi;
  final List<List<List<num>>> sonListe;
  final int anahtarid;

  const KarsilastirmaDetay({
    super.key,
    required this.aydetay0,
    required this.aydetay1,
    required this.aydetay2,
    required this.aysayi,
    required this.sonListe,
    required this.anahtarid,
  });

  @override
  State<KarsilastirmaDetay> createState() => _KarsilastirmaDetayState();
}

class _KarsilastirmaDetayState extends State<KarsilastirmaDetay> {
  late final List<String> _formattedValues = _formatValues();

  List<String> _formatValues() {
    final formatter = NumberFormat("#,##0.00", "tr_TR");
    return widget.sonListe[widget.aysayi]
        .map((list) {
          return list.map((value) => formatter.format(value)).toList();
        })
        .expand((element) => element)
        .toList();
  }

  void _paylas() {
    final paylas =
        StringBuffer()
          ..writeln("${widget.aydetay2} Ayı Karşılaştırma\n")
          ..writeln("Zam Oranı   : % ${widget.aydetay0}")
          ..writeln("Kıdem Farkı : ${widget.aydetay1}\n")
          ..writeln("Brüt Ücret Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[0]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[1]}")
          ..writeln("Fark        : ${_formattedValues[2]}\n")
          ..writeln("İkramiye Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[3]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[4]}")
          ..writeln("Fark        : ${_formattedValues[5]}\n")
          ..writeln("Sosyal Haklar Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[6]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[7]}")
          ..writeln("Fark        : ${_formattedValues[8]}\n")
          ..writeln("Toplam Brüt Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[9]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[10]}")
          ..writeln("Fark        : ${_formattedValues[11]}\n")
          ..writeln("Sendika Kesintisi Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[12]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[13]}")
          ..writeln("Fark        : ${_formattedValues[14]}\n")
          ..writeln("Avans Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[15]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[16]}")
          ..writeln("Fark        : ${_formattedValues[17]}\n")
          ..writeln("Kalan Maaş Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[18]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[19]}")
          ..writeln("Fark        : ${_formattedValues[20]}\n")
          ..writeln("Toplam Maaş Karşılaştırma")
          ..writeln("Eski Ücret  : ${_formattedValues[21]}")
          ..writeln("Yeni Ücret  : ${_formattedValues[22]}")
          ..writeln("Fark        : ${_formattedValues[23]}");

    SharePlus.instance.share(ShareParams(text: paylas.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _paylas,
            icon: const Icon(Icons.share, size: 20.0, color: Renk.koyuMavi),
          ),
        ],
        leading: const BackButton(color: Renk.koyuMavi),

        title: Text("${widget.aydetay2} Ayı Karşılaştırma"),
      ),
      body: Column(
        children: [
          Expanded(child: _buildComparisonList()),
          const RepaintBoundary(child: BannerReklamiki()),
        ],
      ),
    );
  }

  Widget _buildComparisonList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 10),
      child: Column(
        children: [
          ...List.generate(karsilastirmaBaslik.length + 2, (index) {
            if (index == 1) {
              return const Padding(
                padding: EdgeInsets.only(top: 15),
                child: RepaintBoundary(child: YerelReklamuc()),
              );
            }
            if (index == 9) {
              return const Padding(
                padding: EdgeInsets.only(top: 15),
                child: RepaintBoundary(child: YerelReklamiki()),
              );
            }

            // Reklamların eklenmesi nedeniyle indeks kaymasını düzelt
            final adjustedIndex =
                index > 1 && index < 9
                    ? index - 1
                    : index > 9
                    ? index - 2
                    : index;

            return _buildComparisonKard(adjustedIndex);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildComparisonKard(int index) {
    final baslik = karsilastirmaBaslik[index];
    final eski = _formattedValues[index * 3];
    final yeni = _formattedValues[index * 3 + 1];
    final fark = _formattedValues[index * 3 + 2];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CizgiliCerceve(
        golge: 5,
        backgroundColor: Renk.acikgri,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(baslik, style: Dekor.butonText_15_500mavi),
              ),
              Dekor.cizgi15,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildValueColumn(
                            widget.anahtarid == 1 ? "Eski Ücret" : "1. Maaş",
                            eski,
                          ),
                        ],
                      ),
                    ),
                    _ayiriciCizgi(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildValueColumn(
                            widget.anahtarid == 1 ? "Yeni Ücret" : "2. Maaş",
                            yeni,
                          ),
                        ],
                      ),
                    ),
                    _ayiriciCizgi(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_buildValueColumn("Fark", fark)],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.anahtarid == 1) ...[
                Dekor.cizgi15,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDetailRow("Zam Oranı", "% ${widget.aydetay0}"),
                      _buildDetailRow("Kıdem Farkı", "${widget.aydetay1} TL"),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _ayiriciCizgi() => Container(
    width: 2,
    height: 40,
    color: const Color.fromARGB(255, 216, 216, 216),
  );

  Widget _buildValueColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: Dekor.butonText_13_500siyah),
        const SizedBox(height: 5),
        Text(value, style: Dekor.butonText_12_500mavi),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: Dekor.butonText_13_500siyah),
        Text(value, style: Dekor.butonText_12_500mavi),
      ],
    );
  }

  final List<String> karsilastirmaBaslik = [
    'Brüt Ücret Karşılaştırma',
    'İkramiye Karşılaştırma',
    'Sosyal Haklar Karşılaştırma',
    'Toplam Brüt Karşılaştırma',
    'Sendika Kesintisi Karşılaştırma',
    'Avans Karşılaştırma',
    'Kalan Maaş Karşılaştırma',
    'Toplam Maaş Karşılaştırma',
  ];
}
