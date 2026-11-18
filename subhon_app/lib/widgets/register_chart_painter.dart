import 'package:flutter/rendering.dart';

import 'register_colors.dart';

/// Draws the register illustration: faint grid lines and two rising
/// curves (income above, profit below) that draw in from left to right.
///
/// A picture of what the app does, not data: there are no values or axes.
class RegisterChartPainter extends CustomPainter {
  RegisterChartPainter(this.progress);

  /// 0 … 1: how much of the curves is drawn.
  final double progress;

  /// Heights (0 bottom … 1 top) at evenly spaced points.
  static const _income = [0.22, 0.3, 0.3, 0.46, 0.42, 0.6, 0.66, 0.88];
  static const _profit = [0.1, 0.15, 0.17, 0.24, 0.26, 0.4, 0.47, 0.6];

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = RegisterColors.grid
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    final income = _curve(_income, size);
    // A soft fill under the income curve.
    final fill = Path.from(income)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(0, -1),
          end: const Alignment(0, 1),
          colors: [
            RegisterColors.income.withValues(alpha: 0.22),
            RegisterColors.income.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    _stroke(canvas, income, RegisterColors.income);
    _stroke(canvas, _curve(_profit, size), RegisterColors.profit);
    canvas.restore();
  }

  static Path _curve(List<double> heights, Size size) {
    final step = size.width / (heights.length - 1);
    Offset at(int i) => Offset(i * step, size.height * (1 - heights[i]));
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < heights.length; i++) {
      final a = at(i - 1);
      final b = at(i);
      path.cubicTo(a.dx + step / 2, a.dy, b.dx - step / 2, b.dy, b.dx, b.dy);
    }
    return path;
  }

  static void _stroke(Canvas canvas, Path path, Color color) => canvas.drawPath(
    path,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round,
  );

  @override
  bool shouldRepaint(RegisterChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
