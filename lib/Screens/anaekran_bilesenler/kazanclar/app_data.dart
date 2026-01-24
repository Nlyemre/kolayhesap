import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_gun_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../mesai_izin/mesaihesapla.dart';

class AppData {
  // Aylık gruplanmış veriler (ana depolama)
  final Map<String, List<CalismaGunModel>> _aylikVeriler = {};

  // Veri değişiklik dinleyicileri
  final List<VoidCallback> _veriDegisiklikDinleyicileri = [];

  // Çalışma şekli değişiklik dinleyicileri
  final List<VoidCallback> _calismaSekliDinleyicileri = [];

  // Hesaplama referansları
  final CalismaHesaplama? calismaHesaplama;
  final MesaiHesaplama? mesaiHesaplama;

  AppData({this.calismaHesaplama, this.mesaiHesaplama});

  /// Tüm verileri birleştirir (çalışma + mesai)
  Future<void> verileriBirlestir({
    required String calisanTipi,
    required double kdvOrani,
    double? besOrani,
    bool besAktif = false,
    bool mesaiVerileriniDahilEt = true,
    int? filterByIndex, // YENİ: Sadece belirli index'i göster
  }) async {
    debugPrint('=== VERİLER BİRLEŞTİRİLİYOR (Filter: $filterByIndex) ===');

    // 1. Mevcut verileri temizle
    _aylikVeriler.clear();

    // 2. Çalışma günlerini ekle - FİLTRE UYGULA
    if (calismaHesaplama != null) {
      // Eğer filterByIndex null ise, tüm çalışma kayıtlarını göster
      // Eğer filterByIndex belirtilmişse, sadece o index'e ait kayıtları göster
      for (var gun in calismaHesaplama!.calismaGunleri) {
        if (filterByIndex != null && gun.kaydedilenIndex != filterByIndex) {
          continue; // Filtre uygulanıyorsa ve index eşleşmiyorsa atla
        }
        await _ekleVeyaGuncelleCalismaGunu(gun);
      }
    }

    // 3. Mesai günlerini ekle (mesailer index'e bağlı değil, hepsini göster)
    if (mesaiVerileriniDahilEt && mesaiHesaplama != null) {
      await _mesaiVerileriniEkle();
    }

    debugPrint(
      'Veri birleştirme tamamlandı. Aylar: ${_aylikVeriler.keys.length}',
    );

    // 4. Dinleyicileri uyar
    _veriDegisiklikleriniYay();
  }

  /// Sadece seçili index'e ait verileri birleştir
  Future<void> verileriBirlestirFiltreli({
    required String calisanTipi,
    required double kdvOrani,
    double? besOrani,
    bool besAktif = false,
    bool mesaiVerileriniDahilEt = true,
    required int selectedIndex, // ZORUNLU: Hangi index'i göstereceğiz
  }) async {
    debugPrint('=== FİLTRELİ VERİ BİRLEŞTİRME (Index: $selectedIndex) ===');

    await verileriBirlestir(
      calisanTipi: calisanTipi,
      kdvOrani: kdvOrani,
      besOrani: besOrani,
      besAktif: besAktif,
      mesaiVerileriniDahilEt: mesaiVerileriniDahilEt,
      filterByIndex: selectedIndex, // Filtreyi uygula
    );
  }

