// lib/Screens/anaekran_bilesenler/kazanclar/data_servisi.dart
import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/veri_senkronizasyonu.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';
import 'calisma_hesapla.dart';

// ==================== MODEL SINIFLARI ====================

class AylikVeri {
  final double brutKazanc;
  final double netKazanc;
  final int calismaGunSayisi;
  final int mesaiGunSayisi;
  final int efektifGunSayisi;
  final double toplamCalismaSaati;
  final double toplamMesaiSaati;
  final KesintiDetaylari kesintiDetaylari;
  final String seciliAyIsmi;

  const AylikVeri({
    required this.brutKazanc,
    required this.netKazanc,
    required this.calismaGunSayisi,
    required this.mesaiGunSayisi,
    required this.efektifGunSayisi,
    required this.toplamCalismaSaati,
    required this.toplamMesaiSaati,
    required this.kesintiDetaylari,
    required this.seciliAyIsmi,
  });

  factory AylikVeri.bos() => AylikVeri(
    brutKazanc: 0.0,
    netKazanc: 0.0,
    calismaGunSayisi: 0,
    mesaiGunSayisi: 0,
    efektifGunSayisi: 0,
    toplamCalismaSaati: 0.0,
    toplamMesaiSaati: 0.0,
    kesintiDetaylari: KesintiDetaylari.bos(),
    seciliAyIsmi: '',
  );
}

class KesintiDetaylari {
  final double brut;
  final double net;
  final double sgk;
  final double sgkYuzde;
  final double issizlik;
  final double issizlikYuzde;
  final double vergi;
  final double damga;
  final double uygulananVergi;
  final double uygulananVergiYuzde;
  final double uygulananDamga;
  final double uygulananDamgaYuzde;
  final double agi;
  final double damgaIstisnasi;
  final double bes;
  final double avans;

  const KesintiDetaylari({
    required this.brut,
    required this.net,
    required this.sgk,
    required this.sgkYuzde,
    required this.issizlik,
    required this.issizlikYuzde,
    required this.vergi,
    required this.damga,
    required this.uygulananVergi,
    required this.uygulananVergiYuzde,
    required this.uygulananDamga,
    required this.uygulananDamgaYuzde,
    required this.agi,
    required this.damgaIstisnasi,
    required this.bes,
    this.avans = 0.0,
  });

  factory KesintiDetaylari.bos() => const KesintiDetaylari(
    brut: 0.0,
    net: 0.0,
    sgk: 0.0,
    sgkYuzde: 0.0,
    issizlik: 0.0,
    issizlikYuzde: 0.0,
    vergi: 0.0,
    damga: 0.0,
    uygulananVergi: 0.0,
    uygulananVergiYuzde: 0.0,
    uygulananDamga: 0.0,
    uygulananDamgaYuzde: 0.0,
    agi: 0.0,
    damgaIstisnasi: 0.0,
    bes: 0.0,
    avans: 0.0,
  );

  KesintiDetaylari copyWith({
    double? brut,
    double? net,
    double? sgk,
    double? sgkYuzde,
    double? issizlik,
    double? issizlikYuzde,
    double? vergi,
    double? damga,
    double? uygulananVergi,
    double? uygulananVergiYuzde,
    double? uygulananDamga,
    double? uygulananDamgaYuzde,
    double? agi,
    double? damgaIstisnasi,
    double? bes,
    double? avans,
  }) {
    return KesintiDetaylari(
      brut: brut ?? this.brut,
      net: net ?? this.net,
      sgk: sgk ?? this.sgk,
      sgkYuzde: sgkYuzde ?? this.sgkYuzde,
      issizlik: issizlik ?? this.issizlik,
      issizlikYuzde: issizlikYuzde ?? this.issizlikYuzde,
      vergi: vergi ?? this.vergi,
      damga: damga ?? this.damga,
      uygulananVergi: uygulananVergi ?? this.uygulananVergi,
      uygulananVergiYuzde: uygulananVergiYuzde ?? this.uygulananVergiYuzde,
      uygulananDamga: uygulananDamga ?? this.uygulananDamga,
      uygulananDamgaYuzde: uygulananDamgaYuzde ?? this.uygulananDamgaYuzde,
      agi: agi ?? this.agi,
      damgaIstisnasi: damgaIstisnasi ?? this.damgaIstisnasi,
      bes: bes ?? this.bes,
      avans: avans ?? this.avans,
    );
  }
}

class YuzdeVeri {
  final String ad;
  final double tutar;
  final Color renk;

  const YuzdeVeri(this.ad, this.tutar, this.renk);
}

class DataServisi {
  // ==================== HESAPLAMA SINIFLARI ====================
  late CalismaHesaplama calismaHesaplama;
  late MesaiHesaplama mesaiHesaplama;
  late AppData appData;

