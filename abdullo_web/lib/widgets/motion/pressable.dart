import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// Tactile feedback for cards and chips: lifts 2px with a soft shadow on mouse hover and
/// shrinks to 0.97 while pressed. Hover only reacts to a real mouse (no false hover on touch).
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.lift = true, this.radius = 14});

  final Widget child;

  /// Lift + shadow on hover (cards). False = only press feedback (chips, buttons).
  final bool lift;
  final double radius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    final lifted = widget.lift && _hover && !reduced;
    return MouseRegion(
      onEnter: (e) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _down = true),
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down && !reduced ? 0.97 : 1,
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
                  color: const Color(0xFF142235).withValues(alpha: lifted ? 0.08 : 0),
                  blurRadius: lifted ? 24 : 0,
                  offset: Offset(0, lifted ? 8 : 0),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
