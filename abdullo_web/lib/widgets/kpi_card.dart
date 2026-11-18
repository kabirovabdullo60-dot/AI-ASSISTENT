import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'motion/border_beam.dart';
import 'motion/number_ticker.dart';
import 'icon_box.dart';
import 'status_badge.dart';

/// One KPI tile of "Business Overview" (e.g. Today's Sales 38,450 TJS).
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.unit,
    this.badge,
    this.badgeTone = BadgeTone.positive,
    this.badgeIcon,
    this.badgeDot = false,
    this.caption,
    this.highlight = false,
    this.number,
    this.format,
  });

  /// When set, [value] is ignored and the number counts up to this (formatted by [format]).
  final double? number;
  final String Function(double)? format;

  static const height = 172.0;

  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final String? badge;
  final BadgeTone badgeTone;
  final IconData? badgeIcon;
  final bool badgeDot;
  final String? caption;

  /// Orange accent (used for things that need attention, e.g. unpaid salaries).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = highlight ? AppColors.amber : AppColors.ink;

    final card = SizedBox(
      height: height,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconBox(
                    icon,
                    size: 28,
                    color: highlight ? AppColors.amber : AppColors.teal,
                    background: highlight ? AppColors.amberSoft : AppColors.tealSoft,
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: number != null && format != null
                    ? NumberTicker(
                        value: number!,
                        format: format!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: -0.6,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    : Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: -0.6,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
              if (unit != null) Text(unit!, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 8),
              if (badge != null) StatusBadge(badge!, tone: badgeTone, icon: badgeIcon, dot: badgeDot),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    // Needs attention → a beam of light runs around it twice.
    return highlight ? BorderBeam(radius: 14, loops: 2, child: card) : card;
  }
}
