import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Teknoloji extends StatefulWidget {
  const Teknoloji({super.key});

  @override
  State<Teknoloji> createState() => _TeknolojiState();
}

class _TeknolojiState extends State<Teknoloji> {
  List<dynamic> _veri = [];

  @override
  void initState() {
    super.initState();

    _veriGuncelle();
  }

  Future<void> _veriGuncelle() async {
    final response = await http.get(
      Uri.parse('https://www.kolayhesappro.com/teknoloji_haberler.php'),
    );
    if (response.statusCode == 200 && mounted) {
      setState(() {
        _veri = jsonDecode(response.body);
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
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Teknoloji Haber"),
      ),
      body:
          _veri.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(10.0),
                      children: List.generate(
                        _veri.length + 1, // +1 for the ad
                        (index) {
                          // Reklam 5. haberden sonra gösterilecek
                          if (index == 5) {
                            return const RepaintBoundary(child: YerelReklam());
                          }

                          // Haber öğeleri sırasını ayarla
                          final itemIndex = index > 5 ? index - 1 : index;

                          // Eğer itemIndex, _veri uzunluğunu aşarsa boş bir widget döndür
                          if (itemIndex >= _veri.length) {
                            return const SizedBox.shrink();
                          }

                          final haber = _veri[itemIndex];

                          return GestureDetector(
                            onTap: () {
                              _launchURL(Uri.parse(haber['link']));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: CizgiliCerceve(
                                golge: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        haber['title'] ?? 'No Title',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CachedNetworkImage(
                                        imageUrl: haber['image'] ?? '',
                                        placeholder:
                                            (context, url) =>
                                                const SizedBox.shrink(),
                                        errorWidget:
                                            (context, url, error) =>
                                                const SizedBox.shrink(),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        haber['description'] ??
                                            'No Description',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                        textScaler: TextScaler.noScaling,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const RepaintBoundary(child: BannerReklam()),
                ],
              ),
    );
  }
}
