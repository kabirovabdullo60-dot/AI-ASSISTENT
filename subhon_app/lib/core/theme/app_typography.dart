import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Onest';

  /// Tabular figures keep amounts aligned in lists and tables.
  static const tabularFigures = [FontFeature.tabularFigures()];

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle style(
      double size,
      FontWeight weight,
      Color color, {
      double? height,
      double spacing = 0,
    }) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );

    return TextTheme(
      displayLarge: style(
        40,
        FontWeight.w800,
        primary,
        height: 1.1,
        spacing: -0.8,
      ),
      displayMedium: style(
        32,
        FontWeight.w700,
        primary,
        height: 1.15,
        spacing: -0.6,
      ),
      displaySmall: style(
        28,
        FontWeight.w700,
        primary,
        height: 1.2,
        spacing: -0.4,
      ),
      headlineMedium: style(
        24,
        FontWeight.w700,
        primary,
        height: 1.25,
        spacing: -0.3,
      ),
      headlineSmall: style(
        22,
        FontWeight.w700,
        primary,
        height: 1.25,
        spacing: -0.2,
      ),
      titleLarge: style(20, FontWeight.w700, primary, height: 1.3),
      titleMedium: style(16, FontWeight.w600, primary, height: 1.35),
      titleSmall: style(14, FontWeight.w600, primary, height: 1.35),
      bodyLarge: style(16, FontWeight.w500, primary, height: 1.45),
      bodyMedium: style(15, FontWeight.w500, primary, height: 1.45),
      bodySmall: style(13, FontWeight.w500, secondary, height: 1.4),
      labelLarge: style(15, FontWeight.w600, primary, height: 1.2),
      labelMedium: style(13, FontWeight.w600, primary, height: 1.2),
      labelSmall: style(
        11,
        FontWeight.w600,
        secondary,
        height: 1.2,
        spacing: 0.2,
      ),
    );
  }
}
