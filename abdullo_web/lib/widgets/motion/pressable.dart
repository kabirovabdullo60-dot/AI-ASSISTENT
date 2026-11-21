import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';

/// Tactile feedback for cards and chips:
/// - mouse hover: lifts 2px with a soft shadow, and a soft accent spotlight follows the
///   cursor across the card (Magic UI "Magic Card");
/// - press: shrinks to 0.98.
/// Hover only reacts to a real mouse (no false hover on touch). Reduced motion keeps the
/// spotlight's color hint but drops the movement.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.lift = true, this.radius = 14});

  final Widget child;

  /// Lift + shadow + spotlight on hover (cards). False = only press feedback (buttons).
  final bool lift;
  final double radius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _down = false;
  Offset? _pointer;

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    final lifted = widget.lift && _hover && !reduced;
    return MouseRegion(
      onEnter: (e) => setState(() {
        _hover = true;
        _pointer = e.localPosition;
      }),
      onHover: widget.lift ? (e) => setState(() => _pointer = e.localPosition) : null,
      onExit: (_) => setState(() {
        _hover = false;
        _pointer = null;
      }),
      child: Listener(
        onPointerDown: (_) => setState(() => _down = true),
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down && !reduced ? 0.98 : 1,
          duration: Motion.fast,
          curve: Motion.easeOut,
          child: AnimatedContainer(
            duration: Motion.base,
            curve: Motion.easeOut,
            transform: Matrix4.translationValues(0, lifted ? -2 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: (AppColors.isDark ? Colors.black : AppColors.navy).withValues(
                    alpha: lifted ? (AppColors.isDark ? 0.35 : 0.08) : 0,
                  ),
                  blurRadius: lifted ? 24 : 0,
                  offset: Offset(0, lifted ? 8 : 0),
                ),
              ],
            ),
            child: widget.lift
                ? CustomPaint(
                    foregroundPainter: _SpotlightPainter(
                      center: _hover ? _pointer : null,
                      radius: widget.radius,
                      color: AppColors.teal,
                      strength: AppColors.isDark ? 0.16 : 0.07,
                    ),
                    child: widget.child,
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.center, required this.radius, required this.color, required this.strength});

  final Offset? center;
  final double radius;
  final Color color;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final c = center;
    if (c == null) return;
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final r = size.shortestSide * 0.9 + 60;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.center != center || old.color != color;
}
