import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Altin extends StatefulWidget {
  const Altin({super.key});

  @override
  State<Altin> createState() => _AltinState();
}

class _AltinState extends State<Altin> {
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
    <iframe src="https://api.genelpara.com/iframe/?symbol=altin&altin=GA,C,Y,T,CMR,XAU/USD,ATA,14,18,22,GR,GAG,BSL,IKB,HA,XAUEUR&stil=stil-8&renk=beyaz" title="Altın Fiyatları" frameborder="0" style="width:100%; height:100vh;"></iframe>
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

        title: const Text("Altin & Kur"),
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
