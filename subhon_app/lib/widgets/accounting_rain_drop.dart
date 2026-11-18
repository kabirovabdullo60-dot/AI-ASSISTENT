import 'dart:math' as math;

import 'accounting_item_kind.dart';

/// One falling item of the accounting rain. Positions are fractions of the
/// screen, so the same drops fit any size.
class AccountingRainDrop {
  const AccountingRainDrop({
    required this.kind,
    required this.x,
    required this.phase,
    required this.size,
    required this.speed,
    required this.depth,
    required this.angle,
    required this.spin,
    required this.tiltX,
    required this.tiltY,
    required this.tiltSpeed,
  });

  final AccountingItemKind kind;

  /// Horizontal position, 0 … 1 of the width.
  final double x;

  /// Where in its fall the drop starts, 0 … 1.
  final double phase;

  /// Side of the item's box in logical px (before [depth]).
  final double size;

  /// Falling speed in logical px per second (before [depth]).
  final double speed;

  /// 0.45 far (small, dim, slow) … 1 near.
  final double depth;

  /// Start angle and turning speed (radians, radians per second).
  final double angle;
  final double spin;

  /// How far it rocks around the x / y axis (radians), and how fast.
  final double tiltX;
  final double tiltY;
  final double tiltSpeed;

  /// A fixed, varied set of drops (the same on every start), far ones first
  /// so near ones are painted over them.
  static List<AccountingRainDrop> generate({int count = 22, int seed = 7}) {
    final random = math.Random(seed);
    double between(double a, double b) => a + random.nextDouble() * (b - a);
    const kinds = AccountingItemKind.values;
    final drops = [
      for (var i = 0; i < count; i++)
        AccountingRainDrop(
          kind: kinds[i % kinds.length],
          // Spread evenly across the width, with a little jitter.
          x: ((i * 0.618034) % 1) * 0.9 + 0.05 + between(-0.03, 0.03),
          phase: random.nextDouble(),
          size: between(48, 84),
          speed: between(38, 70),
          depth: between(0.45, 1),
          angle: between(0, 2 * math.pi),
          spin: between(-0.5, 0.5),
          tiltX: between(0.25, 0.7),
          tiltY: between(0.25, 0.8),
          tiltSpeed: between(0.6, 1.3),
        ),
    ]..sort((a, b) => a.depth.compareTo(b.depth));
    return drops;
  }
}
