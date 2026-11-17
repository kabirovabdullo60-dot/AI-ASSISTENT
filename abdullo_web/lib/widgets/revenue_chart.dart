import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chart_point_model.dart';

/// Bars = daily revenue, smooth orange line = cashflow.
/// The best day is orange with a label, today is dark navy.
class RevenueChart extends StatelessWidget {
  const RevenueChart({
    super.key,
    required this.points,
    required this.peakIndex,
    required this.xLabels,
    required this.peakLabel,
    this.height = 260,
  });

  final List<ChartPointModel> points;
  final int peakIndex;

  /// One label per point; empty string = no label.
  final List<String> xLabels;
  final String peakLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('revenue-chart'),
      height: height,
      width: double.infinity,
      child: points.isEmpty
          ? const Center(child: Text('No data yet'))
          : CustomPaint(
              painter: _RevenueChartPainter(
                points: points,
                peakIndex: peakIndex,
                xLabels: xLabels,
                peakLabel: peakLabel,
                labelStyle: Theme.of(context).textTheme.labelSmall ?? const TextStyle(fontSize: 11),
              ),
            ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  _RevenueChartPainter({
    required this.points,
    required this.peakIndex,
    required this.xLabels,
    required this.peakLabel,
    required this.labelStyle,
  });

  final List<ChartPointModel> points;
  final int peakIndex;
  final List<String> xLabels;
  final String peakLabel;
  final TextStyle labelStyle;

  static const _top = 30.0;
  static const _bottomLabels = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final n = points.length;
    final chartH = size.height - _top - _bottomLabels;
    final bottom = _top + chartH;
    final slot = size.width / n;
    final barW = (slot * 0.34).clamp(3.0, 14.0);

    // grid
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var k = 0; k <= 3; k++) {
      final y = _top + chartH * k / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // bars
    final maxRev = points.map((p) => p.revenue).reduce(math.max);
    double xOf(int i) => slot * (i + 0.5);
    for (var i = 0; i < n; i++) {
      final h = maxRev <= 0 ? 0.0 : points[i].revenue / maxRev * chartH * 0.92;
      final rect = Rect.fromLTRB(xOf(i) - barW / 2, bottom - h, xOf(i) + barW / 2, bottom);
      final paint = Paint();
      if (i == peakIndex) {
        paint.color = AppColors.orange;
      } else if (i == n - 1) {
        paint.color = AppColors.navy;
      } else {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.barGray, AppColors.barGray.withValues(alpha: 0.12)],
        ).createShader(rect);
      }
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: Radius.circular(barW / 2), topRight: Radius.circular(barW / 2)),
        paint,
      );
    }

    // cashflow line
    final cash = points.map((p) => p.cashflow).toList();
    final minC = cash.reduce(math.min);
    final maxC = cash.reduce(math.max);
    final span = maxC - minC == 0 ? 1 : maxC - minC;
    final pts = [for (var i = 0; i < n; i++) Offset(xOf(i), bottom - ((cash[i] - minC) / span * 0.78 + 0.12) * chartH)];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < n; i++) {
      final midX = (pts[i - 1].dx + pts[i].dx) / 2;
      line.cubicTo(midX, pts[i - 1].dy, midX, pts[i].dy, pts[i].dx, pts[i].dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, bottom)
      ..lineTo(pts.first.dx, bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.orange.withValues(alpha: 0.22), AppColors.orange.withValues(alpha: 0)],
        ).createShader(Rect.fromLTRB(0, _top, size.width, bottom)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // dots
    void dot(Offset o, Color c) {
      canvas.drawCircle(o, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        o,
        4.5,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (peakIndex >= 0 && peakIndex < n) dot(pts[peakIndex], AppColors.orange);
    dot(pts.last, AppColors.navy);

    // peak label
    if (peakIndex >= 0 && peakIndex < n && peakLabel.isNotEmpty) {
      final tp = _text(peakLabel, labelStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700));
      final w = tp.width + 12;
      final h = tp.height + 6;
      final cx = xOf(peakIndex).clamp(w / 2, math.max(w / 2, size.width - w / 2)).toDouble();
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, _top - h / 2 - 2), width: w, height: h),
        const Radius.circular(4),
      );
      canvas.drawRRect(r, Paint()..color = AppColors.navy);
      tp.paint(canvas, Offset(cx - tp.width / 2, r.top + 3));
      tp.dispose();
    }

    // x labels
    for (var i = 0; i < n && i < xLabels.length; i++) {
      if (xLabels[i].isEmpty) continue;
      final isPeak = i == peakIndex;
      final tp = _text(
        xLabels[i],
        labelStyle.copyWith(
          color: isPeak ? AppColors.orange : AppColors.muted,
          fontWeight: isPeak || i == n - 1 ? FontWeight.w700 : FontWeight.w500,
        ),
      );
      final x = (xOf(i) - tp.width / 2).clamp(0.0, math.max(0.0, size.width - tp.width)).toDouble();
      tp.paint(canvas, Offset(x, bottom + 8));
      tp.dispose();
    }
  }

  TextPainter _text(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();

  @override
  bool shouldRepaint(_RevenueChartPainter old) =>
      old.points != points || old.peakIndex != peakIndex || old.peakLabel != peakLabel || old.xLabels != xLabels;
}
