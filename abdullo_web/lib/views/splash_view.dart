import 'package:flutter/material.dart';

import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/motion/aurora.dart';
import '../widgets/motion/fade_slide_in.dart';
import '../widgets/motion/photo_slideshow.dart';
import '../widgets/pamir_ridge.dart';

/// Shown while the saved session is checked: a slowly zooming photo of money under a dark
/// tint of the current palette, aurora light, the Pamir ridgeline drawing itself, the logo
/// and name rising in, and a thin glowing progress line.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static const photo = 'assets/images/money_stack.jpg';

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.navy;
    return Scaffold(
      backgroundColor: tint,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhotoSlideshow(images: [photo], hold: Duration(seconds: 8), zoom: 0.10),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tint.withValues(alpha: 0.72), tint.withValues(alpha: 0.86), tint.withValues(alpha: 0.97)],
              ),
            ),
          ),
          const AuroraBackground(drift: Duration(seconds: 8)),
          const Positioned(left: 0, right: 0, bottom: 0, height: 220, child: PamirRidges(color: Colors.white)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FadeSlideIn(
                  beginScale: 0.86,
                  offset: Offset(0, 8),
                  duration: Duration(milliseconds: 620),
                  child: _GlowingMark(),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  delay: Motion.staggerAt(3),
                  child: const Text(
                    'Apex Suite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(
                  delay: Motion.staggerAt(5),
                  child: SizedBox(
                    width: 168,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        key: const Key('splash-progress'),
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo with a soft halo in the palette's accent.
class _GlowingMark extends StatelessWidget {
  const _GlowingMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.teal.withValues(alpha: 0.55), blurRadius: 44, spreadRadius: 2),
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 80, spreadRadius: 6),
        ],
      ),
      child: const BrandMark(size: 76),
    );
  }
}
