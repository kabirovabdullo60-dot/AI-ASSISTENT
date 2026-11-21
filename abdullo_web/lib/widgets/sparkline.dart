import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Small area line chart (e.g. "Hourly Velocity"). The highest point gets an orange dot.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, this.height = 64});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparklinePainter(values)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max);
    final peak = values.indexOf(maxV);
    final step = size.width / (values.length - 1);
    Offset at(int i) => Offset(i * step, size.height - 4 - (maxV == 0 ? 0 : values[i] / maxV) * (size.height - 10));

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = AppColors.border.withValues(alpha: 0.8));
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.strong
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawCircle(at(peak), 3.5, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}
