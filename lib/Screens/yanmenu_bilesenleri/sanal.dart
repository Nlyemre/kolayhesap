import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Sanal extends StatefulWidget {
  const Sanal({super.key});

  @override
  State<Sanal> createState() => _SanalState();
}

class _SanalState extends State<Sanal> {
  bool _isLoading = true; // Yükleme durumunu kontrol eden değişken
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading =
                        false; // Sayfa yüklendiğinde yükleme göstergesini gizle
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading =
                        true; // Sayfa yüklenmeye başladığında yükleme göstergesini göster
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _isLoading =
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
    _loadHtmlContent();
  }

  void _loadHtmlContent() async {
    const String htmlContent = '''
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
  <iframe src="https://api.genelpara.com/iframe/?symbol=kripto&kripto=BTC,ETH,XRP,BNB,BCH,LTC,USDT,XAUT,NMR,CKB,DIVI,CEL,STX,BUSD,HBAR,ETN,HUSD,GT,HYN,UBT,LUNA,MATIC,HIVE,FTT,KNC,UMA,CHZ,CETH,LRC,HAV,DOT,CELO,YFI,CHSB,AVAX,UNI,AMP,CRV,AAVE,CDAI,CAKE,NEAR,RSR,ALPHA,SOL,COMP,WBTC,KSM,FIL,BAL,EGLD,RUNE,SUSHI,GRT,OCEAN,FTM,EOS,ADA,XMR,WAVES,MIOTA,OMG,MCO,XVG,VSYS,USDC,TUSD,THETA,XTZ,STEEM,SNT,SOLVE,SC,RR,REN,RVN,QKC,QNT,QTUM,NPXS,PAX,ONT,OKB,NULS,NEXO,NEX,XEM,NAS,NANO,MONA,ETP,MKR,MAID,LSK,LEO,LAMB,KCS,KMD,HT,HOT,GXC,GRIN,GNT,NRG,ELA,EGT,DOGE,ATOM,WAXP,XMX,DGB,DENT,DCR,DAI,CRO,XLINK,BTM,BCN,BTMX,BTT,BTS,BTG,BCD,BSV,AOA,REP,BAT,ARK,ARDR,ALGO,AE,ZIL,ZEN,ZEC,ZRX,ENJ,WTC,XZC,STRAT,ELF,MTH,MANA,POE,TRX,VEN,DSH,NEO,ETC,ICX,CMT,VIB,LUN,VIBE,CND,IOST,HSR,REQ,XLM,PPT&stil=stil-8&renk=beyaz" title="Kripto Paralar" frameborder="0" style="width:100%; height:100vh;"></iframe>
</body>
</html>
  ''';
    await controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Sanal Para"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: WebViewWidget(controller: controller),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          const RepaintBoundary(child: BannerReklam()),
        ],
      ),
    );
  }
}
