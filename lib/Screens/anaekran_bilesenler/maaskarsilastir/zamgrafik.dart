import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ZamGrafikWidget extends StatefulWidget {
  final List<List<List<num>>> sonListe;
  final int sayfano;

  const ZamGrafikWidget({
    super.key,
    required this.sonListe,
    required this.sayfano,
  });

  @override
  State<ZamGrafikWidget> createState() => _ZamGrafikWidgetState();
}

class _ZamGrafikWidgetState extends State<ZamGrafikWidget> {
  late final List<num> grafikzam = List.generate(12, (index) => 0);
  late final List<num> grafikeskimaas = List.generate(12, (index) => 0);
  late final List<num> zamtoplammaas = List.generate(12, (index) => 0);
  late final List<double> netMaasWidths = List.filled(12, 0.0);

  @override
  void initState() {
    super.initState();

    _initializeData();
  }

  void _initializeData() {
    for (int i = 0; i < 12; i++) {
      grafikzam[i] = widget.sonListe[i][7][2];
      grafikeskimaas[i] = widget.sonListe[i][7][0];
      zamtoplammaas[i] = widget.sonListe[i][7][1];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        for (int i = 0; i < 12; i++) {
          double toplam =
              widget.sayfano == 1
                  ? double.parse(grafikzam[i].toString()) +
                      double.parse(grafikeskimaas[i].toString())
                  : double.parse(zamtoplammaas[i].toString()) +
                      double.parse(grafikeskimaas[i].toString());
          if (toplam == 0) {
            toplam = 1;
          }
          netMaasWidths[i] =
              widget.sayfano == 1
                  ? (grafikzam[i] / toplam) * MediaQuery.of(context).size.width
                  : zamtoplammaas[i] > 0
                  ? (grafikeskimaas[i] / toplam) *
                      MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.91;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 15, left: 5, right: 5),
      child: Column(
        children: [
          ...List.generate(14, (index) {
            if (index == 1) {
              return const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: RepaintBoundary(child: YerelReklamuc()),
              );
            }
            if (index == 11) {
              return const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: RepaintBoundary(child: YerelReklamiki()),
              );
            }
            // Reklamların eklenmesi nedeniyle indeks kaymasını düzelt
            final adjustedIndex =
                index > 1 && index < 11
                    ? index - 1
                    : index > 11
                    ? index - 2
                    : index;

            return _buildMonthComparison(adjustedIndex);
          }),
          const SizedBox(height: 80), // Alt kısımda boşluk bırakıyoruz
        ],
      ),
    );
  }

  Widget _buildMonthComparison(int index) {
    final toplam =
        widget.sayfano == 1
            ? double.parse(grafikzam[index].toString()) +
                double.parse(grafikeskimaas[index].toString())
            : double.parse(zamtoplammaas[index].toString()) +
                double.parse(grafikeskimaas[index].toString());
    final netMaasRatio =
        widget.sayfano == 1
            ? grafikzam[index] / toplam
            : grafikeskimaas[index] / toplam;
    final kesintilerRatio =
        widget.sayfano == 1
            ? grafikeskimaas[index] == 0 || grafikzam[index] == 0
                ? 1
                : grafikeskimaas[index] / toplam
            : grafikeskimaas[index] == 0
            ? 1
            : zamtoplammaas[index] / toplam;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(aylarYazi[index], style: Dekor.butonText_14_500mavi),
              if (widget.sayfano == 1)
                Row(
                  children: [
                    const Text(
                      'Eski Maaş : ',
                      style: Dekor.butonText_11_500mavi,
                    ),
                    Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(grafikeskimaas[index])} TL',
                      style: Dekor.butonText_11_500siyah,
                    ),
                  ],
                ),
            ],
          ),
        ),
        Stack(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  width: netMaasWidths[index],
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Renk.pastelAcikMavi, Renk.pastelKoyuMavi],
                      begin: Alignment(1.0, -1.0),
                      end: Alignment(1.0, 1.0),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.sayfano == 1
                          ? '% ${(netMaasRatio * 100).toStringAsFixed(1)}'
                          : '${NumberFormat("#,##0.00", "tr_TR").format(grafikeskimaas[index])} TL',
                      style: Dekor.butonText_12_500beyaz,
                    ),
                  ),
                ),
                if (kesintilerRatio > 0)
                  Expanded(
                    flex: (kesintilerRatio * 100).round(),
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Renk.pastelAcikMavi, Renk.pastelAcikMavi],
                          begin: Alignment(1.0, -1.0),
                          end: Alignment(1.0, 1.0),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.0),
                          bottomRight: Radius.circular(5.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.sayfano == 1
                              ? NumberFormat(
                                "#,##0.00",
                                "tr_TR",
                              ).format(grafikzam[index])
                              : '${NumberFormat("#,##0.00", "tr_TR").format(zamtoplammaas[index])} TL',
                          style: Dekor.butonText_12_500beyaz,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        widget.sayfano == 1
            ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Yeni Maaş Toplam : ',
                    style: Dekor.butonText_11_500mavi,
                  ),
                  Text(
                    '${NumberFormat("#,##0.00", "tr_TR").format(zamtoplammaas[index])} TL',
                    style: Dekor.butonText_11_500siyah,
                  ),
                ],
              ),
            )
            : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Maaş Farkı : ',
                    style: Dekor.butonText_11_500siyah,
                  ),
                  Text(
                    '${NumberFormat("#,##0.00", "tr_TR").format(grafikzam[index])} TL',
                    style: Dekor.butonText_11_500siyah,
                  ),
                ],
              ),
            ),
        Dekor.cizgi15,
      ],
    );
  }

  final List<String> aylarYazi = [
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
