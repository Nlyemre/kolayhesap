import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app/Screens/anaekran_bilesenler/gelir_gider/islem_sayfasi.dart';
import 'package:app/Screens/anaekran_bilesenler/gorevler/gorev.dart';
import 'package:app/Screens/anaekran_bilesenler/issizlik/issizlik.dart';
import 'package:app/Screens/anaekran_bilesenler/kidem/kidemgiris.dart';
import 'package:app/Screens/anaekran_bilesenler/maaskarsilastir/karsilastirana.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/izinler.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesailer.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaileryil.dart';
import 'package:app/Screens/anaekran_bilesenler/qrtara/bir.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/girisreklam.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_4.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_5.dart';
import 'package:app/Screens/anaekran_bilesenler/ses/frekans.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamgiris.dart';
import 'package:app/Screens/yanmenu_bilesenleri/mtv.dart';
import 'package:app/Screens/yanmenu_bilesenleri/nekadar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnaGirisSayfasi extends StatefulWidget {
  const AnaGirisSayfasi({super.key});

  @override
  State<AnaGirisSayfasi> createState() => _AnaGirisSayfasiState();
}

class _AnaGirisSayfasiState extends State<AnaGirisSayfasi> {
  bool isLoading = true;
  late GirisReklam girisReklam = GirisReklam();
  static const List<String> _aylar = [
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

  DateTime iseGirisTarihi = DateTime.now();
  int calismaYili = 0;
  int calismaAyi = 0;
  int calismaGunu = 0;
  int calismaSaati = 0;

  double mesaiSaati = 0;
  double gecenAyMesaiSaati = 0;
  double brutMesai = 0;
  double netMesai = 0;
  String ayAdi = "";
  int secilenYil = DateTime.now().year;
  List<double> grafikDegerleri = List.filled(12, 0.0);
  final List<double> aylikMesaiSaatleri = List.filled(12, 0.0);
  double toplamMesai = 0.0;
  double gelirToplam = 0.0;
  double giderToplam = 0.0;
  double kalanToplam = 0.0;

  double toplamIzin = 0;
  double kullanilanIzin = 0;
  double kalanIzin = 0;
  String zamanAraligi = 'Aylık';
  List<Map<String, dynamic>> gorevListesi = [];
  late SharedPreferences _prefs;

  final _scrollController = ScrollController();
  final ValueNotifier<bool> _showReklamBes = ValueNotifier(false);
  final ValueNotifier<bool> _showReklamUc = ValueNotifier(false);
  late final void Function() _scrollListener;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tumVerileriYukle();
    });
    _scrollListener = () {
      final pixels = _scrollController.position.pixels.round();
      if (!_showReklamBes.value && pixels >= 550 && pixels < 650) {
        _showReklamBes.value = true;
      }
      if (!_showReklamUc.value && pixels >= 1750 && pixels < 1850) {
        _showReklamUc.value = true;
      }
      // Tüm reklamlar yüklendiyse dinleyiciyi kaldır
      if (_showReklamBes.value && _showReklamUc.value) {
        _scrollController.removeListener(_scrollListener);
      }
    };
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _showReklamBes.dispose();
    _showReklamUc.dispose();
    super.dispose();
  }

  Future<void> _tumVerileriYukle() async {
    _prefs = await SharedPreferences.getInstance();
    final gelirToplam = _prefs.getDouble('gelirToplam') ?? 0.0;
    final giderToplam = _prefs.getDouble('giderToplam') ?? 0.0;
    final kalanToplam = _prefs.getDouble('kalanToplam') ?? 0.0;
    final zamanAraligi = _prefs.getString('zamanAraligi') ?? 'Aylık';
    final sayfaIndeksi = _prefs.getInt('index') ?? 0;
    final suankiTarih = DateTime.now();
    final ay = suankiTarih.month;
    final yil = suankiTarih.year;

    final prefsData = {
      'mesaiSaati': _prefs.getDouble('$sayfaIndeksi-$yil-$ay-saat') ?? 0.0,
      'gecenAyMesaiSaati':
          _prefs.getDouble('$sayfaIndeksi-$yil-${ay - 1}-saat') ?? 0.0,
      'brutMesai': _prefs.getDouble('$sayfaIndeksi-$yil-$ay-burut') ?? 0.0,
      'netMesai': _prefs.getDouble('$sayfaIndeksi-$yil-$ay-net') ?? 0.0,
      'kullanilanIzin': _prefs.getDouble('kullanilanIzin') ?? 0.0,
      'toplamIzin': _prefs.getDouble('toplamIzin') ?? 15.0,
      'iseGirisDate': _prefs.getString('iseGirisDate') ?? '',
    };

    final tempAylikMesaiSaatleri = List.generate(
      12,
      (i) => _prefs.getDouble('$sayfaIndeksi-$yil-${i + 1}-saat') ?? 0.0,
    );

    final String? listeJson = _prefs.getString('yapilacaklarListesi');
    List<Map<String, dynamic>> tempGorevListesi = [];

    if (listeJson != null) {
      tempGorevListesi = List<Map<String, dynamic>>.from(
        json.decode(listeJson).map((x) => Map<String, dynamic>.from(x)),
      )..sort(
        (a, b) => DateFormat('dd-MM-yyyy HH:mm')
            .parse(a['tarih'])
            .compareTo(DateFormat('dd-MM-yyyy HH:mm').parse(b['tarih'])),
      );
    }

    this.gelirToplam = gelirToplam;
    this.giderToplam = giderToplam;
    this.kalanToplam = kalanToplam;
    this.zamanAraligi = zamanAraligi;
    mesaiSaati = prefsData['mesaiSaati'] as double;
    gecenAyMesaiSaati = prefsData['gecenAyMesaiSaati'] as double;
    brutMesai = prefsData['brutMesai'] as double;
    netMesai = prefsData['netMesai'] as double;
    kullanilanIzin = prefsData['kullanilanIzin'] as double;
    toplamIzin = prefsData['toplamIzin'] as double;
    kalanIzin = toplamIzin - kullanilanIzin;
    iseGirisTarihi =
        (prefsData['iseGirisDate'] as String).isNotEmpty
            ? Dekor.tarihFormati.parse(prefsData['iseGirisDate'] as String)
            : DateTime.now();
    aylikMesaiSaatleri.setAll(0, tempAylikMesaiSaatleri);
    toplamMesai = aylikMesaiSaatleri.fold(
      0.0,
      (toplam, deger) => toplam + deger,
    );
    grafikDegerleri = List<double>.generate(
      12,
      (i) =>
          toplamMesai == 0
              ? 0.0
              : (aylikMesaiSaatleri[i] / toplamMesai).toDouble(),
    );
    ayAdi = _aylar[ay - 1];
    secilenYil = yil;
    gorevListesi = tempGorevListesi;

    final fark = DateTime.now().difference(iseGirisTarihi);

    calismaYili = fark.inDays ~/ 365;
    calismaAyi = (fark.inDays % 365) ~/ 30;
    calismaGunu = (fark.inDays % 365) % 30;
    calismaSaati = DateTime.now().hour;

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _gelirGiderVerileriniYukle() async {
    if (!mounted) return;
    setState(() {
      gelirToplam = _prefs.getDouble('gelirToplam') ?? 0.0;
      giderToplam = _prefs.getDouble('giderToplam') ?? 0.0;
      kalanToplam = _prefs.getDouble('kalanToplam') ?? 0.0;
      zamanAraligi = _prefs.getString('zamanAraligi') ?? 'Aylık';
    });
  }

  Future<void> _islemlerSayfasinaGit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IslemlerSayfasi()),
    );

    if (result != null && mounted) {
      await Future.wait([
        _prefs.setDouble('gelirToplam', result['gelir']),
        _prefs.setDouble('giderToplam', result['gider']),
        _prefs.setDouble('kalanToplam', result['kalan']),
        _prefs.setString('zamanAraligi', result['zamanAraligi']),
      ]);
      await _gelirGiderVerileriniYukle();
    }

    if (GirisReklam().isAdReady) {
      Future.delayed(const Duration(seconds: 1), () {
        GirisReklam().showInterstitialAd();
      });
    }
  }

  Future<void> _gorevListesiniYukle() async {
    try {
      final String? listeJson = _prefs.getString('yapilacaklarListesi');

      if (listeJson != null && mounted) {
        setState(() {
          gorevListesi = List<Map<String, dynamic>>.from(
            json.decode(listeJson).map((x) => Map<String, dynamic>.from(x)),
          );
          gorevListesi.sort(
            (a, b) => DateFormat('dd-MM-yyyy HH:mm')
                .parse(a['tarih'])
                .compareTo(DateFormat('dd-MM-yyyy HH:mm').parse(b['tarih'])),
          );
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  void _goreviSil(int index) async {
    if (!mounted) return;

    setState(() => gorevListesi.removeAt(index));
    await _prefs.setString('yapilacaklarListesi', json.encode(gorevListesi));
  }

  void _calismaSuresiniHesapla() {
    final fark = DateTime.now().difference(iseGirisTarihi);
    if (mounted) {
      setState(() {
        calismaYili = fark.inDays ~/ 365;
        calismaAyi = (fark.inDays % 365) ~/ 30;
        calismaGunu = (fark.inDays % 365) % 30;
        calismaSaati = DateTime.now().hour;
      });
    }
  }

  Future<void> _tarihSeciciGoster() async {
    final DateTime? secilenTarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );

    if (secilenTarih != null && mounted) {
      await _prefs.setString(
        'iseGirisDate',
        Dekor.tarihFormati.format(secilenTarih),
      );
      setState(() {
        iseGirisTarihi = secilenTarih;
        _calismaSuresiniHesapla();
      });
    }
  }

  Future<void> _sayfayaGit(Widget sayfa) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => sayfa),
    );

    if (result == 'veri_degisti') {
      await _tumVerileriYukle();
    }

    if (GirisReklam().isAdReady) {
      Future.delayed(const Duration(seconds: 1), () {
        GirisReklam().showInterstitialAd();
      });
    }
  }

  Widget _buildReklamadort() {
    return const Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 15),
      child: RepaintBoundary(
        child: YerelReklamdort(key: ValueKey('reklam_dort')),
      ),
    );
  }

  Widget _buildReklamBes() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showReklamBes,
      builder:
          (context, show, _) =>
              show
                  ? const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                    child: RepaintBoundary(
                      child: YerelReklambes(key: ValueKey('reklam_bes')),
                    ),
                  )
                  : const SizedBox.shrink(key: ValueKey('bes')),
    );
  }

  Widget _buildReklamauc() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showReklamUc,
      builder:
          (context, show, _) =>
              show
                  ? const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                    child: RepaintBoundary(
                      child: YerelReklamuc(key: ValueKey('reklam_uc')),
                    ),
                  )
                  : const SizedBox.shrink(key: ValueKey('uc')),
    );
  }

  List<Widget> menuler(BuildContext context) {
    return [
      CalismaHayatimBolumu(
        calismaYili: calismaYili,
        calismaAyi: calismaAyi,
        calismaGunu: calismaGunu,
        calismaSaati: calismaSaati,
        iseGirisTarihi: iseGirisTarihi,
        onTarihSeciciGoster: _tarihSeciciGoster,
      ),
      AylikMesaiBolumu(
        mesaiSaati: mesaiSaati,
        gecenAyMesaiSaati: gecenAyMesaiSaati,
        brutMesai: brutMesai,
        netMesai: netMesai,
        onMesailerSayfasinaGit: () => _sayfayaGit(const Mesailer()),
      ),
      _buildReklamadort(),
      YillikMesaiBolumu(
        grafikDegerleri: grafikDegerleri,
        aylikMesaiSaatleri: aylikMesaiSaatleri,
        onMesaileryilSayfasinaGit: () => _sayfayaGit(const Mesaileryil()),
        onZamGirisSayfasinaGit:
            () => _sayfayaGit(const ZamGiris(id: 1, grafikid: 0, sayfa: 0)),
        onBruttenNetSayfasinaGit:
            () => _sayfayaGit(const ZamGiris(id: 2, grafikid: 0, sayfa: 0)),
      ),
      GelirGiderKart(
        gelirToplam: gelirToplam,
        giderToplam: giderToplam,
        kalanToplam: kalanToplam,
        zamanAraligi: zamanAraligi,
        onIslemlerSayfasinaGit: _islemlerSayfasinaGit,
      ),
      _buildReklamBes(),
      IzinlerBolumu(
        kullanilanIzin: kullanilanIzin,
        toplamIzin: toplamIzin,
        kalanIzin: kalanIzin,
        secilenYil: secilenYil,
        onIzinlerSayfasinaGit: () => _sayfayaGit(const Izinler()),
      ),
      MaasKarsilastirmaBolumu(
        onZamKarsilastirmaSayfasinaGit:
            () => _sayfayaGit(const KarsilastirAna(sayfano: 1)),
        onMaasKarsilastirmaSayfasinaGit:
            () => _sayfayaGit(const KarsilastirAna(sayfano: 2)),
        onParaBirimiKarsilastirmaSayfasinaGit:
            () => _sayfayaGit(const KarsilastirAna(sayfano: 3)),
      ),
      QrKodBolumu(
        onQrGirisSayfasinaGit: () => _sayfayaGit(const QrGiris()),
        onKidemGirisSayfasinaGit: () => _sayfayaGit(const KidemGiris()),
      ),
      GorevlerBolumu(
        gorevListesi: gorevListesi,
        onGorevListesiniYukle: _gorevListesiniYukle,
        onGoreviSil: () => _goreviSil(0),
      ),
      _buildReklamauc(),
      SesBolumu(onFrekansSayfasinaGit: () => _sayfayaGit(const Frekans())),
      KolayHesaplamalarBolumu(
        onIssizlikSayfasinaGit: () => _sayfayaGit(const Issizlik()),
        onMTVHesaplaSayfasinaGit: () => _sayfayaGit(const MTVhesapla()),
        onNekadarSayfasinaGit: () => _sayfayaGit(const Nekadar()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final menuWidgets = menuler(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            return true;
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(children: menuWidgets),
        ),
      ),
    );
  }
}

