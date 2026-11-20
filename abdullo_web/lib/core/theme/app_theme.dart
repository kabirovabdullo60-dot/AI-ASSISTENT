import 'package:flutter/material.dart';

import '../motion/motion.dart';
import 'app_colors.dart';

/// Achromatic ledger (design-taste-frontend, app screens): one grotesk, flat surfaces split by a
/// 1px line, a tight radius pair (8 for cards, 6 for controls), a near-black primary, and colour
/// kept for data and status.
class AppTheme {
  AppTheme._();

  /// One face everywhere: Onest (bundled, full Tajik Cyrillic, real tabular figures).
  /// Kept as a name so headings and figures can ask for it explicitly.
  static const display = 'Onest';

  /// Lining, tabular figures: every number in a table or a row, so digits line up.
  static const numbers = [FontFeature.liningFigures(), FontFeature.tabularFigures()];

  /// Lining, proportional figures for a large figure that stands alone (KPIs, the day's
  /// takings): Onest's tabular digits are too wide at 30px+ and read as letter-spaced.
  static const figure = [FontFeature.liningFigures(), FontFeature.proportionalFigures()];

  static const radiusCard = 8.0;
  static const radiusControl = 6.0;

  /// One gutter, horizontally and vertically.
  static const gap = 12.0;

  /// Theme for the current [AppColors.palette] (light or dark).
  static ThemeData get light {
    final dark = AppColors.isDark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.orange,
      onPrimary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      error: AppColors.red,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Onest',
    ).textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
    const control = BorderRadius.all(Radius.circular(radiusControl));
    const buttonShape = RoundedRectangleBorder(borderRadius: control);
    const controlSize = Size(0, 36);
    OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: control,
      borderSide: BorderSide(color: c, width: w),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme.copyWith(
        surfaceContainerHighest: AppColors.surfaceSoft,
        surfaceContainerHigh: AppColors.surfaceSoft,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        onSurfaceVariant: AppColors.muted,
      ),
      canvasColor: AppColors.card,
      fontFamily: 'Onest',
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.data.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.ink,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(6),
        thumbColor: WidgetStatePropertyAll(AppColors.muted.withValues(alpha: 0.35)),
      ),
      focusColor: AppColors.ink.withValues(alpha: 0.08),
      hoverColor: AppColors.ink.withValues(alpha: 0.04),
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      // App type is not display type: titles 24/600, sections 16/600, body 14, small 12.
      textTheme: base.copyWith(
        displaySmall: base.displaySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6),
        headlineLarge: base.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        titleLarge: base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.43),
        bodySmall: base.bodySmall?.copyWith(fontSize: 12, color: AppColors.muted),
        labelMedium: base.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.muted),
        labelSmall: base.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted),
      ),
      // One near-black primary per screen; a grey pill as the secondary; text for the rest.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: buttonShape,
          minimumSize: controlSize,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 14, fontWeight: FontWeight.w500),
          elevation: 0,
          animationDuration: Motion.fast,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.card,
          shape: buttonShape,
          minimumSize: controlSize,
          side: BorderSide(color: dark ? const Color(0xFF444444) : const Color(0xFFD4D4D4)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 14, fontWeight: FontWeight.w500),
          animationDuration: Motion.fast,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          minimumSize: controlSize,
          foregroundColor: AppColors.ink,
          textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 14, fontWeight: FontWeight.w500),
          animationDuration: Motion.fast,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.muted, shape: buttonShape),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        titleTextStyle: TextStyle(fontFamily: 'Onest', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
      // What floats may cast a shadow: menus, popovers, dialogs.
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: AppColors.border),
        ),
        shadowColor: const Color(0x1F000000),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          color: AppColors.tooltip,
          borderRadius: const BorderRadius.all(Radius.circular(radiusControl)),
        ),
        textStyle: const TextStyle(fontFamily: 'Onest', color: Colors.white, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: AppColors.tooltip),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.ink),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      // Surfaces are flat: a white card, a 1px edge, no shadow at rest.
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      // Fields: white, 1px border, label above (Flutter floats it; it stays inside the frame).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(color: AppColors.muted),
        hintStyle: TextStyle(color: AppColors.muted),
        border: field(AppColors.border),
        enabledBorder: field(AppColors.border),
        focusedBorder: field(AppColors.ink, 1.5),
        errorBorder: field(AppColors.red),
        focusedErrorBorder: field(AppColors.red, 1.5),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: control)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.surfaceSoft : AppColors.card,
          ),
          foregroundColor: WidgetStatePropertyAll(AppColors.ink),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.surfaceSoft,
        side: BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: control),
        labelStyle: TextStyle(fontFamily: 'Onest', color: AppColors.ink, fontSize: 13),
      ),
      // Toggles: on = near-black (light) / white (dark), never the brand hue.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? (dark ? Colors.black : Colors.white) : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? (dark ? Colors.white : AppColors.ink) : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.surfaceSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: 'Onest',
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: s.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted),
        ),
      ),
      // Tables: 12px grey sentence-case header, no band, row rules only.
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          fontFamily: 'Onest',
          color: AppColors.muted,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        dataTextStyle: TextStyle(fontFamily: 'Onest', color: AppColors.ink, fontSize: 14),
        dividerThickness: 1,
        headingRowColor: const WidgetStatePropertyAll(Colors.transparent),
        dataRowColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) ? AppColors.ink.withValues(alpha: 0.03) : null,
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    );
  }
}
