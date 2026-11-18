import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Draws the mark. [tile] `null`: only the ring and the spark (Android
/// adaptive-icon foreground). [cornerRadius] as a share of the size (the
/// icon is square: the system rounds it). [markScale] shrinks the ring and
/// the spark around the centre (adaptive icons keep them in the safe zone).
class OfarLogoPainter extends CustomPainter {
  const OfarLogoPainter({
    this.tile = AppColors.primary,
    this.cornerRadius = 0.28,
    this.markScale = 1,
    this.mark = Colors.white,
    this.spark = const Color(0xFFD9CCFF),
  });

  final Color? tile;
  final double cornerRadius;
  final double markScale;
  final Color mark;
  final Color spark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final tile = this.tile;
    if (tile != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(s * cornerRadius),
        ),
        Paint()..color = tile,
      );
    }
    canvas
      ..save()
      ..translate(s / 2, s / 2)
      ..scale(markScale)
      ..translate(-s / 2, -s / 2);

    final center = Offset(s * 0.47, s * 0.53);
    canvas.drawCircle(
      center,
      s * 0.22,
      Paint()
        ..color = mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.115,
    );

    // Four-pointed spark in the top-right corner.
    final at = Offset(s * 0.76, s * 0.25);
    final r = s * 0.11;
    final path = Path()
      ..moveTo(at.dx, at.dy - r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx + r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx - r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy - r)
      ..close();
    canvas
      ..drawPath(path, Paint()..color = spark)
      ..restore();
  }

  @override
  bool shouldRepaint(OfarLogoPainter oldDelegate) =>
      oldDelegate.tile != tile ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.markScale != markScale ||
      oldDelegate.mark != mark ||
      oldDelegate.spark != spark;
}
