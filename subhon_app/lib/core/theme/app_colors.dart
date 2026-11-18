import 'package:flutter/material.dart';

/// Raw brand colors of OFAR. Widgets should use [AppPalette] (theme-aware)
/// instead of these constants directly.
abstract final class AppColors {
  static const primary = Color(0xFF7048E8);
  static const secondary = Color(0xFF8B6CF6);
  static const primaryLight = Color(0xFFEEE9FF);
  static const background = Color(0xFFF8F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF252039);
  // ≥ 4.5:1 (WCAG AA) on every light background, incl. primaryLight.
  static const textSecondary = Color(0xFF686479);
  static const success = Color(0xFF20A46B);
  static const error = Color(0xFFE34D59);
  static const warning = Color(0xFFE6A23C);
  static const border = Color(0xFFECEAF3);
}

/// Semantic, theme-aware colors available via `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.successLight,
    required this.error,
    required this.errorLight,
    required this.warning,
    required this.warningLight,
    required this.shadow,
    required this.onPrimary,
    required this.warningText,
  });

  static const light = AppPalette(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceMuted: Color(0xFFF3F1F9),
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    success: AppColors.success,
    successLight: Color(0xFFE4F5EC),
    error: AppColors.error,
    errorLight: Color(0xFFFCE8EA),
    warning: AppColors.warning,
    warningLight: Color(0xFFFCF2E3),
    shadow: Color(0x0F252039),
    onPrimary: Color(0xFFFFFFFF),
    warningText: Color(0xFF8F5600),
  );

  static const dark = AppPalette(
    // Light enough for text on dark surfaces (≥ 4.8:1); content on it is
    // dark ([onPrimary]).
    primary: Color(0xFFA48BF8),
    secondary: Color(0xFFB39FFA),
    primaryLight: Color(0xFF2B2445),
    background: Color(0xFF121019),
    surface: Color(0xFF1C1926),
    surfaceMuted: Color(0xFF242031),
    textPrimary: Color(0xFFF3F1FA),
    textSecondary: Color(0xFFA39FB3),
    border: Color(0xFF2E2A3B),
    success: Color(0xFF3CC184),
    successLight: Color(0xFF16302A),
    error: Color(0xFFF06D78),
    errorLight: Color(0xFF3A1E25),
    warning: Color(0xFFF0B45A),
    warningLight: Color(0xFF392D1C),
    shadow: Color(0x33000000),
    onPrimary: Color(0xFF15111F),
    warningText: Color(0xFFF0B45A),
  );

  final Color primary;
  final Color secondary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color successLight;
  final Color error;
  final Color errorLight;
  final Color warning;
  final Color warningLight;
  final Color shadow;

  /// Text and icons on [primary] (buttons, the balance card, own chat
  /// bubbles).
  final Color onPrimary;

  /// [warning] for small text: readable on [warningLight] and surfaces.
  final Color warningText;

  @override
  AppPalette copyWith({Color? primary, Color? textPrimary}) => AppPalette(
    primary: primary ?? this.primary,
    secondary: secondary,
    primaryLight: primaryLight,
    background: background,
    surface: surface,
    surfaceMuted: surfaceMuted,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary,
    border: border,
    success: success,
    successLight: successLight,
    error: error,
    errorLight: errorLight,
    warning: warning,
    warningLight: warningLight,
    shadow: shadow,
    onPrimary: onPrimary,
    warningText: warningText,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: l(primary, other.primary),
      secondary: l(secondary, other.secondary),
      primaryLight: l(primaryLight, other.primaryLight),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      border: l(border, other.border),
      success: l(success, other.success),
      successLight: l(successLight, other.successLight),
      error: l(error, other.error),
      errorLight: l(errorLight, other.errorLight),
      warning: l(warning, other.warning),
      warningLight: l(warningLight, other.warningLight),
      shadow: l(shadow, other.shadow),
      onPrimary: l(onPrimary, other.onPrimary),
      warningText: l(warningText, other.warningText),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
