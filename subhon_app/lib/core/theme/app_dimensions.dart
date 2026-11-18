import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 4-pt spacing scale.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal padding of screen content.
  static const double screen = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screen,
  );
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppShadows {
  static List<BoxShadow> card(AppPalette palette) => [
    BoxShadow(
      color: palette.shadow,
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

/// Minimum interactive size (Material / HIG accessibility guidelines).
const double kMinTapTarget = 48;