  /// Mesai verilerini ekler
  Future<void> _mesaiVerileriniEkle() async {
    try {
      debugPrint('Mesai verileri ekleniyor...');

      for (int i = 0; i < mesaiHesaplama!.mesaiMetinListe.value.length; i++) {
        final metin = mesaiHesaplama!.mesaiMetinListe.value[i];
        final parts = metin.split(' ');

        if (parts.length > 1) {
          final tarihStr = parts[1];
          final mesaiSaati = mesaiHesaplama!.mesaiSaatListe[i];
          final mesaiBrut = mesaiHesaplama!.mesaiBurutListe[i];
          final mesaiNet = mesaiHesaplama!.mesaiNetListe[i];
          final not =
              mesaiHesaplama!.mesaiNotListe.length > i
                  ? mesaiHesaplama!.mesaiNotListe[i]
                  : '';

          try {
            final tarih = DateFormat('dd-MM-yyyy').parse(tarihStr);

            final mesaiGunu = CalismaGunModel(
              tarih: tarih,
              calistiMi: false,
              calismaSaati: 0,
              calismaBrut: 0,
              calismaNet: 0,
              calismaNotu: null,
              mesaiVar: mesaiSaati != 0, // EKSİ İÇİN DE TRUE (satır 76)
              mesaiSaati: mesaiSaati,
              mesaiBrut: mesaiBrut,
              mesaiNet: mesaiNet,
              mesaiNotu: not.isNotEmpty ? not : null,
              mesaiMetni: metin,
              toplamKazanc: mesaiNet,
              toplamBrut: mesaiBrut,
              kaydedilenKdvOrani: mesaiHesaplama?.mesaiKdv ?? 15.0,
            );

            await _ekleVeyaGuncelleMesaiGunu(mesaiGunu);
          } catch (e) {
            debugPrint('Mesai tarih parse hatası: $e - $tarihStr');
          }
        }
      }

      debugPrint('Mesai verileri eklendi');
    } catch (e) {
      debugPrint('Mesai ekleme hatası: $e');
    }
  }

  /// Çalışma gününü ekler/günceller
  Future<void> _ekleVeyaGuncelleCalismaGunu(CalismaGunModel yeniGun) async {
    final ayKey = '${yeniGun.tarih.year}-${yeniGun.tarih.month}';

    if (!_aylikVeriler.containsKey(ayKey)) {
      _aylikVeriler[ayKey] = [];
    }
    final liste = _aylikVeriler[ayKey]!;

    final mevcutIndex = liste.indexWhere((g) => g.tarih == yeniGun.tarih);

    if (mevcutIndex != -1) {
      final mevcut = liste[mevcutIndex];
      liste[mevcutIndex] = mevcut.copyWith(
        calistiMi: yeniGun.calistiMi || mevcut.calistiMi,
        calismaSaati: yeniGun.calismaSaati + mevcut.calismaSaati,
        calismaNet: yeniGun.calismaNet + mevcut.calismaNet,
        calismaBrut: yeniGun.calismaBrut + mevcut.calismaBrut,
        calismaNotu: yeniGun.calismaNotu ?? mevcut.calismaNotu,
        mesaiVar: mevcut.mesaiVar,
        mesaiSaati: mevcut.mesaiSaati,
        mesaiBrut: mevcut.mesaiBrut,
        mesaiNet: mevcut.mesaiNet,
        mesaiNotu: mevcut.mesaiNotu,
        mesaiMetni: mevcut.mesaiMetni,
        toplamKazanc: yeniGun.toplamKazanc + mevcut.toplamKazanc,
        toplamBrut: yeniGun.toplamBrut + mevcut.toplamBrut,
      );
    } else {
      liste.add(yeniGun);
    }

    liste.sort((a, b) => a.tarih.compareTo(b.tarih));
  }

  /// Mesai gününü ekler/günceller
  Future<void> _ekleVeyaGuncelleMesaiGunu(CalismaGunModel mesaiGunu) async {
    final ayKey = '${mesaiGunu.tarih.year}-${mesaiGunu.tarih.month}';

    if (!_aylikVeriler.containsKey(ayKey)) {
      _aylikVeriler[ayKey] = [];
    }
    final liste = _aylikVeriler[ayKey]!;

    final mevcutIndex = liste.indexWhere((g) => g.tarih == mesaiGunu.tarih);

    if (mevcutIndex != -1) {
      final mevcut = liste[mevcutIndex];

      // EKSİ MESAI İÇİN DE MESAI VAR = TRUE (satır 108-120)
      bool yeniMesaiVar = mesaiGunu.mesaiSaati != 0;

      liste[mevcutIndex] = mevcut.copyWith(
        mesaiVar: yeniMesaiVar || mevcut.mesaiVar, // Eksi için de true
        mesaiSaati: mesaiGunu.mesaiSaati + mevcut.mesaiSaati,
        mesaiBrut: mesaiGunu.mesaiBrut + mevcut.mesaiBrut,
        mesaiNet: mesaiGunu.mesaiNet + mevcut.mesaiNet,
        mesaiNotu: mesaiGunu.mesaiNotu ?? mevcut.mesaiNotu,
        mesaiMetni: mesaiGunu.mesaiMetni,
        toplamKazanc: mevcut.toplamKazanc + mesaiGunu.toplamKazanc,
        toplamBrut: mevcut.toplamBrut + mesaiGunu.toplamBrut,
      );
    } else {
      // Yeni mesai eklerken eksi için de mesaiVar = true (satır 123-125)
      final yeniGun = mesaiGunu.copyWith(
        mesaiVar: mesaiGunu.mesaiSaati != 0, // Eksi için true
      );
      liste.add(yeniGun);
    }

    liste.sort((a, b) => a.tarih.compareTo(b.tarih));
  }

