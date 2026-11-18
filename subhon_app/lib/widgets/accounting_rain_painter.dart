import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'accounting_item_drawings.dart';
import 'accounting_rain_drop.dart';

/// Paints the falling accountant's things at [time] seconds: each drop
/// falls, drifts a little sideways, turns and rocks in 3D (a perspective
/// tilt), and starts again from the top after leaving the bottom. Far drops
/// are smaller, slower and dimmer.
class AccountingRainPainter extends CustomPainter {
  AccountingRainPainter({required this.time, required this.drops})
    : super(repaint: time);

  final ValueListenable<double> time;
  final List<AccountingRainDrop> drops;

  /// Strength of the perspective (bigger = stronger 3D).
  static const double _perspective = 0.0025;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    for (final d in drops) {
      final box = d.size * d.depth;
      final margin = box * 1.2;
      final travel = size.height + 2 * margin;
      final fallen = (d.phase * travel + t * d.speed * d.depth) % travel;
      final y = fallen - margin;
      final x =
          d.x * size.width + math.sin(t * 0.6 + d.phase * 6) * 12 * d.depth;
      final rock = t * d.tiltSpeed + d.phase * 2 * math.pi;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, _perspective)
        ..rotateX(math.sin(rock) * d.tiltX)
        ..rotateY(math.cos(rock * 0.8) * d.tiltY)
        ..rotateZ(d.angle + t * d.spin);

      canvas.save();
      canvas.translate(x, y);
      canvas.transform(matrix.storage);
      // Far drops fade into the night; near ones are almost solid.
      // Capped so the labels over them stay easy to read.
      final alpha = (0.22 + 0.43 * (d.depth - 0.45) / 0.55).clamp(0.0, 1.0);
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: box),
        Paint()..color = Color.fromRGBO(255, 255, 255, alpha),
      );
      AccountingItemDrawings.draw(canvas, d.kind, box);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(AccountingRainPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.drops != drops;
}
