import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/maaskarsilastir/karsilastirana.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamhesaplama.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZamGiris extends StatefulWidget {
  final int id;
  final int grafikid;
  final int sayfa;
  const ZamGiris({
    super.key,
    required this.id,
    required this.grafikid,
    required this.sayfa,
  });

  @override
  State<ZamGiris> createState() => _ZamGirisState();
}

class _ZamGirisState extends State<ZamGiris> {
  // Lists initialization
  late List<List<double>> brutDetayList;
  late List<List<double>> saatDetayList;
  late List<List<double>> calismasaatList;
  late List<List<double>> ikramiyeList;
  late List<double> saatList;
  late List<double> brutList;
  late List<double> vergiList;
  late List<int> vergiNoList;
  late List<int> ekodemeNoList;
  late List<double> sosyalHakList;
  late List<double> cocukParasiList;
  late List<double> sadecebuayList;
  late List<double> sendikaList;
  late List<double> avansList;
  late List<int> secimList;
  late List<String> calisanTipiList;
  late List<int> engelliList;
  late List<String> mesaiList;
  late List<String> besList;
  late List<double> zamList;
  late List<double> kidemList;
  late List<double> sosyalzamList;

  // Controllers
  final List<TextEditingController> _saatKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _saatzamKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _saatkidemKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _aylikCalismaSaatKontrol = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _brutKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _zamKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _kidemKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _ikramiyeKontrolDetay = List.generate(
    12,
    (index) => TextEditingController(),
  );

  // Other controllers
  final TextEditingController _sosyalgelirKontrol = TextEditingController();
  final TextEditingController _cocukKontrol = TextEditingController();
  final TextEditingController _sadecebuayyardim = TextEditingController();
  final TextEditingController _avansKontrol = TextEditingController();
  final TextEditingController _sendikaKontrol = TextEditingController();
  final TextEditingController _vergiMatrakDegistirKontrol =
      TextEditingController();
  final TextEditingController _ozelvergiMatrakDegistirKontrol =
      TextEditingController();
  final TextEditingController _burutZamKontrol = TextEditingController();
  final TextEditingController _brutKontrol = TextEditingController();
  final TextEditingController _saatKontrol = TextEditingController();
  final TextEditingController _saatzamKontrol = TextEditingController();
  final TextEditingController _kidemKontrol = TextEditingController();
  final TextEditingController _saatkidemKontrol = TextEditingController();
  final TextEditingController zamsosyalhakkontrol = TextEditingController();

  // Dropdown values
  final List<int> _dropdownDegerleri = List<int>.filled(250, 0);
  double _dropdownDegerlerisendika = 0.0;
  double _dropdownDegerleriavans = 0.0;
  int _saatdetayindex = 0;

  // State variables
  String? _secilenAy;
  String? _ekodemeAy;
  String? _ozelvergi;
  String sendikaKontYazi = "";
  String avansKontYazi = "";
  String mesaiEkle = "Hayir";
  String besEkle = "Hayir";
  int vergiAySatirNo = 0;
  int ozelvergiAySatirNo = 0;
  int ekodemeSatirNo = 0;
  String calisanTipi = "Normal";
  int engelliSayi = 0;
  List<bool> isSelected = [true, false, false, false];
  int _selectedIndex = 0;
  int karsilatirmaanahtar = 0;
  String butontext = "Hesapla";

  // Constants
  static const List<String> aylarYazi = [
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
    'Brüt\nÜcret',
    'Brüt\nDetay',
    'Saat\nÜcret',
    'Saat\nDetay',
  ];

  static const List<String> engelliListe = ['Yok', '1', '2', '3'];

  static const List<String> aylargun = [
    '232.5',
    '211',
    '232.5',
    '225',
    '232.5',
    '225',
    '232.5',
    '232.5',
    '225',
    '232.5',
    '225',
    '232.5',
  ];

  // Dynamic widgets
  List<TextEditingController> dinamikKontroller = [];
  List<String> metinBasliklar = [];
  List<Widget> widgets = [];
  String yeniLabelText = '';
  bool silGorunur = false;

  // Current date strings
  late String simdikiAy;
  late String simdikiYil;
  late String aySayi;

  @override
  void initState() {
    super.initState();
    _initializeDateStrings();
    _girisindexCagir();
    _initializeLists();
    initializeDateFormatting('tr_TR');
    _secimlerCagir();
    _updateButtonText();
    _dinamiksosyalhaklar();
  }

  void _initializeDateStrings() {
    simdikiAy = DateFormat('MMMM').format(DateTime.now());
    simdikiYil = DateFormat('yyyy').format(DateTime.now());
    aySayi = DateFormat('M').format(DateTime.now());
  }

  void _updateButtonText() {
    setState(() {
      butontext =
          widget.id == 3
              ? (widget.grafikid == 1 || widget.grafikid == 4)
                  ? 'Karşılaştır'
                  : '2. Maaş Detaylarını Gir'
              : 'Hesapla';
    });
  }

  void _initializeLists() {
    brutDetayList = List.generate(2, (_) => List.filled(12, 0.0));
    saatDetayList = List.generate(2, (_) => List.filled(12, 0.0));
    calismasaatList = List.generate(2, (_) => List.filled(12, 0.0));
    ikramiyeList = List.generate(2, (_) => List.filled(12, 0.0));

    saatList = List.filled(2, 0.0);
    brutList = List.filled(2, 0.0);
    vergiList = List.filled(2, 0.0);
    vergiNoList = List.filled(2, 0);
    ekodemeNoList = List.filled(2, 0);
    sosyalHakList = List.filled(2, 0.0);
    cocukParasiList = List.filled(2, 0.0);
    sadecebuayList = List.filled(2, 0.0);
    sendikaList = List.filled(2, 0.0);
    avansList = List.filled(2, 0.0);
    secimList = List.filled(2, 0);
    calisanTipiList = List.filled(2, "Normal");
    engelliList = List.filled(2, 0);
    mesaiList = List.filled(2, "Hayır");
    besList = List.filled(2, "Hayır");

    zamList = List.filled(12, 0.0);
    kidemList = List.filled(12, 0.0);
    sosyalzamList = List.filled(12, 0.0);
  }

  Future<void> _secimlerKayit() async {
    final prefs = await SharedPreferences.getInstance();

    // Tüm Future'ları bir listeye topla
    List<Future<void>> futures = [
      prefs.setInt('secim', _selectedIndex),
      prefs.setString('calisanTipi', calisanTipi),
      prefs.setInt('engelli', engelliSayi),
      prefs.setString('MesaiEkle', mesaiEkle),
      prefs.setString('besEkle', besEkle),
      prefs.setDouble(
        'vergiKayit',
        _parseDouble(_vergiMatrakDegistirKontrol.text),
      ),
      prefs.setDouble(
        'ozelvergiKayit',
        _parseDouble(_ozelvergiMatrakDegistirKontrol.text),
      ),
      prefs.setInt('vergiAyNo', vergiAySatirNo),
      prefs.setInt('ozelvergiAyNo', ozelvergiAySatirNo),
      prefs.setInt('ekodemeNo', ekodemeSatirNo),
      prefs.setDouble('sosyalHak', _parseDouble(_sosyalgelirKontrol.text)),
      prefs.setDouble('cocukparasi', _parseDouble(_cocukKontrol.text)),
      prefs.setDouble('sadecebuayyardim', _parseDouble(_sadecebuayyardim.text)),
      prefs.setDouble('sendikaKesintisi', _parseDouble(_sendikaKontrol.text)),
      prefs.setDouble('sendikasaatKesintisi', _dropdownDegerlerisendika),
      prefs.setDouble('avans', _parseDouble(_avansKontrol.text)),
      prefs.setDouble('avanssaat', _dropdownDegerleriavans),
    ];
    // Diğer fonksiyonlardan gelen Future'ları ekle
    futures.addAll(_saveMonthlyValues(prefs));
    futures.addAll(_saveBrutValues(prefs));
    futures.addAll(_saveZamValues(prefs));

    await Future.wait(futures);
    _maaskarsilastirmalistekayit();
  }

  double _parseDouble(String value) {
    return value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
  }

  List<Future> _saveMonthlyValues(SharedPreferences prefs) {
    List<Future> futures = [];
    for (int i = 0; i < 12; i++) {
      futures.add(
        prefs.setDouble(
          'calısmaSaati$i',
          _parseDouble(_aylikCalismaSaatKontrol[i].text),
        ),
      );
      futures.add(
        prefs.setDouble(
          'ikramiyetext$i',
          _parseDouble(_ikramiyeKontrolDetay[i].text),
        ),
      );
      futures.add(prefs.setInt('ikramiyesaattext$i', _dropdownDegerleri[i]));
    }
    return futures;
  }

