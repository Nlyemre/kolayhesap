import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Eczane extends StatefulWidget {
  const Eczane({super.key});

  @override
  State<Eczane> createState() => _EczaneState();
}

class _EczaneState extends State<Eczane> {
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
  <div style="margin:auto;text-align:center;width:100%;"><a href="https://www.eczaneler.gen.tr/" target="_blank" rel="noopener"><img src="https://www.eczaneler.gen.tr/resimler/turkiye-nobetci-eczaneleri.jpg" alt="liste" style="border-radius:3px;width:100%;margin-bottom:0px;"></a><br><iframe src="https://www.eczaneler.gen.tr/turkiye.php" name="Nöbetçi Eczaneler" style="width:100%; height:100vh;border:none;"></iframe></div>
</body>
</html>
  ''';

    await controller.loadHtmlString(htmlContent);
  }

  void _eczanegeri(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
    } else {
      geri();
    }
  }

  void geri() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Anasayfa(pozisyon: 0, tarihyenile: ""),
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final currentContext = context;
        _eczanegeri(currentContext);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.koyuMavi),

          title: const Text("Nöbetçi Eczane"),
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
      ),
    );
  }
}
