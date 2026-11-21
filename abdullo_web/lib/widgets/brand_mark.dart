import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'pamir_ridge.dart';

/// The logo: an ink tile with a two-peak ridge line (the Pamirs) drawn as vector geometry.
/// [light] = a white tile with an ink ridge, for dark photographs.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? Colors.white : AppColors.teal,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.fromLTRB(size * 0.16, size * 0.24, size * 0.16, size * 0.22),
      child: CustomPaint(painter: RidgeMarkPainter(color: light ? const Color(0xFF0A0A0A) : Colors.white)),
    );
  }
}
