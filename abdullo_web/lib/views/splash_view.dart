import 'package:flutter/material.dart';

import '../core/constants/brand.dart';
import '../core/l10n/l10n.dart';
import '../widgets/brand_mark.dart';
import '../widgets/motion/photo_slideshow.dart';

/// Shown while the saved session is checked: a photograph of money drifting very slowly under
/// a neutral black scrim, the mark and the product's name, its one-line promise, and a thin
/// white line that fills over [duration].
class SplashView extends StatelessWidget {
  const SplashView({super.key, this.duration = Duration.zero});

  /// How long the splash is held; the progress line fills over exactly this time.
  final Duration duration;

  static const photo = 'assets/images/money_stack.jpg';

  @override
  Widget build(BuildContext context) {
    LinearProgressIndicator bar([double? v]) => LinearProgressIndicator(
      key: const Key('splash-progress'),
      value: v,
      minHeight: 2,
      backgroundColor: const Color(0x33FFFFFF),
      color: Colors.white,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhotoSlideshow(images: [photo], hold: Duration(seconds: 10), zoom: 0.06),
          // A neutral scrim (no colour cast): the photograph stays a photograph, the words stay legible.
          const DecoratedBox(decoration: BoxDecoration(color: Color(0xA6000000))),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 64, light: true),
                  const SizedBox(height: 24),
                  const Text(
                    AppBrand.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      context.l10n.loginHeadline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xD9FFFFFF), fontSize: 16, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 180,
                    child: duration == Duration.zero
                        ? bar()
                        // Fills from 0 to 100% over the splash time.
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: duration,
                            curve: Curves.easeInOutCubic,
                            builder: (context, v, _) => bar(v),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Text(
              'Photo: Giorgio Trovato · Unsplash',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
