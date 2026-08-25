import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KriptoSayfasi extends StatefulWidget {
  const KriptoSayfasi({super.key});

  @override
  State<KriptoSayfasi> createState() => _KriptoSayfasiState();
}

class _KriptoSayfasiState extends State<KriptoSayfasi>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> kriptolar = {};
  bool yukleniyor = true;
  String? hata;

  // Popüler kripto paralar önce, kalanlar alfabetik
  final List<String> kriptoKodlari = [
    'BTC',
    'ETH',
    'BNB',
    'SOL',
    'XRP',
    'USDT',
    'USDC',
    'DOGE',
    'ADA',
    'AVAX',
    'TRX',
    'DOT',
    'BCH',
    'NEAR',
    'MATIC',
    'LTC',
    'UNI',
    'ATOM',
    'XLINK',
    'AAVE',
    'MKR',
    'ALGO',
    'XLM',
    'FIL',
    'ICP',
    'HBAR',
    'ETC',
    'AXS',
    'MANA',
    'GRT',
    'CAKE',
    'CHZ',
    'FTM',
    'CRV',
    'COMP',
    'SUSHI',
    'FLOW',
    'BAT',
    'MIOTA',
    'BUSD',
  ];

  final Map<String, String> kriptoIsimleri = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'BNB': 'Binance Coin',
    'SOL': 'Solana',
    'XRP': 'Ripple',
    'USDT': 'Tether',
    'USDC': 'USD Coin',
    'DOGE': 'Dogecoin',
    'ADA': 'Cardano',
    'AVAX': 'Avalanche',
    'TRX': 'TRON',
    'DOT': 'Polkadot',
    'BCH': 'Bitcoin Cash',
    'NEAR': 'NEAR Protocol',
    'MATIC': 'Polygon',
    'LTC': 'Litecoin',
    'UNI': 'Uniswap',
    'ATOM': 'Cosmos',
    'XLINK': 'Chainlink',
    'AAVE': 'Aave',
    'MKR': 'Maker',
    'ALGO': 'Algorand',
    'XLM': 'Stellar',
    'FIL': 'Filecoin',
    'ICP': 'Internet Computer',
    'HBAR': 'Hedera',
    'ETC': 'Ethereum Classic',
    'AXS': 'Axie Infinity',
    'MANA': 'Decentraland',
    'GRT': 'The Graph',
    'CAKE': 'PancakeSwap',
    'CHZ': 'Chiliz',
    'FTM': 'Fantom',
    'CRV': 'Curve DAO Token',
    'COMP': 'Compound',
    'SUSHI': 'SushiSwap',
    'FLOW': 'Flow',
    'BAT': 'Basic Attention Token',
    'MIOTA': 'IOTA',
    'BUSD': 'Binance USD',
  };

  // Logo kaynağı: https://github.com/spothq/cryptocurrency-icons
  String _getLogoUrl(String kod) {
    String lowerKod = kod.toLowerCase();
    final Map<String, String> ozel = {'XLINK': 'link', 'MIOTA': 'iota'};
    String symbol = ozel[kod] ?? lowerKod;
    return 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/$symbol.png';
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    kriptoGetir();
  }

  Future<void> kriptoGetir() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.genelpara.com/json/?list=kripto&sembol=all'),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          kriptolar = decoded['data'] ?? {};
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
        title: const Text('Canlı Kripto Para Fiyatları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Renk.pastelKoyuMavi),
            onPressed: () {
              setState(() => yukleniyor = true);
              kriptoGetir();
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
                      onRefresh: kriptoGetir,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: kriptoKodlari.length,
                        itemBuilder: (context, index) {
                          final kod = kriptoKodlari[index];
                          final veri = kriptolar[kod];
                          if (veri == null) return const SizedBox.shrink();

                          final String degisimStr = veri['degisim'] ?? '0.00';
                          final bool isUp = degisimStr.startsWith('+');
                          final bool isDown = degisimStr.startsWith('-');

                          final String paraBirimi = veri['sembol'] ?? '\$';

                          final String logoUrl = _getLogoUrl(kod);

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
                                  // Logo (yuvarlak)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: Image.network(
                                        logoUrl,
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const CircularProgressIndicator(
                                            strokeWidth: 2,
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Text(
                                            '💰',
                                            style: TextStyle(fontSize: 30),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          kriptoIsimleri[kod] ?? kod,
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
