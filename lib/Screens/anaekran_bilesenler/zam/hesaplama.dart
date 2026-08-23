import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/ciktilar/kur.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamhesaplama.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Yardımcı sınıf: Sayısal formatlama ve metin dönüşümleri için
class Hesaplayici {
  static String paraBirimiFormatla(dynamic deger) {
    return NumberFormat("#,##0.00", "tr_TR").format(deger);
  }

  static double metniSayiyaCevir(String metin) {
    String normalizedText = metin.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalizedText) ?? 0;
  }

  static String textSonIkiAl(String kdvt) {
    if (kdvt.isEmpty || kdvt.length < 2) return '';
    return kdvt.substring(kdvt.length - 2);
  }
}

class MaasHesaplayici {
  // Değişken tanımlamaları
  List<num> burutson = List.filled(12, 0);
  List<num> saatson = List.filled(12, 0);
  List<num> ikramiyeListe = List.filled(12, 0);
  List<num> sosyalHakgelen = List.filled(12, 0);
  List<num> cocukparasi = List.filled(12, 0);
  List<num> avans = List.filled(12, 0);
  List<num> sendikaKesintisi = List.filled(12, 0);
  List<num> mesaiListe = List.filled(12, 0);
  List<num> agiGelir = List.filled(12, 0);
  List<num> damgaGelir = List.filled(12, 0);
  List<num> zam = List.filled(12, 0);
  List<num> kidem = List.filled(12, 0);
  List<num> sosyalzam = List.filled(12, 0);
  List<num> calismaSaatigelen = List.filled(12, 0);
  List<num> burut = List.filled(12, 0);
  List<num> besListe = List.filled(12, 0);
  List<num> damgaKes = List.filled(12, 0);
  List<num> sgkKes = List.filled(12, 0);
  List<num> engellikesinti = List.filled(12, 0);
  List<num> matrakAy = List.filled(12, 0);
  List<num> aylarVergi = List.filled(12, 0);
  List<num> gelirVergisi = List.filled(12, 0);
  List<String> kdvYazi = List.filled(12, "");
  List<num> vergitoplam = List.filled(12, 0);
  List<num> netOdeme = List.filled(12, 0);
  List<num> toplamOdeme = List.filled(12, 0);
  List<double> grafiknet = List.filled(12, 0.0);
  List<double> grafikkesinti = List.filled(12, 0.0);
  List<List<List<num>>> sonListe = List.generate(
    12,
    (_) => List.generate(8, (_) => List.filled(3, 0)),
  );
  // TextEditingController yerine String listeleri
  List<List<String>> saatTabloVerileri = List.generate(
    17,
    (_) => List.generate(13, (_) => ""),
  );
  List<List<String>> karsilastirmaTabloVerileri = List.generate(
    24,
    (_) => List.generate(13, (_) => ""),
  );
  List<String> aciklamaAltVergiSayiKontrol = List.filled(10, "");

  // Getter'lar
  List<List<String>> get saatTabloKontrol => saatTabloVerileri;
  List<List<String>> get karsilastirmaTabloKontrol =>
      karsilastirmaTabloVerileri;

  // Diğer değişkenler
  int sayfaSecimiGelen = 0;
  int maaskarsilastirmaanahtar = 0;
  int sayfasaatbrutanahtar = 0;
  int sayfasaatbrutanahtariki = 0;
  bool _besEkle = false;
  double _sgkkesintitutari = 15.0;
  num vergiKayit = 0;
  int vergiAySatirNo = 13;
  int ozelvergiAySatirNo = 0;
  num ozelvergiKayit = 0;
  int engellimi = 0;
  num engelli1 = 0, engelli2 = 0, engelli3 = 0;
  String calisanTipi = "Normal";
  String mesaiekleyazi = "";
  String besekleyazi = "";
  num kdv1 = 0, kdv2 = 0, kdv3 = 0;
  num _kdv1 = 15, _kdv2 = 15, _kdvFark = 0;
  String simdikiYil = DateTime.now().year.toString();
  BuildContext context;
  final ZamHesaplama widget;
  double zamoranikidem = 0;

