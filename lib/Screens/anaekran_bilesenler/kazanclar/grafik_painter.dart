// lib/Screens/anaekran_bilesenler/kazanclar/widgets/grafik_painter.dart
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GrafikPainter extends CustomPainter {
  final double animation;
  final double ekrantext;
  final String ayIsmi;

  const GrafikPainter({
    required this.animation,
    required this.ekrantext,
    required this.ayIsmi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    final shadowRadius = radius + 3;
    final gapRadius = radius - 5;
    final innerRadius = radius - 30;

    // GÖLGE
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

    // BOŞLUK
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

    // ANA ÇİZGİ
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment(-1.0, 1.0),
            end: Alignment(1.0, -1.0),
            colors: [Renk.pastelAcikMavi, Renk.pastelKoyuMavi],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = 30
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35,
      animation,
      false,
      paint,
    );

    // İÇ DAİRE
    final innerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);

    // ÇİZGİLER VE RAKAMLAR
    final linePaint = Paint()..strokeWidth = 2;
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
      if (number == 36) number = 0;
    }

    // ORTA METİN
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${NumberFormat("#,##0.00", "tr_TR").format(ekrantext)}\nTL',
        style: const TextStyle(
          fontSize: 20,
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

    // ALT METİN
    final ayTextPainter = TextPainter(
      text: TextSpan(
        text: ayIsmi,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    ayTextPainter.layout();
    ayTextPainter.paint(
      canvas,
      Offset(
        (size.width - ayTextPainter.width) / 2,
        (size.height - ayTextPainter.height) - 30,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant GrafikPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.ekrantext != ekrantext ||
        oldDelegate.ayIsmi != ayIsmi;
  }
}
