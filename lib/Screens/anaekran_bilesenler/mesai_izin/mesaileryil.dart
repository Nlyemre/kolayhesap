import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mesaileryil extends StatefulWidget {
  const Mesaileryil({super.key});

  @override
  State<Mesaileryil> createState() => _MesaileryilState();
}

class _MesaileryilState extends State<Mesaileryil> {
  final List<List<String>> _mesaiYilVerileri = List.generate(
    13,
    (index2) => List.generate(4, (index) => ''),
  );

  final List<double> netListe = List.generate(12, (index) => 0.0);
  final List<double> burutListe = List.generate(12, (index) => 0.0);

  int secilenYil = int.parse(DateFormat('yyyy').format(DateTime.now()));
  int _selectedIndex = 0;
  final List<bool> isSelected = [true, false, false];

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('tr_TR');
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 500 && !_showAdNotifier.value) {
        _showAdNotifier.value = true;
      }
    });
    _girindex();
  }

  @override
  void dispose() {
    _showAdNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdNotifier = ValueNotifier(false);

  Future<void> _girindex() async {
    final prefs = await SharedPreferences.getInstance();
    final indexSayfa = prefs.getInt('index') ?? 0;
    _selectedIndex = indexSayfa;

    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = (i == _selectedIndex);
    }
    await _girisListele();
  }

  Future<void> _girisListele() async {
    final prefs = await SharedPreferences.getInstance();
    double saatTopla = 0;
    double burutTopla = 0;
    double netTopla = 0;

    for (int i = 0; i < 12; i++) {
      final saat =
          prefs.getDouble('$_selectedIndex-$secilenYil-${i + 1}-saat') ?? 0;
      final burut =
          prefs.getDouble('$_selectedIndex-$secilenYil-${i + 1}-burut') ?? 0;
      final net =
          prefs.getDouble('$_selectedIndex-$secilenYil-${i + 1}-net') ?? 0;

      _mesaiYilVerileri[i][0] = ayList[i];
      _mesaiYilVerileri[i][1] =
          _selectedIndex == 0
              ? NumberFormat("#,##0.0", "tr_TR").format(saat)
              : NumberFormat("#,##0", "tr_TR").format(saat);
      _mesaiYilVerileri[i][2] = NumberFormat("#,##0.00", "tr_TR").format(burut);
      _mesaiYilVerileri[i][3] = NumberFormat("#,##0.00", "tr_TR").format(net);

      netListe[i] = net;
      burutListe[i] = burut;

      saatTopla += saat;
      burutTopla += burut;
      netTopla += net;
    }

    _mesaiYilVerileri[12][0] = "Toplam";
    _mesaiYilVerileri[12][1] =
        _selectedIndex == 0
            ? NumberFormat("#,##0.0", "tr_TR").format(saatTopla)
            : NumberFormat("#,##0", "tr_TR").format(saatTopla);
    _mesaiYilVerileri[12][2] = NumberFormat(
      "#,##0.00",
      "tr_TR",
    ).format(burutTopla);
    _mesaiYilVerileri[12][3] = NumberFormat(
      "#,##0.00",
      "tr_TR",
    ).format(netTopla);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),
        actions: [
          IconButton(
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
        ],

        title: const Text("Mesailer Yil"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _ustSecenekler(),

                  /// 📢 İlk Reklam Alanı
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 5,
                    ),
                    child: RepaintBoundary(child: YerelReklamalti()),
                  ),

                  _aylarSec(),
                  _tablo(),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showAdNotifier,
                    builder: (context, showAd, child) {
                      return showAd
                          ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: RepaintBoundary(child: YerelReklam()),
                          )
                          : const SizedBox.shrink();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                    child: Text(
                      "Aylara Göre Mesai Grafiği",
                      style: TextStyle(
                        color: Renk.pastelKoyuMavi,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// 📊 Brüt & Net Ücret Etiketleri
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _etiketKutusu(Renk.pastelKoyuMavi),
                        const Text(
                          '   Brüt Ücret       ',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        _etiketKutusu(Renk.pastelAcikMavi),
                        const Text(
                          '   Net Ücret',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 📊 Mesai Grafiği
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SizedBox(
                      height: 350,
                      child: GrafikTasarimiki(
                        values: burutListe,
                        labels: ayListiki,
                        valuesiki: netListe,
                      ),
                    ),
                  ),

                  _altbilgilendirme(),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklam()),
        ],
      ),
    );
  }

  /// Küçük etiket kutuları için fonksiyon
  Widget _etiketKutusu(Color renk) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [renk, renk],
          begin: const Alignment(1.0, -1.0),
          end: const Alignment(1.0, 1.0),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(1.0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            offset: Offset(3, 3),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _ustSecenekler() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(isSelected.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: ButonlarRawChip(
                isSelected: isSelected[index],
                text: butonyazi[index],
                onSelected: () {
                  setState(() {
                    _selectedIndex = index;
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }
                    _girisListele();
                  });
                },
                height: 40,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _aylarSec() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _yilDialog();
              },
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Renk.pastelAcikMavi, Renk.pastelKoyuMavi],
                    begin: Alignment(1.0, -1.0),
                    end: Alignment(1.0, 1.0),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      offset: Offset(5, 5),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "$secilenYil Mesai Tablosu",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> butonyazi = ['Saat Ücret', 'Günlük Ücret', 'Aylik Ücret'];
  final List<int> yilListe = [
    2024,
    2025,
    2026,
    2027,
    2028,
    2029,
    2030,
    2031,
    2032,
    2033,
    2034,
    2035,
  ];

  Future<void> _yilDialog() async {
    await AcilanPencere.show(
      context: context,
      title: 'Yıl Seçiniz',
      height: 0.8,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: yilListe.length,
          separatorBuilder:
              (context, index) => const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(color: Renk.cita, height: 0, thickness: 1),
              ),
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              title: Text(
                yilListe[index].toString(),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      secilenYil == yilListe[index]
                          ? Renk.pastelKoyuMavi
                          : Colors.black87,
                  fontWeight:
                      secilenYil == yilListe[index]
                          ? FontWeight.w600
                          : FontWeight.normal,
                ),
              ),
              trailing:
                  secilenYil == yilListe[index]
                      ? const Icon(
                        Icons.check,
                        color: Renk.pastelKoyuMavi,
                        size: 24,
                      )
                      : null,
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  secilenYil = yilListe[index];
                  _girisListele();
                });
              },
            );
          },
        ),
      ),
    );
  }

  final List<String> basliklar = [
    'Aylar',
    'Mesai Saat',
    'Mesai Brüt',
    'Mesai Net',
  ];

  Widget _tablo() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 7),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              TableRow(
                children: List.generate(
                  4,
                  (i) => TableCell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
                      ),
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        i == 1
                            ? (_selectedIndex == 0 ? 'Mesai Saat' : 'Mesai Gün')
                            : basliklar[i],
                        style: const TextStyle(
                          color: Renk.pastelKoyuMavi,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Table(
              border: TableBorder.all(color: Colors.white),
              children: List.generate(
                13,
                (index) => TableRow(
                  decoration: BoxDecoration(
                    color:
                        index.isEven
                            ? Colors.white
                            : Renk.pastelKoyuMavi.withValues(alpha: 0.06),
                  ),
                  children: List.generate(
                    4,
                    (index2) => TableCell(
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            _mesaiYilVerileri[index][index2],
                            style: const TextStyle(
                              color: Color.fromARGB(255, 30, 30, 30),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _paylasPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Table(
                children: [
                  pw.TableRow(
                    children: List.generate(
                      4,
                      (i) => pw.Container(
                        height: 40,
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          i == 1
                              ? (_selectedIndex == 0
                                  ? 'Mesai Saat'
                                  : 'Mesai Gün')
                              : basliklar[i],
                          style: const pw.TextStyle(fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                children: List.generate(
                  13,
                  (j) => pw.TableRow(
                    children: List.generate(
                      4,
                      (i) => pw.Container(
                        height: 40,
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          yaziduzelt(_mesaiYilVerileri[j][i]),
                          style: const pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 12,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/MesaiYilListesi.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
  }

  String yaziduzelt(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 's')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'g')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'o');
  }

  void _paylasExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    CellStyle cellStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 8,
    );

    for (int i = 0; i < 4; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(basliklar[i]);
      cell.cellStyle = cellStyle;
    }

    for (int j = 0; j < 13; j++) {
      for (int i = 0; i < 4; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: j + 1),
        );
        cell.value = TextCellValue(_mesaiYilVerileri[j][i]);
        cell.cellStyle = cellStyle;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/MesaiYilListesi.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file =
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Mesai Yil Listesi Excel Paylaş',
        ),
      );
    }
  }

  String paylas = "";
  void _paylas() {
    paylas = "";
    paylas += "Aylar     M.Saat     M.Brüt      M.Net\n";
    for (int i = 0; i < 12; i++) {
      if (_mesaiYilVerileri[i][1] != "0.0") {
        paylas +=
            "${_mesaiYilVerileri[i][0].padRight(10)} ${_mesaiYilVerileri[i][1].padRight(10)} ${_mesaiYilVerileri[i][2].padRight(10)} ${_mesaiYilVerileri[i][3]}\n";
      }
    }
    paylas +=
        "\n${_mesaiYilVerileri[12][0].padRight(10)} ${_mesaiYilVerileri[12][1].padRight(10)} ${_mesaiYilVerileri[12][2].padRight(10)} ${_mesaiYilVerileri[12][3].padRight(10)}\n";
    SharePlus.instance.share(ShareParams(text: paylas));
  }

  final List<String> ayList = [
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

  final List<String> ayListiki = [
    'Oca',
    'Şub',
    'Mart',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağus',
    'Eyl',
    'Ekim',
    'Kas',
    'Ara',
  ];

  Widget _altbilgilendirme() {
    return const Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sayfanın Temel Özellikleri:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Mesaileryil sayfası, kullanıcıların yıllık mesai bilgilerini takip etmeleri, analiz etmeleri ve paylaşmaları için geliştirilmiş kapsamlı bir araçtır. Bu sayfa, iş yaşamındaki mesai saatlerini ve gelirleri detaylı şekilde yönetmek isteyen kullanıcılar için tasarlanmıştır. Aşağıda, sayfanın sunduğu temel işlevler ve kullanıcıların gerçekleştirebileceği işlemler ayrıntılı şekilde açıklanmıştır.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Sayfanın Genel İşlevleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          Text(
            'Mesaileryil sayfası, kullanıcıların yıllık mesai saatlerini ve ücretlerini görselleştirmesine, incelemesine ve raporlamasına olanak tanır. Kullanıcılar, her ay için detaylı verileri girerek mesailerini analiz edebilir ve geçmiş yıllara ait bilgilere kolayca erişebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Mesai Verilerinin Yönetimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          Text(
            'Aylık Veriler: Her ay için mesai saatleri, brüt ve net maaş bilgileri kaydedilir.\n\n'
            'Yıllık Toplamlar: Kullanıcıların yıl bazında toplam çalışma saatlerini ve kazançlarını görmeleri sağlanır.\n\n'
            'Seçenek Yönetimi: Kullanıcılar saatlik, günlük veya aylık bazda hesaplama yapabilir ve tercihlerine göre sonuçları görüntüleyebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Veri Kaydetme ve Paylaşma',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          Text(
            'Kullanıcının girdiği veriler ve mesaiyil kayıtlarını, Yerel bellek kullanılarak cihazda saklanır. Bu sayede, kullanıcı uygulamayı kapatsa bile veriler kaybolmaz ve daha sonra tekrar erişilebilir.\n\n'
            'Ayrıca, kullanıcı mesaiyil kayıtlarını diğer uygulamalarla paylaşabilir. Örneğin, mesaiyil kayıtlarını bir mesajlaşma uygulaması üzerinden paylaşabilir veya e-posta ile gönderebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Kullanıcı Dostu Arayüz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          Text(
            'Sayfa, kullanıcıların kolayca anlayabileceği ve kullanabileceği bir arayüz sunar.\n\n'
            'Yıl Seçimi: Geçmiş yıllara ait veriler incelenebilir.\n\n'
            'Etkileşimli Kullanım: Kullanıcılar grafik üzerinden detaylı analiz yapabilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Bilgilendirme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.pastelKoyuMavi,
            ),
          ),
          Text(
            'Hesaplama ve hesaplatma için bu uygulamadaki veriler yasal olarak bağlayıcı değildir.Kullanıcı bu uygulamada verilen bilgileri hesaplatma sonuçlarını kendi hesaplamalarına veya kullanımlarına temel almadan önce doğrulatması gerekir.Bu sebepten dolayı bu uygulamada verilen bilgilerin ve elde edilen hesaplatma sonuçlarının doğruluna ilişkin olarak Kolay Hesap Uygulaması sorumluluk veya garanti üstlenmez.',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class GrafikTasarimiki extends StatelessWidget {
  final List<double> values;
  final List<double> valuesiki;
  final List<String> labels;

  const GrafikTasarimiki({
    super.key,
    required this.values,
    required this.labels,
    required this.valuesiki,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Chart(
            layers: [
              // Eksen Katmanı
              ChartAxisLayer(
                settings: ChartAxisSettings(
                  x: ChartAxisSettingsAxis(
                    frequency: 1,
                    max: labels.length.toDouble(),
                    min: 1,
                    textStyle: const TextStyle(
                      color: Renk.pastelKoyuMavi,
                      fontSize: 10.0,
                    ),
                  ),
                  y: ChartAxisSettingsAxis(
                    frequency: 1000.0,
                    max:
                        [
                          values.reduce((a, b) => a > b ? a : b),
                          valuesiki.reduce((a, b) => a > b ? a : b),
                        ].reduce((a, b) => a > b ? a : b) +
                        100,
                    min: 0.0,
                    textStyle: const TextStyle(
                      color: Renk.pastelKoyuMavi,
                      fontSize: 10.0,
                    ),
                  ),
                ),
                labelX: (value) => labels[value.toInt() - 1],
                labelY: (value) => value.toInt().toString(),
              ),
              // Grup Bar Katmanı
              ChartGroupBarLayer(
                items:
                    values
                        .asMap()
                        .entries
                        .map(
                          (entry) => <ChartGroupBarDataItem>[
                            // İlk çubuk: `values`
                            ChartGroupBarDataItem(
                              color: Renk.pastelKoyuMavi,
                              value: entry.value,
                              x: entry.key.toDouble() + 1,
                            ),
                            // İkinci çubuk: `valuesiki`
                            ChartGroupBarDataItem(
                              color: Renk.pastelAcikMavi,
                              value: valuesiki[entry.key],
                              x: entry.key.toDouble() + 1,
                            ),
                          ],
                        )
                        .toList(),
                settings: const ChartGroupBarSettings(
                  radius: BorderRadius.all(Radius.circular(4.0)),
                  thickness: 8.0,
                ),
              ),
              // Tooltip Katmanı
              ChartTooltipLayer(
                shape:
                    () => ChartTooltipBarShape<ChartGroupBarDataItem>(
                      backgroundColor: Colors.white,
                      currentPos: (item) => item.currentValuePos,
                      currentSize: (item) => item.currentValueSize,
                      onTextValue:
                          (item) => '${item.value.toStringAsFixed(2)} TL',
                      marginBottom: 6.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      radius: 6.0,
                      textStyle: const TextStyle(
                        color: Renk.pastelKoyuMavi,
                        fontSize: 12.0,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
