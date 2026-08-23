import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Gizlilik extends StatefulWidget {
  const Gizlilik({super.key});

  @override
  State<Gizlilik> createState() => _GizlilikState();
}

class _GizlilikState extends State<Gizlilik> {
  bool _isLoading = true; // Yükleme durumu kontrolü için bir değişken
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
          )
          ..loadRequest(
            Uri.parse('https://kolayhesappro.com/gizlilik-politikasi/'),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Gizlilik Politikası"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
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
