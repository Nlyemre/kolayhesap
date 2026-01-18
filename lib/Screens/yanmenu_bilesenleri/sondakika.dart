import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SonDakika extends StatefulWidget {
  const SonDakika({super.key});

  @override
  State<SonDakika> createState() => _SonDakikaState();
}

class _SonDakikaState extends State<SonDakika> {
  List<dynamic> _haberveri = [];

  @override
  void initState() {
    super.initState();

    _haberveriGuncelle();
  }

  Future<void> _haberveriGuncelle() async {
    final response = await http.get(
      Uri.parse('https://www.kolayhesappro.com/sondakikahaberler.php'),
    );
    if (response.statusCode == 200 && mounted) {
      setState(() {
        _haberveri = jsonDecode(response.body);
      });
    }
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = _haberveri.length + (_haberveri.length > 4 ? 1 : 0);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Son Dakika Haber"),
      ),
      body:
          _haberveri.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(10.0),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        // Eğer index 0'dan başlayarak 5'in katıysa reklam göster
                        if (_haberveri.length > 4 && index == 4) {
                          // Her 6. eleman reklam olacak (0 bazlı olduğu için +1)
                          return const YerelReklamalti();
                        }
                        final itemIndex =
                            (_haberveri.length > 4 && index > 4)
                                ? index - 1
                                : index;

                        if (itemIndex >= _haberveri.length) {
                          return const SizedBox.shrink();
                        }

                        final haber = _haberveri[itemIndex];

                        return GestureDetector(
                          onTap: () {
                            _launchURL(Uri.parse(haber['link']));
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: CachedNetworkImage(
                                        imageUrl: haber['resim'] ?? '',
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                          left: 10,
                                        ),
                                        child: Text(
                                          haber['baslik'] ?? '',
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Dekor.cizgi15,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const RepaintBoundary(child: BannerReklam()),
                ],
              ),
    );
  }
}
