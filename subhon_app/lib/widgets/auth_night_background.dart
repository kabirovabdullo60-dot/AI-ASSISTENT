import 'package:flutter/material.dart';

/// The dark night backdrop of the login and register screens: deep indigo fading to
/// near-black, with a soft purple glow behind the mascot.
class AuthNightBackground extends StatelessWidget {
  const AuthNightBackground({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1C1442), Color(0xFF0F0C22), Color(0xFF0A0915)],
        stops: [0, 0.45, 1],
      ),
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.78),
          radius: 0.75,
          colors: [Color(0x667048E8), Color(0x007048E8)],
        ),
      ),
      child: SizedBox.expand(),
    ),
  );
}
