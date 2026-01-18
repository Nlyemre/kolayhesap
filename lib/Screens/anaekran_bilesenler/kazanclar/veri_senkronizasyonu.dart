// lib/Screens/anaekran_bilesenler/kazanclar/veri_senkronizasyonu.dart
import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/app_data.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/data_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:flutter/material.dart';

// ==================== MERKEZİ VERİ YÖNETİCİSİ ====================
class VeriYoneticisi {
  // Singleton pattern
  static final VeriYoneticisi _instance = VeriYoneticisi._internal();
  factory VeriYoneticisi() => _instance;
  VeriYoneticisi._internal();

  // ==================== REFERANSLAR ====================
  CalismaHesaplama? _calismaHesaplama;
  MesaiHesaplama? _mesaiHesaplama;
  AppData? _appData;
  DataServisi? _dataServisi;

  // ==================== DİNLEYİCİLER ====================
  final List<VoidCallback> _veriDegisiklikDinleyicileri = [];
  Timer? _debounceTimer;
  bool _guncellemeDevamEdiyor = false;
  bool _baglantilarKuruldu = false; // YENİ: Bağlantı durumunu takip et
  DateTime? _sonGuncellemeZamani; // YENİ: Son güncelleme zamanı

  // ==================== BAĞLANTI KURMA ====================
  void baglantilariKur({
    required CalismaHesaplama calismaHesaplama,
    required MesaiHesaplama mesaiHesaplama,
    required AppData appData,
    required DataServisi dataServisi,
  }) {
    // EĞER ZATEN BAĞLANTI KURULDUYSA TEKRARLAMA!
    if (_baglantilarKuruldu) {
      debugPrint('Bağlantılar zaten kurulu, tekrar kurulmuyor');
      return;
    }

    debugPrint('=== VERİ YÖNETİCİSİ BAĞLANTILARI KURULUYOR ===');

    _calismaHesaplama = calismaHesaplama;
    _mesaiHesaplama = mesaiHesaplama;
    _appData = appData;
    _dataServisi = dataServisi;

    // DİNLEYİCİLERİ EKLE
    _calismaHesaplama?.onDataChanged = _veriDegisti;
    _mesaiHesaplama?.mesaiMetinListe.addListener(_veriDegisti);

    // APPDATA'YA DİNLEYİCİ EKLE
    _appData?.dinleyiciEkle(_veriDegisiklikleriniYay);

    // BAĞLANTI KURULDU OLARAK İŞARETLE
    _baglantilarKuruldu = true;

    debugPrint('Bağlantılar kuruldu');
  }

