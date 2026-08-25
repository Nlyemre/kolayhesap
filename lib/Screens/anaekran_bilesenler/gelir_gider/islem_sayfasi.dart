import 'dart:async';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/gelir_gider/ekle.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/grafikler.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/katagoriler.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/model_iki.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/tarih.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/veri_kayit.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_4.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_5.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

enum IslemTuru { giderler, gelirler, tumu }

enum ZamanAraligi { gunluk, haftalik, aylik, yillik }

extension ZamanAraligiExtension on ZamanAraligi {
  String get displayText {
    switch (this) {
      case ZamanAraligi.gunluk:
        return 'Günlük';
      case ZamanAraligi.haftalik:
        return 'Haftalık';
      case ZamanAraligi.aylik:
        return 'Aylık';
      case ZamanAraligi.yillik:
        return 'Yıllık';
    }
  }

  String tarihEtiketiOlustur(DateTime tarih) {
    switch (this) {
      case ZamanAraligi.gunluk:
        return DateFormat('dd MMM y', 'tr_TR').format(tarih).toUpperCase();
      case ZamanAraligi.haftalik:
        return 'Hafta ${TarihYardimci.haftaNumarasi(tarih)} - ${DateFormat('MMM y', 'tr_TR').format(tarih)}';
      case ZamanAraligi.aylik:
        return DateFormat('MMM y', 'tr_TR').format(tarih).toUpperCase();
      case ZamanAraligi.yillik:
        return DateFormat('y', 'tr_TR').format(tarih).toUpperCase();
    }
  }

  DateTime tarihAyarla(DateTime orijinalTarih) {
    switch (this) {
      case ZamanAraligi.gunluk:
        return DateTime(
          orijinalTarih.year,
          orijinalTarih.month,
          orijinalTarih.day,
        );
      case ZamanAraligi.haftalik:
        return TarihYardimci.haftaninIlkGunu(orijinalTarih);
      case ZamanAraligi.aylik:
        return DateTime(orijinalTarih.year, orijinalTarih.month);
      case ZamanAraligi.yillik:
        return DateTime(orijinalTarih.year);
    }
  }

  String get stringValue => toString().split('.').last;
}

class ZamanAraligiHelper {
  static ZamanAraligi fromString(String value) {
    switch (value) {
      case 'gunluk':
        return ZamanAraligi.gunluk;
      case 'haftalik':
        return ZamanAraligi.haftalik;
      case 'aylik':
        return ZamanAraligi.aylik;
      case 'yillik':
        return ZamanAraligi.yillik;
      default:
        return ZamanAraligi.aylik;
    }
  }
}

class IslemlerSayfasi extends StatefulWidget {
  IslemlerSayfasi({super.key}) : _key = GlobalKey();

  final GlobalKey<_IslemlerSayfasiState> _key;

  @override
  State<IslemlerSayfasi> createState() => _IslemlerSayfasiState();

  void refreshTransactions() {
    _key.currentState?._islemleriYukle();
  }
}

class _IslemlerSayfasiState extends State<IslemlerSayfasi> {
  final IslemServisi _islemServisi = IslemServisi();
  final NumberFormat _paraFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  IslemTuru _seciliTur = IslemTuru.tumu;
  ZamanAraligi _seciliZamanAraligi = ZamanAraligi.aylik;
  DateTime _seciliTarih = DateTime.now();
  String? _seciliKategori;

  List<IslemModel> _islemler = [];
  int _secilenIndex = -1;

  @override
  void initState() {
    super.initState();
    _islemleriYukle();
  }

  Future<void> _islemleriYukle() async {
    final islemler = await _islemServisi.islemleriGetir();
    setState(() {
      _islemler = islemler;
    });
  }

