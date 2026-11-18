import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion/motion.dart';

/// Two sharp peaks for the logo tile.
class RidgeMarkPainter extends CustomPainter {
  const RidgeMarkPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final p = Path()
      ..moveTo(0, s.height)
      ..lineTo(s.width * 0.36, s.height * 0.12)
      ..lineTo(s.width * 0.55, s.height * 0.52)
      ..lineTo(s.width * 0.70, s.height * 0.30)
      ..lineTo(s.width, s.height);
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, s.width * 0.11)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(RidgeMarkPainter old) => false;
}

/// Layered mountain ridgelines (Pamir) drawn as crisp vector lines, back ranges fainter.
/// On first show the lines draw themselves from left to right once — the page's one
/// authored moment. Reduced motion shows them finished.
class PamirRidges extends StatefulWidget {
  const PamirRidges({super.key, this.color = Colors.white});

  final Color color;

  @override
  State<PamirRidges> createState() => _PamirRidgesState();
}

class _PamirRidgesState extends State<PamirRidges> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _RidgesPainter(progress: reduced ? 1 : Motion.easeOut.transform(_c.value), color: widget.color),
      ),
    );
  }
}

class _RidgesPainter extends CustomPainter {
  _RidgesPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  // Each range: points as (x 0..1, y 0..1 from the top of the band).
  static const _ranges = [
    [
      (0.0, 0.62),
      (0.08, 0.48),
      (0.15, 0.55),
      (0.24, 0.30),
      (0.31, 0.42),
      (0.40, 0.22),
      (0.47, 0.36),
      (0.56, 0.18),
      (0.63, 0.34),
      (0.72, 0.26),
      (0.80, 0.44),
      (0.88, 0.32),
      (1.0, 0.50),
    ],
    [
      (0.0, 0.74),
      (0.10, 0.60),
      (0.19, 0.68),
      (0.30, 0.46),
      (0.39, 0.58),
      (0.50, 0.40),
      (0.58, 0.55),
      (0.69, 0.42),
      (0.78, 0.60),
      (0.90, 0.52),
      (1.0, 0.66),
    ],
    [
      (0.0, 0.86),
      (0.14, 0.74),
      (0.26, 0.82),
      (0.38, 0.66),
      (0.52, 0.78),
      (0.64, 0.64),
      (0.77, 0.76),
      (0.89, 0.70),
      (1.0, 0.80),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var r = 0; r < _ranges.length; r++) {
      final pts = _ranges[r];
      final path = Path()..moveTo(pts.first.$1 * size.width, pts.first.$2 * size.height);
      for (final (x, y) in pts.skip(1)) {
        path.lineTo(x * size.width, y * size.height);
      }
      // Back ranges start a little later and stay fainter.
      final t = ((progress - r * 0.12) / (1 - r * 0.12)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: [0.22, 0.34, 0.55][r])
        ..style = PaintingStyle.stroke
        ..strokeWidth = [1.2, 1.4, 1.8][r]
        ..strokeJoin = StrokeJoin.round;
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * t), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RidgesPainter old) => old.progress != progress || old.color != color;
}
