import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tema {
  static ThemeData get normalTema {
    return ThemeData(
      useMaterial3: true, // Material 3 aktif
      cardTheme: const CardThemeData(
        color: Color.fromARGB(255, 250, 250, 250),
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Renk.cita, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        dayStyle: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
        todayBorder: BorderSide(color: Color.fromARGB(255, 31, 86, 150)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          side: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
        ),
      ),
      // Dialog ve ColorScheme (DatePicker için)
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      colorScheme: const ColorScheme.light(
        primary: Color.fromARGB(255, 31, 86, 150),
        onPrimary: Colors.white,
        onSurface: Colors.black,
      ),
      // ElevatedButton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 31, 86, 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            side: BorderSide(color: Renk.cita, width: 1),
          ),
          elevation: 0, // Gölge efekti olmasın isterseniz
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: Colors.black, // Kapalı durumdaki ikon rengi
        collapsedIconColor: Colors.black, // Açık durumdaki ikon rengi
        textColor: Colors.black, // Başlık metin rengi (opsiyonel)
        collapsedTextColor:
            Colors.black, // Kapalı durum metin rengi (opsiyonel)
      ),
      fontFamily: 'Ubuntu',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Ubuntu'),
        bodyMedium: TextStyle(fontFamily: 'Ubuntu'),
        bodySmall: TextStyle(fontFamily: 'Ubuntu'),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 245, 245, 245),
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: Colors.white, // Arka plan BEYAZ
          statusBarIconBrightness: Brightness.dark, // İkonlar SİYAH (Android)
          statusBarBrightness: Brightness.light, // iOS için BEYAZ arka plan
        ),
        backgroundColor: Colors.white,
        centerTitle: true, // Başlığı ortala
        toolbarHeight: 50,
        titleTextStyle: TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Renk.koyuMavi,
        ),
        surfaceTintColor:
            Colors
                .white, // Material 3'te kaydırma sırasında renk değişimini engeller
        scrolledUnderElevation: 0, // Kaydırma sırasında gölgeyi kaldırır
        shadowColor: Colors.transparent, // Gölge rengini şeffaf yapar
        // İçerikleri dikeyde ortalamak için
        titleSpacing: 0, // Başlık boşluğunu sıfırla
        toolbarTextStyle: TextStyle(
          height: 1.0, // Satır yüksekliğini normalleştir
        ),
        actionsIconTheme: IconThemeData(
          size: 24, // İkon boyutu
        ),
        iconTheme: IconThemeData(
          size: 24, // Geri butonu ikon boyutu
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        labelStyle: TextStyle(
          color: Renk.koyuMavi,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 98, 98, 98)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 98, 98, 98)),
        ),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 250, 250, 250),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
    );
  }
}
