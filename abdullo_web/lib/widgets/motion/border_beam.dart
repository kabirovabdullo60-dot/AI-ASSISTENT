import 'package:flutter/material.dart';

/// A short streak of light that travels around the child's border (Magic UI "Border Beam").
/// It runs [loops] laps, then rests; while [active] it keeps going (e.g. while the AI answers).
class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    this.radius = 14,
    this.loops = 2,
    this.active = false,
    this.width = 1.6,
    this.lap = const Duration(milliseconds: 3200),
    this.onceId,
  });

  /// Kept for callers.
  final String? onceId;

  final Widget child;
  final double radius;
  final int loops;
  final bool active;
  final double width;
  final Duration lap;

  /// No light runs around borders any more (no glows): the child is shown as it is.
  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam> {
  @override
  Widget build(BuildContext context) => widget.child;
}
