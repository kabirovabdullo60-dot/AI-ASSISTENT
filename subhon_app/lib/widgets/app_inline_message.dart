import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

enum InlineMessageType { info, warning, error, success }

/// Message embedded in the layout: form errors, demo notices, hints.
class AppInlineMessage extends StatelessWidget {
  const AppInlineMessage({
    required this.message,
    this.type = InlineMessageType.info,
    this.title,
    this.action,
    super.key,
  });

  final String message;
  final String? title;
  final InlineMessageType type;

  /// Optional trailing action (e.g. a small text button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final (icon, color, background) = switch (type) {
      InlineMessageType.info => (
        Icons.info_outline_rounded,
        p.primary,
        p.primaryLight,
      ),
      InlineMessageType.warning => (
        Icons.science_outlined,
        p.warning,
        p.warningLight,
      ),
      InlineMessageType.error => (
        Icons.error_outline_rounded,
        p.error,
        p.errorLight,
      ),
      InlineMessageType.success => (
        Icons.check_circle_outline_rounded,
        p.success,
        p.successLight,
      ),
    };
    return Semantics(
      liveRegion: type == InlineMessageType.error,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        title!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.sm),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
