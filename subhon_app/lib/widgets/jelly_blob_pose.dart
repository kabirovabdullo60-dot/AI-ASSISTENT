import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// What the jelly blob looks like right now; the painter repaints on every
/// change.
class JellyBlobPose extends ChangeNotifier {
  /// Seconds since the blob appeared; drives the wobble.
  double time = 0;

  /// Where the eyes look: each axis -1 … 1, length at most 1.
  Offset look = Offset.zero;

  /// 1 eyes open, 0 closed.
  double openness = 1;

  void update({double? time, Offset? look, double? openness}) {
    if (time != null) this.time = time;
    if (look != null) this.look = look;
    if (openness != null) this.openness = openness;
    notifyListeners();
  }
}
