import 'package:flutter/material.dart';

import '../motion/motion.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Display face for headings and big numbers.
  static const display = 'Raleway';

  /// Lining, tabular figures (Raleway defaults to old-style numerals).
  static const numbers = [FontFeature.liningFigures(), FontFeature.tabularFigures()];

  /// Theme for the current [AppColors.palette] (light or dark).
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.orange,
      onPrimary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      error: AppColors.red,
    );
    // Onest everywhere (bundled, full Tajik Cyrillic).
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Onest',
    ).textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
    const radius = BorderRadius.all(Radius.circular(12));
    const buttonShape = RoundedRectangleBorder(borderRadius: radius);
    return ThemeData(
      useMaterial3: true,
      brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme.copyWith(
        surfaceContainerHighest: AppColors.surfaceSoft,
        surfaceContainerHigh: AppColors.surfaceSoft,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        onSurfaceVariant: AppColors.muted,
      ),
      canvasColor: AppColors.card,
      fontFamily: 'Onest',
      // Browser surfaces carry the palette too: selection, caret, scrollbars.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.teal,
        selectionColor: AppColors.teal.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.teal,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(6),
        thumbColor: WidgetStatePropertyAll(AppColors.muted.withValues(alpha: 0.35)),
      ),
      focusColor: AppColors.teal.withValues(alpha: 0.14),
      hoverColor: AppColors.ink.withValues(alpha: 0.04),
      // Tighter, heavier headings; calm body text.
      // Display voice: Raleway (headings, big numbers). Reading voice: Onest.
      textTheme: base.copyWith(
        displaySmall: base.displaySmall?.copyWith(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.9,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: base.titleMedium?.copyWith(fontFamily: AppTheme.display, fontWeight: FontWeight.w700),
        bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w600, letterSpacing: 0.1),
          animationDuration: Motion.fast,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          animationDuration: Motion.fast,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: buttonShape, animationDuration: Motion.fast),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        titleTextStyle: TextStyle(
          fontFamily: 'Onest',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.border),
        ),
        shadowColor: Color(0x29142235),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: Duration(milliseconds: 450),
        decoration: BoxDecoration(color: AppColors.tooltip, borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: TextStyle(fontFamily: 'Onest', color: Colors.white, fontSize: 12),
      ),
      // Fixed (not floating): a floating bar would cover buttons at the bottom of phone screens.
      snackBarTheme: SnackBarThemeData(backgroundColor: AppColors.tooltip),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.teal),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      // Cards: 20px radius. Light looks float on a soft shadow; the dark look uses a hairline instead.
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: AppColors.isDark ? 0 : 1.5,
        shadowColor: AppColors.navy.withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: AppColors.isDark ? BorderSide(color: AppColors.border) : BorderSide.none,
        ),
      ),
      // Inputs: white field, hairline border, teal focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(color: AppColors.muted),
        hintStyle: TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red, width: 1.6),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.tealSoft : AppColors.card,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.teal : AppColors.ink,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.tealSoft,
        side: BorderSide(color: AppColors.border),
        shape: StadiumBorder(),
        labelStyle: TextStyle(fontFamily: 'Onest', color: AppColors.ink, fontSize: 13),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.teal : null),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.tealSoft,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? AppColors.orange : AppColors.muted),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          fontFamily: 'Onest',
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        dataTextStyle: TextStyle(fontFamily: 'Onest', color: AppColors.ink, fontSize: 13.5),
        dividerThickness: 1,
        headingRowColor: WidgetStatePropertyAll(AppColors.surfaceSoft),
        dataRowColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) ? AppColors.tealSoft.withValues(alpha: 0.45) : null,
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    );
  }
}
