import 'package:flutter/material.dart';

/// The three looks the owner can switch between (Settings → Theme, or the palette button
/// in the top bar). Every color role of the web lives here; widgets read them through
/// [AppColors].
enum AppPalette {
  /// Dark navy lit by violet → cyan aurora light. The default.
  aurora(
    PaletteColors(
      dark: true,
      background: Color(0xFF0A0E1A),
      card: Color(0xFF121829),
      surfaceSoft: Color(0xFF182036),
      border: Color(0xFF232B42),
      ink: Color(0xFFE6E9F2),
      muted: Color(0xFF9AA3B8),
      accent: Color(0xFF7152F7),
      accentText: Color(0xFFA48BFF),
      accentSoft: Color(0xFF231E48),
      accent2: Color(0xFF22D3EE),
      accent2Soft: Color(0xFF0E3340),
      navy: Color(0xFF1E2742),
      navyLight: Color(0xFF2A3557),
      amber: Color(0xFFFBBF24),
      amberSoft: Color(0xFF3A2E12),
      green: Color(0xFF34D399),
      greenSoft: Color(0xFF0F3328),
      red: Color(0xFFF87171),
      redSoft: Color(0xFF3B1A1E),
      blue: Color(0xFF60A5FA),
      blueSoft: Color(0xFF172A47),
      purple: Color(0xFFC084FC),
      purpleSoft: Color(0xFF2E1C46),
      barGray: Color(0xFF3A4560),
    ),
  ),

  /// shadcn-style zinc neutrals with an indigo accent.
  zinc(
    PaletteColors(
      dark: false,
      background: Color(0xFFFAFAFA),
      card: Color(0xFFFFFFFF),
      surfaceSoft: Color(0xFFF4F4F5),
      border: Color(0xFFE4E4E7),
      ink: Color(0xFF09090B),
      muted: Color(0xFF71717A),
      accent: Color(0xFF4F46E5),
      accentSoft: Color(0xFFEEF2FF),
      accent2: Color(0xFFA855F7),
      accent2Soft: Color(0xFFF5F3FF),
      navy: Color(0xFF18181B),
      navyLight: Color(0xFF27272A),
      amber: Color(0xFFB45309),
      amberSoft: Color(0xFFFEF3C7),
      green: Color(0xFF15803D),
      greenSoft: Color(0xFFDCFCE7),
      red: Color(0xFFDC2626),
      redSoft: Color(0xFFFEE2E2),
      blue: Color(0xFF1D4ED8),
      blueSoft: Color(0xFFDBEAFE),
      purple: Color(0xFF7C3AED),
      purpleSoft: Color(0xFFEDE9FE),
      barGray: Color(0xFFD4D4D8),
    ),
  ),

  /// Warm white, deep emerald and champagne gold — private-bank calm.
  emerald(
    PaletteColors(
      dark: false,
      background: Color(0xFFFAFAF7),
      card: Color(0xFFFFFFFF),
      surfaceSoft: Color(0xFFF3F4EF),
      border: Color(0xFFE5E7DF),
      ink: Color(0xFF111827),
      muted: Color(0xFF6B7280),
      accent: Color(0xFF065F46),
      accentSoft: Color(0xFFE6F2EC),
      accent2: Color(0xFFC9A227),
      accent2Soft: Color(0xFFF8F1DB),
      navy: Color(0xFF0B2F25),
      navyLight: Color(0xFF134236),
      amber: Color(0xFFA84F07),
      amberSoft: Color(0xFFFDF0DC),
      green: Color(0xFF15803D),
      greenSoft: Color(0xFFE3F4E8),
      red: Color(0xFFB91C1C),
      redSoft: Color(0xFFFDECEC),
      blue: Color(0xFF1D4ED8),
      blueSoft: Color(0xFFE6EDFB),
      purple: Color(0xFF6D28D9),
      purpleSoft: Color(0xFFF0EAFB),
      barGray: Color(0xFFCBD0C4),
    ),
  );

  const AppPalette(this.colors);

  final PaletteColors colors;

  static AppPalette fromName(String? name) => values.firstWhere((p) => p.name == name, orElse: () => AppPalette.aurora);
}

class PaletteColors {
  const PaletteColors({
    required this.dark,
    required this.background,
    required this.card,
    required this.surfaceSoft,
    required this.border,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentSoft,
    this.accentText,
    required this.accent2,
    required this.accent2Soft,
    required this.navy,
    required this.navyLight,
    required this.amber,
    required this.amberSoft,
    required this.green,
    required this.greenSoft,
    required this.red,
    required this.redSoft,
    required this.blue,
    required this.blueSoft,
    required this.purple,
    required this.purpleSoft,
    required this.barGray,
  });

  final bool dark;
  final Color background, card, surfaceSoft, border, ink, muted;
  final Color accent, accentSoft, accent2, accent2Soft, navy, navyLight;

  /// Accent for text and links when [accent] itself is too dark to read on the page
  /// (dark look). Null = use [accent].
  final Color? accentText;
  final Color amber, amberSoft, green, greenSoft, red, redSoft, blue, blueSoft, purple, purpleSoft, barGray;
}
