import 'package:app/Screens/anaekran_bilesenler/kidem/kidem.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_4.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/girisveriler.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KidemGiris extends StatefulWidget {
  const KidemGiris({super.key});

  @override
  State<KidemGiris> createState() => _KidemGirisState();
}

class _KidemGirisState extends State<KidemGiris> {
  final _kidemikramiyeKontrol = TextEditingController();
  final _kidemBurutKontrol = TextEditingController();
  final _kidemyemekKontrol = TextEditingController();
  final _kidemizinKontrol = TextEditingController();

  String aySayi = DateFormat('M').format(DateTime.now());
  String simdikiYil = DateFormat('yyyy').format(DateTime.now());
  String simdikiTarih = DateFormat(
    'dd MMMM yyyy',
    'tr_TR',
  ).format(DateTime.now());
  String girisTarihi = "";
  String cikisTarihi = "";
  late DateTime girisData;
  late DateTime cikisData;
  int gunn = 0;
  double kidemUstSinirr = 0;
  double izintutar = 0;
  int kidemSayi = 0;
  int kdvSayi = 1;

  final List<String> kidemListe = [
    '0',
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
  ];
  final List<String> kdvListe = ['% 15', '% 20', '% 27', '% 35', '% 40'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    _kidemcekal();
    kidemUstSinirr = GirisVerileri2026.kidemUstSinir;
  }

  @override
  void dispose() {
    _kidemikramiyeKontrol.dispose();
    _kidemBurutKontrol.dispose();
    _kidemyemekKontrol.dispose();
    _kidemizinKontrol.dispose();
    super.dispose();
  }

