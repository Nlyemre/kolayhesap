import 'dart:convert';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Izinler extends StatefulWidget {
  const Izinler({super.key});

  @override
  State<Izinler> createState() => _IzinlerState();
}

class _IzinlerState extends State<Izinler> {
  List<String> izinlerMetinListe = [];
  List<double> izinlerGunListe = [];

  final _kalanIzinKontrol = TextEditingController();
  final _kullanilanIzinKontrol = TextEditingController();
  final _toplamIzinKontrol = TextEditingController();
  final _toplamIzinEkran = TextEditingController();
  final _izinGunKontrol = TextEditingController();
  final _tarihController = TextEditingController();

  int _secilenIndex = 100;
  String tarihIzinler = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String yil = DateFormat('yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('tr_TR');
    _izinleriCagir();
  }

  @override
  void dispose() {
    // Kontrolcüleri temizle
    _kalanIzinKontrol.dispose();
    _kullanilanIzinKontrol.dispose();
    _toplamIzinKontrol.dispose();
    _toplamIzinEkran.dispose();
    _izinGunKontrol.dispose();
    _tarihController.dispose();
    super.dispose();
  }

  void tarih() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );

    if (pickedDate != null) {
      setState(() {
        _tarihController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        tarihIzinler = _tarihController.text;
      });
    }
  }

  void _izinleriCagir() async {
    final prefs = await SharedPreferences.getInstance();
    final kullanilanCagir = prefs.getDouble('kullanilanIzin') ?? 0.0;
    final toplamCagir = prefs.getDouble('toplamIzin') ?? 15;

    String metinJson = prefs.getString('mesaiMetinListe') ?? '[]';
    String gunJson = prefs.getString('mesaiGunListe') ?? '[]';

    double hesapla = toplamCagir - kullanilanCagir;

    _kalanIzinKontrol.text = hesapla.toString();
    _kullanilanIzinKontrol.text = kullanilanCagir.toString();
    _toplamIzinEkran.text = toplamCagir.toString();

    izinlerMetinListe = List<String>.from(jsonDecode(metinJson));
    izinlerGunListe = List<double>.from(
      jsonDecode(gunJson).map((x) => x.toDouble()),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _izinEkle() async {
    final prefs = await SharedPreferences.getInstance();
    final kullanilanKaydet = double.parse(_kullanilanIzinKontrol.text);
    final toplamKaydet = double.parse(_toplamIzinEkran.text);

    final kullanilanArti =
        kullanilanKaydet + double.parse(_izinGunKontrol.text);
    _kullanilanIzinKontrol.text = kullanilanArti.toString();

    final kalanKaydet = toplamKaydet - kullanilanArti;
    _kalanIzinKontrol.text = kalanKaydet.toString();

    izinlerMetinListe.add(
      "- $tarihIzinler Tarihinde ${_izinGunKontrol.text} Gün İzin Kullanıldı.",
    );
    izinlerGunListe.add(double.parse(_izinGunKontrol.text));

    await prefs.setDouble('kullanilanIzin', kullanilanArti);
    await prefs.setString('mesaiMetinListe', jsonEncode(izinlerMetinListe));
    await prefs.setString('mesaiGunListe', jsonEncode(izinlerGunListe));

    if (mounted) {
      setState(() {});
    }
  }

  void _izinKaldir() async {
    final prefs = await SharedPreferences.getInstance();
    final kullanilanKaldir = double.parse(_kullanilanIzinKontrol.text);
    final toplamKaldir = double.parse(_toplamIzinEkran.text);
    final izinListeGun = izinlerGunListe[_secilenIndex];

    final kullanilanEksi = kullanilanKaldir - izinListeGun;
    _kullanilanIzinKontrol.text = kullanilanEksi.toString();

    final kalanKaydet = toplamKaldir - kullanilanEksi;
    _kalanIzinKontrol.text = kalanKaydet.toString();

    izinlerMetinListe.removeAt(_secilenIndex);
    izinlerGunListe.removeAt(_secilenIndex);

    await prefs.setDouble('kullanilanIzin', kullanilanEksi);
    await prefs.setString('mesaiMetinListe', jsonEncode(izinlerMetinListe));
    await prefs.setString('mesaiGunListe', jsonEncode(izinlerGunListe));

    if (mounted) {
      setState(() {
        _secilenIndex = 100;
      });
    }
  }

  void toplamizinkaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final toplamKaydet = double.parse(_toplamIzinEkran.text);
    await prefs.setDouble('toplamIzin', toplamKaydet);
    _izinleriCagir();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Anasayfa(pozisyon: 0, tarihyenile: ""),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
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
              icon: const Icon(Icons.share, size: 20.0, color: Renk.koyuMavi),
            ),
          ],
          leading: const BackButton(color: Renk.koyuMavi),

          title: const Text("İzinler"),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _toplamizin(),
                    ),
                    Dekor.cizgi15,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Kartt.kartHazir(
                            baslik: 'Kalan\nİzin',
                            deger: _kalanIzinKontrol.text,
                          ),
                          Kartt.kartHazir(
                            baslik: 'Kullanılan\nİzin',
                            deger: _kullanilanIzinKontrol.text,
                          ),
                          Kartt.kartHazir(
                            baslik: 'Toplam\nİzin',
                            deger: _toplamIzinEkran.text,
                          ),
                        ],
                      ),
                    ),
                    Dekor.cizgi15,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: _izinlerUstButonlar(),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: RepaintBoundary(child: YerelReklam()),
                    ),
                    _izinlerListeBaslik(),
                    _izinlerListe(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            const RepaintBoundary(child: BannerReklamuc()),
          ],
        ),
      ),
    );
  }

  void _bilgiDialog(String aciklama) {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'Bilgilendirme',
      content: aciklama,
      buttonText: 'Kapat',
    );
  }

  Widget _toplamizin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "$yil Yil'ı Toplam İzin",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            IconButton(
              onPressed: () {
                _bilgiDialog(
                  "Hak ettiğiniz yıllık izin gün sayısını düzenle kısmından ekrana girebilir, kalan izin sürenizi hesaplayabilirsiniz.",
                );
              },
              icon: const Icon(Icons.info_outline, color: Renk.koyuMavi),
            ),
          ],
        ),
        GestureDetector(
          onTap: _toplamizinDialog,
          child: const CizgiliCerceve(
            golge: 5,
            padding: EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 6),
            child: Text(
              "Düzenle",
              style: TextStyle(
                color: Renk.koyuMavi,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _izinlerUstButonlar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_secilenIndex == 100) {
                Mesaj.altmesaj(
                  context,
                  'Lütfen Listeden Kaldırmak İstediğiniz Öğeyi Seçiniz.',
                  Colors.red,
                );
              } else {
                _izinKaldir();
                Mesaj.altmesaj(
                  context,
                  "${izinlerGunListe[_secilenIndex]} Gün izin Kaldırıldı",
                  Colors.green,
                );
              }
            },
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: Renk.gradient,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: const Center(
                child: Text(
                  "KALDIR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_toplamIzinEkran.text.isEmpty ||
                  _toplamIzinEkran.text == "0.0" ||
                  _toplamIzinEkran.text == "0") {
                Mesaj.altmesaj(
                  context,
                  'Lütfen Toplam İzin Giriniz.',
                  Colors.red,
                );
              } else {
                _izinGunKontrol.text = "";
                _izinEkleDialog();
              }
            },
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: Renk.gradient,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: const Center(
                child: Text(
                  "EKLE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _izinlerListeBaslik() {
    return Container(
      height: 40,
      color: Renk.koyuMavi.withValues(alpha: 0.1),
      child: const Center(
        child: Text(
          "Kullanılan İzin Listesi",
          style: TextStyle(
            fontSize: 15,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _izinlerListe() {
    if (izinlerMetinListe.isEmpty) {
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(
            "$yil yılı kayıtlı izin gününüz bulunmamaktadır.",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ),
      );
    }
    return Column(
      children: List.generate(izinlerMetinListe.length, (index) {
        return GestureDetector(
          onTap: () => setState(() => _secilenIndex = index),
          child: Container(
            color:
                _secilenIndex == index
                    ? Renk.koyuMavi.withValues(alpha: 0.06)
                    : Colors.white,
            child: ListTile(
              title: Text(
                izinlerMetinListe[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _izinEkleDialog() {
    _tarihController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    AcilanPencere.show(
      context: context,
      title: 'İzin Tarih ve Gün Seç',
      height: 0.9,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                tarih();
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _tarihController,
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: izingunSecimListe.length,
                separatorBuilder:
                    (context, index) => const Divider(
                      color: Renk.cita,
                      height: 5,
                      thickness: 1,
                    ),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      izingunSecimListe[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      tarihIzinler = _tarihController.text;
                      Navigator.pop(context); // BottomSheet'i kapat
                      _izinGunKontrol.text = izingunSecimListe[index];
                      Mesaj.altmesaj(
                        context,
                        "${_izinGunKontrol.text.toString()} Gün İzin Eklendi",
                        Colors.green,
                      );
                      _izinEkle();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> izingunSecimListe = [
    '0.5',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
  ];

  void _toplamizinDialog() {
    AcilanPencere.show(
      context: context,
      title: "Toplam İzin Gün Kaydet",
      height: 0.8,
      showAd: false,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 15),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              MetinKutusu(
                controller: _toplamIzinKontrol,
                labelText: "Toplam İzin Gün",
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                clearButtonVisible: true,
                onChanged: (value) {},
                hintText: '',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Renk.buton('İptal', 45),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_toplamIzinKontrol.text.isEmpty ||
                            _toplamIzinKontrol.text == "0.0" ||
                            _toplamIzinKontrol.text == "0") {
                          Mesaj.altmesaj(
                            context,
                            'Lütfen Toplam İzin Giriniz.',
                            Colors.red,
                          );
                        } else {
                          _toplamIzinEkran.text = _toplamIzinKontrol.text;
                          toplamizinkaydet();
                          Mesaj.altmesaj(
                            context,
                            "Toplam İzin ${_toplamIzinEkran.text} Gün Olarak Değiştirildi",
                            Colors.green,
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: Renk.buton('Kaydet', 45),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  textAlign: TextAlign.center,
                  'Yıllık olarak kullanabileceğiniz toplam izin gün sayısını buraya girin.Örneğin: 14, 20, 30 Bu bilgi, kullandığınız izinleri takip etmenize ve kalan izin günlerinizi kolayca görmenize yardımcı olur.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              const RepaintBoundary(child: YerelReklamuc()),
            ],
          ),
        ),
      ),
    );
  }

  void _paylasPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Izin Listesi"),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: izinlerMetinListe.length,
                itemBuilder: (context, index) {
                  return pw.Text(replaceTurkishChars(izinlerMetinListe[index]));
                },
              ),
              pw.SizedBox(height: 10),
              pw.Text("Toplam Izin      : ${_toplamIzinEkran.text}"),
              pw.Text("Kullanilan Izin  : ${_kullanilanIzinKontrol.text}"),
              pw.Text("Kalan Izin       : ${_kalanIzinKontrol.text}"),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/izinListesi.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
  }

  String replaceTurkishChars(String input) {
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
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      "İzin Listesi",
    );

    for (int i = 0; i < izinlerMetinListe.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(izinlerMetinListe[i]);
    }

    sheetObject
        .cell(CellIndex.indexByString("A${izinlerMetinListe.length + 2}"))
        .value = TextCellValue("Toplam İzin");
    sheetObject
        .cell(CellIndex.indexByString("B${izinlerMetinListe.length + 2}"))
        .value = TextCellValue(_toplamIzinEkran.text);

    sheetObject
        .cell(CellIndex.indexByString("A${izinlerMetinListe.length + 3}"))
        .value = TextCellValue("Kullanılan İzin");
    sheetObject
        .cell(CellIndex.indexByString("B${izinlerMetinListe.length + 3}"))
        .value = TextCellValue(_kullanilanIzinKontrol.text);

    sheetObject
        .cell(CellIndex.indexByString("A${izinlerMetinListe.length + 4}"))
        .value = TextCellValue("Kalan İzin");
    sheetObject
        .cell(CellIndex.indexByString("B${izinlerMetinListe.length + 4}"))
        .value = TextCellValue(_kalanIzinKontrol.text);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/izinListesi.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file =
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'İzin Listesi Excel Paylaş',
        ),
      );
    }
  }

  void _paylas() {
    String paylas = "İzin Listesi\n";
    for (int i = 0; i < izinlerMetinListe.length; i++) {
      paylas += "${izinlerMetinListe[i]} \n";
    }
    paylas += "Toplam İzin ${_toplamIzinEkran.text}\n";
    paylas += "Kullanılan İzin ${_kullanilanIzinKontrol.text}\n";
    paylas += "Kalan İzin ${_kalanIzinKontrol.text}\n";
    SharePlus.instance.share(ShareParams(text: paylas));
  }
}
