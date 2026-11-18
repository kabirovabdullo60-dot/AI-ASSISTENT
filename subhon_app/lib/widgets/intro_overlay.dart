import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import 'drip_painter.dart';
import 'intro_eyes.dart';
import 'intro_title.dart';

/// Length of the launch intro, in seconds.
const double _total = 2.6;

/// When the sheet starts draining upward, in seconds.
const double _drainStart = 1.95;

/// Where the eyes look over time: (seconds, -1 left … 1 right).
const _lookKeys = <(double, double)>[
  (0.35, 0),
  (0.60, -1),
  (0.95, -1),
  (1.25, 1),
  (1.60, 1),
  (1.80, 0),
];

/// The launch intro, played once over [child] when the app opens: a full
/// screen of the brand colour with two eyes in the middle that look left
/// and right and blink, with [title] ("ИИ бухгалтер") under them, then the
/// colour drains upward with drips and shows the app (login or home)
/// underneath.
///
/// Taps go straight to [child]; with "reduce motion" on it is skipped.
class IntroOverlay extends StatefulWidget {
  const IntroOverlay({required this.child, this.title, super.key});

  final Widget child;

  /// Shown under the eyes.
  final String? title;

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600), // = _total
  );
  late final Animation<double> _drain = CurvedAnimation(
    parent: _clock,
    curve: const Interval(_drainStart / _total, 1),
  );
  bool _done = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _done = true;
      return;
    }
    _clock.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  static double _look(double s) {
    if (s <= _lookKeys.first.$1) return _lookKeys.first.$2;
    for (var i = 1; i < _lookKeys.length; i++) {
      final (t1, v1) = _lookKeys[i];
      if (s <= t1) {
        final (t0, v0) = _lookKeys[i - 1];
        final f = Curves.easeInOut.transform((s - t0) / (t1 - t0));
        return v0 + (v1 - v0) * f;
      }
    }
    return _lookKeys.last.$2;
  }

  /// 0 → 1 between [from] and [to] seconds.
  static double _ramp(double s, double from, double to) =>
      ((s - from) / (to - from)).clamp(0.0, 1.0);

  static double _openness(double s) {
    final open = Curves.easeOutBack.transform(_ramp(s, 0.1, 0.35));
    // One quick blink, then the eyes close just before the drain.
    final blink = 1 - 0.9 * (1 - (2 * _ramp(s, 1.05, 1.21) - 1).abs());
    final close = 1 - Curves.easeIn.transform(_ramp(s, 1.82, 1.95));
    return open * blink * close;
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: CustomPaint(
                  painter: DripPainter(
                    progress: _drain,
                    color: AppColors.primary,
                  ),
                  child: AnimatedBuilder(
                    animation: _clock,
                    builder: (context, _) {
                      final s = _clock.value * _total;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IntroEyes(look: _look(s), openness: _openness(s)),
                          if (widget.title != null)
                            Transform.translate(
                              offset: const Offset(0, 48),
                              child: IntroTitle(
                                text: widget.title!,
                                seconds: s,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
