import 'package:app/Screens/anaekran_bilesenler/maaskarsilastir/karsilastirmadetay.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AylikNetUcretKarsilastirma extends StatefulWidget {
  final int sayfaId;
  final int grafiksayfaId;
  final List<String> aylarYazi;
  final List<List<List<num>>> sonListe;
  final List<num> zam;
  final List<num> kidem;

  const AylikNetUcretKarsilastirma({
    super.key,
    required this.sayfaId,
    required this.grafiksayfaId,
    required this.aylarYazi,
    required this.sonListe,
    required this.zam,
    required this.kidem,
  });

  @override
  State<AylikNetUcretKarsilastirma> createState() =>
      _AylikNetUcretKarsilastirmaState();
}

class _AylikNetUcretKarsilastirmaState
    extends State<AylikNetUcretKarsilastirma> {
  final NumberFormat _numberFormat = NumberFormat("#,##0.00", "tr_TR");

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    for (int i = 0; i < widget.aylarYazi.length + 2; i++) {
      if (i == 2) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              alignment: Alignment.center,
              child: const RepaintBoundary(child: YerelReklam()),
            ),
          ),
        );
      } else if (i == 8) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              alignment: Alignment.center,
              child: const RepaintBoundary(child: YerelReklamiki()),
            ),
          ),
        );
      } else {
        final adjustedIndex = i - ((i > 2) ? 1 : 0) - ((i > 8) ? 1 : 0);

        if (adjustedIndex < 0 || adjustedIndex >= widget.aylarYazi.length) {
          items.add(const SizedBox.shrink());
        } else {
          final baslik = widget.aylarYazi[adjustedIndex];
          final eskimetin =
              '${_numberFormat.format(widget.sonListe[adjustedIndex][7][0])} TL';
          final yenimetin =
              '${_numberFormat.format(widget.sonListe[adjustedIndex][7][1])} TL';
          final farkmetin =
              '${_numberFormat.format(widget.sonListe[adjustedIndex][7][2])} TL';

          items.add(
            _kartkarsilastirma(
              context,
              adjustedIndex,
              baslik,
              eskimetin,
              yenimetin,
              farkmetin,
            ),
          );
        }
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 50),
      child: Column(children: items),
    );
  }

  Widget _kartkarsilastirma(
    BuildContext context,
    int index,
    String baslik,
    String eski,
    String yeni,
    String fark,
  ) {
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
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        baslik,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Renk.pastelKoyuMavi,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Text(
                      "Detaylar >",
                      style: TextStyle(
                        fontSize: 15,
                        color: Renk.pastelKoyuMavi,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Dekor.cizgi15,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bilgiKolonu("Önceki Maaş", eski),
                    _ayiriciCizgi(),
                    _bilgiKolonu("Sonraki Maaş", yeni),
                    _ayiriciCizgi(),
                    _bilgiKolonu("Fark", fark),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => KarsilastirmaDetay(
                      aydetay0: widget.zam[index].toString(),
                      aydetay1: widget.kidem[index].toString(),
                      aydetay2: widget.aylarYazi[index].toString(),
                      aysayi: index,
                      sonListe: widget.sonListe,
                      anahtarid: widget.grafiksayfaId,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bilgiKolonu(String baslik, String deger) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          baslik,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(
          deger,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Renk.pastelKoyuMavi,
          ),
        ),
      ],
    );
  }

  Widget _ayiriciCizgi() => Container(
    width: 2,
    height: 40,
    color: const Color.fromARGB(255, 216, 216, 216),
  );
}
