import 'package:app/Screens/anaekran_bilesenler/gelir_gider/islem_sayfasi.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/model_iki.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/tarih.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

class GrafikYardimcisi {
  static Widget gunlukBarGrafikOlustur(
    BuildContext context,
    List<IslemModel> islemler, {
    DateTime? baslangicTarihi,
    required IslemTuru seciliTur,
  }) {
    final secilenGun = baslangicTarihi ?? DateTime.now();
    final gunTarihi = DateTime(
      secilenGun.year,
      secilenGun.month,
      secilenGun.day,
    );

    // 6 saat dilimi tanımla
    final saatAraliklari = [
      {'baslangic': 4, 'bitis': 10, 'etiket': '04:00-10:00'},
      {'baslangic': 10, 'bitis': 14, 'etiket': '10:00-14:00'},
      {'baslangic': 14, 'bitis': 18, 'etiket': '14:00-18:00'},
      {'baslangic': 18, 'bitis': 22, 'etiket': '18:00-22:00'},
      {'baslangic': 22, 'bitis': 2, 'etiket': '22:00-02:00'},
      {'baslangic': 2, 'bitis': 4, 'etiket': '02:00-04:00'},
    ];

    final gelirVerileri = List<double>.filled(6, 0.0);
    final giderVerileri = List<double>.filled(6, 0.0);
    final etiketler = saatAraliklari.map((a) => a['etiket'] as String).toList();

    for (final islem in islemler) {
      final islemTarihi = islem.tarih;
      if (islemTarihi.year == gunTarihi.year &&
          islemTarihi.month == gunTarihi.month &&
          islemTarihi.day == gunTarihi.day) {
        final saat = islemTarihi.hour;
        for (int i = 0; i < saatAraliklari.length; i++) {
          final aralik = saatAraliklari[i];
          final baslangic = aralik['baslangic'] as int;
          final bitis = aralik['bitis'] as int;

          bool saatAralikta;
          if (baslangic > bitis) {
            // Gece yarısını aşan aralıklar için
            saatAralikta = saat >= baslangic || saat < bitis;
          } else {
            saatAralikta = saat >= baslangic && saat < bitis;
          }

          if (saatAralikta) {
            if (islem.giderMi) {
              giderVerileri[i] += islem.miktar;
            } else {
              gelirVerileri[i] += islem.miktar;
            }
            break;
          }
        }
      }
    }

    return BarGrafik(
      gelirDegerler: gelirVerileri,
      giderDegerler: giderVerileri,
      etiketler: etiketler,
      seciliTur: seciliTur,
      zamanAraligi: ZamanAraligi.gunluk,
    );
  }

