import 'dart:convert';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesailer.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MesaiHesaplama {
  bool veriDegisti = false;
  double mesaiSgkEmekliKesintiOrani = 15;
  String tarihMesai = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final tarihController = TextEditingController();
  int simdikiAy = int.parse(DateFormat('M').format(DateTime.now()));
  int simdikiYil = int.parse(DateFormat('yyyy').format(DateTime.now()));
  List<double> mesaiSaatListe = [];
  List<double> mesaiBurutListe = [];
  List<double> mesaiNetListe = [];
  List<String> mesaiNotListe = [];
  final ValueNotifier<List<String>> mesaiMetinListe = ValueNotifier([]);
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final ValueNotifier<int> secilenIndex = ValueNotifier(
    -1,
  ); // Seçili liste öğesi için
  double saatUcreti = 0;
  double mesaiSaat = 0;
  double mesaiSaatYuzde = 0;
  double mesaiKdv = 15;
  double mesaiBurut = 0;
  String saatgunhangisi = "";
  String calisanTipi = "Normal";
  int secilenAy = int.parse(DateFormat('M').format(DateTime.now()));
  int secilenYil = int.parse(DateFormat('yyyy').format(DateTime.now()));
  int mesaiSayi = 1;
  int kdvSayi = 1;
  String secilenMesaiSaat = '0';
  String secilenMesaiGun = '';
  final mesaiSec = TextEditingController();
  final kdvSec = TextEditingController();
  final saatUcretiSec = TextEditingController();
  final gunlukUcretiSec = TextEditingController();
  final aylikUcretiSec = TextEditingController();
  final toplamMesai = TextEditingController();
  final brutMesai = TextEditingController();
  final netMesai = TextEditingController();
  final notController = TextEditingController();
  int tarihanahtar = 0;

  static const List<String> ayListe = [
    '',
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
  static const List<String> butonyazi = [
    'Saat Ücret',
    'Günlük Ücret',
    'Aylik Ücret',
  ];
  static const List<int> yilListe = [
    2024,
    2025,
    2026,
    2027,
    2028,
    2029,
    2030,
    2031,
    2032,
    2033,
    2034,
    2035,
  ];
  static const List<String> mesaiListe = [
    '% 50',
    '% 80',
    '% 100',
    '% 125',
    '% 150',
    '% 200',
    '% 250',
    '% 300',
    '% 400',
  ];
  static const List<String> kdvListe = [
    '% 0',
    '% 15',
    '% 20',
    '% 27',
    '% 35',
    '% 40',
  ];
  static const List<String> mesaiGunSecimListe = [
    '0.5 Gün Mesai',
    '1 Gün Mesai',
  ];
  static const List<String> mesaiSaatSecimListe = [
    '0.5 Saat Mesai',
    '1 Saat Mesai',
    '1.5 Saat Mesai',
    '2 Saat Mesai',
    '2.5 Saat Mesai',
    '3 Saat Mesai',
    '3.5 Saat Mesai',
    '4 Saat Mesai',
    '4.5 Saat Mesai',
    '5 Saat Mesai',
    '5.5 Saat Mesai',
    '6 Saat Mesai',
    '6.5 Saat Mesai',
    '7 Saat Mesai',
    '7.5 Saat Mesai',
    '8 Saat Mesai',
    '8.5 Saat Mesai',
    '9 Saat Mesai',
    '9.5 Saat Mesai',
    '10 Saat Mesai',
    '10.5 Saat Mesai',
    '11 Saat Mesai',
    '11.5 Saat Mesai',
    '12 Saat Mesai',
    '12.5 Saat Mesai',
    '13 Saat Mesai',
    '13.5 Saat Mesai',
    '14 Saat Mesai',
    '14.5 Saat Mesai',
    '15 Saat Mesai',
    '15.5 Saat Mesai',
  ];

  static const List<String> mesaiSaatEksikListe = [
    '-0.5 Saat Gelinmedi',
    '-1 Saat Gelinmedi',
    '-1.5 Saat Gelinmedi',
    '-2 Saat Gelinmedi',
    '-2.5 Saat Gelinmedi',
    '-3 Saat Gelinmedi',
    '-3.5 Saat Gelinmedi',
    '-4 Saat Gelinmedi',
    '-4.5 Saat Gelinmedi',
    '-5 Saat Gelinmedi',
    '-5.5 Saat Gelinmedi',
    '-6 Saat Gelinmedi',
    '-6.5 Saat Gelinmedi',
    '-7 Saat Gelinmedi',
    '-7.5 Saat Gelinmedi',
    '-8 Saat Gelinmedi',
    '-8.5 Saat Gelinmedi',
    '-9 Saat Gelinmedi',
    '-9.5 Saat Gelinmedi',
    '-10 Saat Gelinmedi',
    '-10.5 Saat Gelinmedi',
    '-11 Saat Gelinmedi',
    '-11.5 Saat Gelinmedi',
    '-12 Saat Gelinmedi',
    '-12.5 Saat Gelinmedi',
    '-13 Saat Gelinmedi',
    '-13.5 Saat Gelinmedi',
    '-14 Saat Gelinmedi',
    '-14.5 Saat Gelinmedi',
    '-15 Saat Gelinmedi',
    '-15.5 Saat Gelinmedi',
  ];
  static const List<String> mesaiGunEksikListe = [
    '-0.5 Gün Gelinmedi',
    '-1 Gün Gelinmedi',
    '-1.5 Gün Gelinmedi',
    '-2 Gün Gelinmedi',
    '-2.5 Gün Gelinmedi',
    '-3 Gün Gelinmedi',
    '-3.5 Gün Gelinmedi',
    '-4 Gün Gelinmedi',
    '-4.5 Gün Gelinmedi',
    '-5 Gün Gelinmedi',
    '-5.5 Gün Gelinmedi',
    '-6 Gün Gelinmedi',
    '-6.5 Gün Gelinmedi',
    '-7 Gün Gelinmedi',
    '-7.5 Gün Gelinmedi',
    '-8 Gün Gelinmedi',
    '-8.5 Gün Gelinmedi',
    '-9 Gün Gelinmedi',
    '-9.5 Gün Gelinmedi',
    '-10 Gün Gelinmedi',
    '-10.5 Gün Gelinmedi',
    '-11 Gün Gelinmedi',
    '-11.5 Gün Gelinmedi',
    '-12 Gün Gelinmedi',
    '-12.5 Gün Gelinmedi',
    '-13 Gün Gelinmedi',
    '-13.5 Gün Gelinmedi',
    '-14 Gün Gelinmedi',
    '-14.5 Gün Gelinmedi',
    '-15 Gün Gelinmedi',
    '-15.5 Gün Gelinmedi',
    '-16 Gün Gelinmedi',
    '-16.5 Gün Gelinmedi',
    '-17 Gün Gelinmedi',
    '-17.5 Gün Gelinmedi',
    '-18 Gün Gelinmedi',
    '-18.5 Gün Gelinmedi',
    '-19 Gün Gelinmedi',
    '-19.5 Gün Gelinmedi',
    '-20 Gün Gelinmedi',
    '-20.5 Gün Gelinmedi',
    '-21 Gün Gelinmedi',
    '-21.5 Gün Gelinmedi',
    '-22 Gün Gelinmedi',
    '-22.5 Gün Gelinmedi',
    '-23 Gün Gelinmedi',
    '-23.5 Gün Gelinmedi',
    '-24 Gün Gelinmedi',
    '-24.5 Gün Gelinmedi',
    '-25 Gün Gelinmedi',
    '-25.5 Gün Gelinmedi',
    '-26 Gün Gelinmedi',
    '-26.5 Gün Gelinmedi',
    '-27 Gün Gelinmedi',
    '-27.5 Gün Gelinmedi',
    '-28 Gün Gelinmedi',
    '-28.5 Gün Gelinmedi',
    '-29 Gün Gelinmedi',
    '-29.5 Gün Gelinmedi',
    '-30 Gün Gelinmedi',
  ];

  Future<void> init() async {
    veriDegisti = false;
    await indexCagir();
    await mesaiListeCagir();
  }

  void dispose() {
    mesaiSec.dispose();
    kdvSec.dispose();
    saatUcretiSec.dispose();
    notController.dispose();
    gunlukUcretiSec.dispose();
    aylikUcretiSec.dispose();
    toplamMesai.dispose();
    brutMesai.dispose();
    netMesai.dispose();
    tarihController.dispose();
    mesaiMetinListe.dispose();
    selectedIndex.dispose();
    secilenIndex.dispose();
  }

  void _klavyeyiKapat() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  String saatMesaiAyikla(String ayiklaiki) {
    final iki = ayiklaiki.split(' ');
    return iki.isNotEmpty ? iki[0] : '';
  }

  void listeyiGuncelle({required String islem, int? index}) {
    // 1. Yardımcı fonksiyon
    double yuzdeAyikla(String text) {
      if (text.isEmpty || text.length < 2) return 0;
      String clean = text.replaceAll('%', '').trim();
      return double.tryParse(clean) ?? 0;
    }

    double getUcretDegeri() {
      if (selectedIndex.value == 0) {
        return double.tryParse(saatUcretiSec.text) ?? 0;
      } else if (selectedIndex.value == 1) {
        return double.tryParse(gunlukUcretiSec.text) ?? 0;
      } else {
        return double.tryParse(aylikUcretiSec.text) ?? 0;
      }
    }

    saatgunhangisi = selectedIndex.value == 0 ? "Saat" : "Gün";

    // 2. Değerleri al
    double mesaiSaati = double.parse(saatMesaiAyikla(secilenMesaiSaat));
    double vergiOrani = yuzdeAyikla(kdvSec.text);
    double mesaiYuzdesi = yuzdeAyikla(mesaiSec.text);
    double ucret = getUcretDegeri();

    // 3. Mevcut değişkenlere ata (geri uyumluluk için)
    saatUcreti = ucret;
    mesaiSaat = mesaiSaati;
    mesaiKdv = vergiOrani;
    mesaiSaatYuzde = mesaiYuzdesi;

    // 4. MERKEZİ SERVİSİ KULLAN
    final merkeziServis = MerkeziHesaplamaServisi();

    // 4a. MESAI BRUT'Ü MERKEZİ SERVİSLE HESAPLA
    double mesaiBrut = merkeziServis.mesaiBrutHesapla(
      mesaiSaati: mesaiSaati,
      kaydedilenIndex: selectedIndex.value,
      kaydedilenUcret: ucret,
      mesaiYuzde: mesaiYuzdesi,
    );

    // Geri uyumluluk için eski değişkenleri güncelle
    mesaiBurut = ucret + ucret * (mesaiYuzdesi / 100); // 1 saatlik mesai ücreti
    double saatburuthesap = mesaiBrut; // Toplam brut artık merkezi servisten

    // 4b. TARİHİ PARSE ET
    DateTime tarih;
    try {
      tarih = DateFormat('dd-MM-yyyy').parse(tarihMesai);
    } catch (e) {
      tarih = DateTime.now();
    }

    // 4c. BORDROYU MERKEZİ SERVİSLE HESAPLA
    Map<String, double> bordro = merkeziServis.hesapBordro(
      brut: mesaiBrut,
      calisanTipi: calisanTipi,
      vergiOrani: vergiOrani,
      tarih: tarih,
      calismaGunSayisi: 1, // Mesai tek gün olarak hesaplanıyor
    );

    // 5. NET HESAPLA (merkezi servisten)
    double netHesap = bordro['net'] ?? 0;

    // SGK ve diğer detayları merkezi servisten al (isteğe bağlı)
    double sgkKesintisi = bordro['sgk'] ?? 0;
    double issizlikKesintisi = bordro['issizlik'] ?? 0;
    double gelirVergisi = bordro['vergi'] ?? 0;
    double damgaVergisi = bordro['damga'] ?? 0;
    double agiIstisnasi = bordro['agi'] ?? 0;
    double damgaIstisnasi = bordro['damgaIstisnasi'] ?? 0;

    // 6. METİN OLUŞTUR (eski format korunsun)
    String metin =
        "- ${tarihMesai.toString()} Tarihinde ${mesaiSaati.toString()} $saatgunhangisi %${mesaiYuzdesi.toStringAsFixed(0)} Mesai";

    // 7. LİSTELERİ GÜNCELLE
    final tempList = List<String>.from(mesaiMetinListe.value);
    final tempNotList = List<String>.from(mesaiNotListe);

    if (islem == "ekle") {
      mesaiSaatListe.insert(0, mesaiSaati);
      mesaiBurutListe.insert(0, saatburuthesap); // mesaiBrut kullan
      mesaiNetListe.insert(0, netHesap);
      tempList.insert(0, metin);
      tempNotList.insert(0, notController.text);
    } else if (islem == "duzenle" && index != null) {
      mesaiSaatListe[index] = mesaiSaati;
      mesaiBurutListe[index] = saatburuthesap; // mesaiBrut kullan
      mesaiNetListe[index] = netHesap;
      tempList[index] = metin;
      tempNotList[index] = notController.text;
    } else if (islem == "sil" && index != null) {
      mesaiSaatListe.removeAt(index);
      mesaiBurutListe.removeAt(index);
      mesaiNetListe.removeAt(index);
      tempList.removeAt(index);
      tempNotList.removeAt(index);
    }

    mesaiMetinListe.value = tempList;
    mesaiNotListe = tempNotList;
    veriDegisti = true;
    mesaiListeKaydet();
    notController.clear();

    // DEBUG: Hesaplamaları kontrol et
    debugPrint('=== MERKEZİ SERVİS HESAPLAMA ===');
    debugPrint('Mesai Saati: $mesaiSaati');
    debugPrint('Ücret: $ucret');
    debugPrint('Mesai Yüzdesi: %$mesaiYuzdesi');
    debugPrint('Brüt (Merkezi): $mesaiBrut');
    debugPrint('Net (Merkezi): $netHesap');
    debugPrint('SGK: $sgkKesintisi');
    debugPrint('İşsizlik: $issizlikKesintisi');
    debugPrint('Gelir Vergisi: $gelirVergisi');
    debugPrint('Damga Vergisi: $damgaVergisi');
    debugPrint('AGİ İstisnası: $agiIstisnasi');
    debugPrint('Damga İstisnası: $damgaIstisnasi');
  }

  void hesaplaToplamlar() {
    double toplamSaatYazi = 0;
    for (int i = 0; i < mesaiSaatListe.length; i++) {
      toplamSaatYazi += mesaiSaatListe[i];
    }
    toplamMesai.text = toplamSaatYazi.toStringAsFixed(2);

    double burutSaatYazi = 0;
    for (int i = 0; i < mesaiBurutListe.length; i++) {
      burutSaatYazi += mesaiBurutListe[i];
    }
    brutMesai.text = burutSaatYazi.toStringAsFixed(2);

    double netSaatYazi = 0;
    for (int i = 0; i < mesaiNetListe.length; i++) {
      netSaatYazi += mesaiNetListe[i];
    }
    netMesai.text = netSaatYazi.toStringAsFixed(2);

    secilenIndex.value = -1; // Seçili öğeyi sıfırla
  }

  void mesaiListeKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('index', selectedIndex.value);
    prefs.setString('calisanTipi', calisanTipi);
    prefs.setDouble(
      '${selectedIndex.value}-$secilenYil-$secilenAy-saatUcreti',
      saatUcreti,
    );
    prefs.setInt(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiKdv',
      mesaiKdv.toInt(),
    );
    prefs.setInt(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiYüzde',
      mesaiSaatYuzde.toInt(),
    );

    prefs.setString(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiSaatListe',
      jsonEncode(mesaiSaatListe),
    );
    prefs.setString(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiBurutListe',
      jsonEncode(mesaiBurutListe),
    );
    prefs.setString(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiNetListe',
      jsonEncode(mesaiNetListe),
    );
    prefs.setString(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiMetinListe',
      jsonEncode(mesaiMetinListe.value),
    );
    prefs.setString(
      '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiNotListe',
      jsonEncode(mesaiNotListe),
    );

    hesaplaToplamlar();
    await prefs.setDouble(
      '${selectedIndex.value}-$secilenYil-$secilenAy-saat',
      double.parse(toplamMesai.text),
    );
    await prefs.setDouble(
      '${selectedIndex.value}-$secilenYil-$secilenAy-burut',
      double.parse(brutMesai.text),
    );
    await prefs.setDouble(
      '${selectedIndex.value}-$secilenYil-$secilenAy-net',
      double.parse(netMesai.text),
    );
  }

  Future<void> indexCagir() async {
    final prefs = await SharedPreferences.getInstance();
    selectedIndex.value = prefs.getInt('index') ?? 0;
  }

  Future<void> mesaiListeCagir() async {
    final prefs = await SharedPreferences.getInstance();
    calisanTipi = prefs.getString('calisanTipi') ?? "Normal";

    // Listeleri sıfırla
    mesaiSaatListe = [];
    mesaiBurutListe = [];
    mesaiNetListe = [];
    mesaiMetinListe.value = [];
    mesaiNotListe = [];

    // Ücret ve ayarları yükle
    double saatUcreti;
    int mesaiKdv;
    int mesaiYuzde;

    if (simdikiAy == secilenAy && simdikiYil == secilenYil) {
      saatUcreti =
          prefs.getDouble(
            '${selectedIndex.value}-$secilenYil-$secilenAy-saatUcreti',
          ) ??
          300;
      mesaiKdv =
          prefs.getInt(
            '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiKdv',
          ) ??
          15;
      mesaiYuzde =
          prefs.getInt(
            '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiYüzde',
          ) ??
          100;
    } else {
      saatUcreti =
          prefs.getDouble(
            '${selectedIndex.value}-$simdikiYil-$simdikiAy-saatUcreti',
          ) ??
          200;
      mesaiKdv =
          prefs.getInt(
            '${selectedIndex.value}-$simdikiYil-$simdikiAy-mesaiKdv',
          ) ??
          15;
      mesaiYuzde =
          prefs.getInt(
            '${selectedIndex.value}-$simdikiYil-$simdikiAy-mesaiYüzde',
          ) ??
          100;
    }

    // Ücret controller'larını güncelle
    if (selectedIndex.value == 0) {
      saatUcretiSec.text = saatUcreti.toString();
      gunlukUcretiSec.clear();
      aylikUcretiSec.clear();
    } else if (selectedIndex.value == 1) {
      gunlukUcretiSec.text = saatUcreti.toString();
      saatUcretiSec.clear();
      aylikUcretiSec.clear();
    } else {
      aylikUcretiSec.text = saatUcreti.toString();
      saatUcretiSec.clear();
      gunlukUcretiSec.clear();
    }
    kdvSec.text = '% $mesaiKdv';
    mesaiSec.text = '% $mesaiYuzde';

    // Listeleri yükle (her zaman secilenYil ve secilenAy ile)
    String saatJson =
        prefs.getString(
          '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiSaatListe',
        ) ??
        '[]';
    String burutJson =
        prefs.getString(
          '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiBurutListe',
        ) ??
        '[]';
    String netJson =
        prefs.getString(
          '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiNetListe',
        ) ??
        '[]';
    String metinJson =
        prefs.getString(
          '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiMetinListe',
        ) ??
        '[]';
    String notJson =
        prefs.getString(
          '${selectedIndex.value}-$secilenYil-$secilenAy-mesaiNotListe',
        ) ??
        '[]';

    // Verileri parse et
    try {
      mesaiSaatListe =
          (jsonDecode(saatJson) as List)
              .map((item) => double.parse(item.toString()))
              .toList();
      mesaiBurutListe =
          (jsonDecode(burutJson) as List)
              .map((item) => double.parse(item.toString()))
              .toList();
      mesaiNetListe =
          (jsonDecode(netJson) as List)
              .map((item) => double.parse(item.toString()))
              .toList();
      mesaiMetinListe.value =
          (jsonDecode(metinJson) as List)
              .map((item) => item.toString())
              .toList();
      // Not listesini yükle ve uyumluluğu sağla
      mesaiNotListe =
          (jsonDecode(notJson) as List).map((item) => item.toString()).toList();

      // Eğer mesaiNotListe'nin boyutu mesaiMetinListe'den küçükse, eksik notları "" ile doldur
      while (mesaiNotListe.length < mesaiMetinListe.value.length) {
        mesaiNotListe.add("");
      }
    } catch (e) {
      mesaiSaatListe = [];
      mesaiBurutListe = [];
      mesaiNetListe = [];
      mesaiMetinListe.value = [];
      mesaiNotListe = [];
    }

    // Toplamları hesapla
    hesaplaToplamlar();
  }

  bool mesaiTarihZatenVarMi(String tarih) {
    for (final metin in mesaiMetinListe.value) {
      final parts = metin.split(' ');
      if (parts.length > 1 && parts[1] == tarih) {
        return true;
      }
    }
    return false;
  }

  /// Mesai tarih listesini getirir
  List<String> getMesaiTarihListe() {
    final List<String> tarihler = [];
    for (final metin in mesaiMetinListe.value) {
      final parts = metin.split(' ');
      if (parts.length > 1) tarihler.add(parts[1]);
    }
    return tarihler;
  }

  Future<void> mesaiEkleDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required bool isEksik,
  }) async {
    _klavyeyiKapat();

    if (selectedIndex.value == 0 && saatUcretiSec.text.isEmpty) {
      Mesaj.altmesaj(context, 'Lütfen Saat Ücretini Giriniz.', Colors.red);
    } else if (selectedIndex.value == 1 && gunlukUcretiSec.text.isEmpty) {
      Mesaj.altmesaj(context, 'Lütfen Günlük Ücretini Giriniz.', Colors.red);
    } else if (selectedIndex.value == 2 && aylikUcretiSec.text.isEmpty) {
      Mesaj.altmesaj(context, 'Lütfen Aylık Ücretini Giriniz.', Colors.red);
    } else {
      notController.clear();
      if (selectedIndex.value == 0) {
        await mesaiSaatSecDialog(context, onUpdate: onUpdate, isEksik: isEksik);
      } else {
        await mesaiGunSecDialog(context, onUpdate: onUpdate, isEksik: isEksik);
      }
    }
  }

  Future<void> mesaiSaatSecDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required bool isEksik,
  }) async {
    // Tarih kontrolünü BURADAN KALDIRIYORUZ
    await AcilanPencere.show(
      context: context,
      title: isEksik ? 'Eksik Saat Seçiniz' : 'Mesai Saati Seçiniz',
      height: 0.95,
      content: MesaiSecimDialog(
        tarihController: tarihController,
        notController: notController,
        items: isEksik ? mesaiSaatEksikListe : mesaiSaatSecimListe,
        onSelected: (index) async {
          // async yapıyoruz
          final secilenTarih = tarihController.text;
          final secilenSaat =
              isEksik ? mesaiSaatEksikListe[index] : mesaiSaatSecimListe[index];

          // Tarih kontrolünü BURADA YAPIYORUZ
          if (mesaiTarihZatenVarMi(secilenTarih)) {
            Mesaj.altmesaj(
              context,
              '$secilenTarih tarihinde zaten mesai kaydı var! '
              'Lütfen mevcut kaydı düzenleyin veya farklı bir tarih seçin.',
              Colors.red,
            );
            return; // İşlemi durduruyoruz
          }

          secilenMesaiSaat = secilenSaat;
          tarihMesai = secilenTarih;
          listeyiGuncelle(islem: "ekle");
          Mesaj.altmesaj(
            context,
            double.parse(saatMesaiAyikla(secilenMesaiSaat)) < 0
                ? "${secilenMesaiSaat.toString()} düşüldü"
                : "${secilenMesaiSaat.toString()} Mesai Eklendi",
            Colors.green,
          );
          onUpdate();
        },
        onUpdate: () => mesaiListeKaydet(),
      ),
    );
  }

  Future<void> mesaiGunSecDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required bool isEksik,
  }) async {
    await AcilanPencere.show(
      context: context,
      title: isEksik ? 'Eksik Gün Seçiniz' : 'Mesai Gün Seçiniz',
      height: 0.95,
      content: MesaiSecimDialog(
        tarihController: tarihController,
        notController: notController,
        items: isEksik ? mesaiGunEksikListe : mesaiGunSecimListe,
        onSelected: (index) async {
          // async yapıyoruz
          final secilenTarih = tarihController.text;
          final secilenGun =
              isEksik ? mesaiGunEksikListe[index] : mesaiGunSecimListe[index];

          // Tarih kontrolünü BURADA YAPIYORUZ
          if (mesaiTarihZatenVarMi(secilenTarih)) {
            Mesaj.altmesaj(
              context,
              '$secilenTarih tarihinde zaten mesai kaydı var! '
              'Lütfen mevcut kaydı düzenleyin veya farklı bir tarih seçin.',
              Colors.red,
            );
            return; // İşlemi durduruyoruz
          }

          secilenMesaiSaat = secilenGun;
          tarihMesai = secilenTarih;
          listeyiGuncelle(islem: "ekle");
          Mesaj.altmesaj(
            context,
            double.parse(saatMesaiAyikla(secilenMesaiSaat)) < 0
                ? "${secilenMesaiSaat.toString()} düşüldü"
                : "${secilenMesaiSaat.toString()} Mesai Eklendi",
            Colors.green,
          );
          onUpdate();
        },
        onUpdate: () => mesaiListeKaydet(),
      ),
    );
  }

  Future<void> duzenleMesaiDialog(
    BuildContext context,
    int index, {
    required VoidCallback onUpdate,
  }) async {
    final eskitarih = mesaiMetinListe.value[index].split(' ')[1];
    tarihController.text = eskitarih;
    notController.text =
        mesaiNotListe.length > index ? mesaiNotListe[index] : "";
    final isEksik = mesaiSaatListe[index] < 0;

    await AcilanPencere.show(
      context: context,
      title:
          selectedIndex.value == 0
              ? isEksik
                  ? 'Eksik Saat Düzenle'
                  : 'Mesai Saati Düzenle'
              : isEksik
              ? 'Eksik Gün Düzenle'
              : 'Mesai Gün Düzenle',
      height: 0.95,
      content: MesaiSecimDialog(
        notController: notController,
        tarihController: tarihController,
        items:
            selectedIndex.value == 0
                ? isEksik
                    ? mesaiSaatEksikListe
                    : mesaiSaatSecimListe
                : isEksik
                ? mesaiGunEksikListe
                : mesaiGunSecimListe,
        onSelected: (listIndex) async {
          // async yapıyoruz
          final yeniTarih = tarihController.text;

          // Eğer tarih değişmişse ve yeni tarihte zaten mesai varsa
          if (yeniTarih != eskitarih && mesaiTarihZatenVarMi(yeniTarih)) {
            Mesaj.altmesaj(
              context,
              '$yeniTarih tarihinde zaten mesai kaydı var! '
              'Farklı bir tarih seçin veya mevcut kaydı silin.',
              Colors.red,
            );
            return; // İşlemi durduruyoruz
          }

          tarihMesai = yeniTarih;
          secilenMesaiSaat =
              selectedIndex.value == 0
                  ? isEksik
                      ? mesaiSaatEksikListe[listIndex]
                      : mesaiSaatSecimListe[listIndex]
                  : isEksik
                  ? mesaiGunEksikListe[listIndex]
                  : mesaiGunSecimListe[listIndex];
          listeyiGuncelle(islem: "duzenle", index: index);
          Mesaj.altmesaj(context, "Mesai Güncellendi", Colors.green);
          onUpdate();
        },
        onUpdate: () => mesaiListeKaydet(),
      ),
    );
  }

  void ciktilar(BuildContext context) {
    paylasimPenceresiAc(
      context: context,
      paylasPDF: paylasPDF,
      paylasExcel: paylasExcel,
      paylasMetin: paylas,
    );
  }

  void paylasPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Mesai Listesi"),
                pw.SizedBox(height: 10),
                pw.ListView.builder(
                  itemCount: mesaiMetinListe.value.length,
                  itemBuilder: (context, index) {
                    return pw.Text(
                      replaceTurkishChars(mesaiMetinListe.value[index]),
                    );
                  },
                ),
                pw.SizedBox(height: 10),
                pw.Text("Toplam Mesai : ${toplamMesai.text}"),
                pw.Text("Brut Mesai   : ${brutMesai.text}"),
                pw.Text("Net Mesai    : ${netMesai.text}"),
              ],
            ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/MesaiListesi.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
  }

  void paylasExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      "Mesai Listesi",
    );

    for (int i = 0; i < mesaiMetinListe.value.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(mesaiMetinListe.value[i]);
    }

    sheetObject
        .cell(CellIndex.indexByString("A${mesaiMetinListe.value.length + 2}"))
        .value = TextCellValue("Toplam Mesai");
    sheetObject
        .cell(CellIndex.indexByString("B${mesaiMetinListe.value.length + 2}"))
        .value = TextCellValue(toplamMesai.text);
    sheetObject
        .cell(CellIndex.indexByString("A${mesaiMetinListe.value.length + 3}"))
        .value = TextCellValue("Brut Mesai");
    sheetObject
        .cell(CellIndex.indexByString("B${mesaiMetinListe.value.length + 3}"))
        .value = TextCellValue(brutMesai.text);
    sheetObject
        .cell(CellIndex.indexByString("A${mesaiMetinListe.value.length + 4}"))
        .value = TextCellValue("Net Mesai");
    sheetObject
        .cell(CellIndex.indexByString("B${mesaiMetinListe.value.length + 4}"))
        .value = TextCellValue(netMesai.text);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/MesaiListesi.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file =
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Mesai Listesi Excel Paylaş',
        ),
      );
    }
  }

  void paylas() {
    String paylas = "Mesai Listesi\n";
    for (int i = 0; i < mesaiMetinListe.value.length; i++) {
      paylas += "${mesaiMetinListe.value[i]}\n";
    }
    paylas += "Toplam Mesai ${toplamMesai.text}\n";
    paylas += "Brüt Mesai ${brutMesai.text}\n";
    paylas += "Net Mesai ${netMesai.text}\n";
    SharePlus.instance.share(ShareParams(text: paylas));
  }

  String replaceTurkishChars(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 's')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'g')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'o');
  }

  void tarihSec(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );
    if (pickedDate != null) {
      tarihController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      tarihMesai = tarihController.text;
    }
  }
}
