import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// Full-bleed photos that slowly zoom in (Ken Burns) and cross-fade into each other.
/// Shows each photo once for [hold] and then rests on the last one — no endless loop.
/// Reduced motion shows the first photo, still.
class PhotoSlideshow extends StatefulWidget {
  const PhotoSlideshow({
    super.key,
    required this.images,
    this.hold = const Duration(seconds: 6),
    this.zoom = 0.08,
    this.alignment = Alignment.center,
  });

  /// Asset paths.
  final List<String> images;
  final Duration hold;

  /// How much each photo grows while shown (0.08 = 8%).
  final double zoom;
  final Alignment alignment;

  @override
  State<PhotoSlideshow> createState() => _PhotoSlideshowState();
}

class _PhotoSlideshowState extends State<PhotoSlideshow> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  /// Last part of each slot where the next photo fades in.
  static const _fade = 0.22;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.hold * widget.images.length)..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in widget.images) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _photo(String path, double scale) => Transform.scale(
    scale: scale,
    alignment: widget.alignment,
    child: Image.asset(
      path,
      fit: BoxFit.cover,
      alignment: widget.alignment,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final n = widget.images.length;
    if (n == 0) return const SizedBox.shrink();
    if (Motion.reduced(context)) return ClipRect(child: _photo(widget.images.first, 1));
    return ClipRect(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final seg = _c.value * n;
          final i = seg.floor().clamp(0, n - 1);
          final local = (seg - i).clamp(0.0, 1.0);
          final fadeIn = i < n - 1 && local > 1 - _fade ? (local - (1 - _fade)) / _fade : 0.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              _photo(widget.images[i], 1 + widget.zoom * Curves.easeOut.transform(local)),
              if (fadeIn > 0)
                Opacity(opacity: Curves.easeInOut.transform(fadeIn), child: _photo(widget.images[i + 1], 1)),
            ],
          );
        },
      ),
    );
  }
}
