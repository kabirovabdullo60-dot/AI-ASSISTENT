import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'ofar_logo_painter.dart';

/// OFAR brand mark: a purple tile with a white "O" ring and an accent spark
/// (the AI assistant). Drawn in code — crisp at any size, no asset needed.
/// The same drawing makes the app icon and the splash image
/// (`tool/generate_brand_assets.dart`).
class OfarLogo extends StatelessWidget {
  const OfarLogo({this.size = 64, super.key});

  final double size;

  /// The brand colours of the tile: fixed, not the theme's accent (which
  /// is adjusted for text contrast).
  static const lightTile = AppColors.primary;
  static const darkTile = AppColors.secondary;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'OFAR',
    image: true,
    child: CustomPaint(
      size: Size.square(size),
      painter: OfarLogoPainter(
        tile: Theme.of(context).brightness == Brightness.dark
            ? darkTile
            : lightTile,
      ),
    ),
  );
}
