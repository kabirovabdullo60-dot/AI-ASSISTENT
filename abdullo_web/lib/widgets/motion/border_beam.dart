import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';

/// A short streak of light that travels around the child's border (Magic UI "Border Beam").
/// It runs [loops] laps, then rests; while [active] it keeps going (e.g. while the AI answers).
class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    this.radius = 14,
    this.loops = 2,
    this.active = false,
    this.width = 1.6,
    this.lap = const Duration(milliseconds: 3200),
  });

  final Widget child;
  final double radius;
  final int loops;
  final bool active;
  final double width;
  final Duration lap;

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.lap);
    _run();
  }

  void _run() {
    if (widget.active) {
      _c.repeat();
    } else {
      _c.repeat(count: widget.loops).whenCompleteOrCancel(() {
        if (mounted && !widget.active) _c.value = 0;
      });
    }
  }

  @override
  void didUpdateWidget(BorderBeam old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      if (widget.active) {
        _c.repeat();
      } else {
        _c.repeat(count: 1);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => CustomPaint(
        foregroundPainter: _c.isAnimating
            ? _BeamPainter(t: _c.value, radius: widget.radius, width: widget.width)
            : null,
        child: child,
      ),
    );
  }
}

class _BeamPainter extends CustomPainter {
  _BeamPainter({required this.t, required this.radius, required this.width});

  final double t;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(width / 2), Radius.circular(radius));
    final shader = SweepGradient(
      transform: GradientRotation(t * 2 * math.pi),
      colors: [
        Colors.transparent,
        Colors.transparent,
        AppColors.teal.withValues(alpha: 0.0),
        AppColors.teal,
        AppColors.gold,
        Colors.transparent,
      ],
      stops: const [0, 0.62, 0.70, 0.84, 0.94, 1],
    ).createShader(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_BeamPainter old) => old.t != t;
}
