// lib/Screens/anaekran_bilesenler/kazanclar/kazanclar_ana.dart
import 'dart:async';
import 'dart:math';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/data_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/grafik_painter.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/isci_takvim_widget.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Anagrafik extends StatefulWidget {
  final CircularBottomNavigationController navigationController;
  final int pozisyon;

  const Anagrafik({
    super.key,
    required this.navigationController,
    required this.pozisyon,
  });

  @override
  State<Anagrafik> createState() => _AnagrafikState();
}

class _AnagrafikState extends State<Anagrafik>
    with SingleTickerProviderStateMixin {
  // ANİMASYON
  late AnimationController _kontrolor;
  late Animation<double> _animasyon;
  final _avansController = TextEditingController();
  //final _veriYoneticisi = VeriYoneticisi();
  late final DataServisi _dataServisi;

  // TAKVİM KEY
  late final GlobalKey<IsciTakvimWidgetState> _takvimKey;

  // STATE DEĞİŞKENLERİ
  final _aylikVeri = ValueNotifier<AylikVeri>(AylikVeri.bos());

  @override
  void initState() {
    super.initState();

    // TAKVİM KEY
    _takvimKey = GlobalKey<IsciTakvimWidgetState>();
    _dataServisi = DataServisi();

    // VERİ YÖNETİCİSİNE DİNLEYİCİ EKLE
    //_veriYoneticisi.dinleyiciEkle(_grafigiGuncelle);

    // ANİMASYON
    _kontrolor = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animasyon = Tween<double>(begin: 0.0, end: 0.0).animate(_kontrolor);

    // NAVİGASYON DİNLEYİCİSİ
    widget.navigationController.addListener(_onTabChanged);

    // İLK YÜKLEME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baslangicIslemleri();
    });
  }

  Future<void> _baslangicIslemleri() async {
    try {
      debugPrint('Başlangıç işlemleri başlatılıyor...');

      // 1. AYARLARI YÜKLE
      await _dataServisi.ayarlariYukle();

      // 2. GRAFİĞİ GÜNCELLE
      // await _grafigiGuncelle();

      debugPrint('Başlangıç işlemleri tamamlandı');
    } catch (e) {
      debugPrint('!!! Başlangıç hatası: $e');
    }
  }

  Future<void> _grafigiGuncelle() async {
    debugPrint('Grafik hesaplanıyor (bu mesaj SADECE 1 KEZ çıkmalı)');

    try {
      final takvimState = _takvimKey.currentState;
      if (takvimState == null || !mounted) {
        debugPrint('HATA: Takvim state bulunamadı');
        return;
      }

      if (!takvimState.veriYuklendi) {
        debugPrint('Veri henüz yüklenmedi (bu olmamalı)');
        return;
      }

      final yeniVeri = await _dataServisi.aylikVeriyiHesapla(
        takvimState.seciliAy,
      );

      final double grafikDegeri = _grafikDegeriHesapla(takvimState.seciliAy);

      if (mounted) {
        _aylikVeri.value = yeniVeri;

        _animasyon = Tween<double>(
          begin: 0.0,
          end: grafikDegeri,
        ).animate(CurvedAnimation(parent: _kontrolor, curve: Curves.easeOut));

        if (widget.navigationController.value == widget.pozisyon) {
          if (_kontrolor.isCompleted) _kontrolor.reset();
          _kontrolor.forward();
        }

        debugPrint('Grafik güncellendi: Net Kazanç = ${yeniVeri.netKazanc}');
      }
    } catch (e) {
      debugPrint('!!! Grafik güncelleme hatası: $e');
      if (mounted) {
        _aylikVeri.value = AylikVeri.bos();
      }
    }
  }

  double _grafikDegeriHesapla(DateTime seciliAy) {
    final now = DateTime.now();
    final bool suankiAy =
        (seciliAy.year == now.year && seciliAy.month == now.month);

    if (!suankiAy) return 4.7;

    final int simdikiGun = min(30, now.day);
    double oran = 0.0;

    if (simdikiGun >= 1 && simdikiGun <= 14) {
      final ayar = 0.07 - ((simdikiGun - 1) * (0.07 / 15));
      oran = (simdikiGun / 30) - ayar;
    } else if (simdikiGun >= 15 && simdikiGun <= 30) {
      final ayar = ((simdikiGun - 15) * (0.04 / 15));
      oran = (simdikiGun / 30) + ayar;
    }

    return (4.7 * oran).clamp(0.0, 4.7);
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (widget.navigationController.value == widget.pozisyon) {
      if (!_kontrolor.isAnimating) _kontrolor.forward();
    } else {
      if (_kontrolor.isAnimating) _kontrolor.stop();
    }
  }

  @override
  void dispose() {
    debugPrint('=== ANAGRAFİK DİSPOSE EDİLİYOR ===');
    //_veriYoneticisi.dinleyiciKaldir(_grafigiGuncelle);
    _avansController.dispose();
    _kontrolor.dispose();
    widget.navigationController.removeListener(_onTabChanged);
    _dataServisi.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ValueListenableBuilder<AylikVeri>(
                  valueListenable: _aylikVeri,
                  builder: (context, veri, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TAKVİM
                        IsciTakvimWidget(
                          key: _takvimKey,
                          onKazancChanged: _grafigiGuncelle,
                          onGunlerChanged: () => setState(() {}),
                          dataServisi: _dataServisi,
                        ),

                        const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: RepaintBoundary(child: YerelReklamalti()),
                        ),

                        // GRAFİK BÖLÜMÜ
                        _grafikBolumu(veri),

                        // GÜN BİLGİLERİ
                        _gunBilgileriBolumu(veri),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: RepaintBoundary(child: YerelReklam()),
                        ),
                        // KESİNTİLER
                        _kesintilerBolumu(veri),
                        const SizedBox(height: 10),
                        // VERGİ KESİNTİLERİ
                        _vergiKesintileriBolumu(veri),
                        // YÜZDE GRAFİĞİ
                        _yuzdeGrafikBolumu(veri),
                        const SizedBox(height: 10),
                        _baslikContainer('Hesaplama Sonuçları'),
                        const SizedBox(height: 10),
                        // TOPLAM KESİNTİ
                        _sonHesaplamaWidget(veri),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: RepaintBoundary(child: YerelReklamiki()),
                        ),
                        // BİLGİLENDİRME
                        _baslikContainer('Bilgilendirme'),
                        const SizedBox(height: 10),
                        _bilgilendirmeBolumu(),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sonHesaplamaWidget(AylikVeri veri) {
    final toplamKesinti =
        veri.kesintiDetaylari.sgk +
        veri.kesintiDetaylari.issizlik +
        veri.kesintiDetaylari.uygulananVergi +
        veri.kesintiDetaylari.uygulananDamga +
        veri.kesintiDetaylari.bes;

    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Column(
        children: [
          _kesintiSatiriWidget(
            'Brüt Kazanç',
            veri.brutKazanc,
            Renk.pastelKoyuMavi.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'Toplam Kesinti',
            toplamKesinti,
            Colors.red.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'BES Kesintisi (${_dataServisi.besOrani.toStringAsFixed(1)}%)',
            veri.kesintiDetaylari.bes,
            Colors.purple.withValues(alpha: 0.3),
          ),
          Dekor.cizgi15,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Text('Avans', style: TextStyle(fontSize: 14)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  () => _showAvansGirisDialog(
                                    veri.kesintiDetaylari.avans,
                                  ),
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                                color: Renk.pastelKoyuMavi.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              label: Text(
                                'Avansı Düzenle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Renk.pastelKoyuMavi.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  NumberFormat(
                    "₺ #,##0.00",
                    "tr_TR",
                  ).format(veri.kesintiDetaylari.avans),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // AVANS DÜZENLEME BUTONU
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'Net Kazanç (Eline Geçen)',
            veri.netKazanc,
            Colors.teal.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvansGirisDialog(double mevcutAvans) async {
    _avansController.text =
        mevcutAvans > 0 ? mevcutAvans.toStringAsFixed(2) : '';

    final takvimState = _takvimKey.currentState;
    if (takvimState == null) return;

    await AcilanPencere.show(
      context: context,
      title: 'Avans Miktarı',
      height: 0.5,
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${DateFormat('MMMM yyyy', 'tr_TR').format(takvimState.seciliAy)} için avans miktarı:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 15),

            MetinKutusu(
              controller: _avansController,
              labelText: 'Avans Miktarı (TL)',
              hintText: '0,00 TL',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              clearButtonVisible: true,
              onChanged: (String value) {},
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Renk.buton('İptal', 45),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final miktar =
                          double.tryParse(_avansController.text) ?? 0.0;

                      await _dataServisi.avansAyarlariniKaydet(
                        miktar,
                        takvimState.seciliAy,
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      await _grafigiGuncelle();
                    },
                    child: Renk.buton('Kaydet', 45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _grafikBolumu(AylikVeri veri) {
    return Column(
      children: [
        _baslikContainer('Grafik Bilgileri'),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: AnimatedBuilder(
            animation: _animasyon,
            builder: (context, _) {
              return CustomPaint(
                painter: GrafikPainter(
                  animation: _animasyon.value,
                  ekrantext: veri.netKazanc,
                  ayIsmi: veri.seciliAyIsmi,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _gunBilgileriBolumu(AylikVeri veri) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _gunBilgiWidget(
                  baslik: "Çalışılan\nGün",
                  deger: "${veri.calismaGunSayisi} gün",
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _gunBilgiWidget(
                  baslik: "Mesai\nGün",
                  deger: "${veri.mesaiGunSayisi} gün",
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _gunBilgiWidget(
                  baslik: "Çalışma\nSaat",
                  deger: veri.toplamCalismaSaati.toStringAsFixed(1),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _gunBilgiWidget(
                  baslik: "Mesai\nSaat",
                  deger: veri.toplamMesaiSaati.toStringAsFixed(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gunBilgiWidget({required String baslik, required String deger}) {
    return CizgiliCerceve(
      golge: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                baslik,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Dekor.cizgi15,

            Text(
              deger,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Renk.pastelKoyuMavi,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _kesintilerBolumu(AylikVeri veri) {
    return Column(
      children: [
        _baslikContainer('Kesintiler'),
        const SizedBox(height: 15),
        // BES AYARI
        _besAyariWidget(),
        const SizedBox(height: 15),
        _baslikContainer(
          'Sgk Kesintiler',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        _sgkBesKesintileriWidget(veri),
      ],
    );
  }

  Widget _sgkBesKesintileriWidget(AylikVeri veri) {
    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Column(
        children: [
          _kesintiSatiriWidget(
            'SGK İşçi Payı (${veri.kesintiDetaylari.sgkYuzde.toStringAsFixed(0)}%)',
            veri.kesintiDetaylari.sgk,
            Colors.orange.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'İşsizlik İşçi Payı (${veri.kesintiDetaylari.issizlikYuzde.toStringAsFixed(0)}%)',
            veri.kesintiDetaylari.issizlik,
            Colors.amber.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'Sgk Kesintisi Toplam',
            veri.kesintiDetaylari.sgk + veri.kesintiDetaylari.issizlik,
            Colors.teal.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _vergiKesintileriBolumu(AylikVeri veri) {
    return Column(
      children: [
        _baslikContainer(
          'Vergi Kesintiler',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        _vergiKesintileriWidget(veri),
      ],
    );
  }

  Widget _vergiKesintileriWidget(AylikVeri veri) {
    final double uygulananVergi = veri.kesintiDetaylari.uygulananVergi;
    final double uygulananDamga = veri.kesintiDetaylari.uygulananDamga;

    final double toplamVergiDamgaKesintisi =
        veri.kesintiDetaylari.uygulananVergi +
        veri.kesintiDetaylari.uygulananDamga;

    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Column(
        children: [
          _kesintiSatiriWidget(
            'Hesaplanan Gelir Vergisi',
            veri.kesintiDetaylari.vergi,
            Colors.red.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,

          _kesintiSatiriWidget(
            'Asgari Geçim İstisnası',
            veri.kesintiDetaylari.agi,
            Colors.grey.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,
          _kesintiSatiriWidget(
            'Uygulanan Gelir Vergisi',
            uygulananVergi,
            Colors.red.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,
          _kesintiSatiriWidget(
            'Hesaplanan Damga Vergisi',
            veri.kesintiDetaylari.damga,
            Colors.purple.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,
          _kesintiSatiriWidget(
            'Damga Vergisi İstisnası',
            veri.kesintiDetaylari.damgaIstisnasi,
            Colors.blue.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,
          _kesintiSatiriWidget(
            'Uygulanan Damga Vergisi',
            uygulananDamga,
            Colors.purple.withValues(alpha: 0.8),
          ),
          Dekor.cizgi15,
          _kesintiSatiriWidget(
            'Vergi Kesintileri Toplam',
            toplamVergiDamgaKesintisi,
            Colors.red.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _yuzdeGrafikBolumu(AylikVeri veri) {
    return Column(
      children: [
        const SizedBox(height: 15),
        _baslikContainer(
          'Kesinti Dağılımı',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 15),
        CizgiliCerceve(
          golge: 5,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: _yuzdeGrafikWidget(veri),
        ),
      ],
    );
  }

  Widget _yuzdeGrafikWidget(AylikVeri veri) {
    final brut = veri.brutKazanc;
    if (brut <= 0) return const SizedBox();
    final double hesaplananVergi = veri.kesintiDetaylari.vergi;
    final double hesaplananDamga = veri.kesintiDetaylari.damga;

    final List<YuzdeVeri> veriler = [
      YuzdeVeri(
        'Net Kazanç',
        veri.netKazanc,
        Colors.green.withValues(alpha: 0.8),
      ),
      YuzdeVeri(
        'SGK İşçi Payı',
        veri.kesintiDetaylari.sgk,
        Colors.orange.withValues(alpha: 0.8),
      ),
      YuzdeVeri(
        'İşsizlik',
        veri.kesintiDetaylari.issizlik,
        Colors.amber.withValues(alpha: 0.8),
      ),
      YuzdeVeri(
        'Gelir Vergisi',
        veri.kesintiDetaylari.uygulananVergi,
        Colors.red.withValues(alpha: 0.8),
      ),
      YuzdeVeri(
        'Damga Vergisi',
        veri.kesintiDetaylari.uygulananDamga,
        Colors.purple.withValues(alpha: 0.8),
      ),
      if (veri.kesintiDetaylari.avans > 0)
        YuzdeVeri(
          'Avans',
          veri.kesintiDetaylari.avans,
          Colors.blue.withValues(alpha: 0.8),
        ),
      YuzdeVeri(
        'BES',
        veri.kesintiDetaylari.bes,
        Colors.teal.withValues(alpha: 0.8),
      ),
    ];

    return Column(
      children:
          veriler.map((veriItem) {
            final double yuzde = (veriItem.tutar / brut) * 100;
            String? istisnaBilgisi;

            if (veriItem.ad == 'Gelir Vergisi' &&
                veri.kesintiDetaylari.agi > 0) {
              final double agiKarsilamaYuzdesi =
                  hesaplananVergi > 0
                      ? (veri.kesintiDetaylari.agi / hesaplananVergi * 100)
                          .clamp(0.0, 100.0)
                      : 0.0;
              istisnaBilgisi =
                  '(${agiKarsilamaYuzdesi.toStringAsFixed(1)}% Vergi İstisnası ile karşılandı)';
            } else if (veriItem.ad == 'Damga Vergisi' &&
                veri.kesintiDetaylari.damgaIstisnasi > 0) {
              final double damgaKarsilamaYuzdesi =
                  hesaplananDamga > 0
                      ? (veri.kesintiDetaylari.damgaIstisnasi /
                              hesaplananDamga *
                              100)
                          .clamp(0.0, 100.0)
                      : 0.0;
              istisnaBilgisi =
                  '(${damgaKarsilamaYuzdesi.toStringAsFixed(1)}% Vergi İstisnası ile karşılandı)';
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: veriItem.renk,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),

                          Text(
                            veriItem.ad,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          if (istisnaBilgisi != null)
                            Text(
                              istisnaBilgisi,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${yuzde.toStringAsFixed(1)} %',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: yuzde / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(veriItem.renk),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
    );
  }

  Widget _bilgilendirmeBolumu() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 120, top: 10),
      child: Column(
        children: [
          _bilgiKartWidget(
            title: '📊 Grafik Ne Gösteriyor?',
            content: [
              '• Bu daire, seçtiğiniz ayda takvimde işaretlediğiniz çalışma + mesai saatlerinin **toplam net kazancını** gösterir',
              '• Dairenin doluluk oranı sadece **mevcut ay** için gün ilerlemesini temsil eder:',
              '   - Bugün ayın 15 i ise daire yaklaşık %50 dolu görünür',
              '   - Geçmiş veya gelecek aylarda daire **tam dolu** gözükür',
              '• Ortadaki büyük rakam → seçilen aya ait **toplam elinize geçen net kazanç** (₺)',
            ],
            color: Colors.blue.shade50,
          ),
          const SizedBox(height: 16),

          _bilgiKartWidget(
            title: '💰 Kazanç Nasıl Hesaplanır?',
            content: [
              'BRÜT KAZANÇ = (Normal Çalışma Saati × Saat Ücreti) + (Mesai Saati × Mesai Katsayısı)',
              '',
              'KESİNTİLER (yaklaşık):',
              '• SGK İşçi Payı: Brütten %14 (normal), %7.5 (emekli), %0 (SGK yok seçeneği)',
              '• İşsizlik Primi: Brütten %1 (sadece normal çalışanlar)',
              '• Gelir Vergisi: SGK sonrası kalan üzerinden seçtiğiniz oran',
              '• Damga Vergisi: Brütten %0.759 (her durumda kesilir)',
              '• BES Kesintisi: Brütten %1–%10 arası (siz belirlersiniz, isteğe bağlı)',
              '',
              'NET KAZANÇ (Eline Geçen) = Brüt Kazanç − (SGK + İşsizlik + Gelir Vergisi + Damga + BES)',
              'Not: AGİ ve Damga İstisnası otomatik olarak uygulanır',
            ],
            color: Colors.green.shade50,
          ),
          const SizedBox(height: 16),

          _bilgiKartWidget(
            title: '⚠️ Önemli Uyarılar',
            content: [
              '• Gösterilen tüm tutarlar **yaklaşık tahmini** değerlerdir',
              '• Gerçek bordroda vergi dilimleri, asgari ücret desteği, ek ödemeler gibi faktörler farklılık yaratabilir',
              '• Resmi tatil, bayram, izin hakkı vb. otomatik hesaplanmaz',
              '• Kesin bordro ve yasal ödeme için mutlaka **muhasebecinize** veya **SGKya danışın',
              '• Tüm veriler cihazınızda yerel olarak saklanır – yedek almayı unutmayın!',
            ],
            color: Colors.red.shade50,
          ),
          const SizedBox(height: 20),

          CizgiliCerceve(
            golge: 5,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📝 Çok Önemli Hatırlatma',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu uygulama sadece tahmini hesaplama yapar. Gerçek bordro, vergi beyannamesi, SGK primleri ve yasal kesintiler için mutlaka muhasebe uzmanınıza veya SGK ya danışınız.\n\n'
                  'Uygulamada yer alan tüm bilgiler ve hesaplamalar kişisel kullanım içindir. Uygulama hiçbir şekilde yasal veya mali sorumluluk kabul etmez.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baslikContainer(String baslik, {TextStyle? style}) {
    return Container(
      height: 45,
      color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            baslik,
            style:
                style ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _kesintiSatiriWidget(String ad, double tutar, Color renk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(ad, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            NumberFormat("₺ #,##0.00", "tr_TR").format(tutar),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _bilgiKartWidget({
    required String title,
    required List<String> content,
    required Color color,
  }) {
    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...content.map((line) {
            return Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _besAyariWidget() {
    return CizgiliCerceve(
      golge: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.savings, color: Renk.pastelKoyuMavi, size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'BES (Bireysel Emeklilik)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Renk.pastelKoyuMavi,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _dataServisi.besAktif,
                  activeThumbColor: Renk.pastelKoyuMavi.withValues(alpha: 0.8),
                  onChanged: (value) async {
                    await _dataServisi.besAyarlariniKaydet(
                      value,
                      _dataServisi.besOrani,
                    );
                    _grafigiGuncelle();
                  },
                ),
              ],
            ),

            if (_dataServisi.besAktif) ...[
              const SizedBox(height: 10),
              const Text(
                'BES Oranı (%)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              _BesSliderWidget(
                dataServisi: _dataServisi,
                onGrafigiGuncelle: _grafigiGuncelle,
              ),

              const SizedBox(height: 5),
              const Text(
                'BES kesintisi brüt maaşınızın belirlediğiniz yüzdesi kadar kesilir.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ] else ...[
              const SizedBox(height: 5),
              const Text(
                'BES kesintisi aktif değil',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BesSliderWidget extends StatefulWidget {
  final DataServisi dataServisi;
  final VoidCallback onGrafigiGuncelle;

  const _BesSliderWidget({
    required this.dataServisi,
    required this.onGrafigiGuncelle,
  });

  @override
  State<_BesSliderWidget> createState() => _BesSliderWidgetState();
}

class _BesSliderWidgetState extends State<_BesSliderWidget> {
  late double _tempBesOrani;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tempBesOrani = widget.dataServisi.besOrani;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _tempBesOrani,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            label: '${_tempBesOrani.toStringAsFixed(1)}%',
            activeColor: Renk.pastelKoyuMavi.withValues(alpha: 0.9),
            inactiveColor: Renk.pastelMavi,

            onChanged: (value) {
              setState(() {
                _tempBesOrani = value;
              });

              _debounceTimer?.cancel();
              _debounceTimer = Timer(
                const Duration(milliseconds: 300),
                () async {
                  await widget.dataServisi.besAyarlariniKaydet(
                    widget.dataServisi.besAktif,
                    value,
                  );
                  widget.onGrafigiGuncelle();
                },
              );
            },
          ),
        ),

        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Renk.pastelMavi,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${_tempBesOrani.toStringAsFixed(1)} %',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
