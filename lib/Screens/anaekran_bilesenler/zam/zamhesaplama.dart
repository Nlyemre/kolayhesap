import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/ciktilar/excel.dart';
import 'package:app/Screens/anaekran_bilesenler/ciktilar/pdf.dart';
import 'package:app/Screens/anaekran_bilesenler/maaskarsilastir/zamgrafik.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/grafik.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/hesaplama.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/listeana.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/tablo.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamaylardetay.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamgiris.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';

class ZamHesaplama extends StatefulWidget {
  final int sayfa;
  final int sayfaId;
  final int grafiksayfaId;
  final List<num> zamList;
  final List<num> kidemList;
  final List<List<num>> brutDetayList;
  final List<List<num>> saatDetayList;
  final List<List<num>> calismasaatList;
  final List<List<num>> ikramiyeList;
  final List<num> saatList;
  final List<num> brutList;
  final List<num> vergiList;
  final List<int> vergiNoList;
  final List<num> sosyalHakList;
  final List<num> cocukParasiList;
  final List<num> sendikaList;
  final List<num> avansList;
  final List<int> secimList;
  final List<String> calisanTipiList;
  final List<int> engelliList;
  final List<String> mesaiList;
  final List<num> sosyalzamList;
  final List<num> sadecebuayList;
  final List<num> ekodemeList;
  final List<String> besList;
  final double ozelvergi;
  final int ozelvergino;

  const ZamHesaplama({
    super.key,
    required this.sayfaId,
    required this.zamList,
    required this.kidemList,
    required this.grafiksayfaId,
    required this.brutDetayList,
    required this.saatDetayList,
    required this.calismasaatList,
    required this.ikramiyeList,
    required this.saatList,
    required this.brutList,
    required this.vergiList,
    required this.vergiNoList,
    required this.sosyalHakList,
    required this.cocukParasiList,
    required this.sendikaList,
    required this.avansList,
    required this.secimList,
    required this.calisanTipiList,
    required this.engelliList,
    required this.mesaiList,
    required this.sosyalzamList,
    required this.sadecebuayList,
    required this.ekodemeList,
    required this.sayfa,
    required this.besList,
    required this.ozelvergi,
    required this.ozelvergino,
  });

  @override
  State<ZamHesaplama> createState() => ZamHesaplamaState();
}

