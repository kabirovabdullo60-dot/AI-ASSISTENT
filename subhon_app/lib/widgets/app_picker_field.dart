import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// A field that opens a picker (sheet, date picker…) instead of a keyboard.
/// Looks like `AppTextField` so forms stay consistent.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder,
    this.leading,
    this.helper,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? value;
  final String? placeholder;
  final Widget? leading;

  /// Secondary line under the field (e.g. available balance).
  final String? helper;
  final String? errorText;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final hasValue = value != null && value!.isNotEmpty;
    final borderColor = errorText != null ? p.error : p.border;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      value: value ?? placeholder,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: enabled ? p.surface : p.surfaceMuted,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
              side: BorderSide(color: borderColor),
            ),
            child: InkWell(
              borderRadius: AppRadius.mdAll,
              onTap: enabled ? onTap : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Text(
                          hasValue ? value! : (placeholder ?? ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: hasValue ? p.textPrimary : p.textSecondary,
                          ),
                        ),
                      ),
                      Icon(Icons.expand_more_rounded, color: p.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (errorText != null || helper != null)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.md,
              ),
              child: Text(
                errorText ?? helper!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: errorText != null ? p.error : p.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
