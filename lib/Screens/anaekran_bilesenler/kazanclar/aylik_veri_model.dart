import 'package:flutter/material.dart';

class KesintiDetaylari {
  final double brut;
  final double net;
  final double sgk;
  final double sgkYuzde;
  final double issizlik;
  final double issizlikYuzde;
  final double vergi;
  final double damga;
  final double uygulananVergi;
  final double uygulananVergiYuzde;
  final double uygulananDamga;
  final double uygulananDamgaYuzde;
  final double agi;
  final double damgaIstisnasi;
  final double bes;
  final double avans;

  const KesintiDetaylari({
    required this.brut,
    required this.net,
    required this.sgk,
    required this.sgkYuzde,
    required this.issizlik,
    required this.issizlikYuzde,
    required this.vergi,
    required this.damga,
    required this.uygulananVergi,
    required this.uygulananVergiYuzde,
    required this.uygulananDamga,
    required this.uygulananDamgaYuzde,
    required this.agi,
    required this.damgaIstisnasi,
    required this.bes,
    this.avans = 0.0,
  });

  factory KesintiDetaylari.bos() => const KesintiDetaylari(
    brut: 0.0,
    net: 0.0,
    sgk: 0.0,
    sgkYuzde: 0.0,
    issizlik: 0.0,
    issizlikYuzde: 0.0,
    vergi: 0.0,
    damga: 0.0,
    uygulananVergi: 0.0,
    uygulananVergiYuzde: 0.0,
    uygulananDamga: 0.0,
    uygulananDamgaYuzde: 0.0,
    agi: 0.0,
    damgaIstisnasi: 0.0,
    bes: 0.0,
    avans: 0.0,
  );

  KesintiDetaylari copyWith({
    double? brut,
    double? net,
    double? sgk,
    double? sgkYuzde,
    double? issizlik,
    double? issizlikYuzde,
    double? vergi,
    double? damga,
    double? uygulananVergi,
    double? uygulananVergiYuzde,
    double? uygulananDamga,
    double? uygulananDamgaYuzde,
    double? agi,
    double? damgaIstisnasi,
    double? bes,
    double? avans,
  }) {
    return KesintiDetaylari(
      brut: brut ?? this.brut,
      net: net ?? this.net,
      sgk: sgk ?? this.sgk,
      sgkYuzde: sgkYuzde ?? this.sgkYuzde,
      issizlik: issizlik ?? this.issizlik,
      issizlikYuzde: issizlikYuzde ?? this.issizlikYuzde,
      vergi: vergi ?? this.vergi,
      damga: damga ?? this.damga,
      uygulananVergi: uygulananVergi ?? this.uygulananVergi,
      uygulananVergiYuzde: uygulananVergiYuzde ?? this.uygulananVergiYuzde,
      uygulananDamga: uygulananDamga ?? this.uygulananDamga,
      uygulananDamgaYuzde: uygulananDamgaYuzde ?? this.uygulananDamgaYuzde,
      agi: agi ?? this.agi,
      damgaIstisnasi: damgaIstisnasi ?? this.damgaIstisnasi,
      bes: bes ?? this.bes,
      avans: avans ?? this.avans,
    );
  }
}

class AylikVeri {
  final double brutKazanc;
  final double netKazanc;
  final int calismaGunSayisi;
  final int mesaiGunSayisi;
  final int efektifGunSayisi;
  final double toplamCalismaSaati;
  final double toplamMesaiSaati;
  final KesintiDetaylari kesintiDetaylari;
  final String seciliAyIsmi;

  const AylikVeri({
    required this.brutKazanc,
    required this.netKazanc,
    required this.calismaGunSayisi,
    required this.mesaiGunSayisi,
    required this.efektifGunSayisi,
    required this.toplamCalismaSaati,
    required this.toplamMesaiSaati,
    required this.kesintiDetaylari,
    required this.seciliAyIsmi,
  });

  factory AylikVeri.bos() => AylikVeri(
    brutKazanc: 0.0,
    netKazanc: 0.0,
    calismaGunSayisi: 0,
    mesaiGunSayisi: 0,
    efektifGunSayisi: 0,
    toplamCalismaSaati: 0.0,
    toplamMesaiSaati: 0.0,
    kesintiDetaylari: KesintiDetaylari.bos(),
    seciliAyIsmi: '',
  );
}

class YuzdeVeri {
  final String ad;
  final double tutar;
  final Color renk;

  const YuzdeVeri(this.ad, this.tutar, this.renk);
}
