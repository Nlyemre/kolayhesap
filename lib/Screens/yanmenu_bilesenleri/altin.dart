import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AltinSayfasi extends StatefulWidget {
  const AltinSayfasi({super.key});

  @override
  State<AltinSayfasi> createState() => _AltinSayfasiState();
}

class _AltinSayfasiState extends State<AltinSayfasi>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> altinler = {};
  bool yukleniyor = true;
  String? hata;

  // Göstermek istediğimiz altın türleri (sırayla, popüler olanlar önce)
  final List<String> altinKodlari = [
    'GA', // Gram Altın
    '22', // 22 Ayar Bilezik (gram)
    'C', // Çeyrek Altın
    'Y', // Yarım Altın
    'T', // Tam Altın
    'ATA', // Ata Altın
    'CMR', // Cumhuriyet Altını
    'GR', // Gremse Altın
    'RA', // Reşat Altın
    'HA', // Hamit Altın
    '14', // 14 Ayar
    '18', // 18 Ayar
    'XAUUSD', // Ons Altın (USD)
  ];

  final Map<String, String> altinIsimleri = {
    'GA': 'Gram Altın',
    '22': '22 Ayar Bilezik (Gram)',
    'C': 'Çeyrek Altın',
    'Y': 'Yarım Altın',
    'T': 'Tam Altın',
    'ATA': 'Ata Altın',
    'CMR': 'Cumhuriyet Altını',
    'GR': 'Gremse Altın',
    'RA': 'Reşat Altın',
    'HA': 'Hamit Altın',
    '14': '14 Ayar Altın',
    '18': '18 Ayar Altın',
    'XAUUSD': 'Ons Altın',
  };

  final String altinEmoji = '🪙';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    altinGetir();
  }

  Future<void> altinGetir() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.genelpara.com/json/?list=altin&sembol=all'),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          altinler = decoded['data'] ?? {};
          yukleniyor = false;
          hata = null;
        });
      } else {
        setState(() {
          hata = 'Sunucu hatası: ${res.statusCode}';
          yukleniyor = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hata = 'Bağlantı hatası: $e';
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),
        title: const Text('Canlı Altın Fiyatları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Renk.pastelKoyuMavi),
            onPressed: () {
              setState(() => yukleniyor = true);
              altinGetir();
            },
          ),
        ],
      ),
      body:
          yukleniyor
              ? const Center(child: CircularProgressIndicator())
              : hata != null
              ? Center(child: Text(hata!))
              : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: altinGetir,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: altinKodlari.length,
                        itemBuilder: (context, index) {
                          final kod = altinKodlari[index];
                          final veri = altinler[kod];
                          if (veri == null) return const SizedBox.shrink();

                          final degisim =
                              double.tryParse(
                                veri['degisim']?.toString() ?? '0',
                              ) ??
                              0;

                          final paraBirimi = veri['sembol'] ?? '₺';

                          return CizgiliCerceve(
                            golge: 5,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$altinEmoji ${altinIsimleri[kod] ?? kod}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Alış: ${veri['alis']} $paraBirimi  |  Satış: ${veri['satis']} $paraBirimi',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        degisim >= 0
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color:
                                            degisim >= 0
                                                ? Colors.green
                                                : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${degisim >= 0 ? "+" : ""}${veri['degisim'] ?? '0'}%',
                                        style: TextStyle(
                                          color:
                                              degisim >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const RepaintBoundary(child: BannerReklamiki()),
                ],
              ),
    );
  }
}
