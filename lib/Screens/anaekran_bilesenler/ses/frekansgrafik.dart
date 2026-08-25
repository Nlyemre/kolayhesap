import 'dart:math' as math;

import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class FrekansGrafik extends StatefulWidget {
  final double frequency;
  final bool isPlaying; // Ses çalma durumu

  const FrekansGrafik({
    super.key,
    required this.frequency,
    required this.isPlaying,
  });

  @override
  State<FrekansGrafik> createState() => _FrequencyAnimationWidgetState();
}

class _FrequencyAnimationWidgetState extends State<FrekansGrafik>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ((1000 / widget.frequency).toInt())),
    )..repeat(); // Animasyonu sürekli tekrar et
  }

  @override
  void didUpdateWidget(covariant FrekansGrafik oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Frekans değiştiğinde animasyon süresini güncelle
    if (_controller.isAnimating) {
      _controller.stop();
      _controller.duration = Duration(
        milliseconds: (1000 / widget.frequency).toInt(),
      );
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Ekran genişliğini al
        final screenWidth = MediaQuery.of(context).size.width;
        return CustomPaint(
          size: Size(screenWidth, 150),
          painter: FrequencyPainter(
            _controller.value,
            widget.frequency,
            widget.isPlaying,
          ),
        );
      },
    );
  }
}

class FrequencyPainter extends CustomPainter {
  final double animationValue;
  final double frequency;
  final bool isPlaying; // Ses çalma durumu

  FrequencyPainter(this.animationValue, this.frequency, this.isPlaying);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Renk.pastelKoyuMavi
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final path = Path();

    final centerY = size.height / 2;

    if (isPlaying) {
      // Ses çalıyorsa normal dalga hareketini çiz
      final amplitude = size.height / 2; // Dalganın yüksekliği

      // Frekans değerini normalize et (20-15000 arasında)
      final normalizedFrequency = frequency.clamp(
        20,
        15000,
      ); // 20 Hz - 15000 Hz arasında sınırla

      // Logaritmik ölçeklendirme için dalga boyunu ayarla
      final wavelength = _calculateWavelength(
        normalizedFrequency.toDouble(),
        size.width,
      );

      for (double x = 0; x < size.width; x += 1) {
        // Dalga boyunu başta yumuşak, sonlara doğru yavaş yavaş artan bir şekilde ayarla
        final waveFactor = math.sin(
          (x / size.width) * math.pi,
        ); // Başta ve sonda dalga boyunu değiştir
        final smoothFactor = math.pow(
          waveFactor,
          2,
        ); // Yumuşak geçiş için kare al

        final y =
            centerY +
            amplitude *
                math.sin(
                  (x / wavelength * 2 * math.pi) + animationValue * 2 * math.pi,
                ) *
                smoothFactor;

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    } else {
      // Ses çalmıyorsa çok ufak dalgalanmalar oluştur
      final smallAmplitude = size.height / 30; // Çok küçük genlik
      final wavelength = size.width / 3; // Sabit dalga boyu

      for (double x = 0; x < size.width; x += 1) {
        final y =
            centerY +
            smallAmplitude *
                math.sin(
                  (x / wavelength * 2 * math.pi) + animationValue * 2 * math.pi,
                );

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  // Dalga boyunu logaritmik olarak ölçeklendir
  double _calculateWavelength(double frequency, double screenWidth) {
    final minFrequency = 20;
    final maxFrequency = 15000;
    final threshold = 1000; // 1000 Hz'e kadar olan kısım

    if (frequency <= threshold) {
      // 20 Hz ile 1000 Hz arası: Doğrusal ölçeklendirme
      final linearScale =
          (frequency - minFrequency) / (threshold - minFrequency);
      return screenWidth / (1 + linearScale * 9); // Dalga boyunu yavaşça artır
    } else {
      // 1000 Hz ile 15000 Hz arası: Logaritmik ölçeklendirme
      final minLog = math.log(threshold);
      final maxLog = math.log(maxFrequency);
      final scale = (maxLog - minLog) / (maxFrequency - threshold);

      final logScale = math.log(frequency) * scale;
      return screenWidth / (10 + logScale * 90); // Dalga boyunu hızla artır
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