  // ==================== MERKEZİ VERİ YÖNETİCİSİ ====================
  final VeriYoneticisi veriYoneticisi = VeriYoneticisi();

  // ==================== AYARLAR ====================
  String calisanTipi = "Normal";
  bool besAktif = true;
  double besOrani = 3.0;

  SharedPreferences? prefs;

  DataServisi() {
    debugPrint('=== DATASERVISI OLUŞTURULDU ===');

    // HESAPLAMA SINIFLARINI OLUŞTUR
    calismaHesaplama = CalismaHesaplama();
    mesaiHesaplama = MesaiHesaplama();
    appData = AppData(
      calismaHesaplama: calismaHesaplama,
      mesaiHesaplama: mesaiHesaplama,
    );
  }

  // ==================== DİSPOSE ====================
  void dispose() {
    debugPrint('DataServisi dispose ediliyor');
    calismaHesaplama.dispose();
    mesaiHesaplama.dispose();
    appData.temizle();
    veriYoneticisi.temizle();
  }

  // ==================== AYARLARI YÜKLE ====================
  Future<void> ayarlariYukle() async {
    debugPrint('=== AYARLAR YÜKLENİYOR ===');

    prefs = await SharedPreferences.getInstance();

    // SINIFLARI BAŞLAT
    await calismaHesaplama.init();
    await mesaiHesaplama.init();

    // BES AYARLARINI YÜKLE
    besAktif = prefs?.getBool('besAktif') ?? false;
    besOrani = prefs?.getDouble('besOrani') ?? 3.0;

    // VERİLERİ GÜNCELLE
    await veriYoneticisi.tumVerileriGuncelle();

    debugPrint('Ayarlar yüklendi');
  }

  // ==================== AVANS AYARLARI ====================
  Future<void> avansAyarlariniKaydet(double miktar, DateTime ay) async {
    final int yil = ay.year;
    final int ayIndex = ay.month;
    await prefs?.setDouble('avans-$yil-$ayIndex', miktar);

    debugPrint('Avans kaydedildi: $miktar TL (${ay.year}-${ay.month})');

    // VERİYİ GÜNCELLE
    await veriYoneticisi.tumVerileriGuncelle();
  }

  Future<double> avansMiktariniYukle(DateTime ay) async {
    final int yil = ay.year;
    final int ayIndex = ay.month;
    return prefs?.getDouble('avans-$yil-$ayIndex') ?? 0.0;
  }

  // ==================== BES AYARLARI ====================
  Future<void> besAyarlariniKaydet(bool aktif, double oran) async {
    besAktif = aktif;
    besOrani = oran;
    await prefs?.setBool('besAktif', aktif);
    await prefs?.setDouble('besOrani', oran);

    debugPrint('BES ayarları kaydedildi: aktif=$aktif, oran=$oran');

    // VERİYİ GÜNCELLE
    await veriYoneticisi.tumVerileriGuncelle();
  }

  // ==================== AYLIK VERİ HESAPLA ====================
  Future<AylikVeri> aylikVeriyiHesapla(DateTime seciliAy) async {
    try {
      final int yil = seciliAy.year;
      final int ay = seciliAy.month;

      debugPrint('=== AYLIK VERİ HESAPLANIYOR: $yil-$ay ===');

      // 1. GÜN VERİLERİNİ AL
      final gunler = appData.ayaGoreGetir(yil, ay);
      debugPrint('Gün sayısı: ${gunler.length}');

      // 2. TOPLAMLARI HESAPLA
      double toplamBrut = appData.aylikBrutToplam(yil, ay);
      double toplamCalismaSaati = appData.aylikToplamCalismaSaati(yil, ay);
      double toplamMesaiSaati = appData.aylikToplamMesaiSaati(yil, ay);
      int calismaGunSayisi = appData.aylikCalismaGunSayisi(yil, ay);
      int mesaiGunSayisi = appData.aylikMesaiGunSayisi(yil, ay);
      Set<int> benzersizGunler = appData.aylikBenzersizCalismaGunleri(yil, ay);

      int efektifGunSayisi = benzersizGunler.length.clamp(1, 30).toInt();

      debugPrint('Toplamlar:');
      debugPrint('- Brut: $toplamBrut');
      debugPrint('- Çalışma Saati: $toplamCalismaSaati');
      debugPrint('- Mesai Saati: $toplamMesaiSaati');

      // 3. KESİNTİ DETAYLARINI HESAPLA
      final kesintiDetaylari = await _kesintiDetaylariniHesapla(
        gunler: gunler,
        efektifGunSayisi: efektifGunSayisi,
        seciliAy: seciliAy,
        toplamBrut: toplamBrut,
      );

      // 4. AVANS MİKTARINI AL
      final double avansMiktari = await avansMiktariniYukle(seciliAy);

      // 5. NET KAZANCI HESAPLA
      double netKazanc = (kesintiDetaylari.net - avansMiktari).clamp(
        0,
        double.infinity,
      );

      // 6. SONUÇ OLUŞTUR
      final sonuc = AylikVeri(
        brutKazanc: toplamBrut,
        netKazanc: netKazanc,
        calismaGunSayisi: calismaGunSayisi,
        mesaiGunSayisi: mesaiGunSayisi,
        efektifGunSayisi: efektifGunSayisi,
        toplamCalismaSaati: toplamCalismaSaati,
        toplamMesaiSaati: toplamMesaiSaati,
        kesintiDetaylari: kesintiDetaylari.copyWith(avans: avansMiktari),
        seciliAyIsmi: DateFormat('MMMM yyyy', 'tr_TR').format(seciliAy),
      );

      debugPrint('=== AYLIK VERİ HESAPLANDI ===');
      debugPrint('Net Kazanç: $netKazanc');
      debugPrint('Brut Kazanç: $toplamBrut');

      return sonuc;
    } catch (e) {
      debugPrint('!!! Aylık veri hesaplama hatası: $e');
      return AylikVeri.bos();
    }
  }