  static Widget haftalikBarGrafikOlustur(
    BuildContext context,
    List<IslemModel> islemler, {
    DateTime? baslangicTarihi,
    required IslemTuru seciliTur,
  }) {
    final secilenHafta = baslangicTarihi ?? DateTime.now();
    final ilkGun = TarihYardimci.haftaninIlkGunu(secilenHafta);
    final haftaninGunleri = List.generate(
      7,
      (i) => DateTime(ilkGun.year, ilkGun.month, ilkGun.day + i),
    );

    final gelirVeri = <DateTime, double>{};
    final giderVeri = <DateTime, double>{};

    // Verileri topla
    for (var islem in islemler) {
      final tarih = DateTime(
        islem.tarih.year,
        islem.tarih.month,
        islem.tarih.day,
      );
      if (islem.giderMi) {
        giderVeri.update(
          tarih,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      } else {
        gelirVeri.update(
          tarih,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      }
    }

    // Etiketleri ve değerleri hazırla
    final etiketler =
        haftaninGunleri.map((d) => DateFormat('E', 'tr_TR').format(d)).toList();

    final gelirDegerler =
        haftaninGunleri.map((d) => gelirVeri[d] ?? 0.0).toList();

    final giderDegerler =
        haftaninGunleri.map((d) => giderVeri[d] ?? 0.0).toList();

    // Geçersiz veri kontrolü
    if (gelirDegerler.isEmpty ||
        giderDegerler.isEmpty ||
        etiketler.isEmpty ||
        gelirDegerler.any((v) => v.isNaN) ||
        giderDegerler.any((v) => v.isNaN)) {
      return const Center(
        child: Text(
          'Gösterilecek veri bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BarGrafik(
      gelirDegerler: gelirDegerler,
      giderDegerler: giderDegerler,
      etiketler: etiketler,
      seciliTur: seciliTur,
      zamanAraligi: ZamanAraligi.haftalik,
    );
  }

  static Widget aylikBarGrafikOlustur(
    BuildContext context,
    List<IslemModel> islemler, {
    DateTime? baslangicTarihi,
    required IslemTuru seciliTur,
  }) {
    final secilenAy = baslangicTarihi ?? DateTime.now();
    final ayinGunleri = List.generate(
      DateTime(secilenAy.year, secilenAy.month + 1, 0).day,
      (i) => DateTime(secilenAy.year, secilenAy.month, i + 1),
    );

    final gelirVeri = <DateTime, double>{};
    final giderVeri = <DateTime, double>{};

    for (var gun in ayinGunleri) {
      gelirVeri[gun] = 0.0;
      giderVeri[gun] = 0.0;
    }

    for (var islem in islemler) {
      final tarih = DateTime(
        islem.tarih.year,
        islem.tarih.month,
        islem.tarih.day,
      );
      if (islem.giderMi) {
        giderVeri.update(
          tarih,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      } else {
        gelirVeri.update(
          tarih,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      }
    }

    // Haftalık gruplama
    final haftalikGruplar = <String, double>{};
    final haftalikGiderGruplar = <String, double>{};
    final haftalikEtiketler = <String>[];

    for (int i = 0; i < ayinGunleri.length; i += 7) {
      final haftaBaslangic = i;
      final haftaBitis =
          (i + 6) < ayinGunleri.length ? (i + 6) : ayinGunleri.length - 1;
      final haftaKey =
          '${DateFormat('d').format(ayinGunleri[haftaBaslangic])}-${DateFormat('d MMM').format(ayinGunleri[haftaBitis])}';

      double haftalikGelir = 0;
      double haftalikGider = 0;

      for (int j = haftaBaslangic; j <= haftaBitis; j++) {
        haftalikGelir += gelirVeri[ayinGunleri[j]] ?? 0;
        haftalikGider += giderVeri[ayinGunleri[j]] ?? 0;
      }

      haftalikGruplar[haftaKey] = haftalikGelir;
      haftalikGiderGruplar[haftaKey] = haftalikGider;
      haftalikEtiketler.add(haftaKey);
    }

    final gelirDegerler =
        haftalikEtiketler.map((k) => haftalikGruplar[k] ?? 0.0).toList();
    final giderDegerler =
        haftalikEtiketler.map((k) => haftalikGiderGruplar[k] ?? 0.0).toList();

    // NaN değerleri kontrolü
    if (gelirDegerler.any((v) => v.isNaN) ||
        giderDegerler.any((v) => v.isNaN)) {
      return const Center(child: Text('Geçersiz veri tespit edildi'));
    }

    return BarGrafik(
      gelirDegerler: gelirDegerler,
      giderDegerler: giderDegerler,
      etiketler: haftalikEtiketler,
      seciliTur: seciliTur,
      zamanAraligi: ZamanAraligi.aylik,
    );
  }

  static Widget yillikBarGrafikOlustur(
    BuildContext context,
    List<IslemModel> islemler, {
    DateTime? baslangicTarihi,
    required IslemTuru seciliTur,
  }) {
    final secilenYil = baslangicTarihi ?? DateTime.now();
    final tumAylar = List.generate(12, (i) => DateTime(secilenYil.year, i + 1));

    final gelirVeri = <String, double>{};
    final giderVeri = <String, double>{};

    for (var ay in tumAylar) {
      final key = DateFormat('MMM', 'tr_TR').format(ay);
      gelirVeri[key] = 0.0;
      giderVeri[key] = 0.0;
    }

    for (var islem in islemler) {
      final key = DateFormat('MMM', 'tr_TR').format(islem.tarih);
      if (islem.giderMi) {
        giderVeri.update(
          key,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      } else {
        gelirVeri.update(
          key,
          (v) => v + islem.miktar,
          ifAbsent: () => islem.miktar,
        );
      }
    }

    final etiketler =
        tumAylar.map((a) => DateFormat('MMM', 'tr_TR').format(a)).toList();
    final gelirDegerler = etiketler.map((k) => gelirVeri[k] ?? 0.0).toList();
    final giderDegerler = etiketler.map((k) => giderVeri[k] ?? 0.0).toList();

    // NaN değerleri kontrolü
    if (gelirDegerler.any((v) => v.isNaN) ||
        giderDegerler.any((v) => v.isNaN)) {
      return const Center(child: Text('Geçersiz veri tespit edildi'));
    }

    return BarGrafik(
      gelirDegerler: gelirDegerler,
      giderDegerler: giderDegerler,
      etiketler: etiketler,
      seciliTur: seciliTur,
      zamanAraligi: ZamanAraligi.yillik,
    );
  }
}

class BarGrafik extends StatelessWidget {
  final List<double> gelirDegerler;
  final List<double> giderDegerler;
  final List<String> etiketler;
  final IslemTuru seciliTur;
  final ZamanAraligi zamanAraligi; // Yeni eklenen parametre

  const BarGrafik({
    super.key,
    required this.gelirDegerler,
    required this.giderDegerler,
    required this.etiketler,
    required this.seciliTur,
    required this.zamanAraligi,
  }) : assert(gelirDegerler.length == giderDegerler.length),
       assert(gelirDegerler.length == etiketler.length);

  @override
  Widget build(BuildContext context) {
    try {
      final maxDeger = _calculateMaxValue();
      final cubukKalinligi = _calculateBarThickness();

      return Chart(
        layers: [
          _buildAxisLayer(maxDeger),
          _buildBarsLayer(cubukKalinligi),
          _buildTooltipLayer(),
        ],
      );
    } catch (e) {
      return const Center(
        child: Text(
          'Grafik oluşturulamadı',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  double _calculateMaxValue() {
    try {
      final values =
          seciliTur == IslemTuru.tumu
              ? [...gelirDegerler, ...giderDegerler]
              : (seciliTur == IslemTuru.giderler
                  ? giderDegerler
                  : gelirDegerler);

      if (values.isEmpty) return 100.0;

      final maxVal = values.reduce((a, b) => a > b ? a : b);
      return maxVal <= 0 ? 100.0 : maxVal * 1.1;
    } catch (e) {
      return 100.0;
    }
  }

  double _calculateBarThickness() {
    // Yıllık ve tümü seçeneğinde daha ince çubuklar
    if (zamanAraligi == ZamanAraligi.yillik && seciliTur == IslemTuru.tumu) {
      return 10.0;
    }
    return 15.0; // Diğer durumlarda normal kalınlık
  }

  ChartAxisLayer _buildAxisLayer(double maxValue) {
    return ChartAxisLayer(
      settings: ChartAxisSettings(
        x: ChartAxisSettingsAxis(
          frequency: 1.0,
          max: etiketler.length.toDouble() - 1,
          min: 0.0,
          textStyle: const TextStyle(color: Renk.pastelKoyuMavi, fontSize: 10),
        ),
        y: ChartAxisSettingsAxis(
          frequency: _calculateYFrequency(maxValue),
          max: maxValue,
          min: 0.0,
          textStyle: const TextStyle(color: Renk.pastelKoyuMavi, fontSize: 10),
        ),
      ),
      labelX: (value) {
        final index = value.toInt();
        if (index < 0 || index >= etiketler.length) return '';

        // Günlük grafikte saat aralıklarını kısalt
        if (zamanAraligi == ZamanAraligi.gunluk) {
          return etiketler[index]
              .replaceAll(':00', '') // 04:00-10:00 -> 04-10
              .replaceAll('-0', '-'); // 04-10:00 -> 04-10
        }
        return etiketler[index];
      },
      labelY: (value) => '${value.toInt()} ₺',
    );
  }

  ChartGroupBarLayer _buildBarsLayer(double thickness) {
    return ChartGroupBarLayer(
      items: List.generate(
        etiketler.length,
        (index) =>
            seciliTur == IslemTuru.tumu
                ? [
                  ChartGroupBarDataItem(
                    color: Renk.pastelAcikMavi,
                    value: gelirDegerler[index],
                    x: index.toDouble(),
                  ),
                  ChartGroupBarDataItem(
                    color: Renk.pastelKoyuMavi,
                    value: giderDegerler[index],
                    x: index.toDouble(),
                  ),
                ]
                : [
                  ChartGroupBarDataItem(
                    color:
                        seciliTur == IslemTuru.giderler
                            ? Renk.pastelKoyuMavi
                            : Renk.pastelAcikMavi,
                    value:
                        seciliTur == IslemTuru.giderler
                            ? giderDegerler[index]
                            : gelirDegerler[index],
                    x: index.toDouble(),
                  ),
                ],
      ),
      settings: ChartGroupBarSettings(
        thickness: thickness,
        radius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  ChartTooltipLayer _buildTooltipLayer() {
    return ChartTooltipLayer(
      shape:
          () => ChartTooltipBarShape<ChartGroupBarDataItem>(
            backgroundColor: const Color.fromARGB(255, 250, 250, 250),
            currentPos: (item) => item.currentValuePos,
            currentSize: (item) => item.currentValueSize,
            onTextValue: (item) => '${item.value.toStringAsFixed(2)} ₺',
            marginBottom: 8.0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(color: Colors.black, fontSize: 12),
          ),
    );
  }

  double _calculateYFrequency(double maxValue) {
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    if (maxValue <= 25000) return 5000;
    if (maxValue <= 50000) return 10000;
    if (maxValue <= 100000) return 20000;
    if (maxValue <= 200000) return 50000;
    if (maxValue <= 500000) return 100000;
    if (maxValue <= 1000000) return 200000;
    if (maxValue <= 5000000) return 1000000;
    return 2000000;
  }
}
