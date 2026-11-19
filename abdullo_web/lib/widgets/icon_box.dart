import 'package:flutter/material.dart';

/// Rounded square with an icon, used on cards and activity rows.
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, required this.color, required this.background, this.size = 34});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.28)),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
