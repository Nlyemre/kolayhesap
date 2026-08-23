import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Hava extends StatefulWidget {
  const Hava({super.key});

  @override
  State<Hava> createState() => _HavaState();
}

class _HavaState extends State<Hava> {
  String secilenYill = '';
  bool isLoading = true; // Sayfa yüklenme durumunu izleyen değişken
  String secilenSehir = 'Kocaeli';
  late WebViewController controller;

  final Map<String, String> ilKodlari = {
    "Adana": "wl3090",
    "Adıyaman": "wl5939",
    "Afyon": "wl5946",
    "Ağrı": "wl5782",
    "Amasya": "wl5794",
    "Ankara": "wl3006",
    "Antalya": "wl3994",
    "Aydın": "wl1493",
    "Balıkesir": "wl2175",
    "Bilecik": "wl5856",
    "Bingöl": "wl5793",
    "Bitlis": "wl5858",
    "Bolu": "wl5770",
    "Burdur": "wl5813",
    "Bursa": "wl5738",
    "Çanakkale": "wl5789",
    "Çankırı": "wl5817",
    "Çorum": "wl5754",
    "Denizli": "wl1509",
    "Diyarbakır": "wl5742",
    "Edirne": "wl5762",
    "Elazığ": "wl1584",
    "Erzincan": "wl5796",
    "Erzurum": "wl5747",
    "Eskişehir": "wl5741",
    "Gaziantep": "wl4575",
    "Giresun": "wl5791",
    "Hakkari": "wl5820",
    "Hatay": "wl5942",
    "Isparta": "wl5759",
    "Mersin": "wl5740",
    "İstanbul": "wl3197",
    "İzmir": "wl2985",
    "Kars": "wl5805",
    "Kastamonu": "wl1106",
    "Kayseri": "wl3400",
    "Kırklareli": "wl5819",
    "Kırşehir": "wl5774",
    "Kocaeli": "wl5931",
    "Konya": "wl5739",
    "Kütahya": "wl5753",
    "Malatya": "wl5745",
    "Manisa": "wl5749",
    "Kahramanmaraş": "wl5926",
    "Mardin": "wl5801",
    "Muğla": "wl5826",
    "Muş": "wl5812",
    "Nevşehir": "wl5797",
    "Niğde": "wl5775",
    "Ordu": "wl5764",
    "Rize": "wl5784",
    "Sakarya": "wl5924",
    "Samsun": "wl5743",
    "Siirt": "wl5767",
    "Sinop": "wl5874",
    "Sivas": "wl5750",
    "Tekirdağ": "wl5761",
    "Tokat": "wl5769",
    "Trabzon": "wl3339",
    "Tunceli": "wl5897",
    "Şanlıurfa": "wl5744",
    "Uşak": "wl5758",
    "Van": "wl4395",
    "Yozgat": "wl5814",
    "Zonguldak": "wl5776",
    "Aksaray": "wl1740",
    "Bayburt": "wl5887",
    "Karaman": "wl5765",
    "Kırıkkale": "wl5757",
    "Batman": "wl1294",
    "Şırnak": "wl5821",
    "Bartın": "wl5845",
    "Iğdır": "wl5806",
    "Yalova": "wl5790",
    "Karabük": "wl5777",
    "Kilis": "wl5804",
    "Osmaniye": "wl5756",
    "Düzce": "wl2276",
  };

  final List<String> sehirListe = [
    "Adana",
    "Adıyaman",
    "Afyon",
    "Ağrı",
    "Amasya",
    "Ankara",
    "Antalya",
    "Artvin",
    "Aydın",
    "Balıkesir",
    "Bilecik",
    "Bingöl",
    "Bitlis",
    "Bolu",
    "Burdur",
    "Bursa",
    "Çanakkale",
    "Çankırı",
    "Çorum",
    "Denizli",
    "Diyarbakır",
    "Edirne",
    "Elazığ",
    "Erzincan",
    "Erzurum ",
    "Eskişehir",
    "Gaziantep",
    "Giresun",
    "Gümüşhane",
    "Hakkari",
    "Hatay",
    "Isparta",
    "Mersin",
    "İstanbul",
    "İzmir",
    "Kars",
    "Kastamonu",
    "Kayseri",
    "Kırklareli",
    "Kırşehir",
    "Kocaeli",
    "Konya",
    "Kütahya ",
    "Malatya",
    "Manisa",
    "Kahramanmaraş",
    "Mardin",
    "Muğla",
    "Muş",
    "Nevşehir",
    "Niğde",
    "Ordu",
    "Rize",
    "Sakarya",
    "Samsun",
    "Siirt",
    "Sinop",
    "Sivas",
    "Tekirdağ",
    "Tokat",
    "Trabzon  ",
    "Tunceli",
    "Şanlıurfa",
    "Uşak",
    "Van",
    "Yozgat",
    "Zonguldak",
    "Aksaray",
    "Bayburt ",
    "Karaman",
    "Kırıkkale",
    "Batman",
    "Şırnak",
    "Bartın",
    "Ardahan",
    "Iğdır",
    "Yalova",
    "Karabük ",
    "Kilis",
    "Osmaniye ",
    "Düzce",
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');

    _initializeWebViewController();
    _sehirCagir();
  }

