import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Gives [child] (the main button of the dark auth screens) the vivid brand
/// purple with white text, as on the design; the dark theme's own accent
/// is lighter, for text on dark backgrounds.
class VividButtonTheme extends StatelessWidget {
  const VividButtonTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      extensions: [
        context.palette.copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
        ),
      ],
    ),
    child: child,
  );
}
