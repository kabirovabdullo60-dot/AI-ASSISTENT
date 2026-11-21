import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/theme/app_colors.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  for (final (name, p) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    test('every text colour on its background is at least 4.5:1 ($name)', () {
      final pairs = <String, (Color, Color)>{
        'textPrimary / background': (p.textPrimary, p.background),
        'textPrimary / surface': (p.textPrimary, p.surface),
        'textPrimary / primaryLight': (p.textPrimary, p.primaryLight),
        'textSecondary / background': (p.textSecondary, p.background),
        'textSecondary / surface': (p.textSecondary, p.surface),
        'textSecondary / surfaceMuted': (p.textSecondary, p.surfaceMuted),
        'textSecondary / primaryLight': (p.textSecondary, p.primaryLight),
        'primary / surface': (p.primary, p.surface),
        'primary / background': (p.primary, p.background),
        'primary / primaryLight': (p.primary, p.primaryLight),
        'onPrimary / primary': (p.onPrimary, p.primary),
        'onPrimary / error (red button)': (p.onPrimary, p.error),
        'success / surface': (p.success, p.surface),
        'success / background': (p.success, p.background),
        'success / successLight': (p.success, p.successLight),
        'error / surface': (p.error, p.surface),
        'error / background': (p.error, p.background),
        'error / errorLight': (p.error, p.errorLight),
        'warningText / surface': (p.warningText, p.surface),
        'warningText / warningLight': (p.warningText, p.warningLight),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        expect(
          _contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$label ($name)',
        );
      }
    });
  }
}