class ZamHesaplamaState extends State<ZamHesaplama> {
  late MaasHesaplayici hesaplayici;
  int sayfasecimi = 0;
  List<bool> isSelected = [true, false, false];
  bool _sayfayuklendi = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    hesaplayici = MaasHesaplayici(context, widget);
    Future.microtask(() async {
      await hesaplayici.veriGuncelle();
      setState(() {
        _sayfayuklendi = false;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    if (widget.grafiksayfaId == 4 || widget.grafiksayfaId == 3) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ZamGiris(
                  id: widget.sayfaId,
                  grafikid: widget.grafiksayfaId,
                  sayfa: widget.sayfa,
                ),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                onPressed: ciktilar,
                icon: const Icon(
                  Icons.share,
                  size: 20.0,
                  color: Renk.pastelKoyuMavi,
                ),
              ),
            ),
          ],
          leading: const BackButton(color: Renk.pastelKoyuMavi),
          centerTitle: true,
          title: Text(
            widget.sayfaId == 3
                ? "Karşılaştırma Sonuçları"
                : "Hesaplama Sonuçları",
            style: Dekor.butonText_18_500mavi,
          ),
        ),
        body:
            _sayfayuklendi
                ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
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
                                    sayfasecimi = index;
                                    isSelected = List.generate(
                                      isSelected.length,
                                      (i) => i == index,
                                    );
                                  });
                                },
                                maxLines: 1,
                                height: 40,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            widget.sayfaId == 3
                                ? karsilastirmaSayfalari(sayfasecimi)
                                : ortaSayfalar(sayfasecimi),
                      ),
                      const RepaintBoundary(child: BannerReklamiki()),
                    ],
                  ),
                ),
      ),
    );
  }

  List<List<String>> saattablotextal() {
    return hesaplayici.saatTabloKontrol;
  }

  Widget ortaSayfalar(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKartRow(
                'İlk Ay Net',
                '${hesaplayici.saatTabloKontrol[16][0].isEmpty ? Hesaplayici.paraBirimiFormatla(0) : hesaplayici.saatTabloKontrol[16][0]} TL',
                'Son Ay Net',
                '${hesaplayici.saatTabloKontrol[16][11].isEmpty ? Hesaplayici.paraBirimiFormatla(0) : hesaplayici.saatTabloKontrol[16][11]} TL',
              ),
              _buildKartRow(
                'Ort.Günlük Brüt',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[8]} TL',
                'Ort.Günlük Net',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[9]} TL',
              ),
              _buildKartRow(
                'Ort. Aylık Brüt',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[6]} TL',
                'Ort. Aylık Net',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[7]} TL',
              ),
              const SizedBox(height: 15),
              const RepaintBoundary(child: YerelReklamuc()),
              const SizedBox(height: 5),
              baslik("Aylara Göre Net Maaş Detayları"),
              const SizedBox(height: 10),
              ...List.generate(12, (i) {
                String month = aylarBuyuk[i];
                String value =
                    '${hesaplayici.saatTabloKontrol[16][i].isEmpty ? Hesaplayici.paraBirimiFormatla(0) : hesaplayici.saatTabloKontrol[16][i]} TL';
                return _kartaylar(context, i, month, value);
              }),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _showAdNotifier,
                builder: (context, showAd, child) {
                  return showAd
                      ? const RepaintBoundary(child: YerelReklamiki())
                      : const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 10),
              baslik("Aylara Göre Vergi Detayları"),

              const SizedBox(height: 15),
              _buildKartRow(
                'Yılda Kaç Maaş\nVergi Ödeniyor',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[4]} Maaş',
                'Yıllık Ortalama\nVergi',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[1]} TL',
              ),
              _buildKartRow(
                'Kaç Gün Vergi\nİçin Çalışılıyor',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[5]} Gün',
                'Aylık Ortalama\nVergi',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[2]} TL',
              ),
              _buildKartRow(
                'Ortalama Yıllık\nVergi Yüzdesi',
                hesaplayici.aciklamaAltVergiSayiKontrol[0],
                'Günlük Ortalama\nVergi',
                '${hesaplayici.aciklamaAltVergiSayiKontrol[3]} TL',
              ),
              if (hesaplayici.calisanTipi != "Normal") ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Text(
                    "Çalışan Tipi Emekli olduğu için Sgk prim tutarı % 7.5 hesaplanmıştır.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
              if (hesaplayici.engellimi != 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  child: Text(
                    "Gelir Vergisi Kanunu’nun 31’inci maddesinde yer alan engellilik indirimine göre ${hesaplayici.engellimi}. derece engelli indiriminden yararlandığınız için kdv matrah tutarından ${hesaplayici.engellikesinti[1]} düşülerek gelir vergisi tutarı hesaplanmıştır",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              baslik("Sayfanın Temel Özellikleri"),
              _altbilgilendirme(),
              const SizedBox(height: 40),
            ],
          ),
        );
      case 1:
        return DynamicTable(
          sutunsayisi: 17,
          aylar: aylar,
          basliklar:
              hesaplayici.sayfaSecimiGelen == 0 ||
                      hesaplayici.sayfaSecimiGelen == 1
                  ? basliklar
                  : saatListeBaslik,
          veriler: hesaplayici.saatTabloKontrol,
        );
      case 2:
        return GrafikWidget(
          grafiknett: hesaplayici.grafiknet,
          grafikkesintii: hesaplayici.grafikkesinti,
          burutt: hesaplayici.burut,
          saattablo: saattablotextal(),
          saatsonn: hesaplayici.saatson,
          calismasaatii: hesaplayici.calismaSaatigelen,
          sayfaSecimiGelenn: hesaplayici.sayfaSecimiGelen,
          bes: hesaplayici.besListe,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget karsilastirmaSayfalari(int index) {
    switch (index) {
      case 0:
        return AylikNetUcretKarsilastirma(
          sayfaId: widget.sayfaId,
          grafiksayfaId: widget.grafiksayfaId,
          aylarYazi: aylarYazi,
          sonListe: hesaplayici.sonListe,
          zam: hesaplayici.zam,
          kidem: hesaplayici.kidem,
        );
      case 1:
        return DynamicTable(
          sutunsayisi: 24,
          aylar: aylar,
          basliklar:
              widget.sayfaId == 3 && widget.grafiksayfaId == 1
                  ? karsilastirmaBaslik
                  : karsilastirmaBaslikiki,
          veriler: hesaplayici.karsilastirmaTabloKontrol,
        );
      case 2:
        return ZamGrafikWidget(
          sonListe: hesaplayici.sonListe,
          sayfano: widget.grafiksayfaId,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget baslik(String metin) {
    return Container(
      height: 45,
      width: double.infinity,
      color: Renk.pastelKoyuMavi.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          metin,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Renk.pastelKoyuMavi,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // Kart satırları oluşturma
  Widget _buildKartRow(
    String baslik1,
    String deger1,
    String baslik2,
    String deger2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Kartt.kartHazir(baslik: baslik1, deger: deger1),
        Kartt.kartHazir(baslik: baslik2, deger: deger2),
      ],
    );
  }

  // Aylık detay kartları
  Widget _kartaylar(
    BuildContext context,
    int index,
    String month,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 1, left: 1),
      child: CizgiliCerceve(
        golge: 5,
        backgroundColor: Renk.acikgri,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(month, style: Dekor.butonText_14_400siyah),
              Text(value, style: Dekor.butonText_16_500mavi),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color.fromARGB(255, 98, 98, 98),
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ZamaylarDetay(
                      aydetay0: hesaplayici.saatTabloKontrol[0][index],
                      aydetay1: hesaplayici.saatTabloKontrol[1][index],
                      aydetay2: hesaplayici.saatTabloKontrol[2][index],
                      aydetay3: hesaplayici.saatTabloKontrol[3][index],
                      aydetay4: hesaplayici.saatTabloKontrol[4][index],
                      aydetay5: hesaplayici.saatTabloKontrol[5][index],
                      aydetay6: hesaplayici.saatTabloKontrol[6][index],
                      aydetay7: hesaplayici.saatTabloKontrol[7][index],
                      aydetay8: hesaplayici.saatTabloKontrol[8][index],
                      aydetay9: hesaplayici.saatTabloKontrol[9][index],
                      aydetay10: hesaplayici.saatTabloKontrol[10][index],
                      aydetay11: hesaplayici.saatTabloKontrol[11][index],
                      aydetay12: hesaplayici.saatTabloKontrol[12][index],
                      aydetay13: hesaplayici.saatTabloKontrol[13][index],
                      aydetay14: hesaplayici.saatTabloKontrol[15][index],
                      aydetay15: hesaplayici.saatTabloKontrol[16][index],
                      aydetay16: "$month DETAYLAR",
                      aydetay17: hesaplayici.sayfaSecimiGelen.toString(),
                      aydetay18: hesaplayici.grafikkesinti[index]
                          .toStringAsFixed(2),
                      aydetay19: (hesaplayici.saatson[index] *
                              hesaplayici.calismaSaatigelen[index])
                          .toStringAsFixed(2),
                      aydetay20: hesaplayici.saatTabloKontrol[14][index],
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _paylas() {
    String paylas = "";
    for (int i = 0; i < 12; i++) {
      String bir = Hesaplayici.paraBirimiFormatla(
        hesaplayici.sonListe[i][7][0],
      );
      String iki = Hesaplayici.paraBirimiFormatla(
        hesaplayici.sonListe[i][7][1],
      );
      String uc = Hesaplayici.paraBirimiFormatla(hesaplayici.sonListe[i][7][2]);
      paylas += "${aylarYazi[i]} Ayı Karşılaştırma\n\n";
      paylas += "Eski Ücret  : $bir\n";
      paylas += "Yeni Ücret  : $iki\n";
      paylas += "Fark        : $uc\n";
      paylas +=
          "Zam Oranı   : % ${hesaplayici.zam[i].toString()} - ${hesaplayici.sosyalzam[i].toString()}\n";
      paylas += "Kıdem Farkı : ${hesaplayici.kidem[i].toString()} TL\n\n";
    }
    SharePlus.instance.share(ShareParams(text: paylas));
  }

  void _paylasiki() {
    String paylasiki = "";
    for (int i = 0; i < 12; i++) {
      String bir = Hesaplayici.paraBirimiFormatla(
        hesaplayici.sonListe[i][7][0],
      );
      String iki = Hesaplayici.paraBirimiFormatla(
        hesaplayici.sonListe[i][7][1],
      );
      String uc = Hesaplayici.paraBirimiFormatla(hesaplayici.sonListe[i][7][2]);
      paylasiki += "${aylarYazi[i]} Ayı Karşılaştırma\n\n";
      paylasiki += "1. Maaş  : $bir\n";
      paylasiki += "2. Maaş  : $iki\n";
      paylasiki += "Fark     : $uc\n";
    }
    SharePlus.instance.share(ShareParams(text: paylasiki));
  }

  void _paylasuc() {
    String paylasuc = "Aylara Göre Net Maaş Detayları\n\n";
    for (int i = 0; i < 12; i++) {
      String bir = Hesaplayici.paraBirimiFormatla(hesaplayici.netOdeme[i]);
      paylasuc += "${aylarBuyuk[i]} : $bir TL\n\n";
    }
    SharePlus.instance.share(ShareParams(text: paylasuc));
  }

  void ciktilar() async {
    final double ekranYuksekligi = MediaQuery.of(context).size.height;

    double oran;
    if (ekranYuksekligi < 600) {
      oran = 0.65;
    } else {
      oran = 0.5;
    }
    await AcilanPencere.show(
      context: context,
      title: 'Paylaş',
      height: oran,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text(
              'PDF Oluştur Ve Paylaş',
              style: Dekor.butonText_16_400siyah,
            ),
            onTap: () {
              if (!AboneMi.isReklamsiz) {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  // ignore: use_build_context_synchronously
                  AbonelikDialog.abonegit(context);
                });
              } else {
                Navigator.of(context).pop();
                Future.microtask(() {
                  if (widget.sayfaId == 3 && sayfasecimi != 2) {
                    PdfOlustur.olusturPdf(
                      aylar: aylar,
                      basliklar:
                          widget.sayfaId == 3 && widget.grafiksayfaId == 1
                              ? karsilastirmaBaslik
                              : karsilastirmaBaslikiki,
                      veriler: hesaplayici.karsilastirmaTabloKontrol,
                    );
                  } else if ((widget.sayfaId == 2 || widget.sayfaId == 1) &&
                      sayfasecimi != 2) {
                    PdfOlustur.olusturPdf(
                      aylar: aylar,
                      basliklar:
                          hesaplayici.sayfaSecimiGelen == 0 ||
                                  hesaplayici.sayfaSecimiGelen == 1
                              ? basliklar
                              : saatListeBaslik,
                      veriler: hesaplayici.saatTabloKontrol,
                    );
                  }
                });
              }
            },
          ),
          Dekor.cizgi15,
          ListTile(
            title: const Text(
              'Excel Oluştur Ve Paylaş',
              style: Dekor.butonText_16_400siyah,
            ),
            onTap: () {
              if (!AboneMi.isReklamsiz) {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  // ignore: use_build_context_synchronously
                  AbonelikDialog.abonegit(context);
                });
              } else {
                Navigator.of(context).pop();
                Future.microtask(() {
                  if (widget.sayfaId == 3 && sayfasecimi != 2) {
                    ExcelSayfa.olusturExcel(
                      aylar: aylar,
                      basliklar:
                          widget.sayfaId == 3 && widget.grafiksayfaId == 1
                              ? karsilastirmaBaslik
                              : karsilastirmaBaslikiki,
                      veriler: hesaplayici.karsilastirmaTabloKontrol,
                      sutunsayisi: 24,
                      satirsayisi: 13,
                    );
                  } else if ((widget.sayfaId == 2 || widget.sayfaId == 1) &&
                      sayfasecimi != 2) {
                    ExcelSayfa.olusturExcel(
                      aylar: aylar,
                      basliklar:
                          hesaplayici.sayfaSecimiGelen == 0 ||
                                  hesaplayici.sayfaSecimiGelen == 1
                              ? basliklar
                              : saatListeBaslik,
                      veriler: hesaplayici.saatTabloKontrol,
                      sutunsayisi: 17,
                      satirsayisi: 13,
                    );
                  }
                });
              }
            },
          ),
          Dekor.cizgi15,
          if (sayfasecimi == 0)
            ListTile(
              title: const Text(
                'Düz Metin Oluştur Ve Paylaş',
                style: Dekor.butonText_16_400siyah,
              ),
              onTap: () {
                if (!AboneMi.isReklamsiz) {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    // ignore: use_build_context_synchronously
                    AbonelikDialog.abonegit(context);
                  });
                } else {
                  Navigator.of(context).pop();
                  if (widget.sayfaId == 3 && widget.grafiksayfaId == 1) {
                    _paylas();
                  } else if (widget.sayfaId == 3 && widget.grafiksayfaId == 2) {
                    _paylasiki();
                  } else if ((widget.sayfaId == 2 || widget.sayfaId == 1) &&
                      sayfasecimi == 0) {
                    _paylasuc();
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  // Alt bilgilendirme metni
  Widget _altbilgilendirme() {
    return const Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text('Hesaplama Mantığı', style: Dekor.butonText_18_500mavi),
          SizedBox(height: 10),
          Text(
            'Sayfa, kullanıcının girdiği brüt maaş, saatlik ücret, ikramiye, sosyal haklar, mesai ücreti gibi bilgileri kullanarak aylık net maaşı hesaplar. Bu hesaplamalar, vergi matrahı, gelir vergisi, SGK kesintileri, damga vergisi gibi detayları da içerir.\n\n'
            'Kullanıcının girdiği verilere göre aylık brüt maaşı, vergi kesintilerini, net maaşı ve diğer finansal detayları hesaplar.\n\n'
            'Ayrıca, kullanıcının engellilik durumu, emeklilik durumu gibi özel durumlar da hesaplamalara dahil edilir ve bu durumlara göre vergi indirimleri veya kesintileri uygulanır.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text(
            'Kullanıcı Arayüzü ve Görsel Sunum',
            style: Dekor.butonText_18_500mavi,
          ),
          SizedBox(height: 10),
          Text(
            'Sayfa, kullanıcıya hesaplama sonuçlarını farklı şekillerde sunar. Kullanıcı, hesaplama sonuçlarını liste, tablo veya grafik şeklinde görüntüleyebilir. Bu seçenekler, sayfanın üst kısmında bulunan butonlar aracılığıyla seçilir.\n\n'
            'Liste görünümü, aylık net maaş, vergi detayları, SGK kesintileri gibi bilgileri kullanıcıya özetler. Tablo görünümü, tüm hesaplama detaylarını aylara göre ayrıntılı bir şekilde sunar. Grafik görünümü ise net maaş ve kesintilerin aylara göre değişimini görsel olarak gösterir.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text('Paylaşım ve Çıktı Alma', style: Dekor.butonText_18_500mavi),
          SizedBox(height: 10),
          Text(
            'Kullanıcı, hesaplama sonuçlarını PDF, Excel veya düz metin olarak paylaşabilir. Bu özellik, kullanıcının hesaplama sonuçlarını başkalarıyla paylaşmasını veya arşivlemesini kolaylaştırır.\n\n'
            'Paylaşım seçenekleri, sayfanın alt kısmında bulunan bir modal bottom sheet içerisinde sunulur. Kullanıcı, bu seçeneklerden birini seçerek hesaplama sonuçlarını istediği formatta dışa aktarabilir.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text('Veri Kaydetme ve Paylaşma', style: Dekor.butonText_18_500mavi),
          SizedBox(height: 10),
          Text(
            'Kullanıcının girdiği veriler ve hesaplama sonuçları, Yerel bellek kullanılarak cihazda saklanır. Bu sayede, kullanıcı uygulamayı kapatsa bile veriler kaybolmaz ve daha sonra tekrar erişilebilir.\n\n'
            'Ayrıca, kullanıcı hesaplama sonuçlarını diğer uygulamalarla paylaşabilir. Örneğin, hesaplama sonuçlarını bir mesajlaşma uygulaması üzerinden paylaşabilir veya e-posta ile gönderebilir.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text(
            'Vergi ve Kesinti Hesaplamaları',
            style: Dekor.butonText_18_500mavi,
          ),
          SizedBox(height: 10),
          Text(
            'Sayfa, kullanıcının gelir vergisi matrahını hesaplarken Türk vergi mevzuatına uygun olarak farklı vergi dilimlerini dikkate alır. Gelir vergisi, kullanıcının yıllık gelirine göre farklı oranlarda hesaplanır.\n\n'
            'Engellilik indirimi, emeklilik durumu gibi özel durumlar da hesaplamalara dahil edilir. Örneğin, engelli bireyler için belirli bir vergi indirimi uygulanır.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text('Dinamik Tablo ve Grafikler', style: Dekor.butonText_18_500mavi),
          SizedBox(height: 10),
          Text(
            'Sayfa, kullanıcının girdiği verilere göre dinamik olarak tablolar ve grafikler oluşturur. Bu tablolar ve grafikler, kullanıcının aylık maaşını, vergi kesintilerini, net maaşını ve diğer finansal detayları görselleştirir.\n\n'
            'Grafikler, kullanıcının net maaşının ve kesintilerin aylara göre nasıl değiştiğini gösterir. Bu, kullanıcının finansal durumunu daha iyi anlamasına yardımcı olur.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 20),
          Text(
            'Sayfanın Kullanım Senaryoları:',
            style: Dekor.butonText_18_500mavi,
          ),
          SizedBox(height: 10),
          Text(
            'Maaş Karşılaştırma: Kullanıcı, iki farklı maaş senaryosunu karşılaştırabilir. Örneğin, mevcut maaşı ile zam sonrası maaşını karşılaştırarak zam oranının net etkisini görebilir.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 10),
          Text(
            'Vergi ve Kesinti Analizi: Kullanıcı, maaşı üzerinden kesilen vergileri ve SGK primlerini detaylı bir şekilde analiz edebilir. Bu analiz, kullanıcının net maaşını nasıl etkilediğini gösterir.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 10),
          Text(
            'Sosyal Haklar ve İkramiyeler: Kullanıcı, sosyal haklar ve ikramiyelerin maaşına nasıl eklendiğini görebilir. Bu, kullanıcının toplam gelirini daha iyi anlamasına yardımcı olur.',
            style: Dekor.butonText_15_400siyah,
          ),
          SizedBox(height: 10),
          Text(
            'Hesaplama ve hesaplatma için bu uygulamadaki veriler yasal olarak bağlayıcı değildir. Kullanıcı bu uygulamada verilen bilgileri hesaplatma sonuçlarını kendi hesaplamalarına veya kullanımlarına temel almadan önce doğrulatması gerekir. Bu sebepten dolayı bu uygulamada verilen bilgilerin ve elde edilen hesaplatma sonuçlarının doğruluğuna ilişkin olarak Kolay Hesap Uygulaması sorumluluk veya garanti üstlenmez.',
            style: Dekor.butonText_15_400siyah,
          ),
        ],
      ),
    );
  }

  // Sabit listeler
  static const List<String> basliklar = [
    'Brüt Ücret',
    'İkramiye',
    'Sosyal Haklar',
    'Mesai Brüt',
    'Toplam Brüt',
    'Sgk Kesintisi',
    'Damga Vergisi',
    'Gelir Vergisi',
    'Kdv Oranı',
    'Vergi Matrağı',
    'Gelir V.İade',
    'Damga V.İade',
    'Sendika Kes.',
    'Avans',
    'B.E.S %3',
    'Kalan Maaş',
    'Toplam Maaş',
  ];

  static const List<String> saatListeBaslik = [
    'Saat Ücret',
    'İkramiye',
    'Sosyal Haklar',
    'Mesai Brüt',
    'Toplam Brüt',
    'Sgk Kesintisi',
    'Damga Vergisi',
    'Gelir Vergisi',
    'Kdv Oranı',
    'Vergi Matrağı',
    'Gelir V.İade',
    'Damga V.İade',
    'Sendika Kes.',
    'Avans',
    'B.E.S %3',
    'Kalan Maaş',
    'Toplam Maaş',
  ];

  static const List<String> karsilastirmaBaslik = [
    'Brüt Ücret\nÖnceki',
    'Brüt\nFark',
    'Brüt Ücret\nSonraki',
    'İkramiye\nÖnceki',
    'İkramiye\nFark',
    'İkramiye\nSonraki',
    'Sosy.Haklar\nÖnceki',
    'Sosy.Haklar\nFark',
    'Sosy.Haklar\nSonraki',
    'Toplam Brüt\nÖnceki',
    'Toplam Brüt\nFark',
    'Toplam Brüt\nSonraki',
    'Sendika Kes\nÖnceki',
    'Sendika Kes\nFark',
    'Sendika Kes\nSonraki',
    'Avans\nÖnceki',
    'Avans\nFark',
    'Avans\nSonraki',
    'Kalan Maaş\nÖnceki',
    'Kalan Maaş\nFark',
    'Kalan Maaş\nSonraki',
    'Toplam Maaş\nÖnceki',
    'Toplam Maaş\nFark',
    'Toplam Maaş\nSonraki',
  ];

  static const List<String> karsilastirmaBaslikiki = [
    'Brüt Ücret\n1. Maaş',
    'Brüt\nFark',
    'Brüt Ücret\n2. Maaş',
    'İkramiye\n1. Maaş',
    'İkramiye\nFark',
    'İkramiye\n2. Maaş',
    'Sosy.Haklar\n1. Maaş',
    'Sosy.Haklar\nFark',
    'Sosy.Haklar\n2. Maaş',
    'Toplam Brüt\n1. Maaş',
    'Toplam Brüt\nFark',
    'Toplam Brüt\n2. Maaş',
    'Sendika Kes\n1. Maaş',
    'Sendika Kes\nFark',
    'Sendika Kes\n2. Maaş',
    'Avans\n1. Maaş',
    'Avans\nFark',
    'Avans\n2. Maaş',
    'Kalan\n1. Maaş',
    'Kalan\nMaaş Fark',
    'Kalan\n2. Maaş',
    'Toplam\n1. Maaş',
    'Toplam\nMaaş Fark',
    'Toplam\n2. Maaş',
  ];

  static const List<String> aylar = [
    '  Aylar',
    '  Ocak',
    '  Şubat',
    '  Mart',
    '  Nisan',
    '  Mayıs',
    '  Haziran',
    '  Temmuz',
    '  Ağustos',
    '  Eylül',
    '  Ekim',
    '  Kasım',
    '  Aralık',
    '  Toplam',
  ];

  static const List<String> aylarBuyuk = [
    'OCAK',
    'ŞUBAT',
    'MART',
    'NİSAN',
    'MAYIS',
    'HAZİRAN',
    'TEMMUZ',
    'AĞUSTOS',
    'EYLÜL',
    'EKİM',
    'KASIM',
    'ARALIK',
  ];

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

  static const List<String> butonyazi = ['Liste', 'Tablo', 'Grafik'];
}