  // ==================== GETTER METOTLARI ====================

  List<CalismaGunModel> ayaGoreGetir(int yil, int ay) {
    final key = '$yil-$ay';
    return _aylikVeriler[key] ?? [];
  }

  double aylikBrutToplam(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    return gunler.fold(0.0, (sum, gun) => sum + gun.toplamBrut);
  }

  double aylikToplamCalismaSaati(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    return gunler.fold(0.0, (sum, gun) => sum + gun.calismaSaati);
  }

  double aylikToplamMesaiSaati(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    return gunler.fold(0.0, (sum, gun) => sum + gun.mesaiSaati);
  }

  int aylikCalismaGunSayisi(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    return gunler.where((g) => g.calistiMi && g.calismaSaati > 0).length;
  }

  int aylikMesaiGunSayisi(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    return gunler.where((g) => g.mesaiVar).length;
  }

  Set<int> aylikBenzersizCalismaGunleri(int yil, int ay) {
    final gunler = ayaGoreGetir(yil, ay);
    final benzersiz = <int>{};

    for (var gun in gunler) {
      if ((gun.calistiMi && gun.calismaSaati > 0) ||
          (gun.mesaiVar && gun.mesaiSaati.abs() > 0)) {
        benzersiz.add(gun.tarih.day);
      }
    }

    return benzersiz;
  }

  // ==================== DİNLEYİCİ YÖNETİMİ ====================

  void dinleyiciEkle(VoidCallback callback) {
    if (!_veriDegisiklikDinleyicileri.contains(callback)) {
      _veriDegisiklikDinleyicileri.add(callback);
    }
  }

  void dinleyiciKaldir(VoidCallback callback) {
    _veriDegisiklikDinleyicileri.remove(callback);
  }

  void _veriDegisiklikleriniYay() {
    for (var dinleyici in _veriDegisiklikDinleyicileri) {
      try {
        dinleyici();
      } catch (e) {
        debugPrint('Dinleyici hatası: $e');
      }
    }
  }

  // ==================== ÇALIŞMA ŞEKLİ DİNLEYİCİLERİ ====================

  void calismaSekliDegisti() {
    debugPrint('Çalışma şekli değişti, dinleyiciler uyarılıyor...');
    for (var dinleyici in _calismaSekliDinleyicileri) {
      try {
        dinleyici();
      } catch (e) {
        debugPrint('Çalışma şekli dinleyici hatası: $e');
      }
    }
  }

  void calismaSekliDinleyiciEkle(VoidCallback callback) {
    if (!_calismaSekliDinleyicileri.contains(callback)) {
      _calismaSekliDinleyicileri.add(callback);
    }
  }

  void calismaSekliDinleyiciKaldir(VoidCallback callback) {
    _calismaSekliDinleyicileri.remove(callback);
  }

  // ==================== VERİ TEMİZLEME ====================

  /// Verileri tamamen temizle
  void temizle() {
    _aylikVeriler.clear();
    _veriDegisiklikDinleyicileri.clear();
    _calismaSekliDinleyicileri.clear();
  }

  /// Belirli bir index'e ait verileri temizle
  void indexVerileriniTemizle(int index, int yil, int ay) {
    final key = '$yil-$ay';
    if (_aylikVeriler.containsKey(key)) {
      _aylikVeriler[key]!.removeWhere((gun) => gun.kaydedilenIndex == index);
      if (_aylikVeriler[key]!.isEmpty) {
        _aylikVeriler.remove(key);
      }
    }
  }
}
