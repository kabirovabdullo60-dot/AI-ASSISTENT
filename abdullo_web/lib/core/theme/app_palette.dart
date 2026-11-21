import 'package:flutter/material.dart';

/// The two looks the owner can switch between (Settings → Theme, or the palette button
/// in the top bar): light ledger and dark graphite. Every color role of the web lives here; widgets read them through
/// [AppColors].
enum AppPalette {
  /// Achromatic ledger on a stone ground (a shop's floor, not a template's #f8f8f8). The chrome
  /// holds no colour: ink for money and counts, near-black for the one primary action, and one
  /// blue only on the screen's main data (today, the current period). The default.
  ledger(
    PaletteColors(
      dark: false,
      background: Color(0xFFF4F3F1),
      card: Color(0xFFFFFFFF),
      surfaceSoft: Color(0xFFEEEEEE),
      border: Color(0xFFE6E6E6),
      ink: Color(0xFF0A0A0A),
      muted: Color(0xFF6B6B6B),
      accent: Color(0xFF141414),
      accentText: Color(0xFF0A0A0A),
      accentSoft: Color(0xFFEEEEEE),
      accent2: Color(0xFF1D5FBF),
      accent2Soft: Color(0xFFE8EEF8),
      navy: Color(0xFF141414),
      navyLight: Color(0xFF2A2A2A),
      amber: Color(0xFF92400E),
      amberSoft: Color(0xFFFFFBEB),
      green: Color(0xFF247B50),
      greenSoft: Color(0xFFDCFAE5),
      red: Color(0xFFC4242A),
      redSoft: Color(0xFFFFEDEA),
      blue: Color(0xFF1D5FBF),
      blueSoft: Color(0xFFE8EEF8),
      purple: Color(0xFF1D5FBF),
      purpleSoft: Color(0xFFE8EEF8),
      barGray: Color(0xFFD4D4D4),
    ),
  ),

  /// The same ledger in true neutral dark (no navy, no slate): elevation by lightness alone,
  /// white text, a grey-filled primary, the blue lifted for contrast on data only.
  graphite(
    PaletteColors(
      dark: true,
      background: Color(0xFF000000),
      card: Color(0xFF111111),
      surfaceSoft: Color(0xFF222222),
      border: Color(0xFF2E2E2E),
      ink: Color(0xFFFFFFFF),
      muted: Color(0xFFB4B4B4),
      accent: Color(0xFF333333),
      accentText: Color(0xFFFFFFFF),
      accentSoft: Color(0xFF222222),
      accent2: Color(0xFF6EA6F2),
      accent2Soft: Color(0xFF16233A),
      navy: Color(0xFF222222),
      navyLight: Color(0xFF2E2E2E),
      amber: Color(0xFFF2B451),
      amberSoft: Color(0xFF2A2112),
      green: Color(0xFF3FC07A),
      greenSoft: Color(0xFF172A1D),
      red: Color(0xFFE5566F),
      redSoft: Color(0xFF2C1A20),
      blue: Color(0xFF6EA6F2),
      blueSoft: Color(0xFF16233A),
      purple: Color(0xFF6EA6F2),
      purpleSoft: Color(0xFF16233A),
      barGray: Color(0xFF3A3A3A),
    ),
  );

  const AppPalette(this.colors);

  final PaletteColors colors;

  /// Older saved names (aurora, zinc, emerald) fall back to the ledger.
  static AppPalette fromName(String? name) => values.firstWhere((p) => p.name == name, orElse: () => AppPalette.ledger);
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
