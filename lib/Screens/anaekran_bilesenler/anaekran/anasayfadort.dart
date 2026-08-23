import 'dart:convert';
import 'dart:io';

import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Altdort ana widget'ı, "Destek Ol" sayfasını temsil eder
class Altdort extends StatefulWidget {
  const Altdort({super.key});

  @override
  State<Altdort> createState() => _AltdortState();
}

class _AltdortState extends State<Altdort> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdNotifier = ValueNotifier<bool>(false);
  List<dynamic> _destekVerileri = []; // Sponsor verileri
  bool _isLoading = true; // Yükleme durumu
  bool _hasError = false; // Hata durumu

  @override
  void initState() {
    super.initState();
    // Verileri yükle
    _loadDestekVerileri();
    // Kaydırma dinleyicisi: 500px sonrası reklam göster
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 500 && !_showAdNotifier.value) {
        if (mounted) {
          _showAdNotifier.value = true;
        }
      }
    });
  }

  // Sponsor verilerini yükleme fonksiyonu
  Future<void> _loadDestekVerileri() async {
    if (_destekVerileri.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('https://kolayhesappro.com/destekson.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _destekVerileri = data is List ? data : [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showAdNotifier.dispose();
    super.dispose();
  }

  // URL başlatma fonksiyonu
  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  return true; // Gerekli kaydırma işlemleri
                }
                return false; // Diğer bildirimleri (Overscroll, vb.) durdur
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _buildBaslikBir(),
                    const SizedBox(height: 10),
                    const RepaintBoundary(child: YerelReklamuc()),
                    _buildBaslikUc(),
                    const SizedBox(height: 10),
                    _buildBaslikIki(),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showAdNotifier,
                      builder: (context, showAd, child) {
                        return showAd
                            ? const RepaintBoundary(child: YerelReklamiki())
                            : const SizedBox.shrink();
                      },
                    ),
                    _buildBaslikDort(),
                    Dekor.cizgi15,
                    _buildDestekLogo(),
                    Dekor.cizgi15,
                    _buildAltBosluk(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Bize destek olmak ister misiniz?" başlığı
  Widget _buildBaslikBir() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        "Bize destek olmak ister \n misiniz?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
      ),
    );
  }

  // "Değerlendir, yıldız ver ve paylaş" başlığı ve mağaza bağlantısı
  Widget _buildBaslikIki() {
    final Uri storeUrl =
        Platform.isIOS
            ? Uri.parse('https://apps.apple.com/app/id6739851184')
            : Uri.parse(
              'https://play.google.com/store/apps/details?id=com.kolayhesap.app',
            );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            "Değerlendir, yıldız ver\n ve paylaş",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Renk.koyuMavi,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => _launchURL(storeUrl),
            child: const Image(
              image: AssetImage('assets/images/r533.png'),
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // Sosyal medya bölümü
  Widget _buildBaslikUc() {
    return Column(
      children: [
        const Text(
          "Sosyal medya",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialMediaIcon(
                imagePath: 'assets/images/INSTAGRAM.png',
                url: 'https://www.instagram.com/kolayhesappro_/',
              ),
              _buildSocialMediaIcon(
                imagePath: 'assets/images/FACE.png',
                url:
                    'https://www.facebook.com/profile.php?id=61555554283013&mibextid=ZbWKwL',
              ),
              _buildSocialMediaIcon(
                imagePath: 'assets/images/TWITER.png',
                url:
                    'https://x.com/kolayhesappro_?t=j6Uetf_TC-kLN0wNHMrRCg&s=09',
              ),
              _buildSocialMediaIcon(
                imagePath: 'assets/images/YTUBE.png',
                url: 'https://www.youtube.com/channel/UCFx01I2ohNkrZhIkJl2Hhlg',
              ),
            ],
          ),
        ),
        const Text(
          "Paylaşarak destekleyin",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          "Paylaşımlarımızı beğenerek ve paylaşarak daha geniş kitlelere ulaşmamıza yardımcı olun.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        const Text(
          "Yorum yaparak destekleyin",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          "Düşüncelerinizi ve fikirlerinizi yorumlarda paylaşarak etkileşimi artırın.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        const Text(
          "Etiket kullanarak destekleyin",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          "Paylaşımlarınızda #hashtag kullanarak daha fazla kişiye ulaşmamızı sağlayın.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        const Text(
          "Bizi takip edin",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          "Bizi takip ederek her daim destekte bulunun \n Desteğinizle daha güçlü olalım!\n",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  // Sosyal medya ikonu oluşturur
  Widget _buildSocialMediaIcon({
    Key? key,
    required String imagePath,
    required String url,
  }) {
    return GestureDetector(
      key: key,
      onTap: () => _launchURL(Uri.parse(url)),
      child: Image(
        image: AssetImage(imagePath),
        width: 75,
        fit: BoxFit.contain,
      ),
    );
  }

  // "Buy Me a Coffee" bölümü
  Widget _buildBaslikDort() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            "Buy Me a Coffee",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Renk.koyuMavi,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap:
                () => _launchURL(
                  Uri.parse('https://buymeacoffee.com/kolayhesapc'),
                ),
            child: const Image(
              image: AssetImage('assets/images/DESTEK_LOGO.png'),
              height: 100,
              fit: BoxFit.fitHeight,
            ),
          ),
          const Text(
            "Dilediğiniz kadar kahve ısmarlayarak bize destek olabilirsiniz.\n",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  // Sponsor logoları bölümü
  Widget _buildDestekLogo() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              'Sponsor verileri yüklenirken bir hata oluştu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadDestekVerileri,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      );
    } else if (_destekVerileri.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          'Henüz sponsor bulunmamaktadır.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          "Uygulama Sponsorları",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
        Column(
          children:
              _destekVerileri.map((destek) {
                return GestureDetector(
                  onTap: () => _launchURL(Uri.parse(destek["web"])),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: CachedNetworkImage(
                      imageUrl: destek['image'],
                      width: 380,
                      fit: BoxFit.contain,
                      placeholder:
                          (context, url) => const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // Alt teşekkür metni
  Widget _buildAltBosluk() {
    return const Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 120),
      child: Text(
        "Sizlere daha iyi hizmet verebilmek için tüm gücümüzle çalışıyoruz.\n\nDesteğiniz için teşekkürler.\n",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
