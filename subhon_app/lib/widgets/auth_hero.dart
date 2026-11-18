import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import 'accounting_rain.dart';

/// The purple header of the register screen: soft rings of light around
/// [child] (the jelly mascot) and the rain of accountant's things.
class AuthHero extends StatelessWidget {
  const AuthHero({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8D6BFA), AppColors.primary, Color(0xFF5A35D6)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Rings of light behind the mascot.
          for (final (radius, alpha) in const [
            (1.15, 0.05),
            (0.85, 0.07),
            (0.58, 0.09),
          ])
            Align(
              alignment: const Alignment(0, 0.15),
              child: FractionallySizedBox(
                heightFactor: radius,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: alpha),
                    ),
                  ),
                ),
              ),
            ),
          const AccountingRain(),
          SafeArea(
            bottom: false,
            child: Align(alignment: const Alignment(0, 0.1), child: child),
          ),
        ],
      ),
    ),
  );
}
