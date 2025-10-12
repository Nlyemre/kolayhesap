import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelSayfa {
  // Static method to export to Excel
  static Future<void> olusturExcel({
    required List<String> aylar,
    required List<String> basliklar,
    required List<List<String>> veriler,
    required int sutunsayisi,
    required int satirsayisi,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    CellStyle cellStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 8,
    );

    // Ayları ekleme
    for (int i = 0; i < aylar.length; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
      );
      cell.value = TextCellValue(aylar[i]); // String olarak ayları ekle
      cell.cellStyle = cellStyle;
    }

    // Başlıkları ekleme
    for (int i = 0; i < basliklar.length; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: 0),
      );
      cell.value = TextCellValue(basliklar[i]); // String olarak başlıkları ekle
      cell.cellStyle = cellStyle;
    }

    // Verileri ekleme
    for (int i = 0; i < satirsayisi; i++) {
      // 13 satır
      for (int j = 0; j < sutunsayisi; j++) {
        // Sutun sayısı kadar döner
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: i + 1),
        );
        cell.value = TextCellValue(veriler[j][i]);
        cell.cellStyle = cellStyle;
      }
    }

    // Dosya sistemine kaydetme
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/tablo.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      File file =
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Dosya Paylaş'),
      );
    }
  }
}
