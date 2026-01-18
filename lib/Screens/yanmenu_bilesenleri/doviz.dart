import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DovizSayfasi extends StatefulWidget {
  const DovizSayfasi({super.key});

  @override
  State<DovizSayfasi> createState() => _DovizSayfasiState();
}

class _DovizSayfasiState extends State<DovizSayfasi>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> dovizler = {};
  bool yukleniyor = true;
  String? hata;

  // Tüm dövizler (TRY hariç, popüler olanlar önce, kalanlar alfabetik)
  final List<String> paralar = [
    // En popüler ve yüksek ilgi görenler (öncelikli sıralama)
    'USD', 'EUR', 'GBP', 'CHF', 'CAD', 'AUD', 'JPY',
    'KWD', 'BHD', 'OMR', 'SAR', 'AED', 'SGD',
    'RUB', 'CNY', 'PLN', 'DKK', 'SEK', 'NOK', 'NZD',

    // Kalanlar alfabetik sırada
    'ALL', 'ARS', 'AZN', 'BAM', 'BGN', 'BRL',
    'CLP', 'COP', 'CRC', 'DZD', 'EGP', 'GEL',
    'HKD', 'HUF', 'IDR', 'INR', 'IQD', 'IRR',
    'ISK', 'KRW', 'KZT', 'LBP', 'LKR', 'LYD',
    'MAD', 'MDL', 'MKD', 'MXN', 'MYR', 'PEN',
    'PHP', 'PKR', 'QAR', 'RON', 'RSD', 'SYP',
    'THB', 'TND', 'TWD', 'UAH', 'UYU', 'ZAR',
  ];

  final Map<String, String> bayraklar = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'CHF': '🇨🇭',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'NZD': '🇳🇿',
    'SEK': '🇸🇪',
    'NOK': '🇳🇴',
    'DKK': '🇩🇰',
    'CNY': '🇨🇳',
    'RUB': '🇷🇺',
    'SAR': '🇸🇦',
    'AED': '🇦🇪',
    'KWD': '🇰🇼',
    'BHD': '🇧🇭',
    'OMR': '🇴🇲',
    'SGD': '🇸🇬',
    'PLN': '🇵🇱',
    'ZAR': '🇿🇦',
    'ALL': '🇦🇱',
    'ARS': '🇦🇷',
    'AZN': '🇦🇿',
    'BAM': '🇧🇦',
    'BGN': '🇧🇬',
    'BRL': '🇧🇷',
    'CLP': '🇨🇱',
    'COP': '🇨🇴',
    'CRC': '🇨🇷',
    'DZD': '🇩🇿',
    'EGP': '🇪🇬',
    'GEL': '🇬🇪',
    'HKD': '🇭🇰',
    'HUF': '🇭🇺',
    'IDR': '🇮🇩',
    'INR': '🇮🇳',
    'IQD': '🇮🇶',
    'IRR': '🇮🇷',
    'ISK': '🇮🇸',
    'KRW': '🇰🇷',
    'KZT': '🇰🇿',
    'LBP': '🇱🇧',
    'LKR': '🇱🇰',
    'LYD': '🇱🇾',
    'MAD': '🇲🇦',
    'MDL': '🇲🇩',
    'MKD': '🇲🇰',
    'MXN': '🇲🇽',
    'MYR': '🇲🇾',
    'PEN': '🇵🇪',
    'PHP': '🇵🇭',
    'PKR': '🇵🇰',
    'QAR': '🇶🇦',
    'RON': '🇷🇴',
    'RSD': '🇷🇸',
    'SYP': '🇸🇾',
    'THB': '🇹🇭',
    'TND': '🇹🇳',
    'TWD': '🇹🇼',
    'UAH': '🇺🇦',
    'UYU': '🇺🇾',
  };

  final Map<String, String> paraIsimleri = {
    'USD': 'ABD Doları',
    'EUR': 'Euro',
    'GBP': 'İngiliz Sterlini',
    'CHF': 'İsviçre Frangı',
    'JPY': 'Japon Yeni',
    'CAD': 'Kanada Doları',
    'AUD': 'Avustralya Doları',
    'NZD': 'Yeni Zelanda Doları',
    'SEK': 'İsveç Kronu',
    'NOK': 'Norveç Kronu',
    'DKK': 'Danimarka Kronu',
    'CNY': 'Çin Yuanı',
    'RUB': 'Rus Rublesi',
    'SAR': 'Suudi Riyali',
    'AED': 'BAE Dirhemi',
    'KWD': 'Kuveyt Dinarı',
    'BHD': 'Bahreyn Dinarı',
    'OMR': 'Umman Riyali',
    'SGD': 'Singapur Doları',
    'PLN': 'Polonya Zlotisi',
    'ZAR': 'Güney Afrika Randı',
    'ALL': 'Arnavutluk Leki',
    'ARS': 'Arjantin Pesosu',
    'AZN': 'Azerbaycan Manatı',
    'BAM': 'Bosna Hersek Markı',
    'BGN': 'Bulgar Levası',
    'BRL': 'Brezilya Reali',
    'CLP': 'Şili Pesosu',
    'COP': 'Kolombiya Pesosu',
    'CRC': 'Kosta Rika Kolonu',
    'DZD': 'Cezayir Dinarı',
    'EGP': 'Mısır Lirası',
    'GEL': 'Gürcistan Larisi',
    'HKD': 'Hong Kong Doları',
    'HUF': 'Macar Forinti',
    'IDR': 'Endonezya Rupisi',
    'INR': 'Hindistan Rupisi',
    'IQD': 'Irak Dinarı',
    'IRR': 'İran Riyali',
    'ISK': 'İzlanda Kronu',
    'KRW': 'Güney Kore Wonu',
    'KZT': 'Kazakistan Tengesi',
    'LBP': 'Lübnan Lirası',
    'LKR': 'Sri Lanka Rupisi',
    'LYD': 'Libya Dinarı',
    'MAD': 'Fas Dirhemi',
    'MDL': 'Moldova Leyi',
    'MKD': 'Kuzey Makedonya Dinarı',
    'MXN': 'Meksika Pesosu',
    'MYR': 'Malezya Ringgiti',
    'PEN': 'Peru Solü',
    'PHP': 'Filipin Pesosu',
    'PKR': 'Pakistan Rupisi',
    'QAR': 'Katar Riyali',
    'RON': 'Rumen Leyi',
    'RSD': 'Sırp Dinarı',
    'SYP': 'Suriye Lirası',
    'THB': 'Tayland Bahtı',
    'TND': 'Tunus Dinarı',
    'TWD': 'Tayvan Doları',
    'UAH': 'Ukrayna Grivnası',
    'UYU': 'Uruguay Pesosu',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dovizGetir();
  }

  Future<void> dovizGetir() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.genelpara.com/json/?list=doviz&sembol=all'),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          dovizler = decoded['data'] ?? {};
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
        title: const Text('Canlı Döviz Kurları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Renk.pastelKoyuMavi),
            onPressed: () {
              setState(() => yukleniyor = true);
              dovizGetir();
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
                      onRefresh: dovizGetir,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: paralar.length,
                        itemBuilder: (context, index) {
                          final kod = paralar[index];
                          final veri = dovizler[kod];
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
                                        '${bayraklar[kod] ?? ''} ${paraIsimleri[kod] ?? kod}',
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