  List<Future> _saveBrutValues(SharedPreferences prefs) {
    List<Future> futures = [];
    if (_selectedIndex == 0) {
      futures.add(
        prefs.setDouble(
          '$simdikiYil-$aySayi-brüt',
          _parseDouble(_brutKontrol.text),
        ),
      );
    } else if (_selectedIndex == 1) {
      for (int i = 0; i < 12; i++) {
        futures.add(
          prefs.setDouble(
            '$simdikiYil-$i-brüt',
            _parseDouble(_brutKontrolDetay[i].text),
          ),
        );
      }
    } else if (_selectedIndex == 2) {
      futures.add(
        prefs.setDouble(
          '$simdikiYil-$aySayi-saatUcreti',
          _parseDouble(_saatKontrol.text),
        ),
      );
    } else if (_selectedIndex == 3) {
      for (int i = 0; i < 12; i++) {
        futures.add(
          prefs.setDouble(
            '$simdikiYil-$i-saatUcreti',
            _parseDouble(_saatKontrolDetay[i].text),
          ),
        );
      }
    }
    return futures;
  }

  List<Future> _saveZamValues(SharedPreferences prefs) {
    List<Future> futures = [];
    if ((widget.id == 1) || (widget.id == 3)) {
      for (int i = 0; i < 12; i++) {
        zamList[i] = _getZamValue(i);
        kidemList[i] = _getKidemValue(i);
        sosyalzamList[i] = _getSosyalZamValue(i);
      }
    }
    return futures;
  }

  double _getZamValue(int index) {
    if (_selectedIndex == 0) return _parseDouble(_burutZamKontrol.text);
    if (_selectedIndex == 1) return _parseDouble(_zamKontrolDetay[index].text);
    if (_selectedIndex == 2) return _parseDouble(_saatzamKontrol.text);
    return _parseDouble(_saatzamKontrolDetay[index].text);
  }

  double _getKidemValue(int index) {
    if (_selectedIndex == 0) return _parseDouble(_kidemKontrol.text);
    if (_selectedIndex == 1) {
      return _parseDouble(_kidemKontrolDetay[index].text);
    }
    if (_selectedIndex == 2) return _parseDouble(_saatkidemKontrol.text);
    return _parseDouble(_saatkidemKontrolDetay[index].text);
  }

  double _getSosyalZamValue(int index) {
    final sosyalZam = _parseDouble(zamsosyalhakkontrol.text);
    return sosyalZam == 0 ? _getZamValue(index) : sosyalZam;
  }

  void _maaskarsilastirmalistekayit() {
    for (int i = 0; i < 12; i++) {
      brutDetayList[0][i] = _parseDouble(_brutKontrolDetay[i].text);
      saatDetayList[0][i] = _parseDouble(_saatKontrolDetay[i].text);
      calismasaatList[0][i] = _parseDouble(_aylikCalismaSaatKontrol[i].text);
      ikramiyeList[0][i] = _parseDouble(_ikramiyeKontrolDetay[i].text);
    }

    brutList[0] = _parseDouble(_brutKontrol.text);
    saatList[0] = _parseDouble(_saatKontrol.text);
    vergiList[0] = _parseDouble(_vergiMatrakDegistirKontrol.text);
    vergiNoList[0] = vergiAySatirNo;
    ekodemeNoList[0] = ekodemeSatirNo;
    sosyalHakList[0] = _parseDouble(_sosyalgelirKontrol.text);
    cocukParasiList[0] = _parseDouble(_cocukKontrol.text);
    sadecebuayList[0] = _parseDouble(_sadecebuayyardim.text);
    sendikaList[0] = _parseDouble(_sendikaKontrol.text);
    avansList[0] = _parseDouble(_avansKontrol.text);
    secimList[0] = _selectedIndex;
    calisanTipiList[0] = calisanTipi;
    engelliList[0] = engelliSayi;
    mesaiList[0] = mesaiEkle;
    besList[0] = besEkle;

    if (widget.id == 3 && widget.grafikid == 2) {
      butontext = "Maaşları Karşılaştır";
      for (var controller in _brutKontrolDetay) {
        controller.clear();
      }
      for (var controller in _saatKontrolDetay) {
        controller.clear();
      }
      _brutKontrol.clear();
      _saatKontrol.clear();
      karsilatirmaanahtar = 1;
      _bilgiDialog(
        " İlk maaş bilgileri başarıyla kaydedildi ve giriş alanları sıfırlandı. Şimdi, ikinci maaş karşılaştırmasını yapmak için aynı alanlara ikinci maaş bilgilerinizi girin.",
      );
      setState(() {});
    } else {
      sayfayaGit();
    }
  }

  void _maaskarsilastirmalistekayitikinciMaas() {
    for (int i = 0; i < 12; i++) {
      brutDetayList[1][i] = _parseDouble(_brutKontrolDetay[i].text);
      saatDetayList[1][i] = _parseDouble(_saatKontrolDetay[i].text);
      calismasaatList[1][i] = _parseDouble(_aylikCalismaSaatKontrol[i].text);
      ikramiyeList[1][i] = _parseDouble(_ikramiyeKontrolDetay[i].text);
    }

    brutList[1] = _parseDouble(_brutKontrol.text);
    saatList[1] = _parseDouble(_saatKontrol.text);
    vergiList[1] = _parseDouble(_vergiMatrakDegistirKontrol.text);
    vergiNoList[1] = vergiAySatirNo;
    ekodemeNoList[1] = ekodemeSatirNo;
    sosyalHakList[1] = _parseDouble(_sosyalgelirKontrol.text);
    cocukParasiList[1] = _parseDouble(_cocukKontrol.text);
    sadecebuayList[1] = _parseDouble(_sadecebuayyardim.text);
    sendikaList[1] = _parseDouble(_sendikaKontrol.text);
    avansList[1] = _parseDouble(_avansKontrol.text);
    secimList[1] = _selectedIndex;
    calisanTipiList[1] = calisanTipi;
    engelliList[1] = engelliSayi;
    mesaiList[1] = mesaiEkle;
    besList[1] = besEkle;

    sayfayaGit();
  }

  Future<void> _secimlerCagir() async {
    final prefs = await SharedPreferences.getInstance();
    _setDefaultValues();
    await _loadPreferences(prefs);
    setState(() {});
  }

  void _setDefaultValues() {
    _burutZamKontrol.text = "0";
    _kidemKontrol.text = "0";
    _saatkidemKontrol.text = "0";
    _saatzamKontrol.text = "0";
    zamsosyalhakkontrol.text = "0";
  }

  Future<void> _loadPreferences(SharedPreferences prefs) async {
    _brutKontrol.text =
        _getPreferenceDouble(prefs, '$simdikiYil-$aySayi-brüt').toString();

    _saatKontrol.text =
        _getPreferenceDouble(
          prefs,
          '$simdikiYil-$aySayi-saatUcreti',
        ).toString();

    for (int i = 0; i < 12; i++) {
      _brutKontrolDetay[i].text =
          _getPreferenceDouble(prefs, '$simdikiYil-$i-brüt').toString();
      _zamKontrolDetay[i].text = "0";
      _kidemKontrolDetay[i].text = "0";

      _saatKontrolDetay[i].text =
          _getPreferenceDouble(prefs, '$simdikiYil-$i-saatUcreti').toString();
      _saatzamKontrolDetay[i].text = "0";
      _saatkidemKontrolDetay[i].text = "0";

      _ikramiyeKontrolDetay[i].text =
          _getPreferenceDouble(prefs, 'ikramiyetext$i').toString();
      _dropdownDegerleri[i] = prefs.getInt('ikramiyesaattext$i') ?? 0;

      double calismaSaati = _getPreferenceDouble(prefs, 'calısmaSaati$i');
      _aylikCalismaSaatKontrol[i].text =
          calismaSaati == 0 ? aylargun[i] : calismaSaati.toString();
    }

    calisanTipi = prefs.getString('calisanTipi') ?? 'Normal';
    engelliSayi = prefs.getInt('engelli') ?? 0;
    mesaiEkle = prefs.getString('MesaiEkle') ?? 'Hayir';
    besEkle = prefs.getString('besEkle') ?? 'Hayir';

    _vergiMatrakDegistirKontrol.text =
        _getPreferenceDouble(prefs, 'vergiKayit').toString();
    _ozelvergiMatrakDegistirKontrol.text =
        _getPreferenceDouble(prefs, 'ozelvergiKayit').toString();

    vergiAySatirNo = prefs.getInt('vergiAyNo') ?? int.parse(aySayi) - 1;
    ozelvergiAySatirNo = prefs.getInt('ozelvergiAyNo') ?? int.parse(aySayi) - 1;
    ekodemeSatirNo = prefs.getInt('ekodemeNo') ?? int.parse(aySayi) - 1;

    _sosyalgelirKontrol.text =
        _getPreferenceDouble(prefs, 'sosyalHak').toString();
    _cocukKontrol.text = _getPreferenceDouble(prefs, 'cocukparasi').toString();
    _sadecebuayyardim.text =
        _getPreferenceDouble(prefs, 'sadecebuayyardim').toString();

    _sendikaKontrol.text =
        _getPreferenceDouble(prefs, 'sendikaKesintisi').toString();
    _dropdownDegerlerisendika = _getPreferenceDouble(
      prefs,
      'sendikasaatKesintisi',
    );

    _avansKontrol.text = _getPreferenceDouble(prefs, 'avans').toString();
    _dropdownDegerleriavans = _getPreferenceDouble(prefs, 'avanssaat');

    _secilenAy = aylarYazi[vergiAySatirNo];
    _ekodemeAy = aylarYazi[ekodemeSatirNo];
    _ozelvergi = aylarYazi[ozelvergiAySatirNo];
  }

