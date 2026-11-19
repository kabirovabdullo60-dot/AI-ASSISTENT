import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'motion.dart';

/// Every dialog of the web opens with Material's fade-through-scale (package:animations):
/// it grows from 0.8 while fading in over 220ms and fades out faster (150ms) on close.
/// Reduced motion opens it at once.
Future<T?> showAppDialog<T>({required BuildContext context, required WidgetBuilder builder}) {
  final reduced = Motion.reduced(context);
  return showModal<T>(
    context: context,
    configuration: FadeScaleTransitionConfiguration(
      barrierDismissible: true,
      transitionDuration: reduced ? Duration.zero : const Duration(milliseconds: 220),
      reverseTransitionDuration: reduced ? Duration.zero : const Duration(milliseconds: 150),
    ),
    builder: builder,
  );
}
