// lib/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart
import 'package:app/Screens/anaekran_bilesenler/veriler/girisveriler.dart';
import 'package:flutter/foundation.dart';

class MerkeziHesaplamaServisi {
  // Singleton pattern
  static final MerkeziHesaplamaServisi _instance =
      MerkeziHesaplamaServisi._internal();
  factory MerkeziHesaplamaServisi() => _instance;
  MerkeziHesaplamaServisi._internal();

  // ==================== TEMEL BORDRO HESAPLAMA ====================
  Map<String, double> hesapBordro({
    required double brut,
    required String calisanTipi,
    required double vergiOrani,
    DateTime? tarih,
    int? calismaGunSayisi,
  }) {
    final hesaplamaTarihi = tarih ?? DateTime.now();
    final int ayIndex = hesaplamaTarihi.month - 1;

    // 1. YILI AYIKLA VE GÜNCELLE
    final int yil = hesaplamaTarihi.year;
    GirisVerileriManager.seciliYil = yil;

    // DEBUG
    if (kDebugMode) {
      debugPrint('=== HESAP BORDRO BAŞLANGIÇ (ÇÖZÜM 3) ===');
      debugPrint('Tarih: $hesaplamaTarihi');
      debugPrint('Brüt: $brut');
      debugPrint('Çalışma gün sayısı: $calismaGunSayisi');
    }

    // 2. SGK İşçi Payı
    double sgkOrani = switch (calisanTipi) {
      'Normal' => 14.0,
      'Emekli' => 7.5,
      'SGK Yok' => 0.0,
      _ => 14.0,
    };
    double sgk = brut * (sgkOrani / 100);

    // 3. İşsizlik İşçi Payı
    double issizlikOrani = calisanTipi == 'Normal' ? 1.0 : 0.0;
    double issizlik = brut * (issizlikOrani / 100);

    // 4. Gelir Vergisi Matrahı
    double matrah = brut - sgk - issizlik;

    // 5. Gelir Vergisi
    double gelirVergisi = matrah * (vergiOrani / 100);

    // 6. Damga Vergisi
    double damgaVergisi = brut * 0.00759;

    // 7. AGİ İstisnası - YILA GÖRE (ÇÖZÜM 3)
    double agiIstisnasi = 0.0;
    final agiListesi = GirisVerileriManager.gelirVergisiIstisnasi;

    if (agiListesi.isNotEmpty && ayIndex < agiListesi.length) {
      double aylikAgi = agiListesi[ayIndex];

      if (kDebugMode) {
        debugPrint('AGİ Hesaplama (ÇÖZÜM 3):');
        debugPrint('  Aylık AGİ: $aylikAgi TL');
      }

      if (calismaGunSayisi != null && calismaGunSayisi > 0) {
        // ÇÖZÜM 3: (aylık × gün) ÷ 30 formülü
        // Bu formülle 30 gün için tam aylık değer elde edilir
        agiIstisnasi = (aylikAgi * calismaGunSayisi) / 30.0;

        if (kDebugMode) {
          debugPrint('  $calismaGunSayisi gün için:');
          debugPrint(
            '    Formül: ($aylikAgi × $calismaGunSayisi) ÷ 30 = $agiIstisnasi TL',
          );

          // 30 gün kontrolü
          if (calismaGunSayisi == 30) {
            debugPrint('    ✅ 30 gün için AGİ: $agiIstisnasi TL');
            debugPrint('    ✅ Aylık AGİ: $aylikAgi TL');
            debugPrint('    ✅ Fark: ${(agiIstisnasi - aylikAgi).abs()} TL');
          }
        }
      } else {
        // Tek gün için: aylık ÷ 30
        agiIstisnasi = aylikAgi / 30.0;
        if (kDebugMode) {
          debugPrint('  1 gün için: $aylikAgi ÷ 30 = $agiIstisnasi TL');
        }
      }
    }

    // 8. Damga Vergisi İstisnası - YILA GÖRE (ÇÖZÜM 3)
    double damgaIstisnasi = 0.0;
    final damgaListesi = GirisVerileriManager.damgaVergisiIstisnasi;

    if (damgaListesi.isNotEmpty && ayIndex < damgaListesi.length) {
      double aylikDamgaIstisnasi = damgaListesi[ayIndex];

      if (calismaGunSayisi != null && calismaGunSayisi > 0) {
        // Aynı çözüm: (aylık × gün) ÷ 30
        damgaIstisnasi = (aylikDamgaIstisnasi * calismaGunSayisi) / 30.0;

        if (kDebugMode) {
          debugPrint('Damga İstisnası (ÇÖZÜM 3):');
          debugPrint('  $calismaGunSayisi gün için:');
          debugPrint(
            '    Formül: ($aylikDamgaIstisnasi × $calismaGunSayisi) ÷ 30 = $damgaIstisnasi TL',
          );

          if (calismaGunSayisi == 30) {
            debugPrint('    ✅ 30 gün için Damga: $damgaIstisnasi TL');
            debugPrint('    ✅ Aylık Damga: $aylikDamgaIstisnasi TL');
            debugPrint(
              '    ✅ Fark: ${(damgaIstisnasi - aylikDamgaIstisnasi).abs()} TL',
            );
          }
        }
      } else {
        damgaIstisnasi = aylikDamgaIstisnasi / 30.0;
      }
    }

    // 9. İstisna sınırları
    agiIstisnasi = agiIstisnasi.clamp(0, gelirVergisi);
    damgaIstisnasi = damgaIstisnasi.clamp(0, damgaVergisi);

    // 10. Uygulanan Vergiler
    double uygulananGelirVergisi = (gelirVergisi - agiIstisnasi).clamp(
      0,
      gelirVergisi,
    );
    double uygulananDamgaVergisi = (damgaVergisi - damgaIstisnasi).clamp(
      0,
      damgaVergisi,
    );

    // 11. Net Ücret (BES olmadan)
    double toplamKesinti =
        sgk + issizlik + uygulananGelirVergisi + uygulananDamgaVergisi;
    double net = brut - toplamKesinti;

    if (kDebugMode) {
      debugPrint('=== HESAP SONUÇLARI (ÇÖZÜM 3) ===');
      debugPrint('AGİ istisnası: $agiIstisnasi TL');
      debugPrint('Damga istisnası: $damgaIstisnasi TL');
      debugPrint('Net: $net TL');
      debugPrint('=== HESAP BORDRO SON ===');
    }

    return {
      'brut': brut,
      'net': net,
      'sgk': sgk,
      'sgk_yuzde': sgkOrani,
      'issizlik': issizlik,
      'issizlik_yuzde': issizlikOrani,
      'vergi': gelirVergisi,
      'uygulananVergi': uygulananGelirVergisi,
      'uygulananVergiYuzde':
          brut > 0 ? (uygulananGelirVergisi / brut) * 100 : 0.0,
      'damga': damgaVergisi,
      'uygulananDamga': uygulananDamgaVergisi,
      'uygulananDamgaYuzde':
          brut > 0 ? (uygulananDamgaVergisi / brut) * 100 : 0.0,
      'agi': agiIstisnasi,
      'damgaIstisnasi': damgaIstisnasi,
      'toplam_kesinti': toplamKesinti,
    };
  }

