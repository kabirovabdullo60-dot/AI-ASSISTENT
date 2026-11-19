import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';

/// Soft aurora light behind a hero: three blurred glows in the accent colors drifting slowly.
/// It drifts for [drift] and then rests, so an idle screen never animates forever.
/// Brighter on the dark palette, a faint tint on the light ones.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, this.drift = const Duration(seconds: 14)});

  final Duration drift;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.drift)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _AuroraPainter(
            t: reduced ? 0.5 : Curves.easeInOut.transform(_c.value),
            strength: AppColors.isDark ? 0.32 : 0.12,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.strength});

  final double t;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final glows = [
      (AppColors.teal, const Offset(0.30, 0.28), const Offset(0.12, 0.06), 0.42),
      (AppColors.gold, const Offset(0.70, 0.22), const Offset(-0.10, 0.08), 0.36),
      (AppColors.purple, const Offset(0.52, 0.55), const Offset(0.06, -0.10), 0.34),
    ];
    for (final (color, start, move, r) in glows) {
      final phase = math.sin(t * math.pi);
      final c = Offset((start.dx + move.dx * phase) * size.width, (start.dy + move.dy * phase) * size.height);
      final radius = r * math.max(size.width, size.height);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: strength),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t || old.strength != strength;
}
