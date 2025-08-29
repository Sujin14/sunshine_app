import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedSkyBackground extends StatefulWidget {
  final int selectedHour; // 0–23

  const AnimatedSkyBackground({Key? key, required this.selectedHour})
      : super(key: key);

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _sunController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat(); // slow rotation

    _cloudController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat(); // drifting clouds
  }

  @override
  void dispose() {
    _sunController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sunController, _cloudController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _SkyPainter(
            widget.selectedHour,
            _sunController.value,
            _cloudController.value,
          ),
        );
      },
    );
  }
}

class _SkyPainter extends CustomPainter {
  final int selectedHour;
  final double sunRotation; // 0–1
  final double cloudShift; // 0–1

  _SkyPainter(this.selectedHour, this.sunRotation, this.cloudShift);

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final gradientColors = _getSkyGradient(selectedHour);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawSun(Canvas canvas, Size size) {
    final sunX = size.width * _getSunXPosition(selectedHour);
    final sunY = size.height * _getSunYPosition(selectedHour);
    final center = Offset(sunX, sunY);

    // Sun glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD700).withOpacity(0.6), Colors.transparent],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 80));
    canvas.drawCircle(center, 80, glowPaint);

    // Sun body
    final sunPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, 25, sunPaint);

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const rayCount = 12;
    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * pi * i / rayCount) + (sunRotation * 2 * pi);
      final start = Offset(center.dx + cos(angle) * 35, center.dy + sin(angle) * 35);
      final end = Offset(center.dx + cos(angle) * 55, center.dy + sin(angle) * 55);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);

    // Drift offset
    final driftX = size.width * (cloudShift - 0.5) * 0.2;

    // Cloud 1
    _drawCloud(canvas, Offset(size.width * 0.3 + driftX, size.height * 0.25), cloudPaint);
    // Cloud 2
    _drawCloud(canvas, Offset(size.width * 0.7 + driftX, size.height * 0.4), cloudPaint);
    // Cloud 3
    _drawCloud(canvas, Offset(size.width * 0.5 - driftX, size.height * 0.6), cloudPaint);
  }

  void _drawCloud(Canvas canvas, Offset position, Paint paint) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: position, radius: 30))
      ..addOval(Rect.fromCircle(center: position + const Offset(35, 10), radius: 25))
      ..addOval(Rect.fromCircle(center: position + const Offset(-35, 10), radius: 25))
      ..addOval(Rect.fromCircle(center: position + const Offset(0, 20), radius: 20));

    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 8, false);
    canvas.drawPath(path, paint);
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
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.selectedHour != selectedHour ||
      oldDelegate.sunRotation != sunRotation ||
      oldDelegate.cloudShift != cloudShift;
}
