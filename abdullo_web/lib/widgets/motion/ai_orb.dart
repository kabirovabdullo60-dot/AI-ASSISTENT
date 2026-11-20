import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The assistant's mark: a flat ink disc with a spark (no gradient, no glow). While [thinking]
/// the spark pulses gently so a long answer still shows life; at rest nothing moves.
class AiOrb extends StatefulWidget {
  const AiOrb({super.key, this.size = 32, this.thinking = false});

  final double size;
  final bool thinking;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    if (widget.thinking) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AiOrb old) {
    super.didUpdateWidget(old);
    if (widget.thinking && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.thinking && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: AppColors.isDark ? AppColors.surfaceSoft : AppColors.ink,
        shape: BoxShape.circle,
      ),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.45).animate(_c),
        child: Icon(Icons.auto_awesome, size: s * 0.5, color: Colors.white),
      ),
    );
  }
}
