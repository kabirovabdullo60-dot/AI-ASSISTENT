import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum BadgeTone {
  positive,
  negative,
  warning,
  info,
  neutral,
  dark;

  /// Dark text of the tag's own hue (pale-pair pills). `info` is neutral: blue is kept for data.
  Color get foreground => switch (this) {
    positive => AppColors.green,
    negative => AppColors.red,
    warning => AppColors.amber,
    info || neutral => AppColors.isDark ? AppColors.muted : const Color(0xFF3D3D3D),
    dark => AppColors.isDark ? Colors.black : Colors.white,
  };

  Color get background => switch (this) {
    positive => AppColors.greenSoft,
    negative => AppColors.redSoft,
    warning => AppColors.amberSoft,
    info || neutral => AppColors.surfaceSoft,
    dark => AppColors.isDark ? Colors.white : AppColors.navy,
  };
}

/// A status tag inside a row or beside a value: 20px, 12/500, a pale tint with dark text of the
/// same hue, 4px corners. One status mark per row; never above a heading; never squeezed.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.text, {super.key, this.tone = BadgeTone.neutral, this.icon, this.dot = false});

  final String text;
  final BadgeTone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone.foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[Icon(icon, size: 12, color: tone.foreground), const SizedBox(width: 3)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone.foreground,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
