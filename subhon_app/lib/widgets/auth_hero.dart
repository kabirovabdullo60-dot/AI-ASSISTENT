import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import 'accounting_rain.dart';

/// The header of the auth page: soft rings of light around [child] (the
/// jelly mascot) and the rain of accountant's things. Purple for sign-up
/// or, with [light], soft lavender for sign-in; switching blends smoothly.
class AuthHero extends StatelessWidget {
  const AuthHero({required this.child, this.light = false, super.key});

  final Widget child;
  final bool light;

  static const _lavender = [
    Color(0xFFF6F3FF),
    Color(0xFFEAE3FF),
    Color(0xFFDCD1FF),
  ];
  static const _purple = [
    Color(0xFF8D6BFA),
    AppColors.primary,
    Color(0xFF5A35D6),
  ];
  static const _rings = [(1.15, 0.05), (0.85, 0.07), (0.58, 0.09)];

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    child: TweenAnimationBuilder<double>(
      // 0 purple … 1 lavender.
      tween: Tween(end: light ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, t, rain) {
        final ring = Color.lerp(
          Colors.white,
          AppColors.primary.withValues(alpha: 0.8),
          t,
        )!;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                for (var i = 0; i < 3; i++)
                  Color.lerp(_purple[i], _lavender[i], t)!,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Rings of light behind the mascot.
              for (final (radius, alpha) in _rings)
                Align(
                  alignment: const Alignment(0, 0.15),
                  child: FractionallySizedBox(
                    heightFactor: radius,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ring.withValues(alpha: alpha),
                        ),
                      ),
                    ),
                  ),
                ),
              rain!,
            ],
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
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
