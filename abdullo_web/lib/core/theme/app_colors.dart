import 'package:flutter/material.dart';

/// "Pamir stone" palette — cool stone surfaces, deep ink text, one teal accent,
/// gold reserved for the AI assistant, amber for things that need attention.
///
/// Older role names are kept so every page picks up the new look:
/// `orange` = the accent (now teal), `navy` = the dark surface (now ink).
class AppColors {
  AppColors._();

  // Surfaces
  static const background = Color(0xFFEDF2F6);
  static const card = Colors.white;
  static const surfaceSoft = Color(0xFFF6F9FB);
  static const border = Color(0xFFDCE4EC);

  // Text
  static const ink = Color(0xFF142235);
  static const muted = Color(0xFF64748B); // 4.8:1 on white

  // Accent (teal) — actions, selection, the brand
  static const orange = Color(0xFF087F80);
  static const orangeSoft = Color(0xFFE1F0EF);
  static const teal = orange;
  static const tealSoft = orangeSoft;

  // Dark surface — user chat bubble, tooltips, dark badges, chart bars
  static const navy = Color(0xFF142235);
  static const navyLight = Color(0xFF22344A);

  // AI only
  static const gold = Color(0xFFE9A23B); // secondary accent (fills, never small text)
  static const goldSoft = Color(0xFFFCF3E3);

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