  // ==================== GÜNLÜK TOPLU BORDRO HESAPLAMA ====================
  Map<String, double> gunlukTopluBordro({
    required List<double> brutListesi,
    required String calisanTipi,
    required double vergiOrani,
    required DateTime ayTarihi,
    required int efektifGunSayisi,
  }) {
    double toplamBrut = brutListesi.fold(0.0, (sum, brut) => sum + brut);

    if (toplamBrut <= 0) {
      return _bosBordroSonucu();
    }

    final int ayIndex = ayTarihi.month - 1;

    // YILI AYIKLA VE GÜNCELLE
    final int yil = ayTarihi.year;
    GirisVerileriManager.seciliYil = yil;

    // Aylık AGİ ve Damga istisnası - YILA GÖRE
    final agiListesi = GirisVerileriManager.gelirVergisiIstisnasi;
    final damgaListesi = GirisVerileriManager.damgaVergisiIstisnasi;

    double aylikAgiIstisnasi =
        ayIndex < agiListesi.length ? agiListesi[ayIndex] : 0.0;

    double aylikDamgaIstisnasi =
        ayIndex < damgaListesi.length ? damgaListesi[ayIndex] : 0.0;

    // ÇÖZÜM 3: Günlere göre oransal hesaplama
    // Formül: (aylık × gün) ÷ 30
    double uygulanacakAgiIstisnasi =
        (aylikAgiIstisnasi * efektifGunSayisi) / 30.0;
    double uygulanacakDamgaIstisnasi =
        (aylikDamgaIstisnasi * efektifGunSayisi) / 30.0;

    if (kDebugMode) {
      debugPrint('=== GÜNLÜK TOPLU BORDRO (ÇÖZÜM 3) ===');
      debugPrint('Etkin gün sayısı: $efektifGunSayisi');
      debugPrint('Aylık AGİ: $aylikAgiIstisnasi TL');
      debugPrint('Aylık Damga: $aylikDamgaIstisnasi TL');
      debugPrint(
        'Hesaplanan AGİ: ($aylikAgiIstisnasi × $efektifGunSayisi) ÷ 30 = $uygulanacakAgiIstisnasi TL',
      );
      debugPrint(
        'Hesaplanan Damga: ($aylikDamgaIstisnasi × $efektifGunSayisi) ÷ 30 = $uygulanacakDamgaIstisnasi TL',
      );

      // 30 gün kontrolü
      if (efektifGunSayisi == 30) {
        debugPrint(
          '✅ 30 gün AGİ: $uygulanacakAgiIstisnasi TL = Aylık: $aylikAgiIstisnasi TL',
        );
        debugPrint(
          '✅ 30 gün Damga: $uygulanacakDamgaIstisnasi TL = Aylık: $aylikDamgaIstisnasi TL',
        );
      }
    }

    // SGK ve İşsizlik
    double sgkOrani = switch (calisanTipi) {
      'Normal' => 14.0,
      'Emekli' => 7.5,
      'SGK Yok' => 0.0,
      _ => 14.0,
    };
    double sgk = toplamBrut * (sgkOrani / 100);
    double issizlik = calisanTipi == 'Normal' ? toplamBrut * 0.01 : 0.0;

    // Vergi hesaplamaları
    double matrah = toplamBrut - sgk - issizlik;
    double gelirVergisi = matrah * (vergiOrani / 100);
    double damgaVergisi = toplamBrut * 0.00759;

    // İstisna sınırları
    double uygulanacakAgiIstisnasiKisitli = uygulanacakAgiIstisnasi.clamp(
      0,
      gelirVergisi,
    );
    double uygulanacakDamgaIstisnasiKisitli = uygulanacakDamgaIstisnasi.clamp(
      0,
      damgaVergisi,
    );

    double uygulananGelirVergisi =
        gelirVergisi - uygulanacakAgiIstisnasiKisitli;
    double uygulananDamgaVergisi =
        damgaVergisi - uygulanacakDamgaIstisnasiKisitli;

    double toplamKesinti =
        sgk + issizlik + uygulananGelirVergisi + uygulananDamgaVergisi;
    double net = toplamBrut - toplamKesinti;

    return {
      'brut': toplamBrut,
      'net': net,
      'sgk': sgk,
      'sgk_yuzde': sgkOrani,
      'issizlik': issizlik,
      'issizlik_yuzde': calisanTipi == 'Normal' ? 1.0 : 0.0,
      'vergi': gelirVergisi,
      'damga': damgaVergisi,
      'uygulananVergi': uygulananGelirVergisi,
      'uygulananVergiYuzde':
          toplamBrut > 0 ? (uygulananGelirVergisi / toplamBrut) * 100 : 0.0,
      'uygulananDamga': uygulananDamgaVergisi,
      'uygulananDamgaYuzde':
          toplamBrut > 0 ? (uygulananDamgaVergisi / toplamBrut) * 100 : 0.0,
      'agi': uygulanacakAgiIstisnasiKisitli,
      'damgaIstisnasi': uygulanacakDamgaIstisnasiKisitli,
      'toplam_kesinti': toplamKesinti,
    };
  }