  void _initializeWebViewController() {
    controller =
        WebViewController()
          ..enableZoom(true)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    isLoading =
                        false; // Sayfa yüklendiğinde yükleme göstergesini gizle
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    isLoading =
                        true; // Sayfa yüklenmeye başladığında yükleme göstergesini göster
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    isLoading =
                        false; // Hata durumunda yükleme göstergesini gizle
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          );

    final now = DateTime.now();
    final yill = DateFormat('dd/MM/yyyy ,EEEE');
    secilenYill = yill.format(now);
    _loadHtmlContent();
  }

  void _sehirCagir() async {
    final prefs = await SharedPreferences.getInstance();
    final sehirValue = prefs.getString('sehir') ?? 'Kocaeli';
    setState(() {
      secilenSehir = sehirValue;
    });
  }

  void _sehirKaydet() async {
    if (secilenSehir.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sehir', secilenSehir);
    }
  }

  void _loadHtmlContent() async {
    final key = ilKodlari[secilenSehir];
    String htmlContent = '''
    <!DOCTYPE html>
<html lang="en">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body, html {
      margin: 0;
      padding: 0;
      height: 100%;
      width: 100%;
    }
    iframe {
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
  <h3 style="font-family:Times;">$secilenYill</h3><h2 style="font-family:Times;">Günlük Hava Durumu</h2><div id="ww_0e7832e879d4c" v='1.3' loc='id' a='{"t":"horizontal","lang":"tr","sl_lpl":1,"ids":["$key"],"font":"Arial","sl_ics":"one_a","sl_sot":"celsius","cl_bkg":"image","cl_font":"#FFFFFF","cl_cloud":"#FFFFFF","cl_persp":"#81D4FA","cl_sun":"#FFC107","cl_moon":"#FFC107","cl_thund":"#FF5722"}'>Daha fazla hava durumu tahmini: <a href="https://oneweather.org/tr/istanbul/15_days/" id="ww_0e7832e879d4c_u" target="_blank">Hava durumu 15 günlük</a></div><script async src="https://app2.weatherwidget.org/js/?id=ww_0e7832e879d4c"></script><h2 style="font-family:Times;">Haftalık Hava Durumu</h2><div id="ww_6351d4274f587" v='1.3' loc='id' a='{"t":"responsive","lang":"tr","sl_lpl":1,"ids":["$key"],"font":"Arial","sl_ics":"one_a","sl_sot":"celsius","cl_bkg":"image","cl_font":"#FFFFFF","cl_cloud":"#FFFFFF","cl_persp":"#81D4FA","cl_sun":"#FFC107","cl_moon":"#FFC107","cl_thund":"#FF5722","sl_tof":"5"}'>Daha fazla hava durumu tahmini: <a href="https://oneweather.org/tr/istanbul/15_days/" id="ww_6351d4274f587_u" target="_blank">Hava durumu 15 günlük</a></div><script async src="https://app2.weatherwidget.org/js/?id=ww_6351d4274f587"></script><br><br><br>
</body>
</html>
  ''';
    await controller.loadHtmlString(htmlContent);
  }

  void _ayDialog() {
    AcilanPencere.show(
      context: context,
      title: 'Şehir Seçiniz',
      height: 0.9,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: sehirListe.length,
          separatorBuilder:
              (context, index) =>
                  const Divider(color: Renk.cita, height: 0, thickness: 1),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                sehirListe[index],
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  secilenSehir = sehirListe[index];
                  _loadHtmlContent();
                  _sehirKaydet();
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _aylarSec() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _ayDialog();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                      width: 1,
                      color: const Color.fromARGB(255, 98, 98, 98),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      secilenSehir,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Renk.koyuMavi,
                        fontWeight: FontWeight.w500,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Hava Durumu"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 8, left: 8),
            child: _aylarSec(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, right: 15, left: 15),
              child:
                  isLoading
                      ? const Center(
                        child:
                            CircularProgressIndicator(), // Yüklenme göstergesi
                      )
                      : WebViewWidget(controller: controller),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }
}
