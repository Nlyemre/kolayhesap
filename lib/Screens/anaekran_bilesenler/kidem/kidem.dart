import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class Kidem extends StatefulWidget {
  final String kidemveri0;
  final String kidemveri1;
  final String kidemveri2;
  final String kidemveri3;
  final String kidemveri4;
  final int kidemveri5;
  final String kidemveri6;
  final String kidemveri7;
  final String kidemveri8;
  final String kidemveri9;
  final String kidemveri10;
  final int kidemveri11;
  final String kidemveri12;
  final int kidemveri13;
  final String kidemveri14;
  final String kidemveri15;

  const Kidem({
    super.key,
    required this.kidemveri0,
    required this.kidemveri1,
    required this.kidemveri2,
    required this.kidemveri3,
    required this.kidemveri4,
    required this.kidemveri5,
    required this.kidemveri6,
    required this.kidemveri7,
    required this.kidemveri8,
    required this.kidemveri9,
    required this.kidemveri10,
    required this.kidemveri11,
    required this.kidemveri12,
    required this.kidemveri13,
    required this.kidemveri14,
    required this.kidemveri15,
  });

  @override
  State<Kidem> createState() => _KidemState();
}

class _KidemState extends State<Kidem> {
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 500 && !_showAdNotifier.value) {
        _showAdNotifier.value = true;
      }
    });
  }

  @override
  void dispose() {
    _showAdNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdNotifier = ValueNotifier(false);

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
              icon: const Icon(
                Icons.share,
                size: 20.0,
                color: Renk.pastelKoyuMavi,
              ),
            ),
          ),
        ],
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Kıdem Tazminat Sonuçları"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: CemberAna(
                        deger1: double.parse(widget.kidemveri4),
                        isim1: "Kıdem Tazminatı",
                        deger2: double.parse(widget.kidemveri9),
                        isim2: "İhbar Tazminatı",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Renk.pastelKoyuMavi,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  offset: Offset(3, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'Kıdem Tazminatı',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Renk.pastelKoyuMavi,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Renk.pastelAcikMavi,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  offset: Offset(3, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          widget.kidemveri13 == 0
                              ? const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  'İhbar Tazminatı',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'İhbar Tazminatı + ${widget.kidemveri12}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Renk.pastelKoyuMavi,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Dekor.cizgi15,
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 10),
                      child: Yansatirikili.satir(
                        'Toplam Tazminat',
                        '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(toplama(widget.kidemveri4, widget.kidemveri9)))} TL',
                        Renk.pastelKoyuMavi,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: RepaintBoundary(child: YerelReklam()),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      color: Renk.pastelKoyuMavi.withValues(alpha: 0.1),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "KIDEM TAZMİNATI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Renk.pastelKoyuMavi,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Yansatirikili.satir(
                      'Hesaplamaya Esas Gün',
                      '${widget.kidemveri0} GÜN',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Kıdem Esas Ücret',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri1))} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Kıdem Tazminatı Brüt',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri2))} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Damga Vergi Kesintisi',
                      '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri3))} TL',
                      Renk.kirmizi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Net Kıdem Tazminatı',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      color: Renk.pastelKoyuMavi.withValues(alpha: 0.1),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "İHBAR TAZMİNATI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Renk.pastelKoyuMavi,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    widget.kidemveri13 == 0
                        ? Yansatirikili.satir(
                          'İhbar Gün',
                          '${widget.kidemveri5} GÜN',
                          Renk.pastelKoyuMavi,
                        )
                        : Yansatirikili.satir(
                          'İhbar Gün',
                          '${widget.kidemveri5} + ${widget.kidemveri13} GÜN',
                          Renk.pastelKoyuMavi,
                        ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'İzin Gün',
                      '${widget.kidemveri14.toString()} GÜN',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'İhbar Brüt',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri6))} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Gelir Vergi Kesintisi ${kdvListe[widget.kidemveri11]}',
                      '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri7))} TL',
                      Renk.kirmizi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Damga Vergi Kesintisi % 0,759',
                      '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri8))} TL',
                      Renk.kirmizi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Net İhbar Tazminatı',
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    ValueListenableBuilder<bool>(
                      valueListenable: _showAdNotifier,
                      builder: (context, showAd, child) {
                        return showAd
                            ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: RepaintBoundary(child: YerelReklamiki()),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        ' Hesaplama ve hesaplatma için bu uygulamadaki veriler yasal olarak bağlayıcı değildir.Kullanıcı bu uygulamada verilen bilgileri hesaplatma sonuçlarını kendi hesaplamalarına veya kullanımlarına temel almadan önce doğrulatması gerekir.Bu sebepten dolayı bu uygulamada verilen bilgilerin ve elde edilen hesaplatma sonuçlarının doğruluna ilişkin olarak Kolay Hesap Uygulaması sorumluluk veya garanti üstlenmez.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const RepaintBoundary(child: BannerReklamiki()),
          ],
        ),
      ),
    );
  }

  String toplama(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    double toplam = birDouble + ikiDouble;

    return toplam.toStringAsFixed(2);
  }

  String cikarma(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    double toplam = birDouble - ikiDouble;

    return toplam.toStringAsFixed(2);
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
            padding: const pw.EdgeInsets.only(left: 5, right: 200, top: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Kidem Tazminati',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8), // Adding space between sections
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Hesaplamaya Esas Gün'),
                    pw.Text('${widget.kidemveri0} GÜN '),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kidem Esas Ücret'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri1))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kidem Tazminati Brüt'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri2))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Damga Vergi Kesintisi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri3))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Net Kidem Tazminati'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
                    ),
                  ],
                ),
                pw.SizedBox(height: 16), // Adding space between sections

                pw.Text(
                  'Ihbar Tazminati',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8), // Adding space between sections
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ihbar Gün'),
                    pw.Text('${widget.kidemveri5} GÜN '),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ihbar Brüt'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri6))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Gelir Vergi Kesintisi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri7))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Damga Vergi Kesintisi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri8))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Net Ihbar Tazminati'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
                    ),
                  ],
                ),
                pw.SizedBox(height: 16), // Adding space between sections

                pw.Text(
                  'Genel Toplam',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8), // Adding space between sections
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kidem Tazminati'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ihbar Tazminati'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Toplam Tazminat'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(toplama(widget.kidemveri4, widget.kidemveri9)))} TL',
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
    final filePath = '${directory.path}/TazminatHesaplama.pdf';
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

    // Set up data in Excel format using TextCellValue
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('Kıdem Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('Hesaplamaya Esas Gün');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = TextCellValue('${widget.kidemveri0} GUN');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('Kıdem Esas Ücret');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri1))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('Kıdem Tazminatı Brüt');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri2))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = TextCellValue('Damga Vergi Kesintisi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri3))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = TextCellValue('Net Kıdem Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
    );

    // Add spacing
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
        .value = TextCellValue('');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .value = TextCellValue('İhbar Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 8))
        .value = TextCellValue('İhbar Gün');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 8))
        .value = TextCellValue('${widget.kidemveri5} GUN');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9))
        .value = TextCellValue('İhbar Brüt');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 9))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri6))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 10))
        .value = TextCellValue('Gelir Vergi Kesintisi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 10))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri7))} TL',
    );
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 11))
        .value = TextCellValue('Damga Vergi Kesintisi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 11))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri8))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 12))
        .value = TextCellValue('Net İhbar Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 12))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
    );

    // Add spacing
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 13))
        .value = TextCellValue('');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 14))
        .value = TextCellValue('Genel Toplam');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 15))
        .value = TextCellValue('Kıdem Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 15))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 16))
        .value = TextCellValue('İhbar Tazminatı');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 16))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL',
    );

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 17))
        .value = TextCellValue('Toplam Tazminat');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 17))
        .value = TextCellValue(
      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(toplama(widget.kidemveri4, widget.kidemveri9)))} TL',
    );

    // Adjust column widths
    setColumnWidth(sheetObject, 0, 25); // Adjust as needed for column A
    setColumnWidth(sheetObject, 1, 15); // Adjust as needed for column B

    CellStyle cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

    for (int row = 1; row <= 17; row++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      cell.cellStyle = cellStyle;
    }

    // Save Excel file
    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/KıdemHesaplama.xlsx';
    var fileBytes = excel.save();
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    // Share Excel file
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'Excel Paylaş'),
    );
  }

  String paylas = "";
  void _paylas() {
    paylas = "";
    paylas += "Kıdem Tazminatı\n";
    paylas += "Hesaplamaya Esas Gün  : ${widget.kidemveri0} GUN\n";
    paylas +=
        "Kıdem Esas Ücret      : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri1))} TL\n";
    paylas +=
        "Kıdem Tazminatı Brüt  : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri2))} TL\n";
    paylas +=
        "Damga Vergi Kesintisi : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri3))} TL\n";
    paylas +=
        "Net Kıdem Tazminatı   : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL\n\n";
    paylas += "İhbar Tazminatı\n";
    paylas += "İhbar Gün             : ${widget.kidemveri5} GUN\n";
    paylas +=
        "İhbar Brüt            : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri6))} TL\n";
    paylas +=
        "Gelir Vergi Kesintisi : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri7))} TL\n";
    paylas +=
        "Damga Vergi Kesintisi : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri8))} TL\n";
    paylas +=
        "Net İhbar Tazminatı   : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL\n\n";
    paylas += "Genel Toplam\n";
    paylas +=
        "Kıdem Tazminatı       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri4))} TL\n";
    paylas +=
        "İhbar Tazminatı       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.kidemveri9))} TL\n";
    paylas +=
        "Toplam Tazminat       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(toplama(widget.kidemveri4, widget.kidemveri9)))} TL\n";
    SharePlus.instance.share(ShareParams(text: paylas));
  }

  List<String> kdvListe = ['% 15', '% 20', '% 27', '% 35', '% 40'];
}
