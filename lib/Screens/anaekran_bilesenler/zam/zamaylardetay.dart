import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ZamaylarDetay extends StatefulWidget {
  final String aydetay0;
  final String aydetay1;
  final String aydetay2;
  final String aydetay3;
  final String aydetay4;
  final String aydetay5;
  final String aydetay6;
  final String aydetay7;
  final String aydetay8;
  final String aydetay9;
  final String aydetay10;
  final String aydetay11;
  final String aydetay12;
  final String aydetay13;
  final String aydetay14;
  final String aydetay15;
  final String aydetay16;
  final String aydetay17;
  final String aydetay18;
  final String aydetay19;
  final String aydetay20;

  const ZamaylarDetay({
    super.key,
    required this.aydetay0,
    required this.aydetay1,
    required this.aydetay2,
    required this.aydetay3,
    required this.aydetay4,
    required this.aydetay5,
    required this.aydetay6,
    required this.aydetay7,
    required this.aydetay8,
    required this.aydetay9,
    required this.aydetay10,
    required this.aydetay11,
    required this.aydetay12,
    required this.aydetay13,
    required this.aydetay14,
    required this.aydetay15,
    required this.aydetay16,
    required this.aydetay17,
    required this.aydetay18,
    required this.aydetay19,
    required this.aydetay20,
  });

  @override
  State<ZamaylarDetay> createState() => _ZamaylarDetayState();
}

class _ZamaylarDetayState extends State<ZamaylarDetay> {
  late final NumberFormat _numberFormat;
  String paylas = "";

