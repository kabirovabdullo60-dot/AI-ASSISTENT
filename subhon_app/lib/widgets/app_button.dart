import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize {
  large(56),
  medium(48),
  small(40);

  const AppButtonSize(this.height);
  final double height;
}

/// The single button component of the design system.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  /// Icon after the label, e.g. a forward arrow on "Далее".
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (background, foreground, border) = switch (variant) {
      AppButtonVariant.primary => (p.primary, p.onPrimary, null),
      AppButtonVariant.secondary => (p.primaryLight, p.primary, null),
      AppButtonVariant.outline => (Colors.transparent, p.textPrimary, p.border),
      AppButtonVariant.text => (Colors.transparent, p.primary, null),
      AppButtonVariant.destructive => (p.errorLight, p.error, null),
    };
    final enabled = onPressed != null && !isLoading;
    final textStyle = Theme.of(context).textTheme.labelLarge;

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expand ? double.infinity : 0, size.height),
      ),
      // At least [size] high; taller only when a large text size needs a
      // second line for the label.
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) && !isLoading
            ? (background == Colors.transparent ? background : p.surfaceMuted)
            : background,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) && !isLoading
            ? p.textSecondary
            : foreground,
      ),
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.08)),
      textStyle: WidgetStatePropertyAll(textStyle),
      elevation: const WidgetStatePropertyAll(0),
      splashFactory: InkSparkle.splashFactory,
    );

    final child = AnimatedSwitcher(
      duration: AppDurations.fast,
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: foreground,
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(trailingIcon, size: 20),
                ],
              ],
            ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? label : null,
      child: TextButton(
        onPressed: enabled ? onPressed : (isLoading ? () {} : null),
        style: style,
        child: child,
      ),
    );
  }
}
