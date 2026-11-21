import 'package:flutter/material.dart';

/// Formerly a gradient sweep across the letters. App screens set text in one colour, so this is
/// now plain text in the given style; the name stays so callers need not change.
class AnimatedGradientText extends StatelessWidget {
  const AnimatedGradientText(this.text, {super.key, required this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(text, style: style, textAlign: textAlign);
}
