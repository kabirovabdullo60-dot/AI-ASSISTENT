import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Rounded square with an icon on a tinted background.
class AppIconBox extends StatelessWidget {
  const AppIconBox({
    required this.icon,
    this.color,
    this.background,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? p.primaryLight,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color ?? p.primary, size: size * 0.5),
    );
  }
}
