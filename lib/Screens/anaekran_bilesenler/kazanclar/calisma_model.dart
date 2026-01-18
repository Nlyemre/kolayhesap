// lib/Screens/anaekran_bilesenler/anaekran/calisma_model.dart
import 'package:intl/intl.dart';

class CalismaGunModel {
  DateTime tarih;
  bool calistiMi;
  double calismaSaati;
  String calismaMetni;
  double calismaNet;
  double calismaBrut;
  String? calismaNotu;
  double mesaiYuzde;
  bool mesaiVar;
  double mesaiSaati;
  String mesaiMetni;
  double mesaiNet;
  double mesaiBrut;
  String? mesaiNotu;
  double toplamKazanc;
  double toplamBrut;
  int kaydedilenIndex;
  double kaydedilenUcret;

  // YENİ ALANLAR
  String? kaydedilenCalisanTipi;
  double? kaydedilenKdvOrani;
  double? kaydedilenBesOrani;
  bool? kaydedilenBesAktif;
  double? agiIstisnasi;
  double? damgaIstisnasi;

  CalismaGunModel({
    required this.tarih,
    this.calistiMi = false,
    this.calismaSaati = 0.0,
    this.calismaMetni = '',
    this.calismaNet = 0.0,
    this.calismaBrut = 0.0,
    this.calismaNotu,
    this.mesaiVar = false,
    this.mesaiSaati = 0.0,
    this.mesaiMetni = '',
    this.mesaiNet = 0.0,
    this.mesaiBrut = 0.0,
    this.mesaiNotu,
    this.toplamKazanc = 0.0,
    this.toplamBrut = 0.0,
    this.mesaiYuzde = 50.0,
    this.kaydedilenIndex = 0,
    this.kaydedilenUcret = 0.0,
    this.kaydedilenCalisanTipi,
    this.kaydedilenKdvOrani,
    this.kaydedilenBesOrani,
    this.kaydedilenBesAktif,
    this.agiIstisnasi,
    this.damgaIstisnasi,
  });

  double get toplamSaati => calismaSaati + mesaiSaati;

  Map<String, dynamic> toJson() => {
    'tarih': DateFormat('dd-MM-yyyy').format(tarih),
    'calistiMi': calistiMi,
    'calismaSaati': calismaSaati,
    'calismaMetni': calismaMetni,
    'calismaNet': calismaNet,
    'calismaBrut': calismaBrut,
    'calismaNotu': calismaNotu ?? '',
    'mesaiVar': mesaiVar,
    'mesaiSaati': mesaiSaati,
    'mesaiMetni': mesaiMetni,
    'mesaiNet': mesaiNet,
    'mesaiBrut': mesaiBrut,
    'mesaiNotu': mesaiNotu ?? '',
    'toplamKazanc': toplamKazanc,
    'toplamBrut': toplamBrut,
    'mesaiYuzde': mesaiYuzde,
    'kaydedilenIndex': kaydedilenIndex,
    'kaydedilenUcret': kaydedilenUcret,
    'agiIstisnasi': agiIstisnasi,
    'damgaIstisnasi': damgaIstisnasi,
    'kaydedilenCalisanTipi': kaydedilenCalisanTipi,
    'kaydedilenKdvOrani': kaydedilenKdvOrani,
    'kaydedilenBesOrani': kaydedilenBesOrani,
    'kaydedilenBesAktif': kaydedilenBesAktif,
  };

