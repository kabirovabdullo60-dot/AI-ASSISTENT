import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// Entrance animation: fades in while moving [offset] pixels into place (and scaling from
/// [beginScale]). Runs once when mounted. [delay] staggers groups (see [Motion.staggerAt]).
/// With reduced motion it only fades.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = Motion.slow,
    this.offset = const Offset(0, 10),
    this.beginScale = 1,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double beginScale;

  /// Scale origin — e.g. a chat bubble grows from its own side.
  final Alignment alignment;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _c = AnimationController(vsync: this, duration: total);
    // The delay is part of the same controller (no timers), so it can never fire after dispose.
    final start = total.inMicroseconds == 0 ? 0.0 : widget.delay.inMicroseconds / total.inMicroseconds;
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: Motion.easeOut),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        if (reduced) return Opacity(opacity: v, child: child);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: widget.offset * (1 - v),
            child: widget.beginScale == 1
                ? child
                : Transform.scale(
                    scale: widget.beginScale + (1 - widget.beginScale) * v,
                    alignment: widget.alignment,
                    child: child,
                  ),
          ),
        );
      },
    );
  }
}