  void _klavyeyiKapat() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  void _kayityap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kidemBrüt', _kidemBurutKontrol.text);
    await prefs.setString('kidemikramiye', _kidemikramiyeKontrol.text);
    await prefs.setString('kidemYemek', _kidemyemekKontrol.text);
    await prefs.setString('kidemİzin', _kidemizinKontrol.text);
    await prefs.setString('KidemiseGiris', girisTarihi);
    await prefs.setInt('kdvsayi', kdvSayi);
    await prefs.setInt('kidemsayi', kidemSayi);
  }

  void _kidemcekal() async {
    final prefs = await SharedPreferences.getInstance();
    final iseGirisyedek = prefs.getString('iseGirisDate') ?? simdikiTarih;
    final iseGirisDateString =
        prefs.getString('KidemiseGiris') ?? iseGirisyedek;

    final burutCagir = prefs.getString('kidemBrüt') ?? '0.0';
    final ikramiye = prefs.getString('kidemikramiye') ?? '0.0';
    final yemek = prefs.getString('kidemYemek') ?? '0.0';
    final izin = prefs.getString('kidemİzin') ?? '0.0';
    final kdv = prefs.getInt('kdvsayi') ?? 1;
    final kidem = prefs.getInt('kidemsayi') ?? 0;

    final simdi = DateTime.now();
    DateFormat tarih = DateFormat('dd MMMM yyyy', 'tr_TR');
    DateTime gir = tarih.parse(iseGirisDateString);
    girisData = gir;
    cikisData = simdi;
    girisTarihi = tarih.format(girisData);
    cikisTarihi = tarih.format(simdi);
    kdvSayi = kdv;
    kidemSayi = kidem;

    _kidemBurutKontrol.text = burutCagir;
    _kidemikramiyeKontrol.text = ikramiye;
    _kidemyemekKontrol.text = yemek;
    _kidemizinKontrol.text = izin;

    setState(() {});
  }

  void _hesaplama() {
    Duration tarihAl = cikisData.difference(girisData);
    gunn = tarihAl.inDays;

    double brutbir = double.parse(
      _kidemBurutKontrol.text.isEmpty ? "0" : _kidemBurutKontrol.text,
    );
    double ikramiye = double.parse(
      _kidemikramiyeKontrol.text.isEmpty ? "0" : _kidemikramiyeKontrol.text,
    );
    if (ikramiye > 0) ikramiye = ikramiye / 12;
    double yol = double.parse(
      _kidemyemekKontrol.text.isEmpty ? "0" : _kidemyemekKontrol.text,
    );
    double izin = double.parse(
      _kidemizinKontrol.text.isEmpty ? "0" : _kidemizinKontrol.text,
    );
    izintutar = izin > 0 ? (brutbir / 30) * izin : 0;

    double brut = yol + ikramiye + brutbir;
    double kidemUcretEger = brut > kidemUstSinirr ? kidemUstSinirr : brut;

    int kidemIhbarGun =
        gunn < 180
            ? 14
            : gunn > 181 && gunn < 547
            ? 28
            : gunn > 548 && gunn < 1095
            ? 42
            : 56;

    final kdvv =
        kdvSayi == 0
            ? 15
            : kdvSayi == 1
            ? 20
            : kdvSayi == 2
            ? 27
            : kdvSayi == 3
            ? 35
            : 40;

    List<double> kidemListeRakam = List<double>.generate(11, (int index) => 0);
    kidemListeRakam[0] = 0;
    kidemListeRakam[1] = kidemUcretEger;
    kidemListeRakam[2] = (kidemUcretEger / 365) * gunn;
    kidemListeRakam[3] = kidemListeRakam[2] * 0.00759;
    kidemListeRakam[4] = kidemListeRakam[2] - kidemListeRakam[3];
    kidemListeRakam[5] = 0;
    kidemListeRakam[6] =
        ((brut / 30) * (kidemIhbarGun + (kidemSayi * 28))) + izintutar;
    kidemListeRakam[7] = (kidemListeRakam[6] / 100) * kdvv;
    kidemListeRakam[8] = kidemListeRakam[6] * 0.00759;
    kidemListeRakam[9] =
        kidemListeRakam[6] - (kidemListeRakam[7] + kidemListeRakam[8]);
    kidemListeRakam[10] = kidemListeRakam[4] + kidemListeRakam[9];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Kidem(
              kidemveri0: gunn.toString(),
              kidemveri1: kidemListeRakam[1].toStringAsFixed(2),
              kidemveri2: kidemListeRakam[2].toStringAsFixed(2),
              kidemveri3: kidemListeRakam[3].toStringAsFixed(2),
              kidemveri4: kidemListeRakam[4].toStringAsFixed(2),
              kidemveri5: kidemIhbarGun,
              kidemveri6: kidemListeRakam[6].toStringAsFixed(2),
              kidemveri7: kidemListeRakam[7].toStringAsFixed(2),
              kidemveri8: kidemListeRakam[8].toStringAsFixed(2),
              kidemveri9: kidemListeRakam[9].toStringAsFixed(2),
              kidemveri10: kidemListeRakam[10].toStringAsFixed(2),
              kidemveri11: kdvSayi,
              kidemveri12: kidemSayi.toString(),
              kidemveri13: kidemSayi * 28,
              kidemveri14: izin.toString(),
              kidemveri15: izintutar.toString(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Kıdem Tazminatı"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 13,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "İşe Giriş Tarihi",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              locale: const Locale('tr', 'TR'),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                girisTarihi = DateFormat(
                                  'dd MMMM yyyy',
                                  'tr_TR',
                                ).format(pickedDate);
                                girisData = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            girisTarihi,
                            style: const TextStyle(
                              color: Renk.pastelKoyuMavi,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Dekor.cizgi15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          " İşten Çıkış Tarihi",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                cikisTarihi = DateFormat(
                                  'dd MMMM yyyy',
                                  'tr_TR',
                                ).format(pickedDate);
                                cikisData = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            cikisTarihi,
                            style: const TextStyle(
                              color: Renk.pastelKoyuMavi,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: RepaintBoundary(child: YerelReklamdort()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                    child: MetinKutusu(
                      controller: _kidemBurutKontrol,
                      labelText: 'Aylık Brüt Maaş (gerekli)',
                      hintText: '0,00 TL',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: MetinKutusu(
                      controller: _kidemikramiyeKontrol,
                      labelText: 'Yıllık Toplam İkramiye (opsiyonel)',
                      hintText: '0,00 TL',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: MetinKutusu(
                      controller: _kidemyemekKontrol,
                      labelText: 'Aylık Yol Ve Yemek Ücreti (opsiyonel)',
                      hintText: '0,00 TL',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 10,
                      right: 10,
                      bottom: 15,
                    ),
                    child: MetinKutusu(
                      controller: _kidemizinKontrol,
                      labelText: 'Kullanılmayan İzin Gün (opsiyonel)',
                      hintText: '0,00 TL',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {},
                      clearButtonVisible: true,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: RepaintBoundary(child: YerelReklamuc()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'İhbar Kdv Oranı Seç',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _internetYokDialog(
                                  ' Çalışanın ihbar tazminatından kesilecek gelir vergisi oranı, yıllık gelirine göre belirlenir ve farklı vergi dilimlerine göre değişiklik gösterir. Kullanıcının, kendi yıllık toplam gelirine uygun vergi dilimini seçmesi gerekmektedir, çünkü bu seçim ihbar tazminatından yapılacak vergi kesintisini doğrudan etkiler. Kullanıcı, yıllık gelirine göre uygun vergi dilimini seçtikten sonra, bu dilim doğrultusunda ihbar tazminatından yapılacak gelir vergisi kesintisi hesaplanır. Bu sayede, kullanıcı doğru vergi dilimini seçerek ihbar tazminatının doğru ve net bir şekilde hesaplanmasını sağlar.',
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10, right: 5),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Renk.pastelKoyuMavi,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Renk.pastelKoyuMavi,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (kdvSayi > 0) kdvSayi--;
                                });
                              },
                            ),
                            SizedBox(
                              width: 45,
                              child: Text(
                                kdvListe[kdvSayi],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Renk.pastelKoyuMavi,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (kdvSayi < kdvListe.length - 1) {
                                    kdvSayi++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Dekor.cizgi15,
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Fazladan İhbar Ekle',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _internetYokDialog(
                                  "  İşverenin çalışanı işten çıkarırken sadece yasal yükümlülüklerini yerine getirmesi yeterli olmayabilir. Bazı durumlarda, işveren, çalışanın dava açmaması veya gelecekte herhangi bir talepte bulunmaması için anlaşmalı olarak ihbar tazminatına ek bir ödeme yapar.\n  Bu ekstra ihbar tazminatı, işveren ile çalışan arasında hukuki bir anlaşmazlığı önlemek adına sunulan bir tazminattır ve karşılıklı anlaşmaya dayanır.\n\n Her bir ihbar 28 gün olarak kidem yılına göre kazanılmış ihbar gününe eklenir",
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10, right: 5),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Renk.pastelKoyuMavi,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Renk.pastelKoyuMavi,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (kidemSayi > 0) kidemSayi--;
                                });
                              },
                            ),
                            SizedBox(
                              width: 45,
                              child: Text(
                                kidemListe[kidemSayi],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Renk.pastelKoyuMavi,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (kidemSayi < kidemListe.length - 1) {
                                    kidemSayi++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 10,
                      right: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _klavyeyiKapat();
                        double sayi = double.parse(
                          _kidemBurutKontrol.text.isEmpty
                              ? "0"
                              : _kidemBurutKontrol.text,
                        );
                        if (sayi > 0) {
                          if (girisTarihi == cikisTarihi) {
                            Mesaj.altmesaj(
                              context,
                              'Lütfen İşe Giriş Tarihi Giriniz',
                              Colors.red,
                            );
                          } else {
                            _kayityap();
                            _hesaplama();
                          }
                        } else {
                          Mesaj.altmesaj(
                            context,
                            'Lütfen Aylık Brüt Maaş Giriniz',
                            Colors.red,
                          );
                        }
                      },
                      child: Renk.buton('Tazminatı Hesapla', 50),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }

  void _internetYokDialog(String aciklama) {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'Bilgilendirme',
      content: aciklama,
      buttonText: 'Kapat',
      onButtonPressed: () async {
        Navigator.of(context).pop();
      },
    );
  }
}