  List<IslemModel> _filtrelenmisIslemler() {
    return _islemler.where((islem) {
        // Tür filtresi
        final turUygun =
            _seciliTur == IslemTuru.tumu ||
            (_seciliTur == IslemTuru.giderler && islem.giderMi) ||
            (_seciliTur == IslemTuru.gelirler && !islem.giderMi);

        // Kategori filtresi
        final kategoriUygun =
            _seciliKategori == null || islem.kategori == _seciliKategori;

        // Tarih filtresi - Günlük için
        final islemTarihi = DateTime(
          islem.tarih.year,
          islem.tarih.month,
          islem.tarih.day,
        );
        final secilenTarih = DateTime(
          _seciliTarih.year,
          _seciliTarih.month,
          _seciliTarih.day,
        );

        bool tarihUygun;
        switch (_seciliZamanAraligi) {
          case ZamanAraligi.gunluk:
            tarihUygun = islemTarihi == _seciliTarih;
            break;
          case ZamanAraligi.haftalik:
            final haftaBaslangic = TarihYardimci.haftaninIlkGunu(secilenTarih);
            final haftaBitis = haftaBaslangic.add(const Duration(days: 6));
            tarihUygun =
                islemTarihi.isAfter(
                  haftaBaslangic.subtract(const Duration(days: 1)),
                ) &&
                islemTarihi.isBefore(haftaBitis.add(const Duration(days: 1)));
            break;
          case ZamanAraligi.aylik:
            tarihUygun =
                islemTarihi.year == secilenTarih.year &&
                islemTarihi.month == secilenTarih.month;
            break;
          case ZamanAraligi.yillik:
            tarihUygun = islemTarihi.year == secilenTarih.year;
            break;
        }

        return turUygun && kategoriUygun && tarihUygun;
      }).toList()
      ..sort((a, b) => b.tarih.compareTo(a.tarih));
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisIslemler = _filtrelenmisIslemler();
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final gelir = filtrelenmisIslemler
            .where((i) => !i.giderMi)
            .fold(0.0, (sum, item) => sum + item.miktar);
        final gider = filtrelenmisIslemler
            .where((i) => i.giderMi)
            .fold(0.0, (sum, item) => sum + item.miktar);
        final kalan = gelir - gider;

        Navigator.pop(context, {
          'gelir': gelir,
          'gider': gider,
          'kalan': kalan,
          'zamanAraligi': _seciliZamanAraligi.displayText,
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const BackButton(color: Renk.pastelKoyuMavi),
            onPressed: () {
              final gelir = filtrelenmisIslemler
                  .where((i) => !i.giderMi)
                  .fold(0.0, (sum, item) => sum + item.miktar);
              final gider = filtrelenmisIslemler
                  .where((i) => i.giderMi)
                  .fold(0.0, (sum, item) => sum + item.miktar);
              final kalan = gelir - gider;

              Navigator.pop(context, {
                'gelir': gelir,
                'gider': gider,
                'kalan': kalan,
                'zamanAraligi': _seciliZamanAraligi.displayText,
              });
            },
          ),

          title: const Text('Gelir - Gider Hesaplama'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                onPressed: () {
                  paylasimPenceresiAc(
                    context: context,
                    paylasPDF: _paylasPDF,
                    paylasExcel: _paylasExcel,
                    paylasMetin: _paylas,
                  );
                },
                icon: const Icon(
                  Icons.share,
                  size: 20.0,
                  color: Renk.pastelKoyuMavi,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _giderlertumugelirler(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200,
                            child: _grafikOlustur(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _zamanAraligiSecimi(),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: RepaintBoundary(child: YerelReklamdort()),
                        ),
                        baslik(
                          "${_seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih)} Gelir-Gider Toplamı",
                        ),
                        const SizedBox(height: 10),
                        _gelirgiderkalan(filtrelenmisIslemler),
                        const SizedBox(height: 5),
                        _tarihVeKategoriButonlar(),
                        const SizedBox(height: 6),
                        baslik(
                          "${_seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih)} Gelir-Gider Listesi",
                        ),
                        const SizedBox(height: 6),
                        _islemListesi(filtrelenmisIslemler),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                const RepaintBoundary(child: BannerReklam()),
              ],
            ),
            Positioned(
              right: 14,
              bottom: 80,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "Arti1",
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const EkleIslemSayfasi(isGider: false),
                          ),
                        );
                        if (result == true || result == null) {
                          _islemleriYukle();
                        }
                      },
                      backgroundColor: Colors.white,
                      elevation: 5,
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Renk.pastelKoyuMavi,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "Eksi1",
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const EkleIslemSayfasi(isGider: true),
                          ),
                        );
                        if (result == true || result == null) {
                          _islemleriYukle();
                        }
                      },
                      backgroundColor: Colors.white,
                      elevation: 5,
                      child: const Icon(
                        Icons.remove,
                        size: 30,
                        color: Renk.kirmizi,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget baslik(String metin) {
    return Container(
      height: 40,
      width: double.infinity,
      color: Renk.pastelKoyuMavi.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          metin,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Renk.pastelKoyuMavi,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _tarihVeKategoriButonlar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SizedBox(
        height: 35,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                onTap: _tarihSec,
                child: CizgiliCerceve(
                  golge: 5,
                  backgroundColor: Renk.acikgri,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Renk.pastelKoyuMavi,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih),
                          style: Dekor.butonText_12_500mavi,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                onTap: _kategoriSec,
                child: CizgiliCerceve(
                  golge: 5,
                  backgroundColor: Renk.acikgri,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.list,
                          size: 14,
                          color: Renk.pastelKoyuMavi,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _seciliKategori != null
                              ? _seciliKategori!
                              : 'KATEGORİ SEÇ',
                          style: Dekor.butonText_12_500mavi,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toplamkart(String baslik, String toplam) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 13, left: 4, right: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Renk.pastelKoyuMavi,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                width: double.infinity,
                child: CizgiliCerceve(
                  golge: 5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Text(
                    toplam,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gelirgiderkalan(List<IslemModel> filtrelenmisIslemler) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: CizgiliCerceve(
        golge: 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Row(
            children: [
              _toplamkart(
                'Gelir\nToplam',
                _paraFormat.format(
                  filtrelenmisIslemler
                      .where((i) => !i.giderMi)
                      .fold(0.0, (sum, item) => sum + item.miktar),
                ),
              ),
              _toplamkart(
                'Gider\nToplam',
                _paraFormat.format(
                  filtrelenmisIslemler
                      .where((i) => i.giderMi)
                      .fold(0.0, (sum, item) => sum + item.miktar),
                ),
              ),
              _toplamkart(
                'Kalan\nToplam',
                _paraFormat.format(
                  filtrelenmisIslemler
                          .where((i) => !i.giderMi)
                          .fold(0.0, (sum, item) => sum + item.miktar) -
                      filtrelenmisIslemler
                          .where((i) => i.giderMi)
                          .fold(0.0, (sum, item) => sum + item.miktar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _kategoriSec() async {
    final kategoriler =
        _seciliTur == IslemTuru.tumu
            ? [...gelirKategorileri, ...giderKategorileri]
            : _seciliTur == IslemTuru.giderler
            ? giderKategorileri
            : gelirKategorileri;

    FocusScope.of(context).unfocus();

    await AcilanPencere.show(
      context: context,
      title: 'Kategori Seçin',
      height: 0.9,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: CizgiliCerceve(
                  golge: 5,
                  backgroundColor: Renk.acikgri,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _seciliKategori = null);
                      Navigator.of(context).pop(); // Modal'ı kapat
                    },
                    child: const Text(
                      'Tümünü Seç',
                      style: TextStyle(color: Renk.pastelKoyuMavi),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: kategoriler.length,
                itemBuilder: (context, index) {
                  final kategori = kategoriler[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _seciliKategori = kategori.ad);
                      Navigator.of(context).pop(); // Modal'ı kapat
                    },
                    child: CizgiliCerceve(
                      golge: 5,
                      backgroundColor: Renk.acikgri,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              kategori.ikon,
                              color: Renk.pastelKoyuMavi,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              kategori.ad,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _tarihSec() async {
    int selectedYear = _seciliTarih.year;
    int? selectedMonth =
        _seciliZamanAraligi == ZamanAraligi.yillik ? null : _seciliTarih.month;

    final List<String> ayIsimleri = [
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

    await AcilanPencere.show(
      context: context,
      title: 'Görüntülenecek Tarihi Seç',
      height: 0.9,
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setModalState(() => selectedYear--);
                      },
                    ),
                    Text(
                      selectedYear.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setModalState(() => selectedYear++);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: CizgiliCerceve(
                    golge: 5,
                    backgroundColor: Renk.acikgri,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _seciliTarih = DateTime(selectedYear);
                          _seciliZamanAraligi = ZamanAraligi.yillik;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Tüm Yılı Göster',
                        style: TextStyle(color: Renk.pastelKoyuMavi),
                      ),
                    ),
                  ),
                ),
                if (_seciliZamanAraligi == ZamanAraligi.haftalik ||
                    _seciliZamanAraligi == ZamanAraligi.gunluk)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: CizgiliCerceve(
                        golge: 5,
                        backgroundColor: Renk.acikgri,
                        child: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              locale: const Locale('tr', 'TR'),
                            );
                            if (picked != null) {
                              setState(() {
                                _seciliTarih = picked;
                                if (_seciliZamanAraligi ==
                                    ZamanAraligi.haftalik) {
                                  _seciliTarih = TarihYardimci.haftaninIlkGunu(
                                    picked,
                                  );
                                }
                              });
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text(
                            'Gün Veya Hafta Seç',
                            style: TextStyle(color: Renk.pastelKoyuMavi),
                          ),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final ayAdi = ayIsimleri[index];
                      final ayNumarasi = index + 1;
                      final secili = selectedMonth == ayNumarasi;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _seciliTarih = DateTime(selectedYear, ayNumarasi);
                            _seciliZamanAraligi = ZamanAraligi.aylik;
                          });
                          Navigator.of(context).pop();
                        },
                        child: CizgiliCerceve(
                          golge: 5,
                          backgroundColor: Renk.acikgri,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ayAdi,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        secili
                                            ? Renk.pastelKoyuMavi
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedYear.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        secili
                                            ? Renk.pastelKoyuMavi
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _giderlertumugelirler() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: ButonlarRawChip(
                isSelected: _seciliTur == IslemTuru.gelirler,
                text: 'Gelirler',
                onSelected: () {
                  setState(() {
                    _seciliTur = IslemTuru.gelirler;
                    _seciliKategori = null;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: ButonlarRawChip(
                isSelected: _seciliTur == IslemTuru.tumu,
                text: 'Tümü',
                onSelected: () {
                  setState(() {
                    _seciliTur = IslemTuru.tumu;
                    _seciliKategori = null;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: ButonlarRawChip(
                isSelected: _seciliTur == IslemTuru.giderler,
                text: 'Giderler',
                onSelected: () {
                  setState(() {
                    _seciliTur = IslemTuru.giderler;
                    _seciliKategori = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zamanAraligiSecimi() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          _zamanAraligiButon(ZamanAraligi.gunluk),
          _zamanAraligiButon(ZamanAraligi.haftalik),
          _zamanAraligiButon(ZamanAraligi.aylik),
          _zamanAraligiButon(ZamanAraligi.yillik),
        ],
      ),
    );
  }

  Widget _zamanAraligiButon(ZamanAraligi aralik) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: ButonlarRawChip(
          isSelected: _seciliZamanAraligi == aralik,
          text: aralik.displayText,
          onSelected: () {
            setState(() {
              _seciliZamanAraligi = aralik;
              _seciliTarih = aralik.tarihAyarla(DateTime.now());
            });
          },
        ),
      ),
    );
  }

  Widget _islemListesi(List<IslemModel> islemler) {
    if (islemler.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Filtrelere uygun işlem bulunamadı')),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < islemler.length; index++) ...[
          // 3. öğeden önce reklamı ekle (index 2'ye denk geldiğinde)
          if (index == 2)
            const Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: 8),
              child: RepaintBoundary(child: YerelReklambes()),
            ),

          // Orijinal işlem öğesini göster (tüm index'ler için)
          _buildIslemItem(islemler[index], index),
        ],
      ],
    );
  }

  // İşlem öğesini ayrı bir metoda taşıdık (tekrar kullanım için)
  Widget _buildIslemItem(IslemModel islem, int index) {
    final kategori = (islem.giderMi ? giderKategorileri : gelirKategorileri)
        .firstWhere((k) => k.ad == islem.kategori);
    bool isSelected = _secilenIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_secilenIndex == index) {
            _secilenIndex = -1;
          } else {
            _secilenIndex = index;
          }
        });
      },
      child: Stack(
        children: [
          if (isSelected)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EkleIslemSayfasi(
                                  duzenlenecekIslem: islem,
                                  isGider: islem.giderMi,
                                ),
                          ),
                        );
                        if (result == true) {
                          _islemleriYukle();
                        }
                        setState(() => _secilenIndex = -1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 7,
                          right: 7,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: Renk.gradient,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          width: 60,
                          child: const Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final basarili = await _islemServisi.islemSil(islem.id);
                        if (basarili) {
                          _islemleriYukle();
                          Mesaj.altmesaj(
                            // ignore: use_build_context_synchronously
                            context,
                            'İşlem başarıyla silindi',
                            Colors.green,
                          );
                        } else {
                          Mesaj.altmesaj(
                            // ignore: use_build_context_synchronously
                            context,
                            'Silme işlemi başarısız oldu',
                            Colors.red,
                          );
                        }
                        setState(() => _secilenIndex = -1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                          top: 5,
                          right: 10,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.red],
                              begin: Alignment(1.0, -1.0),
                              end: Alignment(1.0, 1.0),
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          width: 60,
                          child: const Center(
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(isSelected ? -135 : 0, 0, 0),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              child: CizgiliCerceve(
                golge: 5,
                child: ListTile(
                  leading: Icon(kategori.ikon, color: Renk.pastelKoyuMavi),
                  title: Text(
                    islem.baslik,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${islem.kategori} • ${DateFormat('dd/MM/yyyy').format(islem.tarih)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (islem.not != null)
                        Text(
                          islem.not!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Text(
                    _paraFormat.format(islem.miktar),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: islem.giderMi ? Renk.kirmizi : Renk.pastelKoyuMavi,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grafikOlustur(BuildContext context) {
    final filtrelenmisIslemler = _filtrelenmisIslemler();
    if (filtrelenmisIslemler.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    switch (_seciliZamanAraligi) {
      case ZamanAraligi.gunluk:
        return GrafikYardimcisi.gunlukBarGrafikOlustur(
          context,
          filtrelenmisIslemler,
          baslangicTarihi: _seciliTarih,
          seciliTur: _seciliTur,
        );
      case ZamanAraligi.haftalik:
        return GrafikYardimcisi.haftalikBarGrafikOlustur(
          context,
          filtrelenmisIslemler,
          baslangicTarihi: _seciliTarih,
          seciliTur: _seciliTur,
        );
      case ZamanAraligi.aylik:
        return GrafikYardimcisi.aylikBarGrafikOlustur(
          context,
          filtrelenmisIslemler,
          baslangicTarihi: _seciliTarih,
          seciliTur: _seciliTur,
        );
      case ZamanAraligi.yillik:
        return GrafikYardimcisi.yillikBarGrafikOlustur(
          context,
          filtrelenmisIslemler,
          baslangicTarihi: _seciliTarih,
          seciliTur: _seciliTur,
        );
    }
  }

  void _paylasPDF() async {
    final filtrelenmisIslemler = _filtrelenmisIslemler();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                replaceTurkishChars(
                  "İşlem Listesi - ${_seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih)}",
                ),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          replaceTurkishChars('Tarih'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          replaceTurkishChars('Tür'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          replaceTurkishChars('Kategori'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          replaceTurkishChars('Miktar'),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...filtrelenmisIslemler.map(
                    (islem) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            DateFormat('dd/MM/yyyy').format(islem.tarih),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            replaceTurkishChars(
                              islem.giderMi ? 'Gider' : 'Gelir',
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(replaceTurkishChars(islem.kategori)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(_paraFormat.format(islem.miktar)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                replaceTurkishChars(
                  "Toplam Gelir: ${_paraFormat.format(filtrelenmisIslemler.where((i) => !i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}",
                ),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                replaceTurkishChars(
                  "Toplam Gider: ${_paraFormat.format(filtrelenmisIslemler.where((i) => i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}",
                ),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                replaceTurkishChars(
                  "Net Bakiye: ${_paraFormat.format(filtrelenmisIslemler.where((i) => !i.giderMi).fold(0.0, (sum, item) => sum + item.miktar) - filtrelenmisIslemler.where((i) => i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}",
                ),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final rawFileName =
        'IslemListesi_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final safeFileName = replaceTurkishChars(rawFileName);
    final filePath = '${directory.path}/$safeFileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
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
        .replaceAll('ö', 'o')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'u');
  }

  void _paylasExcel() async {
    final filtrelenmisIslemler = _filtrelenmisIslemler();
    var excel = Excel.createExcel();

    // İlgili sayfa
    Sheet sheetObject = excel['Sheet1'];

    // Başlık satırını manuel olarak ekle
    var cell = sheetObject.cell(CellIndex.indexByString("A1"));
    cell.value = TextCellValue(
      "İşlem Listesi - ${_seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih)}",
    );

    // Sütun başlıkları
    sheetObject.cell(CellIndex.indexByString("A2")).value = TextCellValue(
      "Tarih",
    );
    sheetObject.cell(CellIndex.indexByString("B2")).value = TextCellValue(
      "Tür",
    );
    sheetObject.cell(CellIndex.indexByString("C2")).value = TextCellValue(
      "Kategori",
    );
    sheetObject.cell(CellIndex.indexByString("D2")).value = TextCellValue(
      "Başlık",
    );
    sheetObject.cell(CellIndex.indexByString("E2")).value = TextCellValue(
      "Not",
    );
    sheetObject.cell(CellIndex.indexByString("F2")).value = TextCellValue(
      "Miktar",
    );

    // İşlem verilerini doldur
    for (int i = 0; i < filtrelenmisIslemler.length; i++) {
      final islem = filtrelenmisIslemler[i];
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3))
          .value = TextCellValue(DateFormat('dd/MM/yyyy').format(islem.tarih));
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3))
          .value = TextCellValue(islem.giderMi ? "Gider" : "Gelir");
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 3))
          .value = TextCellValue(islem.kategori);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 3))
          .value = TextCellValue(islem.baslik);
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 3))
          .value = TextCellValue(islem.not ?? "");
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 3))
          .value = TextCellValue(_paraFormat.format(islem.miktar));
    }

    // Toplam satırları
    final baslangicSatir = filtrelenmisIslemler.length + 4;

    sheetObject
        .cell(CellIndex.indexByString("A$baslangicSatir"))
        .value = TextCellValue("Toplam Gelir");
    sheetObject
        .cell(CellIndex.indexByString("B$baslangicSatir"))
        .value = TextCellValue(
      _paraFormat.format(
        filtrelenmisIslemler
            .where((i) => !i.giderMi)
            .fold(0.0, (sum, item) => sum + item.miktar),
      ),
    );

    sheetObject
        .cell(CellIndex.indexByString("A${baslangicSatir + 1}"))
        .value = TextCellValue("Toplam Gider");
    sheetObject
        .cell(CellIndex.indexByString("B${baslangicSatir + 1}"))
        .value = TextCellValue(
      _paraFormat.format(
        filtrelenmisIslemler
            .where((i) => i.giderMi)
            .fold(0.0, (sum, item) => sum + item.miktar),
      ),
    );

    sheetObject
        .cell(CellIndex.indexByString("A${baslangicSatir + 2}"))
        .value = TextCellValue("Net Bakiye");
    sheetObject
        .cell(CellIndex.indexByString("B${baslangicSatir + 2}"))
        .value = TextCellValue(
      _paraFormat.format(
        filtrelenmisIslemler
                .where((i) => !i.giderMi)
                .fold(0.0, (sum, item) => sum + item.miktar) -
            filtrelenmisIslemler
                .where((i) => i.giderMi)
                .fold(0.0, (sum, item) => sum + item.miktar),
      ),
    );

    // Excel dosyasını kaydet ve paylaş
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/IslemListesi_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file =
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'İşlem Listesi Excel Paylaş',
        ),
      );
    }
  }

  void _paylas() {
    final filtrelenmisIslemler = _filtrelenmisIslemler();
    String paylas = "";

    paylas +=
        "İşlem Listesi - ${_seciliZamanAraligi.tarihEtiketiOlustur(_seciliTarih)}\n\n";

    for (var islem in filtrelenmisIslemler) {
      paylas += "Tarih: ${DateFormat('dd/MM/yyyy').format(islem.tarih)}\n";
      paylas += "Tür: ${islem.giderMi ? 'Gider' : 'Gelir'}\n";
      paylas += "Kategori: ${islem.kategori}\n";
      paylas += "Başlık: ${islem.baslik}\n";
      if (islem.not != null) paylas += "Not: ${islem.not}\n";
      paylas += "Miktar: ${_paraFormat.format(islem.miktar)}\n\n";
    }

    paylas += "\nTOPLAMLAR\n";
    paylas +=
        "Toplam Gelir: ${_paraFormat.format(filtrelenmisIslemler.where((i) => !i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}\n";
    paylas +=
        "Toplam Gider: ${_paraFormat.format(filtrelenmisIslemler.where((i) => i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}\n";
    paylas +=
        "Net Bakiye: ${_paraFormat.format(filtrelenmisIslemler.where((i) => !i.giderMi).fold(0.0, (sum, item) => sum + item.miktar) - filtrelenmisIslemler.where((i) => i.giderMi).fold(0.0, (sum, item) => sum + item.miktar))}\n";

    SharePlus.instance.share(ShareParams(text: paylas));
  }
}
