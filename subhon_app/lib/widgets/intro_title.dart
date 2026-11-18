import 'package:flutter/material.dart';

/// The title of the launch intro ("ИИ бухгалтер"), animated by the intro
/// clock [seconds]: the letters rise in one by one, a light shimmer runs
/// across, and it all fades up and out before the colour drains.
class IntroTitle extends StatelessWidget {
  const IntroTitle({required this.text, required this.seconds, super.key});

  final String text;
  final double seconds;

  /// When the first letter starts, the delay between letters and how long
  /// one letter takes to appear.
  static const double _start = 0.4;
  static const double _stagger = 0.045;
  static const double _letter = 0.28;

  /// The shimmer sweep and the fade-out.
  static const double _shimmerFrom = 1.0;
  static const double _shimmerTo = 1.6;
  static const double _outFrom = 1.72;
  static const double _outTo = 1.92;

  static double _ramp(double s, double from, double to) =>
      ((s - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: Colors.white,
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      height: 1.1,
      decoration: TextDecoration.none,
      shadows: const [
        Shadow(color: Color(0x80FFFFFF), blurRadius: 18),
        Shadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 6),
      ],
    );

    final letters = text.characters.toList();
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < letters.length; i++)
          Builder(
            builder: (context) {
              final from = _start + i * _stagger;
              final t = Curves.easeOutBack.transform(
                _ramp(seconds, from, from + _letter),
              );
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - t)),
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * t,
                    child: Text(letters[i], style: style),
                  ),
                ),
              );
            },
          ),
      ],
    );

    // A light band sweeping from left to right over the letters.
    final sweep = _ramp(seconds, _shimmerFrom, _shimmerTo);
    final shimmer = sweep <= 0 || sweep >= 1
        ? row
        : ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Colors.white, Color(0xFFD9CCFF), Colors.white],
              stops: [
                (sweep - 0.2).clamp(0.0, 1.0),
                sweep,
                (sweep + 0.2).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: row,
          );

    final out = _ramp(seconds, _outFrom, _outTo);
    return Opacity(
      opacity: 1 - out,
      child: Transform.translate(offset: Offset(0, -10 * out), child: shimmer),
    );
  }
}
