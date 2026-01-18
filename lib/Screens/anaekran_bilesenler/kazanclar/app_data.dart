// lib/Screens/anaekran_bilesenler/kazanclar/app_data.dart
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_model.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppData {
  // Aylık gruplanmış veriler (ana depolama)
  final Map<String, List<CalismaGunModel>> _aylikVeriler = {};

  // Veri değişiklik dinleyicileri
  final List<VoidCallback> _veriDegisiklikDinleyicileri = [];

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
  }) async {
    debugPrint('=== VERİLER BİRLEŞTİRİLİYOR ===');

    // 1. Mevcut verileri temizle
    _aylikVeriler.clear();

    // 2. Çalışma günlerini ekle
    if (calismaHesaplama != null) {
      for (var gun in calismaHesaplama!.calismaGunleri) {
        await _ekleVeyaGuncelleCalismaGunu(gun);
      }
    }

    // 3. Mesai günlerini ekle
    if (mesaiVerileriniDahilEt && mesaiHesaplama != null) {
      await _mesaiVerileriniEkle();
    }

    debugPrint(
      'Veri birleştirme tamamlandı. Aylar: ${_aylikVeriler.keys.length}',
    );

    // 4. Dinleyicileri uyar
    _veriDegisiklikleriniYay();
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
              mesaiVar: true,
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
      liste[mevcutIndex] = mevcut.copyWith(
        mesaiVar: mesaiGunu.mesaiVar || mevcut.mesaiVar,
        mesaiSaati: mesaiGunu.mesaiSaati + mevcut.mesaiSaati,
        mesaiBrut: mesaiGunu.mesaiBrut + mevcut.mesaiBrut,
        mesaiNet: mesaiGunu.mesaiNet + mevcut.mesaiNet,
        mesaiNotu: mesaiGunu.mesaiNotu ?? mevcut.mesaiNotu,
        mesaiMetni: mesaiGunu.mesaiMetni,
        toplamKazanc: mevcut.toplamKazanc + mesaiGunu.toplamKazanc,
        toplamBrut: mevcut.toplamBrut + mesaiGunu.toplamBrut,
      );
    } else {
      liste.add(mesaiGunu);
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
    return gunler.where((g) => g.mesaiVar && g.mesaiSaati.abs() > 0).length;
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

  /// Verileri tamamen temizle
  void temizle() {
    _aylikVeriler.clear();
    _veriDegisiklikDinleyicileri.clear();
  }
}