  // ==================== DİĞER METOTLAR (Aynı kalacak) ====================

  double calismaBrutHesapla({
    required double calismaSaati,
    required int kaydedilenIndex,
    required double kaydedilenUcret,
  }) {
    if (kaydedilenIndex == 0) {
      return kaydedilenUcret * calismaSaati;
    } else if (kaydedilenIndex == 1) {
      return kaydedilenUcret * calismaSaati;
    } else {
      double gunlukUcret = kaydedilenUcret / 30.0;
      return gunlukUcret * calismaSaati;
    }
  }

  double mesaiBrutHesapla({
    required double mesaiSaati,
    required int kaydedilenIndex,
    required double kaydedilenUcret,
    required double mesaiYuzde,
  }) {
    double normalBrut = calismaBrutHesapla(
      calismaSaati: mesaiSaati,
      kaydedilenIndex: kaydedilenIndex,
      kaydedilenUcret: kaydedilenUcret,
    );

    return normalBrut + (normalBrut * (mesaiYuzde / 100));
  }

  double besKesintisiHesapla({
    required double brut,
    required bool besAktif,
    required double besOrani,
  }) {
    if (!besAktif) return 0.0;
    return brut * (besOrani / 100);
  }

  Map<String, double> _bosBordroSonucu() {
    return {
      'brut': 0.0,
      'net': 0.0,
      'sgk': 0.0,
      'sgk_yuzde': 0.0,
      'issizlik': 0.0,
      'issizlik_yuzde': 0.0,
      'vergi': 0.0,
      'damga': 0.0,
      'uygulananVergi': 0.0,
      'uygulananVergiYuzde': 0.0,
      'uygulananDamga': 0.0,
      'uygulananDamgaYuzde': 0.0,
      'agi': 0.0,
      'damgaIstisnasi': 0.0,
      'toplam_kesinti': 0.0,
    };
  }

  String saatCalismaAyikla(String ayiklaiki) {
    final parts = ayiklaiki.split(' ');
    return parts.isNotEmpty ? parts[0] : '';
  }

  String yuzdeAyikla(String ayiklaBir) {
    if (ayiklaBir.isEmpty || ayiklaBir.length < 2) return '0';
    return ayiklaBir.startsWith('%')
        ? ayiklaBir.replaceAll('%', '').trim()
        : ayiklaBir;
  }
}
