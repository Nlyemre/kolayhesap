// lib/Screens/anaekran_bilesenler/anaekran/hesaplama_model.dart
import 'package:app/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart';

class BordroHesaplama {
  // ORTAK BORDRO HESAPLAMA FONKSİYONU - MERKEZİ SERVİSE YÖNLENDİR
  static Map<String, double> hesapBordro({
    required double brut,
    required String calisanTipi,
    required double vergiOrani,
    DateTime? tarih,
    int? calismaGunSayisi,
  }) {
    return MerkeziHesaplamaServisi().hesapBordro(
      brut: brut,
      calisanTipi: calisanTipi,
      vergiOrani: vergiOrani,
      tarih: tarih,
      calismaGunSayisi: calismaGunSayisi,
    );
  }

  // ÇALIŞMA BRUT HESAPLAMA - MERKEZİ SERVİSE YÖNLENDİR
  static double calismaBrutHesapla({
    required double calismaSaati,
    required int kaydedilenIndex,
    required double kaydedilenUcret,
  }) {
    return MerkeziHesaplamaServisi().calismaBrutHesapla(
      calismaSaati: calismaSaati,
      kaydedilenIndex: kaydedilenIndex,
      kaydedilenUcret: kaydedilenUcret,
    );
  }

  // MESAI BRUT HESAPLAMA - MERKEZİ SERVİSE YÖNLENDİR
  static double mesaiBrutHesapla({
    required double mesaiSaati,
    required int kaydedilenIndex,
    required double kaydedilenUcret,
    required double mesaiYuzde,
  }) {
    return MerkeziHesaplamaServisi().mesaiBrutHesapla(
      mesaiSaati: mesaiSaati,
      kaydedilenIndex: kaydedilenIndex,
      kaydedilenUcret: kaydedilenUcret,
      mesaiYuzde: mesaiYuzde,
    );
  }

  // AYLIK TOPLAM BORDRO - MERKEZİ SERVİSE YÖNLENDİR
  static Map<String, double> hesapAylikBordro({
    required double aylikBrut,
    required String calisanTipi,
    required double vergiOrani,
    required DateTime ayTarihi,
    int? calismaGunSayisi,
  }) {
    final gunSayisi = calismaGunSayisi ?? 30;

    return MerkeziHesaplamaServisi().gunlukTopluBordro(
      brutListesi: List.filled(gunSayisi, aylikBrut / gunSayisi),
      calisanTipi: calisanTipi,
      vergiOrani: vergiOrani,
      ayTarihi: ayTarihi,
      efektifGunSayisi: gunSayisi,
    );
  }

  // GÜNLÜK TOPLU BORDRO HESAPLAMA - YENİ FONKSİYON
  static Map<String, double> gunlukTopluBordro({
    required List<double> brutListesi,
    required String calisanTipi,
    required double vergiOrani,
    required DateTime ayTarihi,
    required int efektifGunSayisi,
  }) {
    return MerkeziHesaplamaServisi().gunlukTopluBordro(
      brutListesi: brutListesi,
      calisanTipi: calisanTipi,
      vergiOrani: vergiOrani,
      ayTarihi: ayTarihi,
      efektifGunSayisi: efektifGunSayisi,
    );
  }

  // BES KESİNTİSİ HESAPLAMA - YENİ FONKSİYON
  static double besKesintisiHesapla({
    required double brut,
    required bool besAktif,
    required double besOrani,
  }) {
    return MerkeziHesaplamaServisi().besKesintisiHesapla(
      brut: brut,
      besAktif: besAktif,
      besOrani: besOrani,
    );
  }

  // METİN AYIKLAMA YARDIMCILARI
  static String saatCalismaAyikla(String ayiklaiki) {
    return MerkeziHesaplamaServisi().saatCalismaAyikla(ayiklaiki);
  }

  static String yuzdeAyikla(String ayiklaBir) {
    return MerkeziHesaplamaServisi().yuzdeAyikla(ayiklaBir);
  }
}