  // ==================== KESİNTİ DETAYLARINI HESAPLA ====================

  Future<KesintiDetaylari> _kesintiDetaylariniHesapla({
    required List<CalismaGunModel> gunler,
    required int efektifGunSayisi,
    required DateTime seciliAy,
    required double toplamBrut,
  }) async {
    if (toplamBrut <= 0) {
      return KesintiDetaylari.bos();
    }

    debugPrint('=== KESİNTİ HESAPLANIYOR (GÜN BAZLI) ===');
    debugPrint('Toplam Gün: ${gunler.length}');

    // Her gün için ayrı ayrı hesapla ve topla
    double toplamSgk = 0;
    double toplamIssizlik = 0;
    double toplamVergi = 0;
    double toplamDamga = 0;
    double toplamAgi = 0;
    double toplamDamgaIstisnasi = 0;

    for (var gun in gunler) {
      if (gun.toplamBrut <= 0) continue;

      // Her gün için bordro hesapla
      final gunBordro = MerkeziHesaplamaServisi().hesapBordro(
        brut: gun.toplamBrut,
        calisanTipi: gun.kaydedilenCalisanTipi ?? calisanTipi,
        vergiOrani: gun.kaydedilenKdvOrani ?? calismaHesaplama.calismaKdv,
        tarih: gun.tarih,
        calismaGunSayisi: 1, // Her gün 1 gün olarak hesaplanıyor
      );

      toplamSgk += gunBordro['sgk'] ?? 0;
      toplamIssizlik += gunBordro['issizlik'] ?? 0;
      toplamVergi += gunBordro['vergi'] ?? 0;
      toplamDamga += gunBordro['damga'] ?? 0;
      toplamAgi += gunBordro['agi'] ?? 0;
      toplamDamgaIstisnasi += gunBordro['damgaIstisnasi'] ?? 0;
    }

    // Uygulanan vergiler
    double uygulananVergi = (toplamVergi - toplamAgi).clamp(0, toplamVergi);
    double uygulananDamga = (toplamDamga - toplamDamgaIstisnasi).clamp(
      0,
      toplamDamga,
    );

    // BES kesintisi
    double besKesintisi = MerkeziHesaplamaServisi().besKesintisiHesapla(
      brut: toplamBrut,
      besAktif: besAktif,
      besOrani: besOrani,
    );

    // Net hesapla
    double toplamKesinti =
        toplamSgk +
        toplamIssizlik +
        uygulananVergi +
        uygulananDamga +
        besKesintisi;
    double net = toplamBrut - toplamKesinti;

    // SGK yüzdesi
    double sgkYuzde = switch (calisanTipi) {
      'Normal' => 14.0,
      'Emekli' => 7.5,
      'SGK Yok' => 0.0,
      _ => 14.0,
    };

    return KesintiDetaylari(
      brut: toplamBrut,
      net: net,
      sgk: toplamSgk,
      sgkYuzde: sgkYuzde,
      issizlik: toplamIssizlik,
      issizlikYuzde: calisanTipi == 'Normal' ? 1.0 : 0.0,
      vergi: toplamVergi,
      damga: toplamDamga,
      uygulananVergi: uygulananVergi,
      uygulananVergiYuzde:
          toplamBrut > 0 ? (uygulananVergi / toplamBrut) * 100 : 0.0,
      uygulananDamga: uygulananDamga,
      uygulananDamgaYuzde:
          toplamBrut > 0 ? (uygulananDamga / toplamBrut) * 100 : 0.0,
      agi: toplamAgi,
      damgaIstisnasi: toplamDamgaIstisnasi,
      bes: besKesintisi,
      avans: 0,
    );
  }

  // ==================== TEMİZLE ====================
  void temizle() {
    calismaHesaplama.tarihController.clear();
    calismaHesaplama.notController.clear();
  }
}
