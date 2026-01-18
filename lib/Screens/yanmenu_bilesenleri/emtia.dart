import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmtiaSayfasi extends StatefulWidget {
  const EmtiaSayfasi({super.key});

  @override
  State<EmtiaSayfasi> createState() => _EmtiaSayfasiState();
}

class _EmtiaSayfasiState extends State<EmtiaSayfasi>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> emtialar = {};
  bool yukleniyor = true;
  String? hata;

  // Popüler emtialar önce (petrol, değerli metaller, tarım vb.)
  final List<String> emtiaKodlari = [
    'XBRUSD', // Brent Petrol
    'NGAS', // Doğal Gaz
    'XAGUSD', // Gümüş (Ons)
    'XPTUSD', // Platin (Ons)
    'XPDUSD', // Paladyum (Ons)
    'COPPER', // Bakır
    'COCOA', // Kakao
    'COFFEE', // Kahve
    'CORN', // Mısır
    'WHEAT', // Buğday
    'SOYBEAN', // Soya Fasulyesi
    'COTTON', // Pamuk
    'SUGAR', // Şeker
    'COIL', // Çelik Bobin (Coil)
  ];

  final Map<String, String> emtiaIsimleri = {
    'XBRUSD': 'Brent Petrol',
    'NGAS': 'Doğal Gaz',
    'XAGUSD': 'Gümüş (Ons)',
    'XPTUSD': 'Platin (Ons)',
    'XPDUSD': 'Paladyum (Ons)',
    'COPPER': 'Bakır',
    'COCOA': 'Kakao',
    'COFFEE': 'Kahve',
    'CORN': 'Mısır',
    'WHEAT': 'Buğday',
    'SOYBEAN': 'Soya Fasulyesi',
    'COTTON': 'Pamuk',
    'SUGAR': 'Şeker',
    'COIL': 'Çelik Bobin',
  };

  final Map<String, String> emtiaEmojileri = {
    'XBRUSD': '🛢️',
    'NGAS': '🔥',
    'XAGUSD': '🥈',
    'XPTUSD': '🔘',
    'XPDUSD': '⚪',
    'COPPER': '🟤',
    'COCOA': '🍫',
    'COFFEE': '☕',
    'CORN': '🌽',
    'WHEAT': '🌾',
    'SOYBEAN': '🫘',
    'COTTON': '👕',
    'SUGAR': '🍚',
    'COIL': '🌀',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    emtiaGetir();
  }

  Future<void> emtiaGetir() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.genelpara.com/json/?list=emtia&sembol=all'),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          emtialar = decoded['data'] ?? {};
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
        title: const Text('Canlı Emtia Fiyatları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Renk.pastelKoyuMavi),
            onPressed: () {
              setState(() => yukleniyor = true);
              emtiaGetir();
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
                      onRefresh: emtiaGetir,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: emtiaKodlari.length,
                        itemBuilder: (context, index) {
                          final kod = emtiaKodlari[index];
                          final veri = emtialar[kod];
                          if (veri == null) return const SizedBox.shrink();

                          final String degisimStr = veri['degisim'] ?? '0.00';
                          final bool isUp = degisimStr.startsWith('+');
                          final bool isDown = degisimStr.startsWith('-');

                          final String paraBirimi = veri['sembol'] ?? '\$';
                          final String emoji = emtiaEmojileri[kod] ?? '📦';

                          return CizgiliCerceve(
                            golge: 5,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Emoji (yuvarlak)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emtiaIsimleri[kod] ?? kod,
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
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        isUp
                                            ? Icons.trending_up
                                            : isDown
                                            ? Icons.trending_down
                                            : Icons.trending_flat,
                                        color:
                                            isUp
                                                ? Colors.green
                                                : isDown
                                                ? Colors.red
                                                : Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$degisimStr%',
                                        style: TextStyle(
                                          color:
                                              isUp
                                                  ? Colors.green
                                                  : isDown
                                                  ? Colors.red
                                                  : Colors.grey,
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
