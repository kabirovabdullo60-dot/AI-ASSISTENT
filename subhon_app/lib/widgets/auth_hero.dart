import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import 'accounting_rain.dart';

/// The header of the auth screens: soft rings of light around [child]
/// (the jelly mascot) and the rain of accountant's things. Purple
/// (register) or, with [light], soft lavender (login).
class AuthHero extends StatelessWidget {
  const AuthHero({required this.child, this.light = false, super.key});

  final Widget child;
  final bool light;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: light
              ? const [Color(0xFFF6F3FF), Color(0xFFEAE3FF), Color(0xFFDCD1FF)]
              : const [Color(0xFF8D6BFA), AppColors.primary, Color(0xFF5A35D6)],
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
                      color: (light ? AppColors.primary : Colors.white)
                          .withValues(alpha: light ? alpha * 0.8 : alpha),
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
