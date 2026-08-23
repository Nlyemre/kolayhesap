import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/gelir_gider/model_iki.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IslemServisi {
  static const String _islemlerAnahtari = 'islemler';

  Future<List<IslemModel>> islemleriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? islemlerJson = prefs.getStringList(_islemlerAnahtari);

    if (islemlerJson == null) return [];

    return islemlerJson.map((json) {
      final Map<String, dynamic> harita = jsonDecode(json);
      return IslemModel.fromMap(harita);
    }).toList();
  }

  Future<bool> islemEkle(IslemModel islem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<IslemModel> islemler = await islemleriGetir();
      islemler.add(islem);
      await prefs.setStringList(
        _islemlerAnahtari,
        islemler.map((i) => jsonEncode(i.toMap())).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> islemGuncelle(IslemModel guncellenenIslem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<IslemModel> islemler = await islemleriGetir();

      // Güncellenecek işlemin indeksini bul
      final index = islemler.indexWhere((i) => i.id == guncellenenIslem.id);

      if (index == -1) {
        return false; // Güncellenecek işlem bulunamadı
      }

      // İşlemi güncelle
      islemler[index] = guncellenenIslem;

      await prefs.setStringList(
        _islemlerAnahtari,
        islemler.map((i) => jsonEncode(i.toMap())).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> islemSil(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final islemler = await islemleriGetir();
      final baslangicSayi = islemler.length;

      islemler.removeWhere((i) => i.id == id);

      if (islemler.length == baslangicSayi) {
        return false; // Silinecek kayıt bulunamadı
      }

      await prefs.setStringList(
        _islemlerAnahtari,
        islemler.map((i) => jsonEncode(i.toMap())).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> tumIslemleriTemizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_islemlerAnahtari);
  }
}