// Çalışma Hayatım Bölümü
class CalismaHayatimBolumu extends StatelessWidget {
  final int calismaYili;
  final int calismaAyi;
  final int calismaGunu;
  final int calismaSaati;
  final DateTime iseGirisTarihi;
  final VoidCallback onTarihSeciciGoster;

  const CalismaHayatimBolumu({
    required this.calismaYili,
    required this.calismaAyi,
    required this.calismaGunu,
    required this.calismaSaati,
    required this.iseGirisTarihi,
    required this.onTarihSeciciGoster,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BolumBasligi(solMetin: "Çalışma Hayatım", sagMetin: ""),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CalismaSuresiKarti(
                      deger: calismaYili.toString(),
                      etiket: "Yıl",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CalismaSuresiKarti(
                      deger: calismaAyi.toString(),
                      etiket: "Ay",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CalismaSuresiKarti(
                      deger: calismaGunu.toString(),
                      etiket: "Gün",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CalismaSuresiKarti(
                      deger: calismaSaati.toString(),
                      etiket: "Saat",
                    ),
                  ),
                ],
              ),
              Dekor.cizgi30,
              DetayButonu(
                metin:
                    "İşe Giriş Tarihi : ${Dekor.tarihFormati.format(iseGirisTarihi)}",
                onPressed: onTarihSeciciGoster,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Çalışma Süresi Kartı
class CalismaSuresiKarti extends StatelessWidget {
  final String deger;
  final String etiket;

  const CalismaSuresiKarti({
    required this.deger,
    required this.etiket,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CizgiliCerceve(
      golge: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              deger.padLeft(2, '0'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Dekor.cizgi15,
            Text(
              etiket,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

// Aylık Mesai Bölümü
class AylikMesaiBolumu extends StatelessWidget {
  final double mesaiSaati;
  final double gecenAyMesaiSaati;
  final double brutMesai;
  final double netMesai;
  final VoidCallback onMesailerSayfasinaGit;

  const AylikMesaiBolumu({
    required this.mesaiSaati,
    required this.gecenAyMesaiSaati,
    required this.brutMesai,
    required this.netMesai,
    required this.onMesailerSayfasinaGit,
    super.key,
  });

  List<ChartLayer> _buildChartLayers() {
    return [
      ChartGroupPieLayer(
        items: [
          [
            ChartGroupPieDataItem(
              amount: brutMesai,
              color: const Color.fromARGB(210, 29, 84, 147),
              label: "Brüt Mesai",
            ),
            ChartGroupPieDataItem(
              amount: netMesai,
              color: const Color.fromARGB(150, 38, 203, 203),
              label: "Net Mesai",
            ),
          ],
        ],
        settings: const ChartGroupPieSettings(
          gapSweepAngle: 30,
          thickness: 15,
          angleOffset: -65.0,
          gapBetweenChartCircles: 18.0,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String ayIsmi = DateFormat.MMMM('tr_TR').format(now);
    final chartLayers = _buildChartLayers();
    return Column(
      children: [
        BolumBasligi(solMetin: "Aylık Mesailer", sagMetin: ayIsmi),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          child: MesaiGrafikWidget(
            chartLayers: chartLayers,
            mesaiSaati: mesaiSaati,
            gecenAyMesaiSaati: gecenAyMesaiSaati,
            onMesailerSayfasinaGit: onMesailerSayfasinaGit,
          ),
        ),
      ],
    );
  }
}

// Mesai Grafik Widget
class MesaiGrafikWidget extends StatelessWidget {
  final List<ChartLayer> chartLayers;
  final double mesaiSaati;
  final double gecenAyMesaiSaati;
  final VoidCallback onMesailerSayfasinaGit;

  const MesaiGrafikWidget({
    required this.chartLayers,
    required this.mesaiSaati,
    required this.gecenAyMesaiSaati,
    required this.onMesailerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Image(
                  image: AppImages.mesai,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 105,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RepaintBoundary(child: Chart(layers: chartLayers)),
                      Text(
                        mesaiSaati.toString(),
                        style: Dekor.butonText_17_500siyah,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 105,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KarsilastirmaWidget(
                        mesaiSaati: mesaiSaati,
                        gecenAyMesaiSaati: gecenAyMesaiSaati,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Önceki aya göre değişim oranı",
                        textAlign: TextAlign.center,
                        style: Dekor.butonText_12_400siyah,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: "Aylık Mesai Detayları",
            onPressed: onMesailerSayfasinaGit,
          ),
        ],
      ),
    );
  }
}

// Karşılaştırma Widget
class KarsilastirmaWidget extends StatelessWidget {
  final double mesaiSaati;
  final double gecenAyMesaiSaati;

  const KarsilastirmaWidget({
    required this.mesaiSaati,
    required this.gecenAyMesaiSaati,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final degisim =
        (gecenAyMesaiSaati == 0)
            ? 0
            : ((mesaiSaati - gecenAyMesaiSaati) / gecenAyMesaiSaati) * 100;
    final bool artis = mesaiSaati > gecenAyMesaiSaati;
    final bool azalis = mesaiSaati < gecenAyMesaiSaati;

    final ikon =
        artis
            ? Icons.arrow_drop_up
            : azalis
            ? Icons.arrow_drop_down
            : Icons.remove;
    final renk =
        artis
            ? const Color.fromARGB(200, 4, 122, 24)
            : azalis
            ? const Color.fromARGB(200, 200, 0, 0)
            : const Color.fromARGB(129, 158, 158, 158);
    final durum = "${degisim.abs().toStringAsFixed(1)} %";

    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: Colors.white, size: 22),
          Text(durum, style: Dekor.butonText_11_500beyaz),
        ],
      ),
    );
  }
}

// Yıllık Mesai Bölümü
class YillikMesaiBolumu extends StatelessWidget {
  final List<double> grafikDegerleri;
  final List<double> aylikMesaiSaatleri;
  final VoidCallback onMesaileryilSayfasinaGit;
  final VoidCallback onZamGirisSayfasinaGit;
  final VoidCallback onBruttenNetSayfasinaGit;

  const YillikMesaiBolumu({
    required this.grafikDegerleri,
    required this.aylikMesaiSaatleri,
    required this.onMesaileryilSayfasinaGit,
    required this.onZamGirisSayfasinaGit,
    required this.onBruttenNetSayfasinaGit,
    super.key,
  });

  static const List<String> _aylar = [
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

  @override
  Widget build(BuildContext context) {
    const double yukseklik = 520;
    return Column(
      children: [
        const SizedBox(height: 10),
        const BolumBasligi(
          solMetin: "Yıllık Mesailer",
          sagMetin: "Maaş Hesaplamaları",
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SizedBox(
            height: yukseklik,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: YillikMesaiGrafikWidget(
                      grafikDegerleri: grafikDegerleri,
                      aylikMesaiSaatleri: aylikMesaiSaatleri,
                      aylarYazi: _aylar,
                      onMesaileryilSayfasinaGit: onMesaileryilSayfasinaGit,
                      yukseklik: yukseklik,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      children: [
                        Expanded(
                          child: MenuKarti(
                            baslik: "Zam Oranı İle Yeni\nMaaş Hesaplayın",
                            image: const Image(
                              image: AppImages.zamOrani,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                            title: "Maaş Zam Hesapla",
                            onTap: onZamGirisSayfasinaGit,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: MenuKarti(
                            baslik: "Bürüt Maaşınızın Net\nTutarını Hesaplayın",
                            image: const Image(
                              image: AppImages.bruttenNet,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                            title: "Net Maaş Hesapla",
                            onTap: onBruttenNetSayfasinaGit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Yıllık Mesai Grafik Widget
class YillikMesaiGrafikWidget extends StatelessWidget {
  final List<double> grafikDegerleri;
  final List<double> aylikMesaiSaatleri;
  final List<String> aylarYazi;
  final VoidCallback onMesaileryilSayfasinaGit;
  final double yukseklik;

  const YillikMesaiGrafikWidget({
    required this.grafikDegerleri,
    required this.aylikMesaiSaatleri,
    required this.aylarYazi,
    required this.onMesaileryilSayfasinaGit,
    required this.yukseklik,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: onMesaileryilSayfasinaGit,
      child: CizgiliCerceve(
        golge: 5,
        padding: const EdgeInsets.all(10.0),
        child: RepaintBoundary(
          child: SizedBox(
            height: yukseklik,
            child: GrafikListe(
              grafikValues: grafikDegerleri,
              saatListe: aylikMesaiSaatleri,
              aylarYazi: aylarYazi,
              maxHeight: yukseklik,
            ),
          ),
        ),
      ),
    );
  }
}

class GrafikListe extends StatelessWidget {
  final List<double> grafikValues;
  final List<double> saatListe;
  final List<String> aylarYazi;
  final double maxHeight;

  const GrafikListe({
    super.key,
    required this.grafikValues,
    required this.saatListe,
    required this.aylarYazi,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double genislik = MediaQuery.of(context).size.width * 0.43;
    final double maxValue =
        grafikValues.isNotEmpty ? grafikValues.reduce(max) : 1.0;

    double normalize(double value) => maxValue == 0 ? 0.0 : value / maxValue;

    final double barHeight = maxHeight * 0.0235; // Çubuk yüksekliği
    final double textHeight = maxHeight * 0.04; // Yazı boyutları için

    return Column(
      children: List.generate(12, (index) {
        double barWidth = normalize(grafikValues[index]) * genislik;
        return GrafikCubugu(
          ay: aylarYazi[index],
          saat: saatListe[index],
          genislik: genislik,
          barWidth: barWidth,
          altCizgi: index < 11,
          barHeight: barHeight,
          textHeight: textHeight,
        );
      }),
    );
  }
}

class GrafikCubugu extends StatelessWidget {
  final String ay;
  final double saat;
  final double genislik;
  final double barWidth;
  final bool altCizgi;
  final double barHeight;
  final double textHeight;

  const GrafikCubugu({
    super.key,
    required this.ay,
    required this.saat,
    required this.genislik,
    required this.barWidth,
    required this.altCizgi,
    required this.barHeight,
    required this.textHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ay,
                style: TextStyle(
                  fontSize:
                      textHeight *
                      0.50, // Yazı boyutunu yüksekliğe göre ölçekle
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 29, 84, 147),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text(
                  saat.toStringAsFixed(1),
                  style: TextStyle(
                    color: const Color.fromARGB(255, 30, 30, 30),
                    fontSize: textHeight * 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: barHeight,
              width: genislik,
              decoration: const BoxDecoration(
                color: Color.fromARGB(130, 105, 147, 164),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
            if (barWidth > 0)
              Container(
                height: barHeight,
                width: barWidth,
                decoration: const BoxDecoration(
                  gradient: Renk.gradient,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
          ],
        ),
        if (altCizgi) const Divider(color: Renk.cita, height: 13, thickness: 1),
      ],
    );
  }
}

// Menu Kartı
class MenuKarti extends StatelessWidget {
  final String baslik;
  final Widget image;
  final String title;
  final VoidCallback? onTap;

  const MenuKarti({
    required this.baslik,
    required this.image,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CizgiliCerceve(
      golge: 5,
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 5),
      child: Column(
        children: [
          if (baslik != "")
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text(
                baslik,
                textAlign: TextAlign.center,
                style: Dekor.butonText_13_500siyah,
                maxLines: 3,
              ),
            ),
          image,
          Dekor.cizgi25,
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DetayButonu(metin: title, onPressed: onTap),
          ),
        ],
      ),
    );
  }
}

// Gelir Gider Kart
class GelirGiderKart extends StatelessWidget {
  final double gelirToplam;
  final double giderToplam;
  final double kalanToplam;
  final String zamanAraligi;
  final VoidCallback onIslemlerSayfasinaGit;

  const GelirGiderKart({
    required this.gelirToplam,
    required this.giderToplam,
    required this.kalanToplam,
    required this.zamanAraligi,
    required this.onIslemlerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BolumBasligi(solMetin: "Gelir Gider Takibi", sagMetin: zamanAraligi),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          child:
              gelirToplam == 0.0 || giderToplam == 0.0
                  ? BosGelirGiderIcerik(
                    onIslemlerSayfasinaGit: onIslemlerSayfasinaGit,
                  )
                  : DoluGelirGiderIcerik(
                    gelirToplam: gelirToplam,
                    giderToplam: giderToplam,
                    kalanToplam: kalanToplam,
                    onIslemlerSayfasinaGit: onIslemlerSayfasinaGit,
                  ),
        ),
      ],
    );
  }
}

// Boş Gelir Gider İçerik
class BosGelirGiderIcerik extends StatelessWidget {
  final VoidCallback onIslemlerSayfasinaGit;

  const BosGelirGiderIcerik({required this.onIslemlerSayfasinaGit, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                width: 105,
                height: 105,
                image: AppImages.gelirgider,
                fit: BoxFit.contain,
              ),
              SizedBox(
                width: 200,
                child: Text(
                  'Gelirinizi ve giderinizi kolayca kaydedin, nerelere harcama yaptığınızı görün. Bütçenizi takip edin ve gereksiz masraflardan kurtulun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: "Gelir Gider Hesapla",
            onPressed: onIslemlerSayfasinaGit,
          ),
        ],
      ),
    );
  }
}

// Dolu Gelir Gider İçerik
class DoluGelirGiderIcerik extends StatelessWidget {
  final double gelirToplam;
  final double giderToplam;
  final double kalanToplam;
  final VoidCallback onIslemlerSayfasinaGit;

  const DoluGelirGiderIcerik({
    required this.gelirToplam,
    required this.giderToplam,
    required this.kalanToplam,
    required this.onIslemlerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GelirGiderBilgi(
                  etiket: "Gelir\nToplam",
                  deger: Dekor.paraFormat.format(gelirToplam),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GelirGiderBilgi(
                  etiket: "Gider\nToplam",
                  deger: Dekor.paraFormat.format(giderToplam),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GelirGiderBilgi(
                  etiket: "Kalan\nToplam",
                  deger: Dekor.paraFormat.format(kalanToplam),
                ),
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: 'Gelir Gider Hesapla',
            onPressed: onIslemlerSayfasinaGit,
          ),
        ],
      ),
    );
  }
}

// Gelir Gider Bilgi
class GelirGiderBilgi extends StatelessWidget {
  final String etiket;
  final String deger;

  const GelirGiderBilgi({required this.etiket, required this.deger, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          etiket,
          style: Dekor.butonText_13_400mavi,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        SizedBox(
          width: double.infinity,
          child: CizgiliCerceve(
            golge: 5,
            margin: const EdgeInsets.symmetric(vertical: 5), // Dış boşluk
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              deger,
              style: Dekor.butonText_13_400siyah,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// Görevler Bölümü
class GorevlerBolumu extends StatelessWidget {
  final List<Map<String, dynamic>> gorevListesi;
  final VoidCallback onGorevListesiniYukle;
  final VoidCallback onGoreviSil;

  const GorevlerBolumu({
    required this.gorevListesi,
    required this.onGorevListesiniYukle,
    required this.onGoreviSil,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BolumBasligi(
          solMetin: "Yapılacaklar Listesi",
          sagMetin: "Görevler",
        ),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          child:
              gorevListesi.isEmpty
                  ? BosGorevListesi(
                    onGorevListesiniYukle: onGorevListesiniYukle,
                  )
                  : GorevListesiItem(
                    gorevListesi: gorevListesi,
                    onGorevListesiniYukle: onGorevListesiniYukle,
                    onGoreviSil: onGoreviSil,
                  ),
        ),
      ],
    );
  }
}

// Boş Görev Listesi
class BosGorevListesi extends StatelessWidget {
  final VoidCallback onGorevListesiniYukle;

  const BosGorevListesi({required this.onGorevListesiniYukle, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                height: 90,
                image: AppImages.yapilacaklar,
                fit: BoxFit.contain,
              ),
              SizedBox(
                width: 220,
                child: Text(
                  'Görevlerinizi ve hatırlatmalarınızı kolayca yönetebileceğiniz kişisel asistanınız ile zamanınızı en iyi şekilde kullanın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: "Yeni Görev Oluştur",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => YapilacaklarListesi(
                          onListeGuncellendi: onGorevListesiniYukle,
                        ),
                  ),
                ).then((_) {
                  if (GirisReklam().isAdReady) {
                    Future.delayed(const Duration(seconds: 1), () {
                      GirisReklam().showInterstitialAd();
                    });
                  }
                }),
          ),
        ],
      ),
    );
  }
}

// Görev Listesi Item
class GorevListesiItem extends StatelessWidget {
  final List<Map<String, dynamic>> gorevListesi;
  final VoidCallback onGorevListesiniYukle;
  final VoidCallback onGoreviSil;

  const GorevListesiItem({
    required this.gorevListesi,
    required this.onGorevListesiniYukle,
    required this.onGoreviSil,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? taskDate;
    final tarihStr = gorevListesi.first['tarih']?.toString() ?? '';
    taskDate = DateFormat('dd-MM-yyyy HH:mm', 'tr_TR').parse(tarihStr);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (gorevListesi.first['baslik'] != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                gorevListesi.first['baslik'].toString(),
                style: Dekor.butonText_14_500siyah,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (gorevListesi.first['aciklama']?.toString().isNotEmpty ?? false)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  gorevListesi.first['aciklama'].toString(),
                  style: Dekor.butonText_14_400siyah,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd-MM-yyyy HH:mm', 'tr_TR').format(taskDate),
                    style: Dekor.butonText_12_400siyah,
                  ),
                ],
              ),
              KalanSureWidget(taskDate: taskDate, onGoreviSil: onGoreviSil),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: "Tüm Görevleri Görüntüle",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => YapilacaklarListesi(
                          onListeGuncellendi: onGorevListesiniYukle,
                        ),
                  ),
                ).then((_) => onGorevListesiniYukle()),
          ),
        ],
      ),
    );
  }
}

// Kalan Süre Widget
class KalanSureWidget extends StatelessWidget {
  final DateTime taskDate;
  final VoidCallback onGoreviSil;

  const KalanSureWidget({
    required this.taskDate,
    required this.onGoreviSil,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final difference = taskDate.difference(DateTime.now());
    String remainingTime;
    if (difference.isNegative) {
      remainingTime = 'Süre doldu';
    } else if (difference.inDays > 0) {
      remainingTime =
          '${difference.inDays} gün ${difference.inHours % 24} saat kaldı';
    } else if (difference.inHours > 0) {
      remainingTime =
          '${difference.inHours} saat ${difference.inMinutes % 60} dakika kaldı';
    } else if (difference.inMinutes > 0) {
      remainingTime = '${difference.inMinutes} dakika kaldı';
    } else {
      remainingTime = '${difference.inSeconds} saniye kaldı';
    }

    return remainingTime == 'Süre doldu'
        ? InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          onTap: onGoreviSil,
          child: const CizgiliCerceve(
            golge: 5,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
            child: Text(
              "Süre doldu Sil",
              style: TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
        )
        : Text(remainingTime, style: Dekor.butonText_12_400mavi);
  }
}

// İzinler Bölümü
class IzinlerBolumu extends StatelessWidget {
  final double kullanilanIzin;
  final double toplamIzin;
  final double kalanIzin;
  final int secilenYil;
  final VoidCallback onIzinlerSayfasinaGit;

  const IzinlerBolumu({
    required this.kullanilanIzin,
    required this.toplamIzin,
    required this.kalanIzin,
    required this.secilenYil,
    required this.onIzinlerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const BolumBasligi(solMetin: "Yıllık İzinler", sagMetin: ""),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          child:
              kullanilanIzin != 0.0
                  ? DoluIzinKarti(
                    toplamIzin: toplamIzin,
                    kullanilanIzin: kullanilanIzin,
                    kalanIzin: kalanIzin,
                    secilenYil: secilenYil,
                    onIzinlerSayfasinaGit: onIzinlerSayfasinaGit,
                  )
                  : BosIzinKarti(
                    secilenYil: secilenYil,
                    onIzinlerSayfasinaGit: onIzinlerSayfasinaGit,
                  ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Dolu İzin Kartı
class DoluIzinKarti extends StatelessWidget {
  final double toplamIzin;
  final double kullanilanIzin;
  final double kalanIzin;
  final int secilenYil;
  final VoidCallback onIzinlerSayfasinaGit;

  const DoluIzinKarti({
    required this.toplamIzin,
    required this.kullanilanIzin,
    required this.kalanIzin,
    required this.secilenYil,
    required this.onIzinlerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: IzinBilgisi(
                  etiket: "Toplam\nİzin",
                  deger: toplamIzin.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IzinBilgisi(
                  etiket: "Kullanılan\nİzin",
                  deger: kullanilanIzin.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IzinBilgisi(
                  etiket: "Kalan\nİzin",
                  deger: kalanIzin.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: '$secilenYil Yılı İzin Detayları',
            onPressed: onIzinlerSayfasinaGit,
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

// Boş İzin Kartı
class BosIzinKarti extends StatelessWidget {
  final int secilenYil;
  final VoidCallback onIzinlerSayfasinaGit;

  const BosIzinKarti({
    required this.secilenYil,
    required this.onIzinlerSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 220,
                child: Text(
                  'Yıllık izinlerinizi kolayca kaydedebilir, geçmiş izinlerinizi görüntüleyebilir ve toplam kalan izninizi takip edebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              Image(
                width: 95,
                height: 95,
                image: AppImages.izinler,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Dekor.cizgi30,
          DetayButonu(
            metin: '$secilenYil Yılı İzin Oluştur',
            onPressed: onIzinlerSayfasinaGit,
          ),
        ],
      ),
    );
  }
}

// İzin Bilgisi
class IzinBilgisi extends StatelessWidget {
  final String etiket;
  final String deger;

  const IzinBilgisi({required this.etiket, required this.deger, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          etiket,
          style: Dekor.butonText_13_400mavi,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        SizedBox(
          width: double.infinity,
          child: CizgiliCerceve(
            golge: 5,
            margin: const EdgeInsets.symmetric(vertical: 5), // Dış boşluk
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              deger,
              style: Dekor.butonText_13_400siyah,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// Maaş Karşılaştırma Bölümü
class MaasKarsilastirmaBolumu extends StatelessWidget {
  final VoidCallback onZamKarsilastirmaSayfasinaGit;
  final VoidCallback onMaasKarsilastirmaSayfasinaGit;
  final VoidCallback onParaBirimiKarsilastirmaSayfasinaGit;

  const MaasKarsilastirmaBolumu({
    required this.onZamKarsilastirmaSayfasinaGit,
    required this.onMaasKarsilastirmaSayfasinaGit,
    required this.onParaBirimiKarsilastirmaSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BolumBasligi(solMetin: "Maaş Karşılaştırma", sagMetin: ""),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "Zam Öncesi\nVe Sonrasını\nKarşılaştır",
                  resim: AppImages.zamKarsilastirma,
                  onTiklandi: onZamKarsilastirmaSayfasinaGit,
                ),
              ),
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "Farklı\nİki Maaş\nKarşılaştır",
                  resim: AppImages.maasKarsilastirma,
                  onTiklandi: onMaasKarsilastirmaSayfasinaGit,
                ),
              ),
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "Ülke Para\nBirimi İle\nKarşılaştır",
                  resim: AppImages.paraBirimiKarsilastirma,
                  onTiklandi: onParaBirimiKarsilastirmaSayfasinaGit,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Karşılaştırma Kartı
class KarsilastirmaKarti extends StatelessWidget {
  final String baslik;
  final AssetImage resim;
  final VoidCallback? onTiklandi;

  const KarsilastirmaKarti({
    required this.baslik,
    required this.resim,
    required this.onTiklandi,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ), // Dış boşluk

      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 10, bottom: 13),
        child: Column(
          children: [
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: Dekor.butonText_13_500siyah,
              maxLines: 3,
            ),
            Image(image: resim, width: 70, height: 80, fit: BoxFit.contain),
            Dekor.cizgi25,
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: DetayButonu(metin: 'Detaylar', onPressed: onTiklandi),
            ),
          ],
        ),
      ),
    );
  }
}

// QR Kod Bölümü
class QrKodBolumu extends StatelessWidget {
  final VoidCallback onQrGirisSayfasinaGit;
  final VoidCallback onKidemGirisSayfasinaGit;

  const QrKodBolumu({
    required this.onQrGirisSayfasinaGit,
    required this.onKidemGirisSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BolumBasligi(
          solMetin: "Qr Kod Tarama",
          sagMetin: "Kıdem Tazminatı",
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: MenuKarti(
                  baslik: "Taranan QR Kodlarını\nKaydet ve Tek\nTıkla Aç",
                  image: const Image(
                    image: AppImages.qrKod,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  title: "Tara Ve Kaydet",
                  onTap: onQrGirisSayfasinaGit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MenuKarti(
                  baslik: "Güncel Kıdem Tazminat\nTutarını Hemen\nÖğrenin",
                  image: const Image(
                    width: 120,
                    height: 120,
                    image: AppImages.kidemTazminati,
                    fit: BoxFit.contain,
                  ),
                  title: "Tazminat Hesapla",
                  onTap: onKidemGirisSayfasinaGit,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Ses Bölümü
class SesBolumu extends StatelessWidget {
  final VoidCallback onFrekansSayfasinaGit;

  const SesBolumu({required this.onFrekansSayfasinaGit, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const BolumBasligi(
          solMetin: "Evcil Hayvan Eğitimi",
          sagMetin: "Meditasyon",
        ),
        const SizedBox(height: 20),
        CizgiliCerceve(
          golge: 10,
          margin: const EdgeInsets.symmetric(horizontal: 10), // Dış boşluk
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AppImages.sesFrekansi,
                    fit: BoxFit.contain,
                    width: 90,
                    height: 90,
                  ),
                  SizedBox(
                    width: 220,
                    child: Text(
                      'Köpek, kuş ve kediler için uygun frekanslarla eğitim verin, yüksek veya düşük frekanslarla istenmeyen davranışları kontrol altına alın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              Dekor.cizgi30,
              DetayButonu(
                metin: "Ses Frekansı Oluştur",
                onPressed: onFrekansSayfasinaGit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Kolay Hesaplamalar Bölümü
class KolayHesaplamalarBolumu extends StatelessWidget {
  final VoidCallback onIssizlikSayfasinaGit;
  final VoidCallback onMTVHesaplaSayfasinaGit;
  final VoidCallback onNekadarSayfasinaGit;

  const KolayHesaplamalarBolumu({
    required this.onIssizlikSayfasinaGit,
    required this.onMTVHesaplaSayfasinaGit,
    required this.onNekadarSayfasinaGit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BolumBasligi(solMetin: "Kolay Hesaplamalar", sagMetin: ""),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "İşsizlik\nMaaşı\nHesapla",
                  resim: AppImages.issizlik,
                  onTiklandi: onIssizlikSayfasinaGit,
                ),
              ),
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "Araç\nMTV\nHesapla",
                  resim: AppImages.mtv,
                  onTiklandi: onMTVHesaplaSayfasinaGit,
                ),
              ),
              Expanded(
                child: KarsilastirmaKarti(
                  baslik: "Değer\nKaybı\nHesapla",
                  resim: AppImages.degerKaybi,
                  onTiklandi: onNekadarSayfasinaGit,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

// Detay Butonu
class DetayButonu extends StatelessWidget {
  final String metin;
  final VoidCallback? onPressed;
  final double? butonGenislik;

  const DetayButonu({
    required this.metin,
    required this.onPressed,
    this.butonGenislik,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Renk.koyuMavi.withValues(alpha: 0.04),
          border: Border.all(width: 1.0, color: Renk.cita),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            metin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Renk.koyuMavi,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// Bölüm Başlığı
class BolumBasligi extends StatelessWidget {
  final String solMetin;
  final String sagMetin;

  const BolumBasligi({
    required this.solMetin,
    required this.sagMetin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: Renk.koyuMavi.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(solMetin, style: Dekor.butonText_14_500siyah),
          Text(sagMetin, style: Dekor.butonText_14_500siyah),
        ],
      ),
    );
  }
}

class AppImages {
  static const AssetImage issizlik = AssetImage('assets/images/r507.png');
  static const AssetImage mesai = AssetImage('assets/images/r508.png');
  static const AssetImage mtv = AssetImage('assets/images/r504.png');
  static const AssetImage degerKaybi = AssetImage('assets/images/r543.png');
  static const AssetImage zamKarsilastirma = AssetImage(
    'assets/images/r506.png',
  );
  static const AssetImage maasKarsilastirma = AssetImage(
    'assets/images/r549.png',
  );
  static const AssetImage paraBirimiKarsilastirma = AssetImage(
    'assets/images/r515.png',
  );
  static const AssetImage qrKod = AssetImage('assets/images/r534.png');
  static const AssetImage kidemTazminati = AssetImage('assets/images/r523.png');
  static const AssetImage sesFrekansi = AssetImage('assets/images/r530.png');
  static const AssetImage yapilacaklar = AssetImage('assets/images/r544.png');
  static const AssetImage izinler = AssetImage('assets/images/r535.png');
  static const AssetImage zamOrani = AssetImage('assets/images/r505.png');
  static const AssetImage bruttenNet = AssetImage('assets/images/r527.png');
  static const AssetImage gelirgider = AssetImage('assets/images/r510.png');
}
