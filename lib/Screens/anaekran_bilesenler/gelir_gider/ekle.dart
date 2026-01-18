import 'package:app/Screens/anaekran_bilesenler/gelir_gider/katagoriler.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/model_iki.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/tarih.dart';
import 'package:app/Screens/anaekran_bilesenler/gelir_gider/veri_kayit.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class EkleIslemSayfasi extends StatefulWidget {
  final IslemModel? duzenlenecekIslem;
  final bool isGider;

  const EkleIslemSayfasi({
    super.key,
    this.duzenlenecekIslem,
    this.isGider = true,
  });

  @override
  State<EkleIslemSayfasi> createState() => _EkleIslemSayfasiState();
}

class _EkleIslemSayfasiState extends State<EkleIslemSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _baslikKontrolcusu = TextEditingController();
  final _miktarKontrolcusu = TextEditingController();
  final _notKontrolcusu = TextEditingController();
  final IslemServisi _islemServisi = IslemServisi();

  DateTime _seciliTarih = DateTime.now();
  String _seciliKategori = giderKategorileri[0].ad;
  late bool _giderMi;

  @override
  void initState() {
    super.initState();

    _giderMi = widget.duzenlenecekIslem?.giderMi ?? widget.isGider;

    if (widget.duzenlenecekIslem != null) {
      final islem = widget.duzenlenecekIslem!;
      _baslikKontrolcusu.text = islem.baslik;
      _miktarKontrolcusu.text = islem.miktar.toString();
      _notKontrolcusu.text = islem.not ?? '';
      _seciliTarih = islem.tarih;
      _seciliKategori = islem.kategori;
      _giderMi = islem.giderMi;
    } else {
      final kategoriler = _giderMi ? giderKategorileri : gelirKategorileri;
      if (!kategoriler.any((k) => k.ad == _seciliKategori)) {
        _seciliKategori = kategoriler[0].ad;
      }
    }
  }

  @override
  void dispose() {
    _baslikKontrolcusu.dispose();
    _miktarKontrolcusu.dispose();
    _notKontrolcusu.dispose();
    super.dispose();
  }

  Future<void> _tarihSec(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _seciliTarih,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (secilen != null && secilen != _seciliTarih) {
      setState(() {
        _seciliTarih = secilen;
      });
    }
  }

  Future<void> _kategoriSec(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final kategoriler = _giderMi ? giderKategorileri : gelirKategorileri;

    await AcilanPencere.show(
      context: context,
      title: 'Kategori Seçin',
      height: 0.9,
      content: GridView.builder(
        padding: const EdgeInsets.all(10),
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
              setState(() {
                _seciliKategori = kategori.ad;
              });
              Navigator.of(context).pop();
            },
            child: CizgiliCerceve(
              golge: 5,
              backgroundColor: Renk.acikgri,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(kategori.ikon, color: Renk.pastelKoyuMavi, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    kategori.ad,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _formGonder() async {
    if (_formAnahtari.currentState!.validate()) {
      if (widget.duzenlenecekIslem != null) {
        final guncellenenIslem = IslemModel(
          id: widget.duzenlenecekIslem!.id,
          baslik: _baslikKontrolcusu.text,
          miktar: double.parse(_miktarKontrolcusu.text),
          tarih: _seciliTarih,
          kategori: _seciliKategori,
          giderMi: _giderMi,
          not: _notKontrolcusu.text.isNotEmpty ? _notKontrolcusu.text : null,
        );

        await _islemServisi.islemGuncelle(guncellenenIslem);
      } else {
        final yeniIslem = IslemModel(
          id: DateTime.now().toString(),
          baslik: _baslikKontrolcusu.text,
          miktar: double.parse(_miktarKontrolcusu.text),
          tarih: _seciliTarih,
          kategori: _seciliKategori,
          giderMi: _giderMi,
          not: _notKontrolcusu.text.isNotEmpty ? _notKontrolcusu.text : null,
        );

        await _islemServisi.islemEkle(yeniIslem);
      }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),
        title: Text(
          widget.duzenlenecekIslem != null
              ? (_giderMi ? 'Gider Düzenle' : 'Gelir Düzenle')
              : (_giderMi ? 'Gider Ekle' : 'Gelir Ekle'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
                top: 5,
              ),
              child: Form(
                key: _formAnahtari,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 13),
                      TextFormField(
                        cursorColor: Colors.black,
                        controller: _baslikKontrolcusu,
                        decoration: const InputDecoration(
                          labelText: 'Başlık',
                          hintText: 'Gelir veya gider başlığı',
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (deger) {
                          if (deger == null || deger.isEmpty) {
                            return 'Lütfen bir başlık girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        cursorColor: Colors.black,
                        controller: _miktarKontrolcusu,
                        decoration: const InputDecoration(
                          labelText: 'Miktar',
                          hintText: 'Örn: 250.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (deger) {
                          if (deger == null || deger.isEmpty) {
                            return 'Lütfen bir miktar girin';
                          }
                          final sayi = double.tryParse(deger);
                          if (sayi == null) {
                            return 'Lütfen geçerli bir sayı girin';
                          }
                          if (sayi <= 0) {
                            return 'Miktar 0\'dan büyük olmalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 13),
                      GestureDetector(
                        onTap: () => _tarihSec(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Tarih'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                TarihYardimci.formatla(_seciliTarih),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      GestureDetector(
                        onTap: () => _kategoriSec(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _seciliKategori,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        cursorColor: Colors.black,
                        controller: _notKontrolcusu,
                        decoration: const InputDecoration(
                          labelText: 'Not (Opsiyonel)',
                          hintText: 'Ek açıklama yazabilirsiniz',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _formGonder,
                        child: Renk.buton(
                          widget.duzenlenecekIslem != null
                              ? 'Güncelle'
                              : 'Kaydet',
                          45,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const RepaintBoundary(child: YerelReklam()),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }
}
