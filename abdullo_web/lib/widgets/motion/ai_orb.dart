import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';

/// The assistant's face: a warm orange → violet → blue orb with a spark.
/// While [thinking] its colors swirl and a soft glow breathes; at rest it is still
/// (no endless animation on an idle screen).
class AiOrb extends StatefulWidget {
  const AiOrb({super.key, this.size = 32, this.thinking = false});

  final double size;
  final bool thinking;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    if (widget.thinking) _c.repeat();
  }

  @override
  void didUpdateWidget(AiOrb old) {
    super.didUpdateWidget(old);
    if (widget.thinking && !_c.isAnimating) _c.repeat();
    if (!widget.thinking && _c.isAnimating) _c.animateTo(0, duration: Motion.base, curve: Motion.easeOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = reduced ? 0.0 : _c.value;
        final breath = widget.thinking && !reduced ? (math.sin(t * math.pi * 4) + 1) / 2 : 0.0;
        return Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              transform: GradientRotation(t * 2 * math.pi),
              colors: const [AppColors.orange, AppColors.purple, AppColors.blue, AppColors.orange],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.18 + 0.22 * breath),
                blurRadius: s * (0.25 + 0.35 * breath),
                spreadRadius: s * 0.02 * breath,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: s * 0.78,
              height: s * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0)],
                ),
              ),
              child: Icon(Icons.auto_awesome, size: s * 0.46, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
