class GirisVerileri2026 {
  const GirisVerileri2026();

  static const double asgariUcret = 33000.30;

  static const double kidemUstSinir = 64948.77;

  static const List<double> gelirVergisiIstisnasi = [
    4211.33,
    4211.33,
    4211.33,
    4211.33,
    4211.33,
    4211.33,
    4537.75,
    5615.10,
    5615.10,
    5615.10,
    5615.10,
    5615.10,
  ];

  static const List<double> damgaVergisiIstisnasi = [
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
    250.70,
  ];

  /// KDV Limitleri (2026)
  static const double kdv1 = 190000;
  static const double kdv2 = 400000;
  static const double kdv3 = 1500000;

  static const double engelli1 = 12000;
  static const double engelli2 = 7000;
  static const double engelli3 = 3000;
}

class GirisVerileri2025 {
  const GirisVerileri2025();

  static const double asgariUcret = 26005.50;

  static const double kidemUstSinir = 53919.68;

  /// AGİ YERİNE: Gelir Vergisi İstisnası
  static const List<double> gelirVergisiIstisnasi = [
    3315.70, // Oca
    3315.70, // Şub
    3315.70, // Mar
    3315.70, // Nis
    3315.70, // May
    3315.70, // Haz
    3315.70, // Tem
    4257.57, // Ağu
    4420.93, // Eyl
    4420.93, // Eki
    4420.93, // Kas
    4420.93, // Ara
  ];

  static const List<double> damgaVergisiIstisnasi = [
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
    197.38,
  ];

  /// KDV Limitleri (2025)
  static const double kdv1 = 150000;
  static const double kdv2 = 300000;
  static const double kdv3 = 1000000;

  /// Engelli Vergi İndirimleri
  static const double engelli1 = 9900;
  static const double engelli2 = 5700;
  static const double engelli3 = 2400;
}

class GirisVerileriManager {
  static int seciliYil = DateTime.now().year;

  static double get asgariUcret {
    switch (seciliYil) {
      case 2025:
        return GirisVerileri2025.asgariUcret;
      case 2026:
        return GirisVerileri2026.asgariUcret;
      default:
        return GirisVerileri2026.asgariUcret;
    }
  }

  static double get kidemUstSinir {
    switch (seciliYil) {
      case 2025:
        return GirisVerileri2025.kidemUstSinir;
      case 2026:
        return GirisVerileri2026.kidemUstSinir;
      default:
        return GirisVerileri2026.kidemUstSinir;
    }
  }

  static List<double> get gelirVergisiIstisnasi {
    switch (seciliYil) {
      case 2025:
        return GirisVerileri2025.gelirVergisiIstisnasi;
      case 2026:
        return GirisVerileri2026.gelirVergisiIstisnasi;
      default:
        return seciliYil > 2026
            ? GirisVerileri2026.gelirVergisiIstisnasi
            : GirisVerileri2025.gelirVergisiIstisnasi;
    }
  }

  static List<double> get damgaVergisiIstisnasi {
    switch (seciliYil) {
      case 2025:
        return GirisVerileri2025.damgaVergisiIstisnasi;
      case 2026:
        return GirisVerileri2026.damgaVergisiIstisnasi;
      default:
        return seciliYil > 2026
            ? GirisVerileri2026.damgaVergisiIstisnasi
            : GirisVerileri2025.damgaVergisiIstisnasi;
    }
  }

  static double get kdv1 {
    return seciliYil == 2025 ? GirisVerileri2025.kdv1 : GirisVerileri2026.kdv1;
  }

  static double get kdv2 {
    return seciliYil == 2025 ? GirisVerileri2025.kdv2 : GirisVerileri2026.kdv2;
  }

  static double get kdv3 {
    return seciliYil == 2025 ? GirisVerileri2025.kdv3 : GirisVerileri2026.kdv3;
  }

  static double get engelli1 {
    return seciliYil == 2025
        ? GirisVerileri2025.engelli1
        : GirisVerileri2026.engelli1;
  }

  static double get engelli2 {
    return seciliYil == 2025
        ? GirisVerileri2025.engelli2
        : GirisVerileri2026.engelli2;
  }

  static double get engelli3 {
    return seciliYil == 2025
        ? GirisVerileri2025.engelli3
        : GirisVerileri2026.engelli3;
  }
}
