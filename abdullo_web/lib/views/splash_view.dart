import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
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
  const SplashView({super.key, this.duration = Duration.zero});

  /// How long the splash is held; the progress line fills over exactly this time.
  final Duration duration;

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
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 650),
                  duration: const Duration(milliseconds: 700),
                  offset: const Offset(0, 6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      context.l10n.loginHeadline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFD5DEE8), fontSize: 15, height: 1.45),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  delay: Motion.staggerAt(5),
                  child: SizedBox(
                    width: 168,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: duration == Duration.zero
                          ? LinearProgressIndicator(
                              key: const Key('splash-progress'),
                              minHeight: 3,
                              backgroundColor: Colors.white.withValues(alpha: 0.14),
                              color: AppColors.gold,
                            )
                          // Fills from 0 to 100% over the splash time, with a slow start and a soft end.
                          : TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: duration,
                              curve: Curves.easeInOutCubic,
                              builder: (context, v, _) => LinearProgressIndicator(
                                key: const Key('splash-progress'),
                                value: v,
                                minHeight: 3,
                                backgroundColor: Colors.white.withValues(alpha: 0.14),
                                color: AppColors.gold,
                              ),
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

/// The logo (no halo: nothing glows).
class _GlowingMark extends StatelessWidget {
  const _GlowingMark();

  @override
  Widget build(BuildContext context) {
    return const BrandMark(size: 76);
  }
}
