import 'package:flutter/material.dart';

/// Formerly a drifting colour glow behind the assistant. Surfaces are flat now, so it draws
/// nothing; kept so callers need not change.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, this.drift = const Duration(seconds: 14)});

  final Duration drift;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
