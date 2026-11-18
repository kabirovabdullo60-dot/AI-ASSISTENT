import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// The coloured sheet of the launch intro that drains upward.
///
/// At [progress] 0 it covers the whole screen; as it grows the bottom edge
/// rises, with rounded drips hanging below it that stretch and then pull
/// back in, until at 1 nothing is left.
class DripPainter extends CustomPainter {
  DripPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  /// Each drip: (x as a fraction of the width, length factor, width factor).
  /// Spaced so that neighbouring drips never overlap.
  static const _drips = <(double, double, double)>[
    (0.08, 0.9, 1.0),
    (0.21, 1.25, 1.2),
    (0.33, 0.7, 0.9),
    (0.47, 1.05, 1.3),
    (0.60, 0.55, 0.8),
    (0.72, 1.2, 1.15),
    (0.86, 0.8, 1.0),
    (0.96, 1.0, 0.7),
  ];

  /// Longest drip, as a fraction of the screen height.
  static const double _maxDrip = 0.14;

  /// Half width of a drip (factor 1), as a fraction of the screen width.
  static const double _halfWidth = 0.035;

  final Paint _paint = Paint();
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final v = progress.value;
    _paint.color = color;
    if (v <= 0) {
      canvas.drawRect(Offset.zero & size, _paint);
      return;
    }
    if (v >= 1) return;

    final w = size.width;
    final h = size.height;
    final maxLength = h * _maxDrip;
    final p = Curves.easeInOutCubic.transform(v);
    // The edge travels from the bottom to above the top, far enough that
    // the drips are gone too.
    final edge = (h + maxLength) * (1 - p) - maxLength;
    // Drips grow while the sheet moves and shrink back as it leaves.
    final grow = math.sin(math.pi * v);

    _path
      ..reset()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, edge);
    // Along the edge from right to left, dipping into each drip.
    for (final (fx, lengthFactor, widthFactor) in _drips.reversed) {
      final cx = fx * w;
      final half = _halfWidth * w * widthFactor;
      final tip = edge + maxLength * lengthFactor * grow;
      _path
        ..lineTo(cx + half * 1.6, edge)
        ..cubicTo(cx + half * 0.8, edge, cx + half, tip, cx, tip)
        ..cubicTo(cx - half, tip, cx - half * 0.8, edge, cx - half * 1.6, edge);
    }
    _path
      ..lineTo(0, edge)
      ..close();
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(DripPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