  // ==================== VERİ DEĞİŞİKLİĞİ ====================
  void _veriDegisti() {
    final now = DateTime.now();

    // SON GÜNCELLEMEDEN 1 SANİYEDEN AZ ZAMAN GEÇTİYSE YOKSAY
    if (_sonGuncellemeZamani != null &&
        now.difference(_sonGuncellemeZamani!) < const Duration(seconds: 1)) {
      debugPrint('Çok sık veri değişikliği, yoksayılıyor');
      return;
    }

    debugPrint('Veri değişikliği tespit edildi');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      tumVerileriGuncelle();
    });
  }

  // ==================== TÜM VERİLERİ GÜNCELLE ====================
  Future<void> tumVerileriGuncelle() async {
    // ÇOK SIK ÇAĞRILIYORSA ENGELLE
    final now = DateTime.now();
    if (_sonGuncellemeZamani != null &&
        now.difference(_sonGuncellemeZamani!) < const Duration(seconds: 2)) {
      debugPrint('Çok sık güncelleme isteği, yoksayılıyor');
      return;
    }

    if (_guncellemeDevamEdiyor) {
      debugPrint('Güncelleme zaten devam ediyor, yeni istek yoksayıldı');
      return;
    }

    _guncellemeDevamEdiyor = true;
    _sonGuncellemeZamani = now;

    try {
      debugPrint('=== TÜM VERİLER GÜNCELLENİYOR ===');

      if (_appData == null || _dataServisi == null) {
        debugPrint('HATA: AppData veya DataServisi bulunamadı!');
        return;
      }

      // APPDATA GÜNCELLE - ÇALIŞMA VE MESAI VERİLERİNİ BİRLEŞTİR
      await _appData!.verileriBirlestir(
        calisanTipi: _dataServisi!.calisanTipi,
        kdvOrani: _calismaHesaplama?.calismaKdv ?? 15.0,
        besOrani: _dataServisi!.besOrani,
        besAktif: _dataServisi!.besAktif,
        mesaiVerileriniDahilEt: true,
      );

      debugPrint('Tüm veriler güncellendi');
    } catch (e) {
      debugPrint('!!! VERİ GÜNCELLEME HATASI: $e');
    } finally {
      // KİLİDİ 100ms SONRA AÇ (DİĞER ÇAĞRILARIN BİTMESİNİ BEKLE)
      Future.delayed(const Duration(milliseconds: 100), () {
        _guncellemeDevamEdiyor = false;
      });
    }
  }

  // ==================== DİNLEYİCİ YÖNETİMİ ====================
  void dinleyiciEkle(VoidCallback callback) {
    if (!_veriDegisiklikDinleyicileri.contains(callback)) {
      _veriDegisiklikDinleyicileri.add(callback);
      debugPrint(
        'Yeni dinleyici eklendi, toplam: ${_veriDegisiklikDinleyicileri.length}',
      );
    }
  }

  void dinleyiciKaldir(VoidCallback callback) {
    _veriDegisiklikDinleyicileri.remove(callback);
    debugPrint(
      'Dinleyici kaldırıldı, kalan: ${_veriDegisiklikDinleyicileri.length}',
    );
  }

  void _veriDegisiklikleriniYay() {
    // DİNLEYİCİ YOKSA ÇIK
    if (_veriDegisiklikDinleyicileri.isEmpty) {
      return;
    }

    debugPrint(
      'Veri değişiklikleri yayılıyor (${_veriDegisiklikDinleyicileri.length} dinleyici)',
    );

    for (var dinleyici in _veriDegisiklikDinleyicileri) {
      try {
        dinleyici();
      } catch (e) {
        debugPrint('Dinleyici hatası: $e');
      }
    }
  }

  // ==================== MANUEL GÜNCELLEME ====================
  Future<void> manuelGuncelle() async {
    debugPrint('=== MANUEL GÜNCELLEME TETİKLENDİ ===');
    await tumVerileriGuncelle();
  }

  // ==================== TEMİZLEME ====================
  void temizle() {
    _debounceTimer?.cancel();
    _veriDegisiklikDinleyicileri.clear();

    // DİNLEYİCİLERİ KALDIR
    if (_calismaHesaplama != null) {
      _calismaHesaplama!.onDataChanged = null;
    }
    if (_mesaiHesaplama != null) {
      try {
        _mesaiHesaplama!.mesaiMetinListe.removeListener(_veriDegisti);
      } catch (e) {
        debugPrint('Mesai dinleyici kaldırma hatası: $e');
      }
    }
    if (_appData != null) {
      _appData!.dinleyiciKaldir(_veriDegisiklikleriniYay);
    }

    _calismaHesaplama = null;
    _mesaiHesaplama = null;
    _appData = null;
    _dataServisi = null;
    _baglantilarKuruldu = false; // SIFIRLA
    _sonGuncellemeZamani = null; // SIFIRLA

    debugPrint('VeriYoneticisi temizlendi');
  }

  // ==================== DURUM KONTROLÜ ====================
  bool baglantilarKurulduMu() {
    return _baglantilarKuruldu;
  }

  void durumuGoster() {
    debugPrint('=== VERİ YÖNETİCİSİ DURUMU ===');
    debugPrint('CalismaHesaplama: ${_calismaHesaplama != null}');
    debugPrint('MesaiHesaplama: ${_mesaiHesaplama != null}');
    debugPrint('AppData: ${_appData != null}');
    debugPrint('DataServisi: ${_dataServisi != null}');
    debugPrint('Bağlantılar kuruldu: $_baglantilarKuruldu');
    debugPrint('Dinleyici sayısı: ${_veriDegisiklikDinleyicileri.length}');
    debugPrint('Güncelleme devam ediyor: $_guncellemeDevamEdiyor');
    debugPrint('Son güncelleme: $_sonGuncellemeZamani');
    debugPrint('==============================');
  }
}
