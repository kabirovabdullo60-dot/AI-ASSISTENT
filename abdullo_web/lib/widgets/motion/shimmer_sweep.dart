import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// A band of light that sweeps across a primary button (Magic UI "Shimmer Button"):
/// once shortly after it appears, then again each time the mouse comes over it.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({super.key, required this.child, this.radius = 12});

  final Widget child;
  final double radius;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    // First sweep after a short pause (the second half of the controller), no timers.
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _sweep() {
    if (_c.isAnimating) return;
    _c.forward(from: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return MouseRegion(
      onEnter: (_) => _sweep(),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    // 0–0.35 waits, 0.35–1 sweeps from left to right.
                    final t = ((_c.value - 0.35) / 0.65).clamp(0.0, 1.0);
                    if (t == 0 || t == 1) return const SizedBox.shrink();
                    final x = -1.6 + 3.2 * Motion.easeOut.transform(t);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(x - 0.6, -1),
                          end: Alignment(x + 0.6, 1),
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.32),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
