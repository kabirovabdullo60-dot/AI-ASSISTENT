import 'package:flutter/material.dart';

/// A band of light that sweeps across a primary button (Magic UI "Shimmer Button"):
/// once, shortly after it appears. (Not on hover: hover happens tens of times a day.)
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({super.key, required this.child, this.radius = 12});

  final Widget child;
  final double radius;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

/// No sweep of light (no glows): the child is shown as it is.
class _ShimmerSweepState extends State<ShimmerSweep> {
  @override
  Widget build(BuildContext context) => widget.child;
}
