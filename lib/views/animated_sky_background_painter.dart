import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';
import '../theme/app_theme.dart';

class AnimatedSkyBackground extends StatefulWidget {
  const AnimatedSkyBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double _fractionalHour(BuildContext context) {
    try {
      final provider = Provider.of<SunshineProvider>(context, listen: false);
      return provider.selectedHour.toDouble().clamp(0.0, 23.9999);
    } catch (_) {}
    final now = DateTime.now();
    return now.hour + now.minute / 60.0 + now.second / 3600.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final fractionalHour = _fractionalHour(context);
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _SkyPainter(fractionalHour, _anim.value),
        );
      },
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double fractionalHour;
  final double tick;
  final List<_Star> _stars;

  _SkyPainter(this.fractionalHour, this.tick)
    : _stars = List.generate(60, (i) {
        final rand = Random(i);
        return _Star(
          dx: rand.nextDouble(),
          dy: rand.nextDouble() * 0.6, // top 60% only
          radius: rand.nextDouble() * 1.6 + 0.6,
          phase: rand.nextDouble() * 2 * pi,
        );
      });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);

    final hour = fractionalHour % 24;
    if (hour >= 5 && hour < 18) {
      _drawSun(canvas, size);
      _drawClouds(canvas, size);
    } else {
      _drawMoon(canvas, size);
      _drawStars(canvas, size);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final left = fractionalHour.floor().toInt() % 24;
    final right = (left + 1) % 24;
    final t = fractionalHour - fractionalHour.floor();

    final g1 = _skyGradientForHour(left);
    final g2 = _skyGradientForHour(right);

    final stops = max(g1.length, g2.length);
    final colors = List<Color>.generate(stops, (i) {
      final c1 = i < g1.length ? g1[i] : g1.last;
      final c2 = i < g2.length ? g2[i] : g2.last;
      return Color.lerp(c1, c2, t) ?? c1;
    });

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawSun(Canvas canvas, Size size) {
    double hour = fractionalHour.clamp(0.0, 23.9999);
    final mapped = ((hour - 7) / 12).clamp(0.0, 1.0);
    final x = lerpDouble(size.width * 0.2, size.width * 0.8, mapped)!;

    final yTop = size.height * 0.12;
    final yMid = size.height * 0.48;
    final curve = 1 - pow((2 * mapped - 1).abs(), 2);
    final y = yMid - curve * (yMid - yTop);

    final center = Offset(x, y);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.sunshineYellow.withOpacity(0.55),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 100));
    canvas.drawCircle(center, 100, glowPaint);

    final sunPaint = Paint()..color = AppColors.sunshineYellow;
    canvas.drawCircle(center, 30, sunPaint);

    final rayPaint = Paint()
      ..color = AppColors.sunshineAmber.withOpacity(0.95)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const rays = 14;
    for (int i = 0; i < rays; i++) {
      final angle = (2 * pi * i / rays) + (tick * 2 * pi / 8);
      final r1 = 36.0;
      final r2 = 68.0;
      final p1 = Offset(
        center.dx + cos(angle) * r1,
        center.dy + sin(angle) * r1,
      );
      final p2 = Offset(
        center.dx + cos(angle) * r2,
        center.dy + sin(angle) * r2,
      );
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    final x = size.width * 0.7;
    final y = size.height * 0.25;
    final center = Offset(x, y);

    final moonPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawCircle(center, 26, moonPaint);

    // Crescent effect
    final cutoutPaint = Paint()..color = Colors.black.withOpacity(0.85);
    canvas.drawCircle(center.translate(10, 0), 26, cutoutPaint);
  }

  void _drawStars(Canvas canvas, Size size) {
    for (final star in _stars) {
      // twinkle between 0.5–1.0 opacity
      final opacity =
          0.5 +
          0.5 * sin(2 * pi * tick * 2 + star.phase); // twinkle ~2 cycles/min
      final paint = Paint()..color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final drift = (tick - 0.5) * size.width * 0.18;
    final paint = Paint()..color = Colors.white.withOpacity(0.9);

    _drawCloud(
      canvas,
      Offset(size.width * 0.22 + drift, size.height * 0.22),
      36,
      paint,
    );
    _drawCloud(
      canvas,
      Offset(size.width * 0.68 - drift * 0.9, size.height * 0.36),
      50,
      paint,
    );
    _drawCloud(
      canvas,
      Offset(size.width * 0.50 + drift * 0.6, size.height * 0.56),
      34,
      paint,
    );
  }

  void _drawCloud(Canvas canvas, Offset pos, double s, Paint paint) {
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: pos.translate(-s * 0.42, 0),
          width: s * 1.1,
          height: s * 0.72,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: pos.translate(s * 0.32, 0),
          width: s * 1.0,
          height: s * 0.76,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: pos.translate(0, s * 0.12),
          width: s * 0.95,
          height: s * 0.6,
        ),
      )
      ..addOval(Rect.fromCenter(center: pos, width: s * 1.35, height: s * 0.9));
    canvas.drawShadow(path, Colors.black.withOpacity(0.14), 8, false);
    canvas.drawPath(path, paint);
  }

  List<Color> _skyGradientForHour(int hour) {
    if (hour >= 0 && hour < 5) {
      return [
        Colors.black,
        const Color.fromARGB(255, 69, 69, 69),
        const Color.fromARGB(255, 51, 50, 50).withOpacity(0.05),
      ];
    } else if (hour >= 5 && hour < 9) {
      return [
        const Color(0xFFFFC371),
        const Color(0xFFFFE0B2),
        const Color(0xFFFFF8E1),
      ];
    } else if (hour >= 9 && hour < 15) {
      return [
        const Color(0xFF64B5F6),
        const Color(0xFF42A5F5),
        const Color(0xFF1976D2),
      ];
    } else if (hour >= 15 && hour < 18) {
      return [
        const Color(0xFFFFB74D),
        const Color(0xFFFF8A65),
        const Color(0xFFF48FB1),
      ];
    } else {
      return [
        Colors.black,
        const Color.fromARGB(255, 69, 69, 69),
        const Color.fromARGB(255, 51, 50, 50).withOpacity(0.05),
      ];
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.fractionalHour != fractionalHour || old.tick != tick;
}

// Represents a single star
class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double phase;
  _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
  });
}