  factory CalismaGunModel.fromJson(Map<String, dynamic> json) {
    final tarihParts = (json['tarih'] as String).split('-');
    final tarih = DateTime(
      int.parse(tarihParts[2]),
      int.parse(tarihParts[1]),
      int.parse(tarihParts[0]),
    );

    return CalismaGunModel(
      tarih: tarih,
      calistiMi: json['calistiMi'] as bool,
      calismaSaati: (json['calismaSaati'] as num).toDouble(),
      calismaMetni: json['calismaMetni'] as String,
      calismaNet: (json['calismaNet'] as num).toDouble(),
      calismaBrut: (json['calismaBrut'] as num?)?.toDouble() ?? 0.0,
      calismaNotu: json['calismaNotu'] as String?,
      mesaiVar: json['mesaiVar'] as bool,
      mesaiSaati: (json['mesaiSaati'] as num).toDouble(),
      mesaiMetni: json['mesaiMetni'] as String,
      mesaiNet: (json['mesaiNet'] as num).toDouble(),
      mesaiBrut: (json['mesaiBrut'] as num?)?.toDouble() ?? 0.0,
      mesaiNotu: json['mesaiNotu'] as String?,
      toplamKazanc: (json['toplamKazanc'] as num).toDouble(),
      toplamBrut: (json['toplamBrut'] as num?)?.toDouble() ?? 0.0,
      mesaiYuzde: (json['mesaiYuzde'] as num?)?.toDouble() ?? 50.0,
      kaydedilenIndex: (json['kaydedilenIndex'] as num?)?.toInt() ?? 0,
      kaydedilenUcret: (json['kaydedilenUcret'] as num?)?.toDouble() ?? 0.0,
      agiIstisnasi: (json['agiIstisnasi'] as num?)?.toDouble(),
      damgaIstisnasi: (json['damgaIstisnasi'] as num?)?.toDouble(),
      kaydedilenCalisanTipi: json['kaydedilenCalisanTipi'] as String?,
      kaydedilenKdvOrani: (json['kaydedilenKdvOrani'] as num?)?.toDouble(),
      kaydedilenBesOrani: (json['kaydedilenBesOrani'] as num?)?.toDouble(),
      kaydedilenBesAktif: json['kaydedilenBesAktif'] as bool?,
    );
  }

  CalismaGunModel copyWith({
    DateTime? tarih,
    bool? calistiMi,
    double? calismaSaati,
    String? calismaMetni,
    double? calismaNet,
    double? calismaBrut,
    String? calismaNotu,
    bool? mesaiVar,
    double? mesaiSaati,
    String? mesaiMetni,
    double? mesaiNet,
    double? mesaiBrut,
    String? mesaiNotu,
    double? mesaiYuzde,
    double? toplamKazanc,
    double? toplamBrut,
    int? kaydedilenIndex,
    double? kaydedilenUcret,
    String? kaydedilenCalisanTipi,
    double? kaydedilenKdvOrani,
    double? kaydedilenBesOrani,
    bool? kaydedilenBesAktif,
    double? agiIstisnasi,
    double? damgaIstisnasi,
  }) {
    return CalismaGunModel(
      tarih: tarih ?? this.tarih,
      calistiMi: calistiMi ?? this.calistiMi,
      calismaSaati: calismaSaati ?? this.calismaSaati,
      calismaMetni: calismaMetni ?? this.calismaMetni,
      calismaNet: calismaNet ?? this.calismaNet,
      calismaBrut: calismaBrut ?? this.calismaBrut,
      calismaNotu: calismaNotu ?? this.calismaNotu,
      mesaiVar: mesaiVar ?? this.mesaiVar,
      mesaiSaati: mesaiSaati ?? this.mesaiSaati,
      mesaiMetni: mesaiMetni ?? this.mesaiMetni,
      mesaiNet: mesaiNet ?? this.mesaiNet,
      mesaiBrut: mesaiBrut ?? this.mesaiBrut,
      mesaiNotu: mesaiNotu ?? this.mesaiNotu,
      toplamKazanc: toplamKazanc ?? this.toplamKazanc,
      toplamBrut: toplamBrut ?? this.toplamBrut,
      mesaiYuzde: mesaiYuzde ?? this.mesaiYuzde,
      kaydedilenIndex: kaydedilenIndex ?? this.kaydedilenIndex,
      kaydedilenUcret: kaydedilenUcret ?? this.kaydedilenUcret,
      kaydedilenCalisanTipi:
          kaydedilenCalisanTipi ?? this.kaydedilenCalisanTipi,
      kaydedilenKdvOrani: kaydedilenKdvOrani ?? this.kaydedilenKdvOrani,
      kaydedilenBesOrani: kaydedilenBesOrani ?? this.kaydedilenBesOrani,
      kaydedilenBesAktif: kaydedilenBesAktif ?? this.kaydedilenBesAktif,
      agiIstisnasi: agiIstisnasi ?? this.agiIstisnasi,
      damgaIstisnasi: damgaIstisnasi ?? this.damgaIstisnasi,
    );
  }
}
