import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/app_data.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/aylik_veri_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_gun_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataServisi {
  // ==================== HESAPLAMA SINIFLARI ====================
  late CalismaHesaplama calismaHesaplama;
  late MesaiHesaplama mesaiHesaplama;
  late AppData appData;

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
  }

  // ==================== AYARLARI YÜKLE ====================
  Future<void> ayarlariYukle() async {
    debugPrint('=== AYARLAR YÜKLENİYOR ===');

    prefs = await SharedPreferences.getInstance();

    final savedIndex = prefs?.getInt('index') ?? 0;

    // TÜM SINIFLARA AYNI INDEX'I ATA
    calismaHesaplama.selectedIndex.value = savedIndex;
    mesaiHesaplama.selectedIndex.value = savedIndex;

    // SINIFLARI BAŞLAT
    await calismaHesaplama.init();
    await mesaiHesaplama.init();

    // BES AYARLARINI YÜKLE
    besAktif = prefs?.getBool('besAktif') ?? false;
    besOrani = prefs?.getDouble('besOrani') ?? 3.0;

    debugPrint('Ayarlar yüklendi');
  }

  // ==================== AVANS AYARLARI ====================
  Future<void> avansAyarlariniKaydet(double miktar, DateTime ay) async {
    final int yil = ay.year;
    final int ayIndex = ay.month;
    await prefs?.setDouble('avans-$yil-$ayIndex', miktar);

    debugPrint('Avans kaydedildi: $miktar TL (${ay.year}-${ay.month})');
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

    // 1. Günlük brüt listesi oluştur
    final List<double> brutListesi = gunler.map((g) => g.toplamBrut).toList();

    // 2. Toplu bordro hesapla (istisnalar tek seferde prorata)
    final bordroSonuc = MerkeziHesaplamaServisi().gunlukTopluBordro(
      brutListesi: brutListesi,
      calisanTipi: calisanTipi,
      vergiOrani: calismaHesaplama.calismaKdv,
      ayTarihi: seciliAy,
      efektifGunSayisi: efektifGunSayisi,
    );

    // 3. BES kesintisi (toplam brüt üzerinden)
    double besKesintisi = MerkeziHesaplamaServisi().besKesintisiHesapla(
      brut: toplamBrut,
      besAktif: besAktif,
      besOrani: besOrani,
    );

    // 4. Net hesapla (BES dahil)
    double net = (bordroSonuc['net'] ?? 0.0) - besKesintisi;

    // 5. Sonuçları KesintiDetaylari'na aktar
    return KesintiDetaylari(
      brut: toplamBrut,
      net: net,
      sgk: bordroSonuc['sgk'] ?? 0.0,
      sgkYuzde: bordroSonuc['sgk_yuzde'] ?? 0.0,
      issizlik: bordroSonuc['issizlik'] ?? 0.0,
      issizlikYuzde: bordroSonuc['issizlik_yuzde'] ?? 0.0,
      vergi: bordroSonuc['vergi'] ?? 0.0,
      damga: bordroSonuc['damga'] ?? 0.0,
      uygulananVergi: bordroSonuc['uygulananVergi'] ?? 0.0,
      uygulananVergiYuzde: bordroSonuc['uygulananVergiYuzde'] ?? 0.0,
      uygulananDamga: bordroSonuc['uygulananDamga'] ?? 0.0,
      uygulananDamgaYuzde: bordroSonuc['uygulananDamgaYuzde'] ?? 0.0,
      agi: bordroSonuc['agi'] ?? 0.0,
      damgaIstisnasi: bordroSonuc['damgaIstisnasi'] ?? 0.0,
      bes: besKesintisi,
      avans: 0.0,
    );
  }

  // ==================== TEMİZLE ====================
  void temizle() {
    calismaHesaplama.tarihController.clear();
    calismaHesaplama.notController.clear();
  }
}
