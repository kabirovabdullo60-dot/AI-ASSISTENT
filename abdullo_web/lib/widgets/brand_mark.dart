import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'pamir_ridge.dart';

/// The logo: a teal tile with a two-peak ridge line (the Pamirs) drawn as vector geometry.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(size * 0.28)),
      padding: EdgeInsets.fromLTRB(size * 0.16, size * 0.24, size * 0.16, size * 0.22),
      child: const CustomPaint(painter: RidgeMarkPainter()),
    );
  }
}
