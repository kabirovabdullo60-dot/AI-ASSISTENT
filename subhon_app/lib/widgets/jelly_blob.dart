import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'jelly_blob_pose.dart';
import 'jelly_blob_painter.dart';

/// The animated mascot of the login screen: a wobbling purple jelly with
/// two eyes that follow [lookAt] (a point in global coordinates: the
/// finger, the mouse or the text cursor), glance around when it is null
/// and blink now and then.
///
/// With [eyesClosed] it shuts its eyes (while the password is typed).
/// With "reduce motion" on it does not wobble or blink, only looks.
class JellyBlob extends StatefulWidget {
  const JellyBlob({
    required this.lookAt,
    this.eyesClosed = false,
    this.size = 132,
    super.key,
  });

  final ValueListenable<Offset?> lookAt;
  final bool eyesClosed;
  final double size;

  @override
  State<JellyBlob> createState() => _JellyBlobState();
}

class _JellyBlobState extends State<JellyBlob>
    with SingleTickerProviderStateMixin {
  final JellyBlobPose _pose = JellyBlobPose();
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  bool _reduceMotion = false;

  /// Distance (logical px) at which the eyes reach the edge.
  static const double _reach = 160;

  /// Seconds between blinks, and how long one lasts.
  static const double _blinkEvery = 3.6;
  static const double _blinkLength = 0.16;

  /// With nothing to look at, the eyes glance around: one spot every
  /// [_glanceEvery] seconds.
  static const double _glanceEvery = 1.3;
  static const _glances = <Offset>[
    Offset(0, 0.15),
    Offset(-0.7, 0.1),
    Offset(-0.4, -0.45),
    Offset(0.6, -0.2),
    Offset(0.75, 0.3),
    Offset(0, 0.4),
    Offset(-0.6, 0.35),
    Offset(0.3, -0.5),
  ];

  @override
  void initState() {
    super.initState();
    widget.lookAt.addListener(_onTarget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      if (_ticker.isActive) _ticker.stop();
      _snap();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(JellyBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lookAt != widget.lookAt) {
      oldWidget.lookAt.removeListener(_onTarget);
      widget.lookAt.addListener(_onTarget);
    }
    if (_reduceMotion) _snap();
  }

  @override
  void dispose() {
    widget.lookAt.removeListener(_onTarget);
    _ticker.dispose();
    _pose.dispose();
    super.dispose();
  }

  void _onTarget() {
    if (_reduceMotion) _snap();
  }

  /// Without animation: jump straight to the target.
  void _snap() =>
      _pose.update(look: _targetLook(), openness: widget.eyesClosed ? 0 : 1);

  /// Where the eyes should look: toward [JellyBlob.lookAt], or a slow
  /// glance around when there is nothing to look at.
  Offset _targetLook() {
    final target = widget.lookAt.value;
    final box = context.findRenderObject() as RenderBox?;
    if (target == null || box == null || !box.hasSize) {
      final step = (_pose.time / _glanceEvery).floor() % _glances.length;
      return _glances[step];
    }
    final d = target - box.localToGlobal(box.size.center(Offset.zero));
    final distance = d.distance;
    if (distance < 1) return Offset.zero;
    return d / distance * math.min(distance / _reach, 1);
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final t = elapsed.inMicroseconds / 1e6;
    // Ease toward the target, so the eyes glide instead of jumping.
    final follow = 1 - math.exp(-dt * 10);
    final look = Offset.lerp(_pose.look, _targetLook(), follow)!;

    final phase = t % _blinkEvery;
    final double openness;
    if (!widget.eyesClosed && phase < _blinkLength) {
      openness = (2 * phase / _blinkLength - 1).abs(); // a quick blink
    } else {
      final open = widget.eyesClosed ? 0.0 : 1.0;
      openness = _pose.openness + (open - _pose.openness) * follow;
    }
    _pose.update(time: t, look: look, openness: openness.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(widget.size),
      painter: JellyBlobPainter(_pose),
    ),
  );
}