  double _getPreferenceDouble(SharedPreferences prefs, String key) {
    return prefs.getDouble(key) ?? 0.0;
  }

  Future<void> _girisindexCagir() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedIndex = prefs.getInt('secim') ?? 0;
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = (i == _selectedIndex);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _disposeControllerList(_saatKontrolDetay);
    _disposeControllerList(_saatzamKontrolDetay);
    _disposeControllerList(_saatkidemKontrolDetay);
    _disposeControllerList(_aylikCalismaSaatKontrol);
    _disposeControllerList(_brutKontrolDetay);
    _disposeControllerList(_zamKontrolDetay);
    _disposeControllerList(_kidemKontrolDetay);
    _disposeControllerList(_ikramiyeKontrolDetay);

    _sosyalgelirKontrol.dispose();
    _cocukKontrol.dispose();
    _sadecebuayyardim.dispose();
    _avansKontrol.dispose();
    _sendikaKontrol.dispose();
    _vergiMatrakDegistirKontrol.dispose();
    _ozelvergiMatrakDegistirKontrol.dispose();
    _burutZamKontrol.dispose();
    _brutKontrol.dispose();
    _saatKontrol.dispose();
    _saatzamKontrol.dispose();
    _kidemKontrol.dispose();
    _saatkidemKontrol.dispose();
    zamsosyalhakkontrol.dispose();

