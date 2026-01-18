import 'package:app/Screens/anaekran_bilesenler/issizlik/issizlikson.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_5.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/girisveriler.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Issizlik extends StatefulWidget {
  const Issizlik({super.key});

  @override
  State<Issizlik> createState() => _IssizlikState();
}

class _IssizlikState extends State<Issizlik> {
  final List<TextEditingController> _issizlikKontrolDetay = List.generate(
    4,
    (index) => TextEditingController(),
  );

  int cekSayi = 0;
  double issizlikBrut = 0;
  int calismaGunu = 1080;
  double issizlikNet = 0;
  int isizlikOdenegiGunu = 0;
  double asagariUcret = 0;
  String tarihIzinler = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _metinsatiral();
    initializeDateFormatting('tr_TR');
    asagariUcret = GirisVerileri2026.asgariUcret;
  }

  @override
  void dispose() {
    for (var controller in _issizlikKontrolDetay) {
      controller.dispose();
    }
    super.dispose();
  }

  void _klavyeyiKapat() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  void _hesaplama() {
    double ortalamaKazanc = issizlikBrut / 4;
    double ortalamaKazancYuzde40 = ortalamaKazanc * 0.40;
    double asgariyuzdeseksen = asagariUcret * 0.80;
    issizlikNet =
        ortalamaKazancYuzde40 > asgariyuzdeseksen
            ? asgariyuzdeseksen
            : ortalamaKazancYuzde40;
    double damgaVergisi = issizlikNet * 0.00759;
    double issizlikOdenegi = issizlikNet - damgaVergisi;
    String aygun = "";

    switch (cekSayi) {
      case 2:
        isizlikOdenegiGunu = 6;
        aygun = "6 Ay (180 Gün)";
        break;
      case 1:
        isizlikOdenegiGunu = 8;
        aygun = "8 Ay (240 Gün)";
        break;
      case 0:
        isizlikOdenegiGunu = 10;
        aygun = "10 Ay (300 Gün)";
        break;
      default:
        isizlikOdenegiGunu = 0;
        aygun = "0 Ay (0 Gün)";
    }

    double issizliktoplam = issizlikOdenegi * isizlikOdenegiGunu;
    double gunissizlik = issizlikOdenegi / 30;

    if (cekSayi == 3) {
      _internetYokDialog();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => IssizlikSon(
                issizlik0: issizlikBrut.toStringAsFixed(2),
                issizlik1: ortalamaKazanc.toStringAsFixed(2),
                issizlik2: ortalamaKazancYuzde40.toStringAsFixed(2),
                issizlik3: asgariyuzdeseksen.toStringAsFixed(2),
                issizlik4: issizlikNet.toStringAsFixed(2),
                issizlik5: damgaVergisi.toStringAsFixed(2),
                issizlik6: issizlikOdenegi.toStringAsFixed(2),
                issizlik7: aygun,
                issizlik8: issizliktoplam.toStringAsFixed(2),
                issizlik9: gunissizlik.toStringAsFixed(2),
                issizlik10: isizlikOdenegiGunu.toString(),
              ),
        ),
      );
    }
  }

  void _internetYokDialog() {
    BilgiDialog.showCustomDialog(
      context: context,
      title: 'Bilgilendirme',
      content:
          'İşsizlik maaşı alabilmek için hizmet akdinin feshinden önceki son üç yıl içinde en az 600 gün süre (20 ay) ile işsizlik sigortası primi ödemiş olmak gerekmektedir. Bu nedenle maalesef işsizlik maaşı alma hakkınız bulunmamaktadır.',
      buttonText: 'Kapat',
      onButtonPressed: () async {
        Navigator.of(context).pop();
      },
    );
  }

  void _metinsatirkaydet() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 4; i++) {
      await prefs.setString('maas$i', _issizlikKontrolDetay[i].text);
    }
    await prefs.setInt('cekgün', cekSayi);
  }

  void _metinsatiral() async {
    final prefs = await SharedPreferences.getInstance();
    final cekS = prefs.getInt('cekgün') ?? 0;
    setState(() {
      cekSayi = cekS;
      for (int i = 0; i < 4; i++) {
        final brutMaas = prefs.getString('maas$i') ?? "0.0";
        _issizlikKontrolDetay[i].text = brutMaas;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("İşsizlik Maaşı Hesapla"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _ustbaslik(),

                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: RepaintBoundary(child: YerelReklambes()),
                  ),
                  _brutsatir(),

                  _ceksatirlari(),
                  _hesaplabuton(),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RepaintBoundary(child: YerelReklamuc()),
                  ),
                  _bilgilendirme(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamiki()),
        ],
      ),
    );
  }

  Widget _ustbaslik() {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 15, top: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Son 4 Ay Brüt Maaş",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                cekSayi = 0;
                for (var controller in _issizlikKontrolDetay) {
                  controller.clear();
                }
              });
            },
            child: const CizgiliCerceve(
              golge: 5,
              padding: EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 6),
              child: Text(
                "Tümünü Temizle",
                style: TextStyle(
                  color: Renk.pastelKoyuMavi,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brutsatir() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: MetinKutusu(
              controller: _issizlikKontrolDetay[index],
              labelText: '${index + 1}.Ay Brüt Maaş',
              hintText: '0,00 TL',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && num.tryParse(value) != null) {
                  setState(() {
                    for (int i = index; i < 4; i++) {
                      if (i > 0) _issizlikKontrolDetay[i].text = value;
                    }
                  });
                }
              },
              clearButtonVisible: true,
            ),
          );
        }),
      ),
    );
  }

  final List<String> cekListe = [
    '1080 Gün Ve Üzeri',
    '900-1079 Gün Arası',
    '600-899 Gün Arası',
    '600 Günden Az',
  ];

  Widget _ceksatirlari() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 10, right: 10),
        childrenPadding: const EdgeInsets.only(left: 5),
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Son 3 Yıl Çalışma Gün Sayısı Seç",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        initiallyExpanded: true,
        children: List.generate(4, (index) {
          return CheckboxListTile(
            title: Text(
              cekListe[index],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            value: cekSayi == index,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) cekSayi = index;
              });
            },
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Renk.pastelKoyuMavi;
              }
              return null;
            }),
          );
        }),
      ),
    );
  }

  Widget _hesaplabuton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _klavyeyiKapat();
                    issizlikBrut = 0;
                    for (int i = 0; i < 4; i++) {
                      if (_issizlikKontrolDetay[i].text.isNotEmpty) {
                        issizlikBrut += double.parse(
                          _issizlikKontrolDetay[i].text,
                        );
                      }
                    }
                    if (issizlikBrut > 0) {
                      _metinsatirkaydet();
                      _hesaplama();
                    } else {
                      Mesaj.altmesaj(
                        context,
                        'Lütfen Aylık Brüt Maaş Giriniz',
                        Colors.red,
                      );
                    }
                  },
                  child: Renk.buton('İşsizlik Maaşını Hesapla', 50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bilgilendirme() {
    return Column(
      children: [
        Container(
          height: 40,
          color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
          child: const Align(
            alignment: Alignment.center,
            child: Text(
              "Sık Sorulan Sorular",
              style: TextStyle(
                fontSize: 16,
                color: Renk.pastelKoyuMavi,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: List.generate(12, (index) {
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  _bilgiBaslik(index),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 30, 30, 30),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Text(
                        _bilgiAciklama(index),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 30, 30, 30),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  String _bilgiBaslik(int index) {
    switch (index) {
      case 0:
        return 'İşsizlik maaşı nedir?';
      case 1:
        return 'İşsizlik maaşı nasıl alınır?';
      case 2:
        return 'Ödenekten kimler yararlanabilir?';
      case 3:
        return 'İşsizlik maaşı şartları nelerdir?';
      case 4:
        return 'İşsizlik maaşı nasıl hesaplanır?';
      case 5:
        return 'İşsizlik maaşı ne kadar?';
      case 6:
        return 'İşsizlik ödeneği hesaplamalarında damga vergisi oranı nedir?';
      case 7:
        return 'İşsizlik ödeneği hangi durumlarda kesilir?';
      case 8:
        return 'İşsizlik maaşı başvurusu nasıl yapılır?';
      case 9:
        return 'İlk ödeme ne zaman alınabilir?';
      case 10:
        return 'İşsizlik maaşı nereden alınır?';
      case 11:
        return 'İşsizlik maaşı kaç ay alınır?';
      default:
        return '';
    }
  }

  String _bilgiAciklama(int index) {
    switch (index) {
      case 0:
        return '4447 sayılı kanun kapsamına giren işyerlerinde bir hizmet akdine dayalı ve sigortalı olarak çalışırken bu kanunun ilgili maddelerinde belirtilen nedenlerle işini kaybeden ve kuruma başvurarak çalışmaya hazır olduğunu bildiren sigortalı işsizlere yine aynı kanunda belirtilen süre ve miktarda yapılan parasal ödemedir. Asıl adı işsizlik ödeneğidir.';
      case 1:
        return 'Ödenekten yararlanmak için hizmet akdinin feshinden sonraki 30 gün içinde başvuruda bulunmak gerekmektedir. Başvurular internet üzerinden kolayca yapılabilmektedir.';
      case 2:
        return '4447 sayılı kanun uyarınca sigortalı sayılanlardan hizmet akitleri aşağıda belirtilen işsizlik ödeneğine hak kazanma şartlarından birisine dayalı olarak sona erenler, İş Kurumuna süresi içinde şahsen başvurarak yeni bir iş almaya hazır olduklarını kaydettirmeleri ve yine bu kanunda yer alan prim ödeme koşullarını sağlamış olmaları kaydıyla ödeme almaya hak kazanırlar.';
      case 3:
        return 'Özetle \n a- İşsizlik sigortası kapsamında bir işyerinde çalışırken çalışma istek, yetenek, sağlık ve yeterliliğinde olmasına rağmen, kendi istek ve kusuru dışında işini kaybetmek, Haklı fesih durumlarında işçi kendi isteğiyle işten ayrılmasına rağmen yine de ödenekten yararlanmaya hak kazanır. Haklı feshe, işverenin ahlak ve iyi niyet hallerine uymayan davranışları sebep gösterilebilir. İş yerinin el değiştirmesi veya başkasına geçmesi, kapanması, işin veya iş yerinin niteliğinin değişmesi nedenleriyle işten çıkarılmış olmak da ödenekten yararlanmayı gerektirir. Yine işverenin işçinin hakkını ödememesi, ücretini eksik göstermesi gibi durumlarda da haklı fesih devreye girer ve istifa halinde işsizlik maaşı alınır.\nb- Hizmet akdinin sona ermesinden önceki son 120 gün hizmet akdine tabi olmak,\nc- Hizmet akdinin feshinden önceki son üç yıl içinde en az 600 gün süre ile işsizlik sigortası primi ödemiş olmak,\nd- Hizmet akdinin feshinden sonraki 30 gün içinde en yakın İŞKUR birimine şahsen ya da elektronik ortamda başvurmak,\nŞartlarının sağlanması halinde ödenekten yararlanılmaktadır.';
      case 4:
        return 'Günlük işsizlik ödeneği, sigortalının son dört aylık prime esas kazançları dikkate alınarak hesaplanan günlük ortalama brüt kazancının yüzde kırkıdır. Bu şekilde hesaplanan ödenek miktarı, 4857 sayılı İş Kanununun 39 uncu maddesine göre onaltı yaşından büyük işçiler için uygulanan aylık asgari ücretin brüt tutarının yüzde seksenini geçemez. İşsizlik maaşını güncel verilerle kolayca hesaplayabilmek için hesaplama aracımızı her zaman kullanabilirsiniz.';
      case 5:
        return 'Örneğin son 4 ayda prime esas kazançlarının aylık ortalaması 3.000 TL olan bir kişi, bu tutarın %40 ı olan 1.200 TL tutarında işsizlik maaşı alabilir. Bu tutara damga vergisi dahildir.';
      case 6:
        return 'Damga vergisi hariç herhangi bir vergi ve kesintiye tabi tutulmamaktadır. Hesaplamalarda 2013 yılı ve sonrası için damga vergisi oranı %0,759, önceki yıllar içinse %0,66 olarak uygulanmaktadır.';
      case 7:
        return 'Ödenekten yararlanmakta iken \na- Kurumca teklif edilen mesleklerine uygun ve son çalıştıkları işin ücret ve çalışma koşullarına yakın ve ikamet edilen yerin belediye mücavir alanı sınırları içinde bir işi haklı bir nedene dayanmaksızın reddeden,\nb- İşsizlik ödeneği aldığı sürede gelir getirici bir işte çalıştığı veya herhangi bir sosyal güvenlik kuruluşundan yaşlılık aylığı aldığı tespit edilen,\nc- Kurum tarafından önerilen meslek geliştirme, edindirme ve yetiştirme eğitimini haklı bir neden göstermeden reddeden veya kabul etmesine karşın devam etmeyen,\nd- Haklı bir nedene dayanmaksızın Kurum tarafından yapılan çağrıları zamanında cevaplamayan, istenilen bilgi ve belgeleri öngörülen süre içinde vermeyen,\nSigortalı işsizlerin maaşları kesilir.';
      case 8:
        return 'Başvurular İŞKUR Genel Müdürlüğü internet sitesi aracılığıyla kolayca yapılabilmektedir. İlgili sayfanın bağlantısını bu paragrafın sonunda bulabilirsiniz. Dikkat etmeniz gereken diğer bir husus ise yeni bir iş bulduktan sonra işsizlik sigortası maaşını iptal ettirmeniz gerektiğidir. Aksi takdirde yeni iş yeriniz sizi sigortalı yaptığı anda devlet sizin hem çalışıp hem de işsizlik ödeneği almaya devam ettiğinizi tespit ederek cezalı olarak aldığınız paraları faiziyle birlikte geri talep etmektedir.';
      case 9:
        return 'Ödeneğe hak kazanılan tarihi izleyen ayın sonuna kadar yapılır.';
      case 10:
        return 'PTT şubeleri tarafından her ayın sonunda aylık olarak ilgili kişinin kendisine ödenir.';
      case 11:
        return 'Hizmet akdinin sona ermesinden önceki son 120 gün hizmet akdine tabi olan sigortalılardan, son üç yıl içinde \na- 600 gün çalışanlara 180 gün,\nb- 900 gün çalışanlara 240 gün,\nc- 1080 gün çalışanlara 300 gün,\nSüre ile ödeme yapılmaktadır.';
      default:
        return '';
    }
  }
}
