import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Color roles of the current [AppPalette]. Switching the palette ([use]) and rebuilding
/// the app repaints every page.
///
/// Older role names are kept so every page follows the palette:
/// `orange` / `teal` = the accent, `gold` = the AI's second accent, `navy` = the dark surface.
class AppColors {
  AppColors._();

  static PaletteColors _c = AppPalette.aurora.colors;
  static AppPalette _palette = AppPalette.aurora;

  static AppPalette get palette => _palette;
  static void use(AppPalette p) {
    _palette = p;
    _c = p.colors;
  }

  static bool get isDark => _c.dark;

  // Surfaces
  static Color get background => _c.background;
  static Color get card => _c.card;
  static Color get surfaceSoft => _c.surfaceSoft;
  static Color get border => _c.border;

  // Text
  static Color get ink => _c.ink;
  static Color get muted => _c.muted;

  // Accent — actions, selection, the brand
  static Color get orange => _c.accent;
  static Color get orangeSoft => _c.accentSoft;
  static Color get teal => _c.accent;
  static Color get tealSoft => _c.accentSoft;

  /// Text / icons on the accent (always light: every accent is dark enough).
  static const onAccent = Colors.white;

  // Dark surface — user chat bubble, tooltips, dark badges, chart bars
  static Color get navy => _c.navy;
  static Color get navyLight => _c.navyLight;

  /// Strong mark on the page (chart highlight, sparkline): dark on light themes, light on dark.
  static Color get strong => _c.dark ? _c.ink : _c.navy;

  // Second accent — the AI
  static Color get gold => _c.accent2;
  static Color get goldSoft => _c.accent2Soft;

  // Meaning
  static Color get amber => _c.amber;
  static Color get amberSoft => _c.amberSoft;
  static Color get green => _c.green;
  static Color get greenSoft => _c.greenSoft;
  static Color get red => _c.red;
  static Color get redSoft => _c.redSoft;
  static Color get blue => _c.blue;
  static Color get blueSoft => _c.blueSoft;
  static Color get purple => _c.purple;
  static Color get purpleSoft => _c.purpleSoft;
  static Color get barGray => _c.barGray;
}