    for (var controller in dinamikKontroller) {
      controller.dispose();
    }
    dinamikKontroller.clear();
  }

  void _disposeControllerList(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  void sayfayaGit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZamHesaplama(
              sayfaId: widget.id,
              zamList: zamList,
              kidemList: kidemList,
              grafiksayfaId: widget.grafikid,
              brutDetayList: brutDetayList,
              saatDetayList: saatDetayList,
              calismasaatList: calismasaatList,
              ikramiyeList: ikramiyeList,
              saatList: saatList,
              brutList: brutList,
              vergiList: vergiList,
              vergiNoList: vergiNoList,
              sosyalHakList: sosyalHakList,
              cocukParasiList: cocukParasiList,
              sendikaList: sendikaList,
              avansList: avansList,
              secimList: secimList,
              calisanTipiList: calisanTipiList,
              engelliList: engelliList,
              mesaiList: mesaiList,
              sosyalzamList: sosyalzamList,
              sadecebuayList: sadecebuayList,
              ekodemeList: ekodemeNoList,
              sayfa: widget.sayfa,
              besList: besList,
              ozelvergi: _parseDouble(_ozelvergiMatrakDegistirKontrol.text),
              ozelvergino: ozelvergiAySatirNo,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    widget.id == 3
                        ? KarsilastirAna(sayfano: widget.sayfa)
                        : widget.id == 1
                        ? const Anasayfa(pozisyon: 0, tarihyenile: "")
                        : widget.grafikid == 3
                        ? const Anasayfa(pozisyon: 1, tarihyenile: "")
                        : const Anasayfa(pozisyon: 0, tarihyenile: ""),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.pastelKoyuMavi),
          backgroundColor: Colors.white,

          title: const Text(
            "Ne Hesaplamak İstersiniz?",

            textScaler: TextScaler.noScaling,
          ),
        ),
        body: GestureDetector(
          onTap: () {
            // Tüm ekranda klavye kontrolü
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 8,
                    bottom: 10,
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(isSelected.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: ButonlarRawChip(
                            isSelected: isSelected[index],
                            text: butonyazi[index],
                            onSelected: () {
                              setState(() {
                                _selectedIndex = index;
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = i == index;
                                }
                              });
                            },
                            maxLines: 2,
                            height: 45,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(child: ortasayfalar(_selectedIndex)),
                const RepaintBoundary(child: BannerReklam()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ortasayfalar(int index) {
    switch (index) {
      case 0:
        return _buildSingleChildScrollView([
          _burutsatir(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _sosyalYardimVekodeme(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _ikramiye(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kesintilerVeEkodemeler(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kumalatifVergimatrak(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _digersecenekleralt(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RepaintBoundary(child: YerelReklam()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _hesaplabuton(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _altbilgilendirme(),
          ),
          const SizedBox(height: 40),
        ]);
      case 1:
        return _buildSingleChildScrollView([
          _burutDetay(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _sosyalYardimVekodeme(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _ikramiye(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kesintilerVeEkodemeler(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kumalatifVergimatrak(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _digersecenekleralt(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RepaintBoundary(child: YerelReklamiki()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _hesaplabuton(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _altbilgilendirme(),
          ),
          const SizedBox(height: 40),
        ]);
      case 2:
        return _buildSingleChildScrollView([
          _saatsatir(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _sosyalYardimVekodeme(),
          ),
          _selectedIndex == 2 || _selectedIndex == 3
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _aylikcalismaSaati(),
              )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _ikramiye(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kesintilerVeEkodemeler(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kumalatifVergimatrak(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _digersecenekleralt(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RepaintBoundary(child: YerelReklamuc()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _hesaplabuton(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _altbilgilendirme(),
          ),
          const SizedBox(height: 40),
        ]);
      case 3:
        return _buildSingleChildScrollView([
          _saatDetay(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _sosyalYardimVekodeme(),
          ),
          _selectedIndex == 2 || _selectedIndex == 3
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _aylikcalismaSaati(),
              )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _ikramiye(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kesintilerVeEkodemeler(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _kumalatifVergimatrak(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _digersecenekleralt(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RepaintBoundary(child: YerelReklam()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _hesaplabuton(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _altbilgilendirme(),
          ),
          const SizedBox(height: 40),
        ]);
      default:
        return Container();
    }
  }

  Widget _buildSingleChildScrollView(List<Widget> children) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: children),
    );
  }

  Widget _burutDetay() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 5),
          child: Container(
            height: 45,
            color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.id == 1
                            ? "Brüt Detay Zam Hesapla"
                            : widget.id == 2
                            ? "Brüt Detay Hesapla"
                            : widget.grafikid == 1
                            ? "Brüt Detay Zam Karşılaştırma"
                            : widget.grafikid == 4
                            ? "Brüt Detay Ülke Para Birimi Ka.."
                            : "Brüt Detay Maaş Karşılaştırma",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      widget.id == 3
                          ? const SizedBox(height: 48)
                          : _bilgizam(
                            widget.id == 1
                                ? "  Brüt ücret zam hesaplama, çalışanın mevcut brüt maaşına belirli bir oranda artış ekleyerek yeni brüt maaşı belirleme işlemidir.Brüt satırına beklediğiniz Ay'ın brüt tutarını,zam satırına beklediğiniz zam oranını varsa kidem satırına beklenen kidem ücreti çarpı kazanılmış kıdem sene(beklenen kıdem zammı 2 tl olan bir çalışan 10 senelik kazanılmış kıdem için kıdem satırına 20 tl yazması gerekiyor) girmeniz gerekmektedir."
                                : "  Brüt ücret, çalışanın işverenle yaptığı sözleşme kapsamında aldığı toplam maaştır. Bu tutar, vergiler, sosyal güvenlik primleri ve diğer kesintiler yapılmadan önceki toplam miktardır. Brüt ücret, çalışanın elde edeceği net gelirden farklıdır, çünkü kesintiler sonrası eline geçen miktar net ücreti oluşturur.",
                          ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 11),
                    child: SizedBox(
                      width: 110,
                      height: 30,
                      child: ElevatedButton.icon(
                        label: const Text(
                          'Tümünü Temizle',
                          style: TextStyle(fontSize: 10),
                        ),
                        onPressed: () {
                          setState(() {
                            for (var controller in _brutKontrolDetay) {
                              controller.clear();
                            }
                            for (var controller in _zamKontrolDetay) {
                              controller.clear();
                            }
                            for (var controller in _kidemKontrolDetay) {
                              controller.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
          child: Column(
            children: List.generate(12, (index) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MetinKutusu(
                        controller: _brutKontrolDetay[index],
                        labelText: 'Brüt Ücret ${aylarYazi[index]}',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              if (num.tryParse(value) != null) {
                                for (int i = index; i < 12; i++) {
                                  if (i > 0) {
                                    _brutKontrolDetay[i].text = value;
                                  }
                                }
                              }
                            });
                          }
                        },
                        clearButtonVisible: true,
                      ),
                    ),
                  ),
                  if (widget.id == 1 ||
                      (widget.id == 3 && widget.grafikid == 1))
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: MetinKutusu(
                          controller: _zamKontrolDetay[index],
                          labelText: 'Zam %',
                          hintText: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (num.tryParse(value) != null) {
                                  for (int i = index; i < 12; i++) {
                                    if (i > 0) {
                                      _zamKontrolDetay[i].text = value;
                                    }
                                  }
                                }
                              });
                            }
                          },
                          clearButtonVisible: true,
                        ),
                      ),
                    ),
                  if (widget.id == 1 ||
                      (widget.id == 3 && widget.grafikid == 1))
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: MetinKutusu(
                          controller: _kidemKontrolDetay[index],
                          labelText: 'Kıdem',
                          hintText: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (num.tryParse(value) != null) {
                                  for (int i = index; i < 12; i++) {
                                    if (i > 0) {
                                      _kidemKontrolDetay[i].text = value;
                                    }
                                  }
                                }
                              });
                            }
                          },
                          clearButtonVisible: true,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _burutsatir() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 5),
          child: Container(
            height: 45,
            color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.id == 1
                        ? "Brüt Ücret Zam Hesapla"
                        : widget.id == 2
                        ? "Brüt Ücret Hesaplama"
                        : widget.grafikid == 1
                        ? "Brüt Ücret Zam Karşılaştırma"
                        : widget.grafikid == 4
                        ? "Brüt Ücret Ülke Para Birimi Karşılaştırma"
                        : "Brüt Ücret Maaş Karşılaştırma",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  widget.id == 3
                      ? const SizedBox(height: 48)
                      : _bilgizam(
                        widget.id == 1
                            ? " Brüt ücret zam hesaplama, çalışanın mevcut brüt maaşına belirli bir oranda artış ekleyerek yeni brüt maaşı belirleme işlemidir.Brüt satırına beklediğiniz Ay'ın brüt tutarını,zam satırına beklediğiniz zam oranını varsa kidem satırına beklenen kidem ücreti çarpı kazanılmış kıdem sene(beklenen kıdem zammı 2 tl olan bir çalışan 10 senelik kazanılmış kıdem için kıdem satırına 20 tl yazması gerekiyor) girmeniz gerekmektedir."
                            : " Brüt ücret, çalışanın işverenle yaptığı sözleşme kapsamında aldığı toplam maaştır. Bu tutar, vergiler, sosyal güvenlik primleri ve diğer kesintiler yapılmadan önceki toplam miktardır. Brüt ücret, çalışanın elde edeceği net gelirden farklıdır, çünkü kesintiler sonrası eline geçen miktar net ücreti oluşturur. ",
                      ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 12,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: MetinKutusu(
                  controller: _brutKontrol,
                  labelText: 'Brüt Maaş',
                  hintText: '0,00 TL',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {},
                  clearButtonVisible: true,
                ),
              ),
              if (widget.id == 1 || (widget.id == 3 && widget.grafikid == 1))
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MetinKutusu(
                      controller: _burutZamKontrol,
                      labelText: 'Zam %',
                      hintText: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                ),
              if (widget.id == 1 || (widget.id == 3 && widget.grafikid == 1))
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MetinKutusu(
                      controller: _kidemKontrol,
                      labelText: 'Kıdem',
                      hintText: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saatsatir() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 5),
          child: Container(
            height: 45,
            color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.id == 1
                        ? "Saat Ücret Zam Hesapla"
                        : widget.id == 2
                        ? "Saat Ücret Hesapla"
                        : widget.grafikid == 1
                        ? "Saat Ücret Zam Karşılaştırma"
                        : widget.grafikid == 4
                        ? "Saat Ücret Ülke Para Birimi Karşılaştırma"
                        : "Saat Ücret Maaş Karşılaştırma",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  widget.id == 3
                      ? const SizedBox(height: 48)
                      : _bilgizam(
                        widget.id == 1
                            ? " Saat ücret zam hesaplama, çalışanın mevcut saat ücretine belirli bir oranda artış ekleyerek yeni saat ücretini belirleme işlemidir.Saat ücret satırına beklediğiniz Ay'ın saat ücretini,zam satırına beklediğiniz zam oranını varsa kidem satırına beklenen kidem ücreti çarpı kazanılmış kıdem sene(beklenen kıdem zammı 2 tl olan bir çalışan 10 senelik kazanılmış kıdem için kıdem satırına 20 tl yazması gerekiyor) girmeniz gerekmektedir."
                            : " Saat ücreti, çalışanın bir saatlik çalışma süresi karşılığında aldığı ücret miktarıdır. Bu tutar, çalışanın işvereni ile yaptığı anlaşmaya göre belirlenir ve brüt ücretin saatlik dilimidir. Saat ücreti, özellikle saatlik çalışanlar veya yarı zamanlı işler için önemlidir. Çalışanın toplam kazancı, haftalık veya aylık çalışma saatine bağlı olarak hesaplanır.",
                      ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
            left: 10,
            right: 10,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: MetinKutusu(
                  controller: _saatKontrol,
                  labelText: 'Saat Ücret',
                  hintText: '0,00 TL',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        if (num.tryParse(value) != null) {
                          for (int i = 0; i < 12; i++) {
                            if (_dropdownDegerleri[i] > 0) {
                              double maassaat =
                                  double.tryParse(_saatKontrol.text) ?? 0.0;
                              double saat =
                                  double.tryParse(
                                    _dropdownDegerleri[i].toString(),
                                  ) ??
                                  0.0;
                              _ikramiyeKontrolDetay[i].text = (saat * maassaat)
                                  .toStringAsFixed(2);
                            }
                          }
                          if (_dropdownDegerlerisendika > 0) {
                            double sendikasaat =
                                double.tryParse(_saatKontrol.text) ?? 0.0;
                            _sendikaKontrol.text = (sendikasaat *
                                    _dropdownDegerlerisendika)
                                .toStringAsFixed(2);
                          }
                          if (_dropdownDegerleriavans > 0) {
                            double avanssaat =
                                double.tryParse(_saatKontrol.text) ?? 0.0;
                            _avansKontrol.text = (avanssaat *
                                    _dropdownDegerleriavans)
                                .toStringAsFixed(2);
                          }
                        }
                      });
                    }
                  },
                  clearButtonVisible: true,
                ),
              ),
              if (widget.id == 1 || (widget.id == 3 && widget.grafikid == 1))
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MetinKutusu(
                      controller: _saatzamKontrol,
                      labelText: 'Zam %',
                      hintText: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                ),
              if (widget.id == 1 || (widget.id == 3 && widget.grafikid == 1))
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MetinKutusu(
                      controller: _saatkidemKontrol,
                      labelText: 'Kıdem',
                      hintText: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saatDetay() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 5),
          child: Container(
            height: 45,
            color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.id == 1
                            ? "Saat Detay Zam Hesapla"
                            : widget.id == 2
                            ? "Saat Detay Hesapla"
                            : widget.grafikid == 1
                            ? "Saat Detay Zam Karşılaştırma"
                            : widget.grafikid == 4
                            ? "Saat Detay Ülke Para Birimi Ka.."
                            : "Saat Detay Maaş Karşılaştırma",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      widget.id == 3
                          ? const SizedBox(height: 48)
                          : _bilgizam(
                            widget.id == 1
                                ? " Saat ücret zam hesaplama, çalışanın mevcut saat ücretine belirli bir oranda artış ekleyerek yeni saat ücretini belirleme işlemidir.Saat ücret satırına beklediğiniz Ay'ın saat ücretini,zam satırına beklediğiniz zam oranını varsa kidem satırına beklenen kidem ücreti çarpı kazanılmış kıdem sene(beklenen kıdem zammı 2 tl olan bir çalışan 10 senelik kazanılmış kıdem için kıdem satırına 20 tl yazması gerekiyor) girmeniz gerekmektedir."
                                : " Saat ücreti, çalışanın bir saatlik çalışma süresi karşılığında aldığı ücret miktarıdır. Bu tutar, çalışanın işvereni ile yaptığı anlaşmaya göre belirlenir ve brüt ücretin saatlik dilimidir. Saat ücreti, özellikle saatlik çalışanlar veya yarı zamanlı işler için önemlidir. Çalışanın toplam kazancı, haftalık veya aylık çalışma saatine bağlı olarak hesaplanır.",
                          ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 11),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        for (var controller in _saatKontrolDetay) {
                          controller.clear();
                        }
                      });
                    },
                    child: const CizgiliCerceve(
                      golge: 5,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 6,
                        bottom: 6,
                      ),
                      child: Text(
                        "Tümünü Temizle",
                        style: TextStyle(
                          color: Renk.pastelKoyuMavi,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
          child: Column(
            children: List.generate(12, (index) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MetinKutusu(
                        controller: _saatKontrolDetay[index],
                        labelText: 'Saat Ücret ${aylarYazi[index]}',
                        hintText: '0,00 TL',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              if (num.tryParse(value) != null) {
                                _saatdetayindex = index;
                                for (int i = index; i < 12; i++) {
                                  if (i > 0) {
                                    _saatKontrolDetay[i].text = value;
                                    if (_dropdownDegerleri[i] > 0) {
                                      double maassaat =
                                          double.tryParse(
                                            _saatKontrolDetay[i].text,
                                          ) ??
                                          0.0;
                                      double saat =
                                          double.tryParse(
                                            _dropdownDegerleri[i].toString(),
                                          ) ??
                                          0.0;
                                      _ikramiyeKontrolDetay[i].text =
                                          (saat * maassaat).toStringAsFixed(2);
                                    }
                                  }
                                }
                                if (_dropdownDegerlerisendika > 0) {
                                  double maassaat =
                                      double.tryParse(
                                        _saatKontrolDetay[index].text,
                                      ) ??
                                      0.0;
                                  _sendikaKontrol.text = (maassaat *
                                          _dropdownDegerlerisendika)
                                      .toStringAsFixed(2);
                                }
                                if (_dropdownDegerleriavans > 0) {
                                  double avanssaat =
                                      double.tryParse(
                                        _saatKontrolDetay[index].text,
                                      ) ??
                                      0.0;
                                  _avansKontrol.text = (avanssaat *
                                          _dropdownDegerleriavans)
                                      .toStringAsFixed(2);
                                }
                              }
                            });
                          }
                        },
                        clearButtonVisible: true,
                      ),
                    ),
                  ),
                  if (widget.id == 1 ||
                      (widget.id == 3 && widget.grafikid == 1))
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: MetinKutusu(
                          controller: _saatzamKontrolDetay[index],
                          labelText: 'Zam %',
                          hintText: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (num.tryParse(value) != null) {
                                  for (int i = index; i < 12; i++) {
                                    if (i > 0) {
                                      _saatzamKontrolDetay[i].text = value;
                                    }
                                  }
                                }
                              });
                            }
                          },
                          clearButtonVisible: true,
                        ),
                      ),
                    ),
                  if (widget.id == 1 ||
                      (widget.id == 3 && widget.grafikid == 1))
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: MetinKutusu(
                          controller: _saatkidemKontrolDetay[index],
                          labelText: 'Kıdem',
                          hintText: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (num.tryParse(value) != null) {
                                  for (int i = index; i < 12; i++) {
                                    if (i > 0) {
                                      _saatkidemKontrolDetay[i].text = value;
                                    }
                                  }
                                }
                              });
                            }
                          },
                          clearButtonVisible: true,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _ikramiye() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "İkramiye Ayları",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                "Her ay veya farklı aylarda ikramiye alıyorsanız, bu ikramiyelerin hangi aylarda ve ne kadar alındığını belirtiniz. Bu bilgiler, net maaşınızı daha doğru bir şekilde hesaplamayı ve ek gelirlerinizi takip etmenizi sağlayacaktır.Dilerseniz bu miktarları saat olarak girebilir böylece aylık çalışma saatinizde yaptığınız değişiklik otomatik olarak buraya saat karşılığı tutar yansıtılır.",
              ),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, right: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              for (var controller in _ikramiyeKontrolDetay) {
                                controller.clear();
                              }
                              if (_selectedIndex == 2 || _selectedIndex == 3) {
                                for (int i = 0; i < 12; i++) {
                                  _dropdownDegerleri[i] = 0;
                                }
                              }
                            });
                          },
                          child: const CizgiliCerceve(
                            golge: 5,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Text(
                              "Tümünü Temizle",
                              style: TextStyle(
                                color: Renk.pastelKoyuMavi,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: List.generate(12, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: MetinKutusu(
                                controller: _ikramiyeKontrolDetay[index],
                                labelText: 'İkramiye ${aylarYazi[index]}',
                                hintText: '0,0 TL',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      // Elle girilen değer, altındaki tüm metin kutularına yansıtılır
                                      for (int i = index; i < 12; i++) {
                                        _ikramiyeKontrolDetay[i].text = value;
                                      }
                                    }
                                  });
                                },
                                clearButtonVisible: true,
                              ),
                            ),
                            if (_selectedIndex == 2 || _selectedIndex == 3)
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: DropdownButtonFormField<int>(
                                    dropdownColor: Colors.white,
                                    initialValue: _dropdownDegerleri[index],
                                    decoration: const InputDecoration(
                                      labelText: "Saat Olarak Seç",
                                    ),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        for (int i = index; i < 12; i++) {
                                          _dropdownDegerleri[i] = newValue!;
                                          double saat = 0.0;
                                          if (_selectedIndex == 2) {
                                            saat =
                                                double.tryParse(
                                                  _saatKontrol.text,
                                                ) ??
                                                0.0;
                                          } else if (_selectedIndex == 3) {
                                            saat =
                                                double.tryParse(
                                                  _saatKontrolDetay[i].text,
                                                ) ??
                                                0.0;
                                          }
                                          _ikramiyeKontrolDetay[i]
                                              .text = (newValue * saat)
                                              .toStringAsFixed(2);
                                        }
                                      });
                                    },
                                    items: List.generate(250, (i) {
                                      return DropdownMenuItem<int>(
                                        value: i,
                                        child: Text(
                                          '$i',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kesintilerVeEkodemeler() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Kesintiler ve Ön Ödemeler",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                "Sendika kesintisi, sendika üyeliğinizden dolayı her ay maaşınızdan belirli bir saat çalışma tutarı düşülen bir miktardır ve sendikanın hizmetlerinden faydalanmanızı sağlar. Avans kesintisi ise, iş yerinizden aldığınız avansın geri ödemesini ifade eder. Bu bilgiler, maaşınızı daha net ve detaylı hesaplanmasına yardımcı olur.Dilerseniz bu miktarları saat olarak girebilir böylece aylık çalışma saatinizde yaptığınız değişiklik otomatik olarak buraya saat karşılığı tutar yansıtılır.",
              ),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MetinKutusu(
                        controller: _sendikaKontrol,
                        labelText: 'Sendika Kesintisi (opsiyonel)',
                        hintText: '0,00 TL',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {},
                        clearButtonVisible: true,
                      ),
                    ),
                    if (_selectedIndex == 2 || _selectedIndex == 3)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: DropdownButtonFormField<double>(
                            dropdownColor: Colors.white,
                            initialValue: _dropdownDegerlerisendika,
                            decoration: const InputDecoration(
                              labelText: "Saat Olarak Seç",
                            ),
                            onChanged: (double? newValue) {
                              setState(() {
                                _dropdownDegerlerisendika = newValue!;
                                double saat =
                                    _selectedIndex == 2
                                        ? double.parse(_saatKontrol.text)
                                        : _selectedIndex == 3
                                        ? double.parse(
                                          _saatKontrolDetay[_saatdetayindex]
                                              .text,
                                        )
                                        : 0;
                                _sendikaKontrol.text = (newValue * saat)
                                    .toStringAsFixed(2);
                              });
                            },
                            items: List.generate(50, (i) {
                              double value =
                                  i * 0.5; // 0.5 artırımlı değerler oluştur
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MetinKutusu(
                        controller: _avansKontrol,
                        labelText: 'Avans Ücreti (opsiyonel)',
                        hintText: '0,00 TL',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {},
                        clearButtonVisible: true,
                      ),
                    ),
                    if (_selectedIndex == 2 || _selectedIndex == 3)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: DropdownButtonFormField<double>(
                            dropdownColor: Colors.white,
                            initialValue: _dropdownDegerleriavans,
                            decoration: const InputDecoration(
                              labelText: "Saat Olarak Seç",
                            ),
                            onChanged: (double? newValue) {
                              setState(() {
                                _dropdownDegerleriavans = newValue!;
                                double saat =
                                    _selectedIndex == 2
                                        ? double.parse(_saatKontrol.text)
                                        : _selectedIndex == 3
                                        ? double.parse(
                                          _saatKontrolDetay[_saatdetayindex]
                                              .text,
                                        )
                                        : 0;
                                _avansKontrol.text = (newValue * saat)
                                    .toStringAsFixed(2);
                              });
                            },
                            items: List.generate(251, (i) {
                              double value =
                                  i * 0.5; // 0.5 artırımlı değerler oluştur
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kumalatifVergimatrak() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Kümülatif Vergi Matrahı",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                " Kümülatif vergi matrahı, her ay elde edilen brüt gelirlerin toplanarak hesaplanmasıdır.Vergi matrahı hesaplamaları bu aylık toplam gelir üzerinden yapılır ve vergi kesintileri % si buna göre belirlenir.Daha doğru bir hesaplama için mevcut ayın kümülatif vergi matrağını girmeyi unutmayın.Ayrıca bordronuzda gözüken özel vergi indirimini girmeyi unutmayın.Örneğin Türkiye'de, tamamlayıcı sağlık sigortası giderleri, belirli koşullar altında özel vergi indirimine tabi tutulabilir. Bu indirim, bireylerin yıllık vergi matrahından düşülebilir ve dolayısıyla ödenecek vergi miktarını azaltır.",
              ),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.bottom,

                          controller: _vergiMatrakDegistirKontrol,
                          decoration: const InputDecoration(
                            labelText: 'Kümülatif Vergi Toplamı (opsiyonel)',

                            hintText: '0,00 TL',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onTap: () {
                            if (_vergiMatrakDegistirKontrol.text.trim() ==
                                "0.0") {
                              // Kullanıcının görebilmesi için controller değerini boş yap
                              _vergiMatrakDegistirKontrol.clear();
                            }
                          },
                          onChanged: (value) {
                            // Girilen metindeki virgülleri nokta ile değiştir
                            String formattedValue = value.replaceAll(',', '.');
                            if (formattedValue != value) {
                              // Eğer değişiklik varsa controller'ı güncelle
                              _vergiMatrakDegistirKontrol.text = formattedValue;
                              // İmleci metnin sonuna taşı
                              _vergiMatrakDegistirKontrol
                                  .selection = TextSelection.fromPosition(
                                TextPosition(offset: formattedValue.length),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          initialValue: _secilenAy,
                          decoration: const InputDecoration(
                            labelText: "Ay Seçiniz",
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _secilenAy = newValue;
                              int secilenAyIndex = aylarYazi.indexOf(
                                newValue!,
                              ); // Seçilen ayın indeksini alıyoruz

                              vergiAySatirNo = secilenAyIndex;
                            });
                          },
                          items:
                              aylarYazi.map((String ay) {
                                return DropdownMenuItem<String>(
                                  value: ay,
                                  child: Text(
                                    ay,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,

                        controller: _ozelvergiMatrakDegistirKontrol,
                        decoration: const InputDecoration(
                          labelText: 'Özel Vergi İndirimi (opsiyonel)',

                          hintText: '0,00 TL',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onTap: () {
                          if (_ozelvergiMatrakDegistirKontrol.text.trim() ==
                              "0.0") {
                            // Kullanıcının görebilmesi için controller değerini boş yap
                            _ozelvergiMatrakDegistirKontrol.clear();
                          }
                        },
                        onChanged: (value) {
                          // Girilen metindeki virgülleri nokta ile değiştir
                          String formattedValue = value.replaceAll(',', '.');
                          if (formattedValue != value) {
                            // Eğer değişiklik varsa controller'ı güncelle
                            _ozelvergiMatrakDegistirKontrol.text =
                                formattedValue;
                            // İmleci metnin sonuna taşı
                            _ozelvergiMatrakDegistirKontrol
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: formattedValue.length),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        initialValue: _ozelvergi,
                        decoration: const InputDecoration(
                          labelText: "Ay Seçiniz",
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _ozelvergi = newValue;
                            int secilenAyIndex = aylarYazi.indexOf(
                              newValue!,
                            ); // Seçilen ayın indeksini alıyoruz

                            ozelvergiAySatirNo = secilenAyIndex;
                          });
                        },
                        items:
                            aylarYazi.map((String ay) {
                              return DropdownMenuItem<String>(
                                value: ay,
                                child: Text(
                                  ay,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aylikcalismaSaati() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Aylik Çalışma Saati",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                " Aylık çalışma saati, günlük 7.5 saat üzerinden hesaplanmaktadır. Bu durumda, ayın gün sayısı ile çarparak aylık toplam çalışma saatinizi bulabilirsiniz. Eğer farklı bir aylık çalışma saati uygulamanız varsa, 'Aylık Çalışma Saati' satırına yeni aylık çalışma saatinizi girerek hesaplamalarınızı buna göre güncelleyebilirsiniz.",
              ),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                      left: 2,
                      right: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              for (int i = 0; i < 12; i++) {
                                _aylikCalismaSaatKontrol[i].text = aylargun[i];
                              }
                            });
                          },
                          child: const CizgiliCerceve(
                            golge: 5,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Text(
                              "Ay'ın Gün Sayısına Ayarla",
                              style: TextStyle(
                                color: Renk.pastelKoyuMavi,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              for (var controller in _aylikCalismaSaatKontrol) {
                                controller.clear();
                              }
                            });
                          },
                          child: const CizgiliCerceve(
                            golge: 5,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Text(
                              "Tümünü Temizle",
                              style: TextStyle(
                                color: Renk.pastelKoyuMavi,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: List.generate(12, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: MetinKutusu(
                          controller: _aylikCalismaSaatKontrol[index],
                          labelText: 'Aylık Çalışma Saati ${aylarYazi[index]}',
                          hintText: '0,00 TL',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (num.tryParse(value) != null) {
                                  for (int i = index; i < 12; i++) {
                                    if (i > 0) {
                                      _aylikCalismaSaatKontrol[i].text = value;
                                    }
                                  }
                                }
                              });
                            }
                          },
                          clearButtonVisible: true,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _digersecenekleralt() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Diğer Seçenekler",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                " Daha fazla detay eklemek isterseniz, 'Diğer seçenekler' tıklayarak Çalışan Tipi, Engellilik Durumu,B.E.S Kesintisi %3 ve Mesaileri eklemeyi güncelleyebilir, değişikliklerinizi kaydedebilirsiniz. Bu, maaş hesaplamasını daha doğru ve kişisel hale getirmenize yardımcı olur.",
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Çalışan Tipi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              calisanTipi =
                                  calisanTipi == 'Emekli'
                                      ? 'Normal'
                                      : calisanTipi == 'Normal'
                                      ? 'SGK Yok'
                                      : 'Emekli';
                            });
                          },
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            calisanTipi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              calisanTipi =
                                  calisanTipi == 'Normal'
                                      ? 'Emekli'
                                      : calisanTipi == 'Emekli'
                                      ? 'SGK Yok'
                                      : 'Normal';
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Dekor.cizgi15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Engellilik Durumu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (engelliSayi > 0) {
                                engelliSayi--;
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            engelliListe[engelliSayi],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (engelliSayi < engelliListe.length - 1) {
                                engelliSayi++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Dekor.cizgi15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'B.E.S. %3 Kesinti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (besEkle == 'Evet') {
                                besEkle = 'Hayir';
                              } else {
                                besEkle = 'Evet';
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            besEkle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (besEkle == 'Evet') {
                                besEkle = 'Hayir';
                              } else {
                                besEkle = 'Evet';
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Dekor.cizgi15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mesaileri Ekle',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (mesaiEkle == 'Evet') {
                                mesaiEkle = 'Hayir';
                              } else {
                                mesaiEkle = 'Evet';
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            mesaiEkle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Renk.pastelKoyuMavi,
                          ),
                          onPressed: () {
                            setState(() {
                              if (mesaiEkle == 'Evet') {
                                mesaiEkle = 'Hayir';
                              } else {
                                mesaiEkle = 'Evet';
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hesaplabuton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Doğrulama
                    if (_selectedIndex == 0 && _brutKontrol.text.isEmpty) {
                      Mesaj.altmesaj(
                        context,
                        "Lütfen brüt maaş giriniz.",
                        Colors.red,
                      );
                      return;
                    }
                    if (_selectedIndex == 2 && _saatKontrol.text.isEmpty) {
                      Mesaj.altmesaj(
                        context,
                        "Lütfen saat ücreti giriniz.",
                        Colors.red,
                      );
                      return;
                    }
                    _toplaVeAta();
                    _kaydetWidgets();
                    if (karsilatirmaanahtar == 1) {
                      _maaskarsilastirmalistekayitikinciMaas();
                    } else {
                      _secimlerKayit();
                    }
                  },
                  child: Renk.buton(butontext, 50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sosyalyardimsatirekleme() {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (dinamikKontroller.isNotEmpty) {
                  silGorunur = true;
                } else {
                  Mesaj.altmesaj(
                    context,
                    "Kaldırılacak öğe bulunamadı.",
                    Colors.red,
                  );
                }
              });
            },
            child: const CizgiliCerceve(
              golge: 5,
              padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Text(
                " Ödeme Satırı Kaldır ",
                style: TextStyle(
                  color: Renk.pastelKoyuMavi,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                silGorunur = false;
              });

              // AcilanPencere.show() ile modal açma
              AcilanPencere.show(
                context: context,
                title: "Yeni Ödeme Satırı Ekle",
                height: 0.8,
                content: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Ödeme Adı Belirleyin',
                        ),
                        onChanged: (value) {
                          setState(() {
                            yeniLabelText = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Renk.buton('İptal', 45),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (yeniLabelText.isNotEmpty) {
                                  _ekleWidget(
                                    yeniLabelText,
                                    fromSharedPreferences: true,
                                  );
                                  Navigator.of(context).pop();
                                  setState(() {});
                                } else {
                                  Mesaj.altmesaj(
                                    context,
                                    "Lütfen Ödeme İsmi Giriniz",
                                    Colors.red,
                                  );
                                }
                              },
                              child: Renk.buton('Kaydet', 45),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          textAlign: TextAlign.center,
                          'Lütfen bu ödeme için kolayca tanıyabileceğiniz bir isim girin. Örneğin: "Yol yardımı", "Prim ödemesi", "Üretim Primi", "Performans bonusu". Bu isim, ödeme kayıtlarınızı düzenli tutmanıza yardımcı olur.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                adWidget: const YerelReklamiki(),
              );
            },
            child: const CizgiliCerceve(
              golge: 5,
              padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Text(
                " Ödeme Satırı Ekle ",
                style: TextStyle(
                  color: Renk.pastelKoyuMavi,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sosyalYardimVekodeme() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(left: 3, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Sosyal Yardım Ve Ek Ödemeler",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgizam(
                "Bu alan, her ay düzenli olarak aldığınız veya belirli aylarda aldığınız ek ödemeleri hesaplamaya eklemek için kullanılmaktadır. Sosyal yardımlar, devlet veya işveren tarafından sunulan desteklerdir ve maddi durumunuzu iyileştirmeyi hedefler. Ek ödemeler ise, özel durumlar veya belirli dönemlerde yapılan finansal yardımlardır. Bu bilgileri kaydederek, gelirlerinizi daha iyi planlayabilir ve mali durumunuzu değerlendirebilirsiniz.Yeni ek ödeme satırı oluşturmak için Ödeme satırı ekle butonuna basarka oluşturabilirsiniz ayrıca mevcut satırları iptal etmek içinde ödeme satırı kaldır butonunu tıklayarak dilediğiniz satırı kaldırabilirsiniz.",
              ),
            ],
          ),
        ),
        children: [
          Column(
            children: [
              widget.id == 1 || (widget.id == 3 && widget.grafikid == 1)
                  ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: MetinKutusu(
                                controller: zamsosyalhakkontrol,
                                labelText:
                                    'Sosyal Haklar Zam Oranı Farklıysa % Giriniz',
                                hintText: '0',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (value) {},
                                clearButtonVisible: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _sosyalyardimsatirekleme(),
                    ],
                  )
                  : _sosyalyardimsatirekleme(),
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      " * Ödemeyi her ay alıyorsanız buraya giriniz.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              ...widgets.map((widget) {
                return Stack(
                  children: [
                    widget, // direkt olarak widget'i kullanın
                    Positioned(
                      right: 0,
                      top: 10,
                      child:
                          silGorunur
                              ? IconButton(
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                  size: 20,
                                  color: Color.fromARGB(197, 244, 67, 54),
                                ),
                                onPressed: () {
                                  // Delete widget
                                  setState(() {
                                    silGorunur = false;
                                    _kaldirWidget(
                                      dinamikKontroller[widgets.indexOf(
                                        widget,
                                      )],
                                      metinBasliklar[widgets.indexOf(widget)],
                                    );
                                    Mesaj.altmesaj(
                                      context,
                                      "Ödeme Satırı Kaldırma Başarılı",
                                      Colors.green,
                                    );
                                  });
                                },
                              )
                              : IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Color.fromARGB(255, 98, 98, 98),
                                ),
                                onPressed: () {
                                  // Clear text
                                  setState(() {
                                    dinamikKontroller[widgets.indexOf(widget)]
                                        .clear();
                                  });
                                },
                              ),
                    ),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: MetinKutusu(
                  controller: _cocukKontrol,
                  labelText: 'Çocuk Yardımı',
                  hintText: '0,00 TL',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {},
                  clearButtonVisible: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      " * Ödemeyi farklı aylarda alıyorsanız buraya giriniz.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MetinKutusu(
                        controller: _sadecebuayyardim,
                        labelText: 'Ek Ödeme',
                        hintText: '0,00 TL',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {},
                        clearButtonVisible: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          initialValue: _ekodemeAy,
                          decoration: const InputDecoration(
                            labelText: "Ay Seçiniz",
                          ),

                          onChanged: (String? newValue) {
                            setState(() {
                              _ekodemeAy = newValue;
                              int secilenAyIndex = aylarYazi.indexOf(
                                newValue!,
                              ); // Seçilen ayın indeksini alıyoruz
                              ekodemeSatirNo = secilenAyIndex;
                            });
                          },
                          items:
                              aylarYazi.map((String ay) {
                                return DropdownMenuItem<String>(
                                  value: ay,
                                  child: Text(
                                    ay,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _createUniqueLabelText(String baseLabelText) {
    String uniqueLabelText = baseLabelText;
    int count = 1;

    while (metinBasliklar.contains(uniqueLabelText)) {
      uniqueLabelText = '$baseLabelText $count';
      count++;
    }
    return uniqueLabelText;
  }

  void _ekleWidget(String baseLabelText, {bool fromSharedPreferences = false}) {
    setState(() {
      String uniqueLabelText =
          fromSharedPreferences == true
              ? _createUniqueLabelText(baseLabelText)
              : baseLabelText;

      TextEditingController yeniKontrol = TextEditingController(
        text: "0.0",
      ); // Varsayılan değer olarak 0.0

      dinamikKontroller.add(yeniKontrol);
      metinBasliklar.add(uniqueLabelText);

      int currentIndex = dinamikKontroller.length - 1;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,

                        controller: yeniKontrol,
                        onTap: () {
                          if (yeniKontrol.text.trim() == "0.0") {
                            // Kullanıcının görebilmesi için controller değerini boş yap
                            yeniKontrol.clear();
                          }
                        },
                        onChanged: (value) {
                          // Virgülü noktaya çevir
                          String formattedValue = value.replaceAll(',', '.');
                          if (formattedValue != value) {
                            // Değişiklik varsa controller'ı güncelle
                            yeniKontrol.text = formattedValue;
                            // İmleci doğru pozisyona taşı
                            yeniKontrol.selection = TextSelection.fromPosition(
                              TextPosition(offset: formattedValue.length),
                            );
                          }
                          // Dinamik kontrolü güncelle
                          setState(() {
                            dinamikKontroller[currentIndex].text =
                                formattedValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: uniqueLabelText,

                          hintText: '0,00 TL',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
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

      if (fromSharedPreferences == true) {
        _kaydetWidgets(); // Eğer SharedPreferences'tan eklenmemişse, kaydedin
      }
    });
  }

  void _kaldirWidget(TextEditingController kontrol, String labelText) {
    setState(() {
      int index = dinamikKontroller.indexOf(kontrol);
      if (index != -1) {
        dinamikKontroller.removeAt(index);
        widgets.removeAt(index);
        metinBasliklar.remove(labelText);

        // SharedPreferences'tan da kaldır
        _kaydetWidgets();
      }
    });
  }

  void _kaydetWidgets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> kontrollerValues =
        dinamikKontroller.map((controller) => controller.text).toList();
    await prefs.setStringList('kontrollerValues', kontrollerValues);
    await prefs.setStringList('metinBasliklar', metinBasliklar);
  }

  void _dinamiksosyalhaklar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? savedBasliklar = prefs.getStringList('metinBasliklar');
    List<String>? savedKontrollerValues = prefs.getStringList(
      'kontrollerValues',
    );

    if (savedBasliklar != null &&
        savedKontrollerValues != null &&
        savedBasliklar.length == savedKontrollerValues.length) {
      metinBasliklar = savedBasliklar;

      for (int i = 0; i < savedBasliklar.length; i++) {
        TextEditingController yeniKontrol = TextEditingController(
          text: savedKontrollerValues[i],
        );
        dinamikKontroller.add(yeniKontrol);

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 50,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: yeniKontrol,
                          decoration: InputDecoration(
                            labelText: metinBasliklar[i],
                            hintText: '0,00 TL',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onTap: () {
                            if (yeniKontrol.text.trim() == "0.0") {
                              // Kullanıcının görebilmesi için controller değerini boş yap
                              yeniKontrol.clear();
                            }
                          },
                          onChanged: (value) {
                            // Virgülü noktaya çevir
                            String formattedValue = value.replaceAll(',', '.');
                            if (formattedValue != value) {
                              // Değişiklik varsa controller'ı güncelle
                              yeniKontrol.text = formattedValue;
                              // İmleci doğru pozisyona taşı
                              yeniKontrol
                                  .selection = TextSelection.fromPosition(
                                TextPosition(offset: formattedValue.length),
                              );
                            }
                          },
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
    } else {
      _ekleWidget('Gece Primi', fromSharedPreferences: false);
      _ekleWidget('Yakacak Parası', fromSharedPreferences: false);
      _ekleWidget('Posta Başı', fromSharedPreferences: false);
    }
    setState(() {});
  }

  void _toplaVeAta() {
    double toplam = 0.0;

    for (var kontrol in dinamikKontroller) {
      String text = kontrol.text.trim();

      if (text.isNotEmpty) {
        double? deger = double.tryParse(text);
        if (deger != null && deger > 0) {
          toplam += deger;
        }
      }
    }

    _sosyalgelirKontrol.text = toplam.toStringAsFixed(
      2,
    ); // Toplamı _sosyalgelirKontrol.text'e yazdır
  }

  Widget _altbilgilendirme() {
    return const Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Brüt Maaş ve Saat Ücreti Hesaplama:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, brüt maaş veya saat ücreti üzerinden hesaplamalar yapabilir. Bu hesaplamalar, kullanıcının girdiği brüt maaş veya saat ücreti üzerinden yapılır ve zam oranları, kıdem zammı gibi ek faktörler de hesaba katılır.\n\n'
            'Kullanıcılar, aylık brüt maaş veya saat ücreti girebilir ve bu bilgileri detaylı bir şekilde kaydedebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Zam ve Kıdem Hesaplama:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, brüt maaş veya saat ücretine zam oranı ekleyebilir ve kıdem zammı gibi ek ödemeleri de hesaba katabilir. Bu sayede, gelecekteki maaş artışlarını veya farklı senaryoları karşılaştırabilirler.\n\n'
            'Zam oranları ve kıdem zammı, kullanıcı tarafından manuel olarak girilebilir veya otomatik olarak hesaplanabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'İkramiye ve Ek Ödemeler:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, aylık veya belirli aylarda aldıkları ikramiyeleri ve ek ödemeleri girebilir. Bu bilgiler, maaş hesaplamalarına dahil edilir ve kullanıcının net gelirini daha doğru bir şekilde hesaplamasına yardımcı olur.\n\n'
            'İkramiye ve ek ödemeler, kullanıcı tarafından manuel olarak girilebilir veya saat ücreti üzerinden otomatik olarak hesaplanabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Vergi ve Kesintiler:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, kümülatif vergi matrahını ve diğer kesintileri (sendika kesintisi, avans gibi) girebilir. Bu bilgiler, net maaş hesaplamalarında dikkate alınır.\n\n'
            'Vergi matrahı, kullanıcının belirli bir ay için girdiği brüt gelir üzerinden hesaplanır ve vergi kesintileri bu matrah üzerinden belirlenir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Sosyal Yardımlar ve Çocuk Parası:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, düzenli olarak aldıkları sosyal yardımları (gece primi, yakacak parası, posta başı gibi) ve çocuk parasını girebilir. Bu bilgiler, maaş hesaplamalarına eklenir ve kullanıcının net gelirini artırır.\n\n'
            'Sosyal yardımlar, kullanıcı tarafından manuel olarak girilebilir veya otomatik olarak hesaplanabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Diğer Seçenekler:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, çalışan tipi (normal veya emekli), engellilik durumu, B.E.S. kesintisi ve mesai eklemeleri gibi diğer seçenekleri de yapılandırabilir. Bu seçenekler, maaş hesaplamalarını kişiselleştirmek ve daha doğru sonuçlar elde etmek için kullanılır.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Karşılaştırma Özelliği:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcılar, iki farklı maaş senaryosunu karşılaştırabilir. Bu özellik, farklı zam oranları, kıdem zammı veya diğer faktörlerin maaş üzerindeki etkisini görmek için kullanışlıdır.\n\n'
            'Karşılaştırma sonuçları, kullanıcıya iki farklı senaryo arasındaki farkları net bir şekilde gösterir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Yerel Depolama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Kullanıcıların girdiği tüm bilgiler, yerel depolama kullanılarak kaydedilir. Bu sayede, kullanıcılar uygulamayı kapattıktan sonra bile girdikleri bilgileri koruyabilir ve daha sonra tekrar kullanabilir.\n\n'
            'Yerel depolama, kullanıcıların hesaplamalarını daha hızlı ve kolay bir şekilde yapmalarını sağlar.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Sayfanın Kullanım Senaryoları:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Maaş Hesaplama: Kullanıcılar, brüt maaş veya saat ücreti üzerinden net maaşlarını hesaplayabilir ve vergi, kesintiler, ikramiye gibi faktörleri hesaba katabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          Text(
            'Zam Karşılaştırma: Kullanıcılar, farklı zam oranlarının maaşlarına nasıl yansıyacağını karşılaştırabilir ve en uygun senaryoyu seçebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          Text(
            'İkramiye ve Ek Ödemeler: Kullanıcılar, aldıkları ikramiyeleri ve ek ödemeleri hesaplamalara dahil ederek daha doğru bir net gelir elde edebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          Text(
            'Vergi ve Kesintiler: Kullanıcılar, vergi matrahı ve diğer kesintileri girerek net maaşlarını daha doğru bir şekilde hesaplayabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          Text(
            'Sosyal Yardımlar: Kullanıcılar, düzenli olarak aldıkları sosyal yardımları hesaplamalara ekleyerek net gelirlerini artırabilir.',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _bilgizam(String yazi) {
    return GestureDetector(
      onTap: () {
        _bilgiDialog(yazi);
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 10, right: 5),
        child: Icon(Icons.info_outline, size: 18, color: Renk.pastelKoyuMavi),
      ),
    );
  }

  void _bilgiDialog(String aciklama) {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'Bilgilendirme',
      content: aciklama,
      buttonText: 'Kapat',
    );
  }
}
