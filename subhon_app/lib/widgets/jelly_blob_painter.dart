import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../core/theme/app_colors.dart';
import 'jelly_blob_pose.dart';

/// Draws the jelly blob of the login screen: a glossy purple body whose
/// outline wobbles, leans and bulges toward where it looks, with a soft
/// shadow under it and two white eyes.
class JellyBlobPainter extends CustomPainter {
  JellyBlobPainter(this.pose) : super(repaint: pose);

  final JellyBlobPose pose;

  static const int _points = 48;
  static const _highlight = Color(0xFFB59CFF);
  static const _deep = Color(0xFF4421B8);

  final Path _body = Path();
  final List<Offset> _outline = List.filled(_points, Offset.zero);
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = pose.time;
    final look = pose.look;
    final r = size.shortestSide * 0.38;
    final breathe = math.sin(t * 2.1);
    final center = Offset(
      size.width / 2 + look.dx * r * 0.06,
      size.height * 0.47 + breathe * r * 0.03 + look.dy * r * 0.04,
    );

    // Soft shadow on the "floor"; smaller when the blob bobs up.
    _paint
      ..shader = null
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.47 + r * 1.14),
        width: r * (1.35 + breathe * 0.05),
        height: r * 0.2,
      ),
      _paint,
    );
    _paint.maskFilter = null;

    // Wobbling outline: a circle with a few slow waves, squashed while
    // breathing and stretched toward the look direction.
    final lookAngle = math.atan2(look.dy, look.dx);
    final lookAmount = look.distance;
    final sx = 1 + breathe * 0.03;
    final sy = 1 - breathe * 0.03;
    for (var i = 0; i < _points; i++) {
      final th = i / _points * 2 * math.pi;
      final lobe =
          0.035 * math.sin(2 * th + t * 1.7) +
          0.025 * math.sin(3 * th - t * 2.3) +
          0.015 * math.sin(5 * th + t * 3.1) +
          0.05 * lookAmount * math.max(0, math.cos(th - lookAngle));
      final radius = r * (1 + lobe);
      _outline[i] =
          center +
          Offset(math.cos(th) * radius * sx, math.sin(th) * radius * sy);
    }
    _body.reset();
    final start = Offset.lerp(_outline.last, _outline.first, 0.5)!;
    _body.moveTo(start.dx, start.dy);
    for (var i = 0; i < _points; i++) {
      final p = _outline[i];
      final next = Offset.lerp(p, _outline[(i + 1) % _points], 0.5)!;
      _body.quadraticBezierTo(p.dx, p.dy, next.dx, next.dy);
    }
    _body.close();

    final bounds = Rect.fromCircle(center: center, radius: r * 1.1);
    // Opaque again: the shadow's alpha would otherwise fade the gradient.
    _paint
      ..color = const Color(0xFFFFFFFF)
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [_highlight, AppColors.primary, _deep],
        stops: [0, 0.55, 1],
      ).createShader(bounds);
    canvas.drawPath(_body, _paint);

    // Gloss.
    _paint
      ..shader = null
      ..color = const Color(0x55FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.4, -r * 0.48),
        width: r * 0.42,
        height: r * 0.22,
      ),
      _paint,
    );
    _paint.maskFilter = null;

    // Eyes.
    final eyeCenter =
        center + Offset(look.dx * r * 0.26, -r * 0.06 + look.dy * r * 0.2);
    final eyeWidth = r * 0.17;
    final eyeHeight = math.max(r * 0.31 * pose.openness, r * 0.04);
    _paint.color = const Color(0xFFFFFFFF);
    for (final side in const [-1, 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: eyeCenter + Offset(side * r * 0.24, 0),
            width: eyeWidth,
            height: eyeHeight,
          ),
          Radius.circular(eyeWidth / 2),
        ),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(JellyBlobPainter oldDelegate) => oldDelegate.pose != pose;
}
