import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class MtvSon extends StatefulWidget {
  final String mtv0;
  final String mtv1;
  final String mtv2;
  final String mtv3;
  final String mtv4;
  final String mtv5;
  final String mtv6;
  final String mtv7;
  final String mtv8;

  const MtvSon({
    super.key,
    required this.mtv0,
    required this.mtv1,
    required this.mtv2,
    required this.mtv3,
    required this.mtv4,
    required this.mtv5,
    required this.mtv6,
    required this.mtv7,
    required this.mtv8,
  });

  @override
  State<MtvSon> createState() => _MtvState();
}

class _MtvState extends State<MtvSon> {
  @override
  void initState() {
    super.initState();

    initializeDateFormatting('tr_TR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: () {
                paylasimPenceresiAc(
                  context: context,
                  paylasPDF: _paylasPDF,
                  paylasExcel: _paylasExcel,
                  paylasMetin: _paylas,
                );
              },
              icon: const Icon(Icons.share, size: 20.0, color: Renk.koyuMavi),
            ),
          ),
        ],
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Araç MTV Sonuçları"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: RepaintBoundary(child: YerelReklamuc()),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    color: Renk.koyuMavi.withValues(alpha: 0.1),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "ARAÇ MTV TUTARI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Renk.koyuMavi,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Yansatirikili.satir(
                      'Yıllık MTV Tutarı',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv6))} TL',
                      Renk.koyuMavi,
                    ),
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İlk Altı Aylık Tutar',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv7))} TL',
                    Renk.koyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İkinci Altı Aylık Tutar',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv8))} TL',
                    Renk.koyuMavi,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    color: Renk.koyuMavi.withValues(alpha: 0.1),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "ARAÇ ÖZELLİKLERİ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Yansatirikili.satir(
                      'Araç Tipi',
                      widget.mtv0,
                      Renk.koyuMavi,
                    ),
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Yakıt Tipi ( % 100 Elektrikli mi? )',
                    widget.mtv1,
                    Renk.koyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Tescil Tarihi ( 01/01/2018 )',
                    widget.mtv2,
                    Renk.koyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir('Araç Yaşı', widget.mtv3, Renk.koyuMavi),
                  Dekor.cizgi15,
                  Yansatirikili.satir('Motor Gücü', widget.mtv4, Renk.koyuMavi),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Taşıt Değeri',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv5))} TL',
                    Renk.koyuMavi,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: YerelReklamiki(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bilgi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Renk.koyuMavi,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "2025 yılı için yeniden değerleme oranı % 43.93 olarak belirlenmiştir. Aşağıdaki sonuçlarda % 43.93 artış oranıyla ortaya çıkan ve Resmi Gazete'de yayınlanarak kesinleşen vergi tutarları sunulmaktadır.",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }

  void _paylasPDF() async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add a page to the PDF document
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 5, right: 20, top: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Arac MTV Detaylari',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8), // Adding space between sections
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Araç Tipi'), pw.Text(widget.mtv0)],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Yakıt Tipi'), pw.Text(widget.mtv1)],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Tescil Tarihi'), pw.Text(widget.mtv2)],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Araç Yaşı'), pw.Text(widget.mtv3)],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Motor Gücü'), pw.Text(widget.mtv4)],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Taşıt Değeri'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv5))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Yıllık MTV Tutarı'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv6))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('İlk Altı Aylık Tutar'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv7))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('İkinci Altı Aylık Tutar'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv8))} TL',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF document
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Arac MTV.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Share the PDF document
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
  }

  void _paylasExcel() async {
    // Create a new Excel document
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Define a helper function to set column widths
    void setColumnWidth(Sheet sheet, int columnIndex, double width) {
      sheet.setColumnWidth(columnIndex, width);
    }

    TextCellValue formattedCellValue(String value) {
      return TextCellValue(
        '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(value))} TL',
      );
    }

    // Set cell values using TextCellValue
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('Araç Mtv Detayları');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('Araç Tipi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = TextCellValue(widget.mtv0);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('Yakıt Tipi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = TextCellValue(widget.mtv1);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('Tescil Tarihi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = TextCellValue(widget.mtv2);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = TextCellValue('Araç Yaşı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = TextCellValue(widget.mtv3);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = TextCellValue(widget.mtv4);
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = formattedCellValue(widget.mtv4);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
        .value = TextCellValue('Taşıt Değeri');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6))
        .value = formattedCellValue(widget.mtv5);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .value = TextCellValue('Yıllık MTV Tutarı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
        .value = formattedCellValue(widget.mtv6);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 8))
        .value = TextCellValue('İlk Altı Aylık Tutar');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 8))
        .value = formattedCellValue(widget.mtv7);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9))
        .value = TextCellValue('İkinci Altı Aylık Tutar');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 9))
        .value = formattedCellValue(widget.mtv8);

    // Adjust column widths
    setColumnWidth(sheetObject, 0, 25); // Adjust as needed for column A
    setColumnWidth(sheetObject, 1, 15); // Adjust as needed for column B

    CellStyle cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

    for (int row = 1; row <= 9; row++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      cell.cellStyle = cellStyle;
    }

    // Save Excel file
    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/Arac MTV.xlsx';
    var fileBytes = excel.save();
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'Excel Paylaş'),
    );
  }

  void _paylas() {
    final paylas = '''
Araç Mtv Detayları

Araç Tipi                : ${widget.mtv0}
Yakıt Tipi               : ${widget.mtv1}
Tescil Tarihi            : ${widget.mtv2}
Araç Yaşı                : ${widget.mtv3}
Motor Gücü               : ${widget.mtv4}
Taşıt Değeri             : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv5))} TL
Yıllık MTV Tutarı        : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv6))} TL
İlk Altı Aylık Tutar     : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv7))} TL
İkinci Altı Aylık Tutar  : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.mtv8))} TL
''';

    SharePlus.instance.share(ShareParams(text: paylas));
  }
}
