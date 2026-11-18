import 'package:flutter/material.dart';

/// "Pamir stone" palette — cool stone surfaces, deep ink text, one teal accent,
/// gold reserved for the AI assistant, amber for things that need attention.
///
/// Older role names are kept so every page picks up the new look:
/// `orange` = the accent (now teal), `navy` = the dark surface (now ink).
class AppColors {
  AppColors._();

  // Surfaces
  static const background = Color(0xFFEEF1F4); // stone
  static const card = Colors.white;
  static const surfaceSoft = Color(0xFFF5F7F9);
  static const border = Color(0xFFDCE2E8);

  // Text
  static const ink = Color(0xFF0D1B2A);
  static const muted = Color(0xFF5B6878); // 5.6:1 on white

  // Accent (teal) — actions, selection, the brand
  static const orange = Color(0xFF0B6E6E);
  static const orangeSoft = Color(0xFFE2F0EF);
  static const teal = orange;
  static const tealSoft = orangeSoft;

  // Dark surface — user chat bubble, tooltips, dark badges, chart bars
  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1E3044);

  // AI only
  static const gold = Color(0xFFD4A017);
  static const goldSoft = Color(0xFFFBF3DC);

  // Meaning
  static const amber = Color(0xFFB25E09); // needs attention
  static const amberSoft = Color(0xFFFCF0E3);
  static const green = Color(0xFF1F7A4D); // money in, growth
  static const greenSoft = Color(0xFFE4F2EA);
  static const red = Color(0xFFB42318); // money out, errors
  static const redSoft = Color(0xFFFDECEA);
  static const blue = Color(0xFF2F5D8A);
  static const blueSoft = Color(0xFFE8EFF6);
  static const purple = Color(0xFF6B4FA0);
  static const purpleSoft = Color(0xFFF0ECF7);
  static const barGray = Color(0xFFA9B4C0);
}
