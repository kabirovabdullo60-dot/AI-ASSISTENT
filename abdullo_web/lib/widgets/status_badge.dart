import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum BadgeTone {
  positive,
  negative,
  warning,
  info,
  neutral,
  dark;

  Color get foreground => switch (this) {
    positive => AppColors.green,
    negative => AppColors.red,
    warning => AppColors.amber,
    info => AppColors.blue,
    neutral => AppColors.muted,
    dark => Colors.white,
  };

  Color get background => switch (this) {
    positive => AppColors.greenSoft,
    negative => AppColors.redSoft,
    warning => AppColors.amberSoft,
    info => AppColors.blueSoft,
    neutral => AppColors.surfaceSoft,
    dark => AppColors.navy,
  };
}

/// Small pill like "+12.4%", "LIVE AUDIT", "4 Pending".
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.text, {super.key, this.tone = BadgeTone.neutral, this.icon, this.dot = false});

  final String text;
  final BadgeTone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone.foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[Icon(icon, size: 12, color: tone.foreground), const SizedBox(width: 3)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tone.foreground, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
