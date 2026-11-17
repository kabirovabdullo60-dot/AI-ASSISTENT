import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum BadgeTone {
  positive(AppColors.green, AppColors.greenSoft),
  negative(AppColors.red, AppColors.redSoft),
  warning(AppColors.orange, AppColors.orangeSoft),
  info(AppColors.blue, AppColors.blueSoft),
  neutral(AppColors.muted, AppColors.surfaceSoft),
  dark(Colors.white, AppColors.navy);

  const BadgeTone(this.foreground, this.background);
  final Color foreground;
  final Color background;
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
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(6)),
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
              style: TextStyle(
                color: tone.foreground,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
