import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chart_point_model.dart';

/// Bars = daily revenue, smooth orange line = number of sales.
/// The best day is orange with a label, today is dark navy.
/// Hover with the mouse (or tap / drag on a phone) to see any day's numbers.
class RevenueChart extends StatefulWidget {
  const RevenueChart({
    super.key,
    required this.points,
    required this.peakIndex,
    required this.xLabels,
    required this.peakLabel,
    required this.tooltipLines,
    this.height = 260,
  });

  final List<ChartPointModel> points;
  final int peakIndex;

  /// One label per point; empty string = no label.
  final List<String> xLabels;
  final String peakLabel;

  /// Text lines shown in the tooltip for point [index] (first line is bold).
  final List<String> Function(int index) tooltipLines;
  final double height;

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int? _hover;

  void _setHover(Offset local, double width) {
    final n = widget.points.length;
    if (n == 0 || width <= 0) return;
    const lane = _RevenueChartPainter._yLane;
    if (local.dx < lane) return _clear();
    final i = ((local.dx - lane) / ((width - lane) / n)).floor().clamp(0, n - 1);
    if (i != _hover) setState(() => _hover = i);
  }

  void _clear() {
    if (_hover != null) setState(() => _hover = null);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    return SizedBox(
      key: const Key('revenue-chart'),
      height: widget.height,
      width: double.infinity,
      child: points.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, c) {
                final hover = _hover != null && _hover! < points.length ? _hover : null;
                final slot = (c.maxWidth - _RevenueChartPainter._yLane) / points.length;
                const tipWidth = 170.0;
                return MouseRegion(
                  cursor: SystemMouseCursors.precise,
                  onHover: (e) => _setHover(e.localPosition, c.maxWidth),
                  onExit: (_) => _clear(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _setHover(d.localPosition, c.maxWidth),
                    onHorizontalDragUpdate: (d) => _setHover(d.localPosition, c.maxWidth),
                    onHorizontalDragEnd: (_) => _clear(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RevenueChartPainter(
                              points: points,
                              peakIndex: widget.peakIndex,
                              hoverIndex: hover,
                              xLabels: widget.xLabels,
                              peakLabel: hover == null ? widget.peakLabel : '',
                              labelStyle: const TextStyle(
                                fontFamily: 'Onest',
                                fontSize: 12,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                        if (hover != null)
                          Positioned(
                            key: const Key('chart-tooltip'),
                            top: 0,
                            left: (_RevenueChartPainter._yLane + slot * (hover + 0.5) - tipWidth / 2).clamp(
                              0.0,
                              math.max(0.0, c.maxWidth - tipWidth),
                            ),
                            width: tipWidth,
                            child: IgnorePointer(child: _Tooltip(lines: widget.tooltipLines(hover))),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tooltip,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++)
            Text(
              lines[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: i == 0 ? Colors.white : Colors.white70,
                fontSize: i == 0 ? 12.5 : 12,
                fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  _RevenueChartPainter({
    required this.points,
    required this.peakIndex,
    required this.hoverIndex,
    required this.xLabels,
    required this.peakLabel,
    required this.labelStyle,
  });

  final List<ChartPointModel> points;
  final int peakIndex;
  final int? hoverIndex;
  final List<String> xLabels;
  final String peakLabel;
  final TextStyle labelStyle;

  static const _top = 24.0;
  static const _bottomLabels = 26.0;

  /// Width of the y-axis lane on the left (ticks never sit on the bars).
  static const _yLane = 44.0;

  /// A round step so 4 ticks cover [max] with the top tick above it.
  static double _niceStep(double max) {
    if (max <= 0) return 1;
    final raw = max / 4;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (m * mag * 4 > max) return m * mag;
    }
    return 10 * mag;
  }

  static String _tick(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = points.length;
    final chartH = size.height - _top - _bottomLabels;
    final bottom = _top + chartH;
    final plotW = size.width - _yLane;
    final slot = plotW / n;
    final barW = (slot * 0.56).clamp(3.0, 28.0);
    double xOf(int i) => _yLane + slot * (i + 0.5);

    // One series, per day: takings. The scale: 4 round steps, the top tick above the maximum.
    final maxRev = points.map((p) => p.revenue).reduce(math.max);
    final step = _niceStep(maxRev);
    final top = step * 4;
    double yOf(double v) => bottom - v / top * chartH;

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var k = 0; k <= 4; k++) {
      final y = yOf(step * k);
      canvas.drawLine(
        Offset(_yLane, y),
        Offset(size.width, y),
        k == 0 ? (Paint()..color = AppColors.muted.withValues(alpha: 0.5)) : grid,
      );
      final tp = _text(_tick(step * k), labelStyle.copyWith(color: AppColors.muted));
      tp.paint(canvas, Offset(_yLane - 8 - tp.width, y - tp.height / 2));
      tp.dispose();
    }

    // Bars: square corners, grey; today's bar (the last) carries the one data hue.
    final h = hoverIndex;
    for (var i = 0; i < n; i++) {
      final v = points[i].revenue;
      if (v <= 0) continue; // an empty day has no bar, not a stub
      final rect = Rect.fromLTRB(xOf(i) - barW / 2, yOf(v), xOf(i) + barW / 2, bottom);
      final isToday = i == n - 1;
      final color = isToday ? AppColors.data : (h == i ? AppColors.muted : AppColors.barGray);
      canvas.drawRect(rect, Paint()..color = color);
    }

    // Hover: a 1px guide in ink.
    if (h != null && h < n) {
      canvas.drawLine(
        Offset(xOf(h), _top),
        Offset(xOf(h), bottom),
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.25)
          ..strokeWidth = 1,
      );
    }

    // The event that matters: the best day, labelled above its bar in plain 12px text.
    if (peakIndex >= 0 && peakIndex < n && peakLabel.isNotEmpty && peakIndex != n - 1) {
      final tp = _text(peakLabel, labelStyle.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600));
      final cx = xOf(
        peakIndex,
      ).clamp(_yLane + tp.width / 2, math.max(_yLane + tp.width / 2, size.width - tp.width / 2)).toDouble();
      final y = (yOf(points[peakIndex].revenue) - tp.height - 4).clamp(0.0, size.height).toDouble();
      tp.paint(canvas, Offset(cx - tp.width / 2, y));
      tp.dispose();
    }

    // x labels: grey, today in ink.
    for (var i = 0; i < n && i < xLabels.length; i++) {
      if (xLabels[i].isEmpty) continue;
      final tp = _text(
        xLabels[i],
        labelStyle.copyWith(
          color: i == n - 1 ? AppColors.ink : AppColors.muted,
          fontWeight: i == n - 1 ? FontWeight.w600 : FontWeight.w400,
        ),
      );
      final x = (xOf(i) - tp.width / 2).clamp(_yLane, math.max(_yLane, size.width - tp.width)).toDouble();
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
      old.points != points ||
      old.peakIndex != peakIndex ||
      old.hoverIndex != hoverIndex ||
      old.peakLabel != peakLabel ||
      old.xLabels != xLabels;
}
