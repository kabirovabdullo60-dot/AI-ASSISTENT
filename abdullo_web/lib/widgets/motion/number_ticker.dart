import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// Counts up from 0 to [value] once (Magic UI "Number Ticker"), and from the old to the new
/// value when it changes. Reduced motion shows the final number at once.
class NumberTicker extends StatelessWidget {
  const NumberTicker({super.key, required this.value, required this.format, required this.style});

  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return Text(format(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Motion.easeOut,
      builder: (context, v, _) => Text(format(v), style: style),
    );
  }
}
