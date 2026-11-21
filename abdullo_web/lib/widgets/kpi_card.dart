import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'motion/number_ticker.dart';
import 'status_badge.dart';

/// One headline figure: a 13px grey label over a 30px figure in tabular digits, the unit as a
/// smaller grey suffix, and an optional change line. No icon, no tile, no glow (KPIs are type,
/// not tiles). Put several side by side with [KpiStrip].
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.unit,
    this.badge,
    this.badgeTone = BadgeTone.positive,
    this.badgeIcon,
    this.badgeDot = false,
    this.caption,
    this.highlight = false,
    this.number,
    this.format,
    this.data = false,
  });

  /// When set, [value] is ignored and the number counts up to this (formatted by [format]).
  final double? number;
  final String Function(double)? format;

  /// Height of one cell, so a row of them lines up.
  static const height = 112.0;

  final String title;
  final String value;
  final String? unit;

  /// Kept for callers; KPIs carry no icon.
  final IconData? icon;

  /// The change, in words with its window ("+4.2% vs last month"). Its tone says good or bad.
  final String? badge;
  final BadgeTone badgeTone;
  final IconData? badgeIcon;
  final bool badgeDot;
  final String? caption;

  /// Needs attention (e.g. unpaid salaries): the figure takes the warning ink.
  final bool highlight;

  /// The screen's main data figure: it takes the one data hue.
  final bool data;

  @override
  Widget build(BuildContext context) {
    final ink = highlight ? AppColors.amber : (data ? AppColors.data : AppColors.ink);
    final valueStyle = TextStyle(
      fontFamily: AppTheme.display,
      fontSize: 30,
      height: 1.1,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.6,
      color: ink,
      fontFeatures: AppTheme.figure,
    );
    final changeColor = switch (badgeTone) {
      BadgeTone.positive => AppColors.green,
      BadgeTone.negative => AppColors.red,
      BadgeTone.warning => AppColors.amber,
      _ => AppColors.muted,
    };
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.3),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (number != null && format != null)
                    NumberTicker(value: number!, format: format!, style: valueStyle)
                  else
                    Text(value, style: valueStyle),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit!,
                      style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  if (badge != null)
                    TextSpan(
                      text: badge,
                      style: TextStyle(color: changeColor, fontWeight: FontWeight.w500),
                    ),
                  if (badge != null && caption != null) const TextSpan(text: '  '),
                  if (caption != null) TextSpan(text: caption),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Peer KPIs in one card split by 1px dividers into equal columns (desktop / tablet), or a
/// 2-column grid split the same way on a phone. An odd count lets the last cell span the row.
class KpiStrip extends StatelessWidget {
  const KpiStrip({super.key, required this.children, this.columns});

  final List<Widget> children;

  /// Cells per row; defaults to all in one row from 720px, two below.
  final int? columns;

  @override
  Widget build(BuildContext context) {
    final line = BorderSide(color: AppColors.border);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) {
          // All in one row while each cell keeps about 200px; otherwise rows of three, two on a phone.
          final perRow =
              columns ??
              (c.maxWidth < 720
                  ? 2
                  : (c.maxWidth / children.length >= 200
                        ? children.length
                        : (children.length > 4 ? 3 : children.length)));
          final rows = <List<Widget>>[];
          for (var i = 0; i < children.length; i += perRow) {
            rows.add(children.sublist(i, (i + perRow).clamp(0, children.length)));
          }
          return Column(
            children: [
              for (var r = 0; r < rows.length; r++)
                DecoratedBox(
                  decoration: BoxDecoration(border: r == 0 ? null : Border(top: line)),
                  child: Row(
                    children: [
                      for (var i = 0; i < rows[r].length; i++)
                        Expanded(
                          // The last cell of a short row takes what is left of the row.
                          flex: i == rows[r].length - 1 ? perRow - rows[r].length + 1 : 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(border: i == 0 ? null : Border(left: line)),
                            child: rows[r][i],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