  MaasHesaplayici(this.context, this.widget);

  Future<void> veriGuncelle() async {
    final response = await http.get(
      Uri.parse('https://kolayhesappro.com/giris_veriler.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> girisVeriler = jsonDecode(response.body);
      agiGelir[0] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[1] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[2] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[3] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[4] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[5] = girisVeriler["AGİ_1"] ?? 3315.70;
      agiGelir[6] = girisVeriler["AGİ_2"] ?? 3315.70;
      agiGelir[7] = girisVeriler["AGİ_3"] ?? 4257.57;
      agiGelir[8] = girisVeriler["AGİ_4"] ?? 4420.93;
      agiGelir[9] = girisVeriler["AGİ_4"] ?? 4420.93;
      agiGelir[10] = girisVeriler["AGİ_4"] ?? 4420.93;
      agiGelir[11] = girisVeriler["AGİ_4"] ?? 4420.93;

      for (int i = 0; i < 12; i++) {
        damgaGelir[i] =
            i <= 5
                ? girisVeriler["DAMGA_1"] ?? 197.38
                : girisVeriler["DAMGA_2"] ?? 197.38;
      }

      kdv1 = girisVeriler["KDV1"] ?? 158000;
      kdv2 = girisVeriler["KDV2"] ?? 330000;
      kdv3 = girisVeriler["KDV3"] ?? 1200000;
      engelli1 = girisVeriler["ENGELLİ1"] ?? 9900;
      engelli2 = girisVeriler["ENGELLİ2"] ?? 5700;
      engelli3 = girisVeriler["ENGELLİ3"] ?? 2400;
    }
    await gelenVeriler();
  }

  Future<void> gelenVeriler() async {
    sayfaSecimiGelen = widget.secimList[0];
    engellimi = widget.engelliList[0];

    sayfasaatbrutanahtar =
        (widget.secimList[0] == 0 || widget.secimList[0] == 1) ? 1 : 2;
    sayfasaatbrutanahtariki =
        (widget.secimList[1] == 0 || widget.secimList[1] == 1) ? 1 : 2;

    for (int i = 0; i < 12; i++) {
      zam[i] = widget.zamList[i];
      kidem[i] = widget.kidemList[i];
      sosyalzam[i] = widget.sosyalzamList[i];

      if (sayfaSecimiGelen == 0) {
        burutson[i] = widget.brutList[0];
      } else if (sayfaSecimiGelen == 1) {
        burutson[i] = widget.brutDetayList[0][i];
      } else if (sayfaSecimiGelen == 2) {
        saatson[i] = widget.saatList[0];
      } else if (sayfaSecimiGelen == 3) {
        saatson[i] = widget.saatDetayList[0][i];
      }

      calismaSaatigelen[i] = widget.calismasaatList[0][i];
      ikramiyeListe[i] = widget.ikramiyeList[0][i];
      sosyalHakgelen[i] =
          (i == widget.ekodemeList[0])
              ? widget.sosyalHakList[0] + widget.sadecebuayList[0]
              : widget.sosyalHakList[0];
      cocukparasi[i] = widget.cocukParasiList[0];
      avans[i] = widget.avansList[0];
      sendikaKesintisi[i] = widget.sendikaList[0];
      engellikesinti[i] =
          engellimi == 1
              ? engelli1
              : engellimi == 2
              ? engelli2
              : engellimi == 3
              ? engelli3
              : 0;
    }

    calisanTipi = widget.calisanTipiList[0];
    _sgkkesintitutari =
        calisanTipi == 'Normal'
            ? 15
            : calisanTipi == 'Emekli'
            ? 7.5
            : 0.0;
    vergiKayit = widget.vergiList[0];
    vergiAySatirNo = vergiKayit == 0 ? 13 : widget.vergiNoList[0];
    mesaiekleyazi = widget.mesaiList[0];
    besekleyazi = widget.besList[0];
    ozelvergiKayit = widget.ozelvergi;
    ozelvergiAySatirNo = widget.ozelvergino;

    await secimlerCagir();
  }

  Future<void> gelenVerilerIki() async {
    sayfaSecimiGelen = widget.secimList[1];
    engellimi = widget.engelliList[1];

    for (int i = 0; i < 12; i++) {
      if (sayfaSecimiGelen == 0) {
        burutson[i] = widget.brutList[1];
      } else if (sayfaSecimiGelen == 1) {
        burutson[i] = widget.brutDetayList[1][i];
      } else if (sayfaSecimiGelen == 2) {
        saatson[i] = widget.saatList[1];
      } else if (sayfaSecimiGelen == 3) {
        saatson[i] = widget.saatDetayList[1][i];
      }

      calismaSaatigelen[i] = widget.calismasaatList[1][i];
      ikramiyeListe[i] = widget.ikramiyeList[1][i];
      sosyalHakgelen[i] =
          (i == widget.ekodemeList[1])
              ? widget.sosyalHakList[1] + widget.sadecebuayList[1]
              : widget.sosyalHakList[1];
      cocukparasi[i] = widget.cocukParasiList[1];
      avans[i] = widget.avansList[1];
      sendikaKesintisi[i] = widget.sendikaList[1];
      engellikesinti[i] =
          engellimi == 1
              ? engelli1
              : engellimi == 2
              ? engelli2
              : engellimi == 3
              ? engelli3
              : 0;
    }

    calisanTipi = widget.calisanTipiList[1];
    _sgkkesintitutari =
        calisanTipi == 'Normal'
            ? 15
            : calisanTipi == 'Emekli'
            ? 7.5
            : 0.0;
    vergiKayit = widget.vergiList[1];
    vergiAySatirNo = vergiKayit == 0 ? 13 : widget.vergiNoList[1];
    mesaiekleyazi = widget.mesaiList[1];
    besekleyazi = widget.besList[1];

    await secimlerCagir();
  }

  Future<void> secimlerCagir() async {
    final prefs = await SharedPreferences.getInstance();
    final mesaiIndex = prefs.getInt('index') ?? 0;

    _besEkle = besekleyazi == "Evet";
    bool mesaiEkle = mesaiekleyazi == "Evet";

    for (int i = 0; i < 12; i++) {
      final mesai =
          prefs.getDouble('$mesaiIndex-$simdikiYil-${i + 1}-burut') ?? 0;
      mesaiListe[i] = mesaiEkle ? mesai : 0;
    }

    if (maaskarsilastirmaanahtar == 0) {
      hesapla();
    }
  }

  void hesapla() {
    if (widget.sayfaId == 3) {
      ilkHesapla();
    }

    if (widget.sayfaId == 1 ||
        (widget.sayfaId == 3 && widget.grafiksayfaId == 1)) {
      zamHesapla();
    } else if (widget.sayfaId == 3 && widget.grafiksayfaId == 2) {
      maaskarsilastirmaanahtar = 1;
      gelenVerilerIki();
    }

    sifirDegerleriKontrolEt();
    brutMaasHesapla();
    kesintileriHesapla();
    vergiHesapla();
    netOdemeHesapla();

    if (widget.sayfaId == 3) {
      karsilastirmaTablosunuDoldur();
      if (widget.grafiksayfaId == 4) {
        kursayfagit();
      } else {
        toplaVeYazdir();
      }
    } else {
      saatTablosunuDoldur();
      if (widget.grafiksayfaId == 3) {
        netMaasKayit();
      } else {
        altToplamlariHesapla();
      }
    }
  }

  void zamHesapla() {
    if (sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1) {
      zamUygula(burutson, 0);
    } else {
      zamUygula(saatson, 0);
    }
    zamUygula(ikramiyeListe, 1);

    for (int i = 0; i < 12; i++) {
      if (sosyalzam[i] != 0 && sosyalHakgelen[i] != 0) {
        sosyalHakgelen[i] += (sosyalHakgelen[i] / 100) * sosyalzam[i];
      }
      if (sosyalzam[i] != 0 && cocukparasi[i] != 0) {
        cocukparasi[i] += (cocukparasi[i] / 100) * sosyalzam[i];
      }
    }

    zamUygula(avans, 1);
    zamUygula(sendikaKesintisi, 1);
  }

  void zamUygula(List<num> zamListesi, int no) {
    for (int i = 0; i < 12; i++) {
      if (no == 0) {
        if (zam[i] != 0 && zamListesi[i] != 0) {
          zamListesi[i] += (zamListesi[i] / 100) * zam[i];
        }
        if (kidem[i] != 0 && zamListesi[i] != 0) {
          if (sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1) {
            zamoranikidem =
                ((calismaSaatigelen[i] * kidem[i]) / zamListesi[i] * 100);
          } else {
            zamoranikidem = (kidem[i] / saatson[i]) * 100;
          }
          zamListesi[i] += (zamListesi[i] / 100) * zamoranikidem;
        }
      } else {
        if (zam[i] != 0 && zamListesi[i] != 0) {
          zamListesi[i] += (zamListesi[i] / 100) * zam[i];
        }
      }
    }
  }

  void sifirDegerleriKontrolEt() {
    for (int i = 0; i < 12; i++) {
      if ((sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1) &&
              burutson[i] == 0 ||
          (sayfaSecimiGelen == 2 || sayfaSecimiGelen == 3) && saatson[i] == 0) {
        sendikaKesintisi[i] = 0;
        avans[i] = 0;
        ikramiyeListe[i] = 0;
        mesaiListe[i] = 0;
        sosyalHakgelen[i] = 0;
        agiGelir[i] = 0;
        damgaGelir[i] = 0;
        cocukparasi[i] = 0;
      }
    }
  }

  void brutMaasHesapla() {
    for (int i = 0; i < 12; i++) {
      burut[i] =
          (sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1)
              ? burutson[i] +
                  ikramiyeListe[i] +
                  sosyalHakgelen[i] +
                  mesaiListe[i] +
                  cocukparasi[i]
              : (saatson[i] * calismaSaatigelen[i]) +
                  ikramiyeListe[i] +
                  sosyalHakgelen[i] +
                  mesaiListe[i] +
                  cocukparasi[i];
    }
  }

  void kesintileriHesapla() {
    for (int i = 0; i < 12; i++) {
      besListe[i] = _besEkle ? (burut[i] / 100) * 3 : 0;
      damgaKes[i] = burut[i] * 0.00759;
      sgkKes[i] = ((burut[i] - cocukparasi[i]) / 100) * _sgkkesintitutari;
      matrakAy[i] =
          (i == ozelvergiAySatirNo)
              ? burut[i] -
                  (sgkKes[i] +
                      sendikaKesintisi[i] +
                      engellikesinti[i] +
                      cocukparasi[i] +
                      ozelvergiKayit)
              : burut[i] -
                  (sgkKes[i] +
                      sendikaKesintisi[i] +
                      engellikesinti[i] +
                      cocukparasi[i]);
    }
  }

  void vergiHesapla() {
    num t = 0;
    for (int i = 0; i < 12; i++) {
      if (i < vergiAySatirNo) {
        t += matrakAy[i];
      } else if (i == vergiAySatirNo) {
        t = vergiKayit;
      } else {
        t += matrakAy[i];
      }
      aylarVergi[i] = t;
    }

    // Vergi dilimlerini ve gelir vergisini hesapla
    for (int i = 0; i < 12; i++) {
      num mevcutMatrah = aylarVergi[i];
      num ayMatrah = matrakAy[i];

      // Vergi dilimlerine göre oranları belirle
      if (mevcutMatrah > 0 && mevcutMatrah <= kdv1) {
        _kdv1 = 15;
        _kdv2 = 15;
        _kdvFark = 0;
      } else if (mevcutMatrah > kdv1 && mevcutMatrah <= kdv2) {
        _kdv1 = 15;
        _kdv2 = 20;
        _kdvFark = min(
          ayMatrah,
          mevcutMatrah - kdv1,
        ); // _kdvFark, ayMatrah ile sınırlı
      } else if (mevcutMatrah > kdv2 && mevcutMatrah <= kdv3) {
        _kdv1 = 20;
        _kdv2 = 27;
        _kdvFark = min(
          ayMatrah,
          mevcutMatrah - kdv2,
        ); // _kdvFark, ayMatrah ile sınırlı
      } else if (mevcutMatrah > kdv3) {
        _kdv1 = 27;
        _kdv2 = 35;
        _kdvFark = min(
          ayMatrah,
          mevcutMatrah - kdv3,
        ); // _kdvFark, ayMatrah ile sınırlı
      } else {
        _kdv1 = 15;
        _kdv2 = 15;
        _kdvFark = 0;
      }

      // Gelir vergisini hesapla
      gelirVergisi[i] =
          (((ayMatrah - _kdvFark) / 100) * _kdv1) + ((_kdvFark / 100) * _kdv2);

      // Vergi oranı yazısını güncelle: Sadece kullanılan oranları göster
      if (ayMatrah - _kdvFark <= 0) {
        // Sadece _kdv2 kullanıldı
        kdvYazi[i] = "%$_kdv2";
      } else if (_kdvFark == 0) {
        // Sadece _kdv1 kullanıldı
        kdvYazi[i] = "%$_kdv1";
      } else {
        // Hem _kdv1 hem _kdv2 kullanıldı
        kdvYazi[i] = "%$_kdv1 ve %$_kdv2";
      }
    }
  }

  void netOdemeHesapla() {
    for (int i = 0; i < 12; i++) {
      vergitoplam[i] =
          (gelirVergisi[i] + sgkKes[i] + damgaKes[i]) -
          (damgaGelir[i] + agiGelir[i]);
      netOdeme[i] =
          burut[i] - (vergitoplam[i] + sendikaKesintisi[i] + besListe[i]);
      toplamOdeme[i] = netOdeme[i] - avans[i];
      grafiknet[i] = netOdeme[i].toDouble();
      grafikkesinti[i] = vergitoplam[i].toDouble();
    }
  }

  void saatTablosunuDoldur() {
    for (int i = 0; i < 12; i++) {
      saatTabloVerileri[0][i] = Hesaplayici.paraBirimiFormatla(
        sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1
            ? burutson[i]
            : saatson[i],
      );
      saatTabloVerileri[1][i] = Hesaplayici.paraBirimiFormatla(
        ikramiyeListe[i],
      );
      saatTabloVerileri[2][i] = Hesaplayici.paraBirimiFormatla(
        sosyalHakgelen[i] + cocukparasi[i],
      );
      saatTabloVerileri[3][i] = Hesaplayici.paraBirimiFormatla(mesaiListe[i]);
      saatTabloVerileri[4][i] = Hesaplayici.paraBirimiFormatla(burut[i]);
      saatTabloVerileri[5][i] = Hesaplayici.paraBirimiFormatla(sgkKes[i]);
      saatTabloVerileri[6][i] = Hesaplayici.paraBirimiFormatla(damgaKes[i]);
      saatTabloVerileri[7][i] = Hesaplayici.paraBirimiFormatla(gelirVergisi[i]);
      saatTabloVerileri[8][i] = burut[i] == 0 ? "% 0" : kdvYazi[i];
      saatTabloVerileri[9][i] = Hesaplayici.paraBirimiFormatla(
        burut[i] == 0 ? 0 : aylarVergi[i],
      );
      saatTabloVerileri[10][i] = Hesaplayici.paraBirimiFormatla(agiGelir[i]);
      saatTabloVerileri[11][i] = Hesaplayici.paraBirimiFormatla(damgaGelir[i]);
      saatTabloVerileri[12][i] = Hesaplayici.paraBirimiFormatla(
        sendikaKesintisi[i],
      );
      saatTabloVerileri[13][i] = Hesaplayici.paraBirimiFormatla(avans[i]);
      saatTabloVerileri[14][i] = Hesaplayici.paraBirimiFormatla(besListe[i]);
      saatTabloVerileri[15][i] = Hesaplayici.paraBirimiFormatla(toplamOdeme[i]);
      saatTabloVerileri[16][i] = Hesaplayici.paraBirimiFormatla(netOdeme[i]);
    }
  }

  void karsilastirmaTablosunuDoldur() {
    for (int i = 0; i < 12; i++) {
      sonListe[i][0][1] =
          (sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1)
              ? burutson[i]
              : (sayfasaatbrutanahtar == sayfasaatbrutanahtariki)
              ? saatson[i]
              : saatson[i] * calismaSaatigelen[i];
      sonListe[i][1][1] = ikramiyeListe[i];
      sonListe[i][2][1] = sosyalHakgelen[i] + cocukparasi[i];
      sonListe[i][3][1] = burut[i];
      sonListe[i][4][1] = sendikaKesintisi[i];
      sonListe[i][5][1] = avans[i];
      sonListe[i][6][1] = toplamOdeme[i];
      sonListe[i][7][1] = netOdeme[i];

      for (int j = 0; j < 8; j++) {
        sonListe[i][j][2] = sonListe[i][j][1] - sonListe[i][j][0];
        karsilastirmaTabloVerileri[j * 3][i] = Hesaplayici.paraBirimiFormatla(
          sonListe[i][j][0],
        );
        karsilastirmaTabloVerileri[j * 3 +
            1][i] = Hesaplayici.paraBirimiFormatla(sonListe[i][j][2]);
        karsilastirmaTabloVerileri[j * 3 +
            2][i] = Hesaplayici.paraBirimiFormatla(sonListe[i][j][1]);
      }
    }
  }

  void ilkHesapla() {
    sifirDegerleriKontrolEt();
    brutMaasHesapla();
    kesintileriHesapla();
    vergiHesapla();
    netOdemeHesapla();

    for (int i = 0; i < 12; i++) {
      sonListe[i][0][0] =
          (sayfaSecimiGelen == 0 || sayfaSecimiGelen == 1)
              ? burutson[i]
              : (sayfasaatbrutanahtar == sayfasaatbrutanahtariki)
              ? saatson[i]
              : saatson[i] * calismaSaatigelen[i];
      sonListe[i][1][0] = ikramiyeListe[i];
      sonListe[i][2][0] = sosyalHakgelen[i] + cocukparasi[i];
      sonListe[i][3][0] = burut[i];
      sonListe[i][4][0] = sendikaKesintisi[i];
      sonListe[i][5][0] = avans[i];
      sonListe[i][6][0] = toplamOdeme[i];
      sonListe[i][7][0] = netOdeme[i];
    }
  }

  Future<void> netMaasKayit() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 12; i++) {
      await prefs.setDouble('$simdikiYil-$i-netmaas', netOdeme[i].toDouble());
    }
    grafiksayfadon();
  }

  void toplaVeYazdir() {
    for (int i = 0; i < 24; i++) {
      double toplam = 0;
      for (int j = 0; j < 12; j++) {
        toplam += Hesaplayici.metniSayiyaCevir(
          karsilastirmaTabloVerileri[i][j],
        );
      }
      karsilastirmaTabloVerileri[i][12] = Hesaplayici.paraBirimiFormatla(
        toplam,
      );
    }
  }

  void altToplamlariHesapla() {
    for (int i = 0; i < 17; i++) {
      double toplam = 0;
      for (int j = 0; j < 12; j++) {
        toplam += Hesaplayici.metniSayiyaCevir(saatTabloVerileri[i][j]);
      }
      saatTabloVerileri[i][12] = Hesaplayici.paraBirimiFormatla(toplam);
    }

    int bosSayi = 0;
    double kdvoranToplam = 0;
    for (int i = 0; i < 12; i++) {
      double ko = double.parse(
        Hesaplayici.textSonIkiAl(
          saatTabloVerileri[8][i].isEmpty ? '%15' : saatTabloVerileri[8][i],
        ),
      );
      if (ko != 0.0) {
        bosSayi++;
        kdvoranToplam += ko;
      }
    }
    double kdvsont = bosSayi > 0 ? kdvoranToplam / bosSayi : 0.0;

    saatTabloVerileri[8][12] = kdvsont.toStringAsFixed(2);
    saatTabloVerileri[9][12] = saatTabloVerileri[9][11];

    aciklamaAltVergiSayiKontrol[0] = "% ${saatTabloVerileri[8][12]}";

    double yillikVergi = Hesaplayici.metniSayiyaCevir(saatTabloVerileri[7][12]);
    double yillikNetOdeme = Hesaplayici.metniSayiyaCevir(
      saatTabloVerileri[16][12],
    );
    double yillikBrut = Hesaplayici.metniSayiyaCevir(saatTabloVerileri[4][12]);

    if (yillikVergi != 0) {
      double ortalamaAylikVergi = yillikVergi / bosSayi;
      double ortalamaGunlukVergi = yillikVergi / (bosSayi * 30);
      aciklamaAltVergiSayiKontrol[1] = Hesaplayici.paraBirimiFormatla(
        yillikVergi,
      );
      aciklamaAltVergiSayiKontrol[2] = Hesaplayici.paraBirimiFormatla(
        ortalamaAylikVergi,
      );
      aciklamaAltVergiSayiKontrol[3] = Hesaplayici.paraBirimiFormatla(
        ortalamaGunlukVergi,
      );
    } else {
      aciklamaAltVergiSayiKontrol[1] = "0.00";
      aciklamaAltVergiSayiKontrol[2] = "0.00";
      aciklamaAltVergiSayiKontrol[3] = "0.00";
    }

    if (yillikNetOdeme != 0) {
      double vergiMaasSayisi = yillikVergi / (yillikNetOdeme / bosSayi);
      double vergiGunSayisi = yillikVergi / (yillikNetOdeme / (bosSayi * 30));
      aciklamaAltVergiSayiKontrol[4] = Hesaplayici.paraBirimiFormatla(
        vergiMaasSayisi,
      );
      aciklamaAltVergiSayiKontrol[5] = Hesaplayici.paraBirimiFormatla(
        vergiGunSayisi,
      );
    } else {
      aciklamaAltVergiSayiKontrol[4] = "0.00";
      aciklamaAltVergiSayiKontrol[5] = "0.00";
    }

    if (yillikBrut != 0) {
      double ortalamaAylikBrut = yillikBrut / bosSayi;
      double ortalamaGunlukBrut = yillikBrut / (bosSayi * 30);
      aciklamaAltVergiSayiKontrol[6] = Hesaplayici.paraBirimiFormatla(
        ortalamaAylikBrut,
      );
      aciklamaAltVergiSayiKontrol[8] = Hesaplayici.paraBirimiFormatla(
        ortalamaGunlukBrut,
      );
    } else {
      aciklamaAltVergiSayiKontrol[6] = "0.00";
      aciklamaAltVergiSayiKontrol[8] = "0.00";
    }

    if (yillikNetOdeme != 0) {
      double ortalamaAylikNet = yillikNetOdeme / bosSayi;
      double ortalamaGunlukNet = yillikNetOdeme / (bosSayi * 30);
      aciklamaAltVergiSayiKontrol[7] = Hesaplayici.paraBirimiFormatla(
        ortalamaAylikNet,
      );
      aciklamaAltVergiSayiKontrol[9] = Hesaplayici.paraBirimiFormatla(
        ortalamaGunlukNet,
      );
    } else {
      aciklamaAltVergiSayiKontrol[7] = "0.00";
      aciklamaAltVergiSayiKontrol[9] = "0.00";
    }
  }

  void grafiksayfadon() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Anasayfa(pozisyon: 1, tarihyenile: ""),
      ),
    );
  }

  void kursayfagit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => Kursayfa(
              sonListe: sonListe,
              sayfaId: widget.sayfaId,
              grafiksayfaId: widget.grafiksayfaId,
            ),
      ),
    );
  }
}
