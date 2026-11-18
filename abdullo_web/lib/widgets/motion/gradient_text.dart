import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';

/// Heading filled with the accent → AI gradient; the gradient glides across once when the
/// heading appears (Magic UI "Animated Gradient Text"). Used only for the AI title.
class AnimatedGradientText extends StatefulWidget {
  const AnimatedGradientText(this.text, {super.key, required this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.text,
      textAlign: widget.textAlign,
      style: widget.style?.copyWith(color: Colors.white),
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final shift = Motion.reduced(context) ? 0.0 : (1 - Motion.easeOut.transform(_c.value)) * 1.5;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1 - shift, 0),
            end: Alignment(1 - shift, 0),
            colors: [AppColors.ink, AppColors.teal, AppColors.gold, AppColors.ink],
            stops: const [0, 0.35, 0.65, 1],
          ).createShader(rect),
          child: child,
        );
      },
      child: text,
    );
  }
}
