import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kaydet {
  static final key = encrypt.Key.fromUtf8('kolayhesapprokolayhesappro123456');

  // Encrypt JSON data with dynamic IV
  static String encryptData(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16); // Dinamik IV oluştur
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Şifreli veriyle birlikte IV'yi başa ekle
    return iv.base64 + encrypted.base64;
  }

  // Decrypt JSON data with IV extraction
  static String decryptData(String encryptedText) {
    try {
      // IV'yi şifreli veriden çıkar
      final ivString = encryptedText.substring(0, 24); // İlk 24 karakter IV
      final encryptedData = encryptedText.substring(
        24,
      ); // Geri kalan şifreli veri

      final iv = encrypt.IV.fromBase64(ivString);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      // Şifreyi çöz
      return encrypter.decrypt64(encryptedData, iv: iv);
    } catch (e) {
      throw Exception("Şifre çözme işlemi başarısız oldu: $e");
    }
  }

  // Verileri JSON olarak kaydet ve paylaş
  static Future<void> kaydetJson(Function(String) onSuccess) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPrefs = prefs.getKeys().fold<Map<String, dynamic>>({}, (
        map,
        key,
      ) {
        map[key] = prefs.get(key);
        return map;
      });

      final jsonString = jsonEncode(allPrefs);

      // Veriyi şifrele
      final encryptedData = encryptData(jsonString);

      // Dosya yolunu oluştur
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/kolayhesappro.json';
      final file = File(filePath);

      // Şifreli veriyi dosyaya yaz
      await file.writeAsString(encryptedData);

      // Dosyayı paylaş
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], text: 'Verileri yedekleme'),
      );

      // Yedekleme işlemi yapıldı, bayrağı sıfırla
      await prefs.setBool('isJsonLoaded', false);

      onSuccess("Veri başarıyla şifrelendi ve yedeklendi");
    } catch (e) {
      onSuccess("Veri yedekleme ve paylaşma başarısız oldu: $e");
    }
  }

  // JSON dosyasını al ve verileri yükle
  static Future<void> alJson(Function(String) onSuccess) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Şifreli veriyi dosyadan oku
        String encryptedData = await file.readAsString();

        // Şifreli veriyi çöz
        String jsonString = decryptData(encryptedData);

        // Veriyi JSON'a çevir
        Map<String, dynamic> jsonMap = jsonDecode(jsonString);

        // SharedPreferences'a geri kaydet
        final prefs = await SharedPreferences.getInstance();

        // Jeton hariç tüm verileri temizle
        await jetonharictemizleme(prefs);

        // JSON dosyası başarıyla yüklendiğinde bayrağı true yap
        await prefs.setBool('isJsonLoaded', true);

        // JSON verilerini kaydet (bayrak true olsa bile)
        jsonMap.forEach((key, value) async {
          if (key != 'degerlendir' &&
              key != 'isJsonLoaded' &&
              key != 'ilkGiris') {
            // Jeton dışında tüm verileri güncelle
            if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            } else if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is String) {
              await prefs.setString(key, value);
            } else if (value is List<String>) {
              await prefs.setStringList(key, value.cast<String>());
            }
          }
        });

        onSuccess("Veriler başarıyla çözüldü, yüklendi ve kaydedildi");
      } else {
        onSuccess("İşlem kullanıcı tarafından iptal edildi");
      }
    } catch (e) {
      onSuccess("Veriler çözülemedi: $e");
    }
  }

  // Jeton ve 'isJsonLoaded' hariç tüm verileri temizle
  static Future<void> jetonharictemizleme(SharedPreferences prefs) async {
    final keys = prefs.getKeys();

    for (String key in keys) {
      if (key != 'degerlendir' && key != 'isJsonLoaded' && key != 'ilkGiris') {
        await prefs.remove(key);
      }
    }
  }
}
