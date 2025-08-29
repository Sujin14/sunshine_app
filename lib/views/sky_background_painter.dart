import 'dart:math';

import 'package:flutter/material.dart';

class SkyBackgroundPainter extends CustomPainter {
  final int selectedHour;
  SkyBackgroundPainter(this.selectedHour);

  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final gradientColors = _getSkyGradient(selectedHour);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Clouds
    _drawCloud(canvas, Offset(size.width * 0.3, size.height * 0.25), 60);
    _drawCloud(canvas, Offset(size.width * 0.7, size.height * 0.35), 80);

    // Sun with rays
    final sunX = size.width * _getSunXPosition(selectedHour);
    final sunY = size.height * _getSunYPosition(selectedHour);
    _drawSun(canvas, Offset(sunX, sunY), 40);
  }

  void _drawSun(Canvas canvas, Offset center, double radius) {
    // Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFF176).withOpacity(0.6), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2));
    canvas.drawCircle(center, radius * 2, glowPaint);

    // Sun body
    final sunPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, radius, sunPaint);

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    const rays = 24;
    for (int i = 0; i < rays; i++) {
      final angle = (2 * 3.14159 / rays) * i;
      final start = Offset(
        center.dx + radius * 1.2 * cos(angle),
        center.dy + radius * 1.2 * sin(angle),
      );
      final end = Offset(
        center.dx + radius * 1.8 * cos(angle),
        center.dy + radius * 1.8 * sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset position, double size) {
    final cloudPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: position, radius: size));

    // Multiple overlapping ovals
    canvas.drawOval(Rect.fromCenter(center: position, width: size * 1.6, height: size), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: position.translate(-size * 0.5, 10), width: size, height: size * 0.7), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: position.translate(size * 0.5, 10), width: size, height: size * 0.8), cloudPaint);
  }

  List<Color> _getSkyGradient(int hour) {
    if (hour <= 9) {
      return [const Color(0xFFFFCCBC), const Color(0xFFFFF3E0)];
    } else if (hour <= 15) {
      return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
    } else {
      return [const Color(0xFFFFB300), const Color(0xFFAB47BC)];
    }
  }

  double _getSunXPosition(int hour) {
    if (hour <= 7) return 0.2;
    if (hour >= 19) return 0.8;
    return 0.2 + (hour - 7) * (0.6 / 12);
  }

  double _getSunYPosition(int hour) {
    if (hour <= 7 || hour >= 19) return 0.5;
    final t = (hour - 7) / 12;
    return 0.5 - 0.4 * (1 - (2 * t - 1) * (2 * t - 1));
  }

  @override
  bool shouldRepaint(covariant SkyBackgroundPainter oldDelegate) =>
      oldDelegate.selectedHour != selectedHour;
}
