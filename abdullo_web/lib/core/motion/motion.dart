import 'package:flutter/widgets.dart';

/// Motion tokens for the whole web — one place for durations and curves.
///
/// Rules: UI feedback stays under 300 ms, entering things use a strong ease-out
/// (fast start = feels instant), nothing appears from scale 0, and when the system asks
/// for reduced motion we keep fades but drop movement.
abstract final class Motion {
  /// Press feedback, hover, small color changes.
  static const fast = Duration(milliseconds: 150);

  /// Page switches, popovers, most entrances.
  static const base = Duration(milliseconds: 240);

  /// Larger reveals (chat bubbles, cards).
  static const slow = Duration(milliseconds: 380);

  /// Data reveals (progress bars) — seen rarely, can take longer.
  static const reveal = Duration(milliseconds: 700);

  /// Delay between items that enter together.
  static const stagger = Duration(milliseconds: 45);

  /// Strong ease-out: starts fast, settles softly. Default for anything entering.
  static const easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Strong ease-in-out: for things moving on screen.
  static const easeInOut = Cubic(0.77, 0, 0.175, 1);

  /// True when the OS / browser asks for reduced motion → no movement, only fades.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Stagger delay for item [i], capped so long lists never feel slow.
  static Duration staggerAt(int i, {int max = 8}) => stagger * (i < max ? i : max);
}