  @override
  void initState() {
    super.initState();
    _numberFormat = NumberFormat("#,##0.00", "tr_TR");
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 500 && !_showAdNotifier.value) {
        _showAdNotifier.value = true;
      }
    });
  }

  @override
  void dispose() {
    _showAdNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdNotifier = ValueNotifier(false);

  void _paylas() {
    paylas = "";
    paylas += "Maaş\n";
    paylas +=
        "Brüt Maaş           ${widget.aydetay17 == "2" || widget.aydetay17 == "3" ? widget.aydetay19 : widget.aydetay0}\n";
    paylas += "Net Maaş            ${widget.aydetay15}\n";
    paylas += "Avans               ${widget.aydetay13}\n";
    paylas += "B.E.S               ${widget.aydetay20}\n";
    paylas += "Kalan Maaş          ${widget.aydetay14}\n";
    paylas += "Kesintiler\n";
    paylas += "Damga Vergisi       ${widget.aydetay6}\n";
    paylas += "SGK Primi           ${widget.aydetay5}\n";
    paylas += "Aylık Gelir Vergisi ${widget.aydetay7}\n";
    paylas += "Sendika Kesintisi   ${widget.aydetay12}\n";
    paylas +=
        "Toplam Kesintiler         ${toplama(widget.aydetay6, widget.aydetay5, widget.aydetay7, widget.aydetay12)}\n";
    paylas += "Destekler \n";
    paylas += "Gelir vergi iadesi  ${widget.aydetay10}\n";
    paylas += "Damga vergi iadesi  ${widget.aydetay11}\n";
    paylas +=
        "Toplam Destekler          ${toplama(widget.aydetay10, widget.aydetay11, "0", "0")}\n";

    SharePlus.instance.share(ShareParams(text: paylas));
  }

  @override
  Widget build(BuildContext context) {
    final iki = toplama(
      widget.aydetay18,
      widget.aydetay12,
      widget.aydetay20,
      "0",
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: _paylas,
              icon: const Icon(Icons.share, size: 20.0, color: Renk.koyuMavi),
            ),
          ),
        ],
        leading: const BackButton(color: Renk.koyuMavi),

        title: Text(widget.aydetay16),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: CemberAna(
                      deger1: double.parse(
                        widget.aydetay4
                            .replaceAll('.', '')
                            .replaceAll(',', '.'),
                      ),
                      isim1: "Toplam Maaş",
                      deger2: double.parse(iki),
                      isim2: "Kesintiler",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 13,
                      right: 16,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(color: Renk.koyuMavi),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Toplam Maaş',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${widget.aydetay4} TL',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Renk.koyuMavi,
                              ),
                              textScaler: TextScaler.noScaling,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 13,
                      right: 16,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(color: Renk.acikMavi),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Vergi Kesintisi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.aydetay18))} TL',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Renk.kirmizi,
                              ),
                              textScaler: TextScaler.noScaling,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 13,
                      right: 16,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(color: Renk.acikMavi),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Sendika Kesintisi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '- ${widget.aydetay12} TL',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Renk.kirmizi,
                              ),
                              textScaler: TextScaler.noScaling,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Net Maaş',
                    '${widget.aydetay15} TL',
                    Renk.koyuMavi,
                  ),
                  Yansatirikili.satir(
                    'B.E.S %3',
                    '- ${widget.aydetay20} TL',
                    Renk.kirmizi,
                  ),
                  Yansatirikili.satir(
                    'Avans',
                    '- ${widget.aydetay13} TL',
                    Renk.kirmizi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Kalan Maaş',
                    '${widget.aydetay14} TL',
                    Renk.koyuMavi,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: RepaintBoundary(child: YerelReklamalti()),
                  ),
                  _buildSectionHeader("MAAŞ"),
                  _buildMaasSection(),
                  _buildSectionHeader("KESİNTİLER"),
                  _buildKesintilerSection(),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showAdNotifier,
                    builder: (context, showAd, child) {
                      return showAd
                          ? const Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            child: RepaintBoundary(child: YerelReklam()),
                          )
                          : const SizedBox.shrink();
                    },
                  ),
                  _buildSectionHeader("DESTEKLER"),
                  _buildDesteklerSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Renk.koyuMavi.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Renk.koyuMavi,
          ),
        ),
      ),
    );
  }

  Widget _buildMaasSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        widget.aydetay17 == "2" || widget.aydetay17 == "3"
            ? Yansatirikili.satir(
              'Saat Ücreti',
              '${widget.aydetay19} TL',
              Renk.koyuMavi,
            )
            : Yansatirikili.satir(
              'Brüt Maaş',
              '${widget.aydetay0} TL',
              Renk.koyuMavi,
            ),
        Dekor.cizgi15,
        Yansatirikili.satir('İkramiye', '${widget.aydetay1} TL', Renk.koyuMavi),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'Sosyal Haklar',
          '${widget.aydetay2} TL',
          Renk.koyuMavi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir('Mesailer', '${widget.aydetay3} TL', Renk.koyuMavi),
      ],
    );
  }

  Widget _buildKesintilerSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Yansatirikili.satir(
          'Damga Vergisi % 0,759',
          '- ${widget.aydetay6} TL',
          Renk.kirmizi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'SGK ve İşsizlik Primi % 15',
          '- ${widget.aydetay5} TL',
          Renk.kirmizi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'Aylık Gelir Vergisi ${widget.aydetay8}',
          '- ${widget.aydetay7} TL',
          Renk.kirmizi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'Sendika Kesintisi',
          '- ${widget.aydetay12} TL',
          Renk.kirmizi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'B.E.S Kesintisi % 3',
          '- ${widget.aydetay20} TL',
          Renk.kirmizi,
        ),
      ],
    );
  }

  Widget _buildDesteklerSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Yansatirikili.satir(
          'Gelir vergi iadesi',
          '${widget.aydetay10} TL',
          Renk.koyuMavi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'Damga vergi iadesi',
          '${widget.aydetay11} TL',
          Renk.koyuMavi,
        ),
        Dekor.cizgi15,
        Yansatirikili.satir(
          'Toplam Destekler',
          '${_numberFormat.format(double.tryParse(toplama(widget.aydetay10.replaceAll('.', '').replaceAll(',', '.'), widget.aydetay11.replaceAll('.', '').replaceAll(',', '.'), "0", "0")))} TL',
          Renk.koyuMavi,
        ),
        Dekor.cizgi15,
      ],
    );
  }

  String toplama(String bir, String iki, String uc, String dort) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;
    double ucDouble = double.tryParse(uc) ?? 0;
    double dortDouble = double.tryParse(dort) ?? 0;

    return (birDouble + ikiDouble + ucDouble + dortDouble).toStringAsFixed(2);
  }

  String cikarma(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    return (birDouble - ikiDouble).toStringAsFixed(2);
  }
}
