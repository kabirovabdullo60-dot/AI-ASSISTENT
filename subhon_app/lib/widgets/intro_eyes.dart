import 'package:flutter/material.dart';

/// The two small eyes of the launch intro.
///
/// [look] moves both eyes sideways: -1 is fully left, 0 centre, 1 right.
/// [openness] squeezes them vertically: 1 open, 0 closed (a blink).
class IntroEyes extends StatelessWidget {
  const IntroEyes({
    required this.look,
    required this.openness,
    this.color = Colors.white,
    super.key,
  });

  final double look;
  final double openness;
  final Color color;

  static const double _eyeWidth = 14;
  static const double _eyeHeight = 20;
  static const double _gap = 10;

  /// How far the eyes travel when looking fully to one side.
  static const double _travel = 14;

  @override
  Widget build(BuildContext context) {
    final eye = Container(
      width: _eyeWidth,
      height: _eyeHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(_eyeWidth / 2)),
      ),
    );
    return Transform.translate(
      offset: Offset(look * _travel, 0),
      child: Transform.scale(
        scaleX: 1,
        scaleY: openness.clamp(0.0, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            eye,
            const SizedBox(width: _gap),
            eye,
          ],
        ),
      ),
    );
  }
}
