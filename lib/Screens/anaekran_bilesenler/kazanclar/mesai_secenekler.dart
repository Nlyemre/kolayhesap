// lib/Screens/anaekran_bilesenler/kazanclar/widgets/mesai_secenekler.dart
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class MesaiSecenekler extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onTipDegisti;
  final String calisanTipi;
  final CalismaHesaplama calismaHesaplama;

  const MesaiSecenekler({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onTipDegisti,
    required this.calisanTipi,
    required this.calismaHesaplama,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(MesaiHesaplama.butonyazi.length, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: ButonlarRawChip(
                    isSelected: selectedIndex == index,
                    text: MesaiHesaplama.butonyazi[index],
                    onSelected: () {
                      onIndexChanged(index);
                      onTipDegisti();
                    },
                    height: 40,
                  ),
                ),
              );
            }),
          ),

          selectedIndex == 0
              ? buildSaatUcret()
              : selectedIndex == 1
              ? buildGunlukUcret()
              : buildAylikUcret(),
        ],
      ),
    );
  }

  Widget buildSaatUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
      child: MetinKutusu(
        controller: calismaHesaplama.saatUcretiSec,
        labelText: 'Saat Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) {},
        clearButtonVisible: true,
      ),
    );
  }

  Widget buildGunlukUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
      child: MetinKutusu(
        controller: calismaHesaplama.gunlukUcretiSec,
        labelText: 'Günlük Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) {},
        clearButtonVisible: true,
      ),
    );
  }

  Widget buildAylikUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
      child: MetinKutusu(
        controller: calismaHesaplama.aylikUcretiSec,
        labelText: 'Aylık Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) {},
        clearButtonVisible: true,
      ),
    );
  }
}
