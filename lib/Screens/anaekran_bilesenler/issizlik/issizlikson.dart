import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class IssizlikSon extends StatefulWidget {
  final String issizlik0;
  final String issizlik1;
  final String issizlik2;
  final String issizlik3;
  final String issizlik4;
  final String issizlik5;
  final String issizlik6;
  final String issizlik7;
  final String issizlik8;
  final String issizlik9;
  final String issizlik10;

  const IssizlikSon({
    super.key,
    required this.issizlik0,
    required this.issizlik1,
    required this.issizlik2,
    required this.issizlik3,
    required this.issizlik4,
    required this.issizlik5,
    required this.issizlik6,
    required this.issizlik7,
    required this.issizlik8,
    required this.issizlik9,
    required this.issizlik10,
  });

  @override
  State<IssizlikSon> createState() => _IssizlikSonState();
}

class _IssizlikSonState extends State<IssizlikSon> {
  late int sayi;
  late List<double> issizlikListe;
  late List<String> aylarListe;

  List<String> aylar = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  void listedongu() {
    int currentMonth = DateTime.now().month - 1;
    int hakedilenay = int.parse(widget.issizlik10);

    for (int i = 0; i < hakedilenay; i++) {
      int monthIndex = (currentMonth + i) % 12;
      issizlikListe[i] = double.parse(widget.issizlik6);
      aylarListe[i] = aylar[monthIndex];
    }
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('tr_TR');
    sayi = int.parse(widget.issizlik10.toString());
    issizlikListe = List.generate(sayi, (index) => 0);
    aylarListe = List.generate(sayi, (index) => '');
    listedongu();
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

        title: const Text("İşsizlik Maaş Sonuçları"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _grafik(),
                  Yansatirikili.satir(
                    'İşsizlik Maaşı Brüt',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Yansatirikili.satir(
                    'İşsizlik Damga Vergisi',
                    '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL',
                    Renk.kirmizi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İşsizlik Maaşı Net',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: RepaintBoundary(child: YerelReklam()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      color: Renk.pastelKoyuMavi.withValues(alpha: 0.1),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "İŞSİZLİK MAAŞ DETAYLARI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Renk.pastelKoyuMavi,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Yansatirikili.satir(
                    '4 Ay Toplam Kazanç',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik0))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Aylık Ortalama Kazanç',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik1))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Ortalama Kazanç %40',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik2))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Ödeme Üst Sınır %80',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik3))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İşsizlik Brüt Maaş',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İşsizlik Damga vergisi',
                    '- ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL',
                    Renk.kirmizi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Günlük İşsizlik Ödeneği',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik9))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Aylık İşsizlik Ödeneği',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'Toplam İşsizlik Ödeneği',
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik8))} TL',
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  Yansatirikili.satir(
                    'İşsizlik Maaşı Süresi',
                    widget.issizlik7,
                    Renk.pastelKoyuMavi,
                  ),
                  Dekor.cizgi15,
                  const SizedBox(height: 10),
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
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }

  String toplama(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    double toplam = birDouble + ikiDouble;

    return toplam.toStringAsFixed(2);
  }

  String carpma(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    double carp = birDouble * ikiDouble;

    return NumberFormat("#,##0.00", "tr_TR").format(carp);
  }

  String cikarma(String bir, String iki) {
    double birDouble = double.tryParse(bir) ?? 0;
    double ikiDouble = double.tryParse(iki) ?? 0;

    double toplam = birDouble - ikiDouble;

    return NumberFormat("#,##0.00", "tr_TR").format(toplam);
  }

  Widget _grafik() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < sayi; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: dikey(
                  aylarListe[i],
                  (i + 1).toString(),
                  '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget dikey(String ay, String aysayi, String maas) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                alignment: Alignment.topCenter,
                height: 165,
                decoration: BoxDecoration(
                  color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    "$maas     ",
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: Renk.gradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        offset: Offset(3, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      "   $ay",
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RotatedBox(
          quarterTurns: 3,
          child: Text(
            "$aysayi.Ay",
            style: const TextStyle(fontSize: 8, color: Renk.pastelKoyuMavi),
          ),
        ),
      ],
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
            padding: const pw.EdgeInsets.only(left: 5, right: 200, top: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Issizlik Maas Detaylari',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8), // Adding space between sections
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('4 Ay Toplam Kazanc'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik0))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Aylik Ortalama Kazanc'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik1))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ortalama Kazanc %40'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik2))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Odeme Üst Sinir %80'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik3))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Issizlik Brüt Maas'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Issizlik Damga vergisi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Gunluk Issizlik Odenegi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik9))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Aylik Issizlik Odenegi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Toplam Issizlik Odenegi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik8))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Issizlik Maas Süresi'),
                    pw.Text(widget.issizlik7),
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
                    pw.Text('Issizlik Maasi Brüt'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Issizlik Damga Vergisi'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL',
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Issizlik Maasi Net'),
                    pw.Text(
                      '${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL',
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
    final filePath = '${directory.path}/IssizlikHesaplama.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

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
        .value = TextCellValue('İşsizlik Maaşı Detayları');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('4 Ay Toplam Kazanç');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = formattedCellValue(widget.issizlik0);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('Aylık Ortalama Kazanç');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = formattedCellValue(widget.issizlik1);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('Ortalama Kazanç %40');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = formattedCellValue(widget.issizlik2);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = TextCellValue('Ödeme Üst Sınır %80');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = formattedCellValue(widget.issizlik3);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = TextCellValue('İşsizlik Brüt Maaş');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = formattedCellValue(widget.issizlik4);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
        .value = TextCellValue('İşsizlik Damga Vergisi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6))
        .value = formattedCellValue(widget.issizlik5);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .value = TextCellValue('Günlük İşsizlik Ödeneği');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
        .value = formattedCellValue(widget.issizlik9);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 8))
        .value = TextCellValue('Aylık İşsizlik Ödeneği');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 8))
        .value = formattedCellValue(widget.issizlik6);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9))
        .value = TextCellValue('Toplam İşsizlik Ödeneği');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 9))
        .value = formattedCellValue(widget.issizlik8);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 10))
        .value = TextCellValue('İşsizlik Maaşı Süresi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 10))
        .value = TextCellValue(widget.issizlik7);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 11))
        .value = TextCellValue('Genel Toplam');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 12))
        .value = TextCellValue('İşsizlik Maaşı Brüt');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 12))
        .value = formattedCellValue(widget.issizlik4);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 13))
        .value = TextCellValue('İşsizlik Damga Vergisi');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 13))
        .value = formattedCellValue(widget.issizlik5);

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 14))
        .value = TextCellValue('İşsizlik Maaşı Net');
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 14))
        .value = formattedCellValue(widget.issizlik6);

    // Adjust column widths
    setColumnWidth(sheetObject, 0, 25); // Adjust as needed for column A
    setColumnWidth(sheetObject, 1, 15); // Adjust as needed for column B

    CellStyle cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

    for (int row = 1; row <= 14; row++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      cell.cellStyle = cellStyle;
    }

    // Save Excel file
    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/IssizlikHesaplama.xlsx';
    var fileBytes = excel.save();
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    // Share Excel file
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'Excel Paylaş'),
    );
  }

  void _paylas() {
    final paylas = '''
Issizlik Maaşı Detayları

4 Ay Toplam Kazanç       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik0))} TL
Aylık Ortalama Kazanç    : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik1))} TL
Ortalama Kazanç %40      : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik2))} TL
Ödeme Üst Sınır %80      : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik3))} TL
İşsizlik Brüt Maaş       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL
İşsizlik Damga Vergisi   : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL
Günlük İşsizlik Ödeneği  : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik9))} TL
Aylık İşsizlik Ödeneği   : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL
Toplam İşsizlik Ödeneği  : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik8))} TL
İşsizlik Maaşı Süresi    : ${widget.issizlik7}

Genel Toplam

İşsizlik Maaşı Brüt      : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik4))} TL
İşsizlik Damga Vergisi   : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik5))} TL
İşsizlik Maaşı Net       : ${NumberFormat("#,##0.00", "tr_TR").format(double.parse(widget.issizlik6))} TL
''';

    SharePlus.instance.share(ShareParams(text: paylas));
  }
}
