import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A plain outline icon where it helps (a row's kind, a card's subject). Never a tinted square:
/// colour belongs to data, not to decoration. [background] is ignored and kept so callers need
/// not change; [color] is used only when it is a status colour, otherwise the icon is grey.
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, required this.color, required this.background, this.size = 34});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final status = color == AppColors.red || color == AppColors.amber || color == AppColors.green;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(icon, size: (size * 0.52).clamp(14, 20), color: status ? color : AppColors.muted),
      ),
    );
  }
}
