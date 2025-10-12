import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamaylardetay.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GrafikWidget extends StatefulWidget {
  final List<num> grafiknett;
  final List<num> grafikkesintii;
  final List<num> burutt;
  final List<List<String>> saattablo;
  final List<num> saatsonn;
  final List<num> calismasaatii;
  final num sayfaSecimiGelenn;
  final List<num> bes;

  const GrafikWidget({
    super.key,
    required this.grafiknett,
    required this.grafikkesintii,
    required this.burutt,
    required this.saattablo,
    required this.saatsonn,
    required this.calismasaatii,
    required this.sayfaSecimiGelenn,
    required this.bes,
  });

  @override
  State<GrafikWidget> createState() => _GrafikWidgetState();
}

class _GrafikWidgetState extends State<GrafikWidget> {
  late List<double> netMaasWidths;
  late NumberFormat _numberFormat;

  @override
  void initState() {
    super.initState();

    _numberFormat = NumberFormat("#,##0.00", "tr_TR");
    netMaasWidths = List.filled(12, 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        for (int i = 0; i < 12; i++) {
          num toplam = widget.grafiknett[i] + widget.grafikkesintii[i].abs();
          if (toplam == 0) toplam = 1;
          netMaasWidths[i] =
              (widget.grafiknett[i] / toplam) *
              (MediaQuery.of(context).size.width * 0.91);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            _buildLegend(),
            Dekor.cizgi15,
            ...List.generate(12, (index) {
              // İndeks 1 ve 11 için özel widget'lar ekleyin
              if (index == 0) {
                return Column(
                  children: [
                    _buildMonthRow(index),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: RepaintBoundary(child: YerelReklam()),
                    ),
                  ],
                );
              }
              if (index == 9) {
                return Column(
                  children: [
                    _buildMonthRow(index),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: RepaintBoundary(child: YerelReklamiki()),
                    ),
                  ],
                );
              }
              return _buildMonthRow(index);
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20,
            width: 20,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              gradient: Renk.gradient,
              borderRadius: BorderRadius.all(Radius.circular(1.0)),
            ),
          ),
          const Text(
            '   Net Maaş       ',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          ),
          Container(
            height: 20,
            width: 20,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Renk.acikMavi, Renk.acikMavi],
                begin: Alignment(1.0, -1.0),
                end: Alignment(1.0, 1.0),
              ),
              borderRadius: BorderRadius.all(Radius.circular(1.0)),
            ),
          ),
          const Text(
            '   Kesintiler',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(int index) {
    final toplam =
        widget.grafiknett[index] + widget.grafikkesintii[index].abs();
    final netMaasRatio = widget.grafiknett[index] / (toplam == 0 ? 1 : toplam);
    final kesintilerRatio =
        widget.grafikkesintii[index] > 0
            ? widget.grafikkesintii[index] / toplam
            : 1;

    return GestureDetector(
      onTap: () => _navigateToDetail(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthHeader(index),
          _buildProgressBar(index, netMaasRatio, kesintilerRatio),
          _buildPercentageRow(netMaasRatio, kesintilerRatio),
          Dekor.cizgi15,
        ],
      ),
    );
  }

  Widget _buildMonthHeader(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            aylarYazi[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Row(
            children: [
              const Text(
                'Brüt Toplam : ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Renk.koyuMavi,
                ),
              ),
              Text(
                '${_numberFormat.format(widget.burutt[index])} TL',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    int index,
    double netMaasRatio,
    num kesintilerRatio,
  ) {
    return Stack(
      children: [
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              width: netMaasWidths[index],
              height: 40,
              decoration: const BoxDecoration(
                gradient: Renk.gradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                ),
              ),
              child: Center(
                child: Text(
                  _numberFormat.format(widget.grafiknett[index]),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: (kesintilerRatio * 100).round(),
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Renk.acikMavi, Renk.acikMavi],
                    begin: Alignment(1.0, -1.0),
                    end: Alignment(1.0, 1.0),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    _numberFormat.format(widget.grafikkesintii[index].abs()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPercentageRow(double netMaasRatio, num kesintilerRatio) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '% ${(netMaasRatio * 100).toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Text(
            '% ${(kesintilerRatio * 100).toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZamaylarDetay(
              aydetay0: widget.saattablo[0][index],
              aydetay1: widget.saattablo[1][index],
              aydetay2: widget.saattablo[2][index],
              aydetay3: widget.saattablo[3][index],
              aydetay4: widget.saattablo[4][index],
              aydetay5: widget.saattablo[5][index],
              aydetay6: widget.saattablo[6][index],
              aydetay7: widget.saattablo[7][index],
              aydetay8: widget.saattablo[8][index],
              aydetay9: widget.saattablo[9][index],
              aydetay10: widget.saattablo[10][index],
              aydetay11: widget.saattablo[11][index],
              aydetay12: widget.saattablo[12][index],
              aydetay13: widget.saattablo[13][index],
              aydetay14: widget.saattablo[14][index],
              aydetay15: widget.saattablo[15][index],
              aydetay16: "${aylarBuyuk[index]} DETAYLAR",
              aydetay17: widget.sayfaSecimiGelenn.toString(),
              aydetay18: widget.grafikkesintii[index].toStringAsFixed(2),
              aydetay19: (widget.saatsonn[index] * widget.calismasaatii[index])
                  .toStringAsFixed(2),
              aydetay20: widget.bes[index].toString(),
            ),
      ),
    );
  }

  final List<String> aylarYazi = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  final List<String> aylarBuyuk = [
    'OCAK',
    'ŞUBAT',
    'MART',
    'NİSAN',
    'MAYIS',
    'HAZİRAN',
    'TEMMUZ',
    'AĞUSTOS',
    'EYLÜL',
    'EKİM',
    'KASIM',
    'ARALIK',
  ];
}
