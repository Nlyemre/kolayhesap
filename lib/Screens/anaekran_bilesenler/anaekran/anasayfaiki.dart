import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamgiris.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Anagrafik extends StatefulWidget {
  final CircularBottomNavigationController navigationController;
  final int pozisyon;

  const Anagrafik({
    super.key,
    required this.navigationController,
    required this.pozisyon,
  });

  @override
  State<Anagrafik> createState() => _AnagrafikState();
}

class _AnagrafikState extends State<Anagrafik>
    with SingleTickerProviderStateMixin {
  late AnimationController _kontrolor;
  late Animation<double> _animasyon;
  List<double> netOdeme = List.generate(12, (index) => 0.0);

  final int simdikiAySayi = int.parse(DateFormat('M').format(DateTime.now()));
  final String simdikiYil = DateFormat('yyyy').format(DateTime.now());
  final int simdikiGun = min(
    30,
    int.parse(DateFormat('d').format(DateTime.now())),
  );
  final String simdikiAy = DateFormat('MMMM', 'tr_TR').format(DateTime.now());

  double simdikiNetGrafik = 0.0;
  double ekranTutar = 0.0;
  double ekranNet = 0.0;
  final int gunSayisi = 30;
  double degerAyarla = 0.0;

  @override
  void initState() {
    super.initState();
    _kontrolor = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animasyon = Tween<double>(begin: 0.0, end: 0.0).animate(_kontrolor);
    // NavigationController'ı dinle
    widget.navigationController.addListener(_onTabChanged);

    // İlk açılışta animasyonu başlat
    if (widget.navigationController.value == widget.pozisyon) {
      _kontrolor.forward();
    }
    Future.microtask(_verileriYukle);
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final tempNetOdeme = List<double>.filled(12, 0.0);
    for (int i = 0; i < 12; i++) {
      tempNetOdeme[i] = prefs.getDouble('$simdikiYil-$i-netmaas') ?? 0.0;
    }

    double ayarSayi = 0.0;
    if (simdikiGun >= 1 && simdikiGun <= 14) {
      ayarSayi = 0.07 - ((simdikiGun - 1) * (0.07 / 15));
      degerAyarla = (simdikiGun / gunSayisi) - ayarSayi;
    } else if (simdikiGun >= 15 && simdikiGun <= 30) {
      ayarSayi = ((simdikiGun - 15) * (0.04 / 15));
      degerAyarla = (simdikiGun / gunSayisi) + ayarSayi;
    }

    if (mounted) {
      setState(() {
        netOdeme = tempNetOdeme;
        simdikiNetGrafik = (4.7 * degerAyarla).clamp(0.0, 4.7);
        ekranTutar = (netOdeme[simdikiAySayi - 1] / gunSayisi) * simdikiGun;
        ekranNet = netOdeme[simdikiAySayi - 1];
        _animasyon = Tween<double>(
          begin: 0.0,
          end: simdikiNetGrafik,
        ).animate(CurvedAnimation(parent: _kontrolor, curve: Curves.easeOut));
        // Animasyonu yalnızca sayfa seçiliyse başlat
        if (widget.navigationController.value == widget.pozisyon &&
            !_kontrolor.isAnimating) {
          _kontrolor.forward(from: 0.0);
        }
      });
    }
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (widget.navigationController.value == widget.pozisyon) {
      // Bu sayfa aktif, animasyonu başlat
      if (!_kontrolor.isAnimating) {
        _kontrolor.forward();
      }
    } else {
      // Bu sayfa aktif değil, animasyonu durdur
      if (_kontrolor.isAnimating) {
        _kontrolor.stop();
      }
    }
  }

  @override
  void dispose() {
    _kontrolor.dispose();
    widget.navigationController.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildNetMaasKards(),
            _buildGrafik(),
            _buildPreviousNextMonthKards(),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: RepaintBoundary(child: YerelReklamalti()),
            ),
            _buildBilgilendirme(),
          ],
        ),
      ),
    );
  }

  // Başlık ve veri girişi butonu
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Kazanılmış Net Maaş",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const ZamGiris(id: 2, grafikid: 3, sayfa: 1),
                  ),
                );
              },
              child: const Text(
                'Grafik Veri Girişi',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kart widget'ı oluşturur
  Widget kartHazirBeyaz({
    required String baslikli,
    required String degerli,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: onTap,
          child: CizgiliCerceve(
            golge: 5,
            backgroundColor: Renk.acikgri,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    baslikli,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    degerli,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Renk.koyuMavi,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Net maaş kartları
  Widget _buildNetMaasKards() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          kartHazirBeyaz(
            baslikli: 'Şimdiki Net Maaş',
            degerli:
                '${NumberFormat("#,##0.00", "tr_TR").format(ekranTutar)} TL',
          ),
          kartHazirBeyaz(
            baslikli: 'Ay Sonu Net Maaş',
            degerli: '${NumberFormat("#,##0.00", "tr_TR").format(ekranNet)} TL',
          ),
        ],
      ),
    );
  }

  // Grafik bölümü
  Widget _buildGrafik() {
    return Column(
      children: [
        Text(
          aylarBuyuz[simdikiAySayi - 1],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: AnimatedBuilder(
            animation: _animasyon,
            builder: (context, child) {
              return CustomPaint(
                painter: Grafik(
                  animation: _animasyon.value,
                  simdikideger: ekranTutar,
                  ekrantext: (_animasyon.value / 4.7) * ekranNet,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Önceki ve sonraki ay kartları
  Widget _buildPreviousNextMonthKards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    aylarBuyuz[simdikiAySayi == 1 ? 11 : simdikiAySayi - 2],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    aylarBuyuz[simdikiAySayi == 12 ? 0 : simdikiAySayi],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              kartHazirBeyaz(
                baslikli: 'Önceki Ay Net',
                degerli:
                    simdikiAySayi == 1
                        ? '0.00 TL'
                        : '${NumberFormat("#,##0.00", "tr_TR").format(netOdeme[simdikiAySayi - 2])} TL',
              ),
              kartHazirBeyaz(
                baslikli: 'Sonraki Ay Net',
                degerli:
                    simdikiAySayi == 12
                        ? '0.00 TL'
                        : '${NumberFormat("#,##0.00", "tr_TR").format(netOdeme[simdikiAySayi])} TL',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bilgilendirme metni
  Widget _buildBilgilendirme() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 120, top: 20),
      child: Column(
        children: [
          Text(
            'Bilgilendirme',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Renk.koyuMavi,
            ),
          ),
          Dekor.cizgi15,
          SizedBox(height: 10),
          Text(
            "Bu ekran, kullanıcıların aylık maaşlarının gün bazında nasıl dağıldığını görmelerini sağlar. Aylık maaşınız, 30 güne bölünerek her bir gün için ne kadar kazandığınızı gösterir. Grafikte, içinde bulunduğunuz günün maaşı ayrı olarak vurgulanmıştır. Bu sayede, günün sonunda ne kadar kazandığınızı kolayca takip edebilirsiniz.\n\nAylık maaşınızı günlük hesaplama yapabilmek için lütfen grafik veri girişinden aylık maaş bilgilerinizi giriniz.\n\nYapmış olduğunuz fazla mesai kazançlarını günlük hesaba dahil edebilmek için tekrar grafik veri girişinden hesaplama yaparak verilerin güncellenmesini sağlayınız.",
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static const List<String> aylarBuyuz = [
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

// Grafik çizimi için özel painter
class Grafik extends CustomPainter {
  final double animation;
  final double simdikideger;
  final double ekrantext;

  const Grafik({
    required this.animation,
    required this.simdikideger,
    required this.ekrantext,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    final shadowRadius = radius + 3;
    final gapRadius = radius - 5;
    final innerRadius = radius - 30;

    // Gölge yay
    final shadowPaint =
        Paint()
          ..color = const Color.fromRGBO(0, 0, 0, 0.1)
          ..strokeWidth = 30
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: shadowRadius),
      2.35,
      4.70,
      false,
      shadowPaint,
    );

    // Beyaz boşluk
    final gapPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 35
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: gapRadius),
      2.35,
      4.70,
      false,
      gapPaint,
    );

    // Ana yay için degrade
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment(-1.0, 1.0),
            end: Alignment(1.0, -1.0),
            colors: [Renk.acikMavi, Renk.koyuMavi],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = 30
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // İlerleme göstergesi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35,
      animation,
      false,
      paint,
    );

    // İç daire
    final innerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerPaint);

    // Çizgiler ve sayılar
    final linePaint =
        Paint()
          ..color = const Color.fromRGBO(0, 0, 0, 0.1)
          ..strokeWidth = 2;

    const double lineLength = 16;
    final double innerLineRadius = gapRadius - 28;
    int number = 24;
    const double textOffset = 10;

    for (int i = 0; i < 12; i++) {
      final double angle = (2 * pi / 12) * i;
      final double startX = center.dx + innerLineRadius * cos(angle);
      final double startY = center.dy + innerLineRadius * sin(angle);
      final double endX =
          center.dx + (innerLineRadius + lineLength) * cos(angle);
      final double endY =
          center.dy + (innerLineRadius + lineLength) * sin(angle);

      linePaint.color =
          (i == 2 || i == 3 || i == 4)
              ? Colors.white
              : const Color.fromRGBO(0, 0, 0, 0.1);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);

      final numberColor =
          (i == 2 || i == 3 || i == 4)
              ? Colors.white
              : const Color.fromARGB(255, 196, 195, 195);

      final double textX =
          center.dx + (innerLineRadius - textOffset) * cos(angle);
      final double textY =
          center.dy + (innerLineRadius - textOffset) * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$number',
          style: TextStyle(color: numberColor, fontSize: 12),
        ),
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
      number += 3;
      if (number == 36) {
        number = 0;
      }
    }

    // Ortadaki metin
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${NumberFormat("#,##0.00", "tr_TR").format(ekrantext)}\nTL',
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // "Bugün" metni
    final todayTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Bugün',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    todayTextPainter.layout();
    todayTextPainter.paint(
      canvas,
      Offset(
        (size.width - todayTextPainter.width) / 2,
        (size.height - todayTextPainter.height) / 2 + 80,
      ),
    );

    // Tarih metni
    final dateTextPainter = TextPainter(
      text: TextSpan(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        style: const TextStyle(fontSize: 15, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    dateTextPainter.layout();
    dateTextPainter.paint(
      canvas,
      Offset(
        (size.width - dateTextPainter.width) / 2,
        (size.height - dateTextPainter.height) / 2 + 110,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant Grafik oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.simdikideger != simdikideger;
  }
}
