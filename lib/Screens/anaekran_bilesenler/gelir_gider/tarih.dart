import 'package:intl/intl.dart';

class TarihYardimci {
  static bool ayniGun(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool ayniHafta(DateTime date1, DateTime date2) {
    final firstDayOfWeek1 = date1.subtract(Duration(days: date1.weekday - 1));
    final firstDayOfWeek2 = date2.subtract(Duration(days: date2.weekday - 1));

    return ayniGun(firstDayOfWeek1, firstDayOfWeek2);
  }

  static bool ayniAy(
    DateTime? date1,
    DateTime? date2, {
    bool yilKontrolu = true,
  }) {
    if (date1 == null || date2 == null) return false;
    return (!yilKontrolu || date1.year == date2.year) &&
        date1.month == date2.month;
  }

  // Tarihlerin aynı yılda olup olmadığını kontrol eder (yeni eklenen fonksiyon)
  static bool ayniYil(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year;
  }

  // Tarihin verilen aralıkta olup olmadığını kontrol eder (sınırlar dahil)
  static bool tarihAraliginda(
    DateTime? tarih,
    DateTime? baslangic,
    DateTime? bitis,
  ) {
    if (tarih == null) return false;
    return (baslangic == null || tarih.compareTo(baslangic) >= 0) &&
        (bitis == null || tarih.compareTo(bitis) <= 0);
  }

  // Tarihi belirtilen formatta string'e çevirir
  static String formatla(DateTime tarih, [String format = 'dd/MM/yyyy']) {
    return DateFormat(format).format(tarih);
  }

  // Yalnızca tarih bilgisini içeren yeni bir DateTime oluşturur (saat bilgisi olmadan)
  static DateTime gunTarihi(DateTime tarih) {
    return DateTime(tarih.year, tarih.month, tarih.day);
  }

  // Hafta numarasını hesaplar
  static int haftaNumarasi(DateTime tarih) {
    final ilkGun = DateTime(tarih.year, 1, 1);
    final gunFarki = tarih.difference(ilkGun).inDays;
    return ((gunFarki + ilkGun.weekday - 1) / 7).floor() + 1;
  }

  static DateTime haftaninIlkGunu(DateTime tarih) {
    return DateTime(tarih.year, tarih.month, tarih.day - (tarih.weekday - 1));
  }

  static DateTime ayinIlkGunu(DateTime tarih) {
    return DateTime(tarih.year, tarih.month);
  }
}
