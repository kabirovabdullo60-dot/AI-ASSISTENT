import 'dart:async';

import 'package:flutter/widgets.dart';

/// Feeds where [child] is pressed (finger or mouse click, in global
/// coordinates) into [lookAt] for the mascot's eyes; a moment after the
/// press ends it goes back to null (look straight ahead), unless [keep]
/// says otherwise (e.g. while the e-mail text is being followed).
///
/// Taps still reach [child] as usual.
class LookAtPointer extends StatefulWidget {
  const LookAtPointer({
    required this.lookAt,
    required this.child,
    this.keep,
    super.key,
  });

  final ValueNotifier<Offset?> lookAt;
  final bool Function()? keep;
  final Widget child;

  /// How long the eyes stay on the spot after the press ends.
  static const releaseAfter = Duration(milliseconds: 1200);

  @override
  State<LookAtPointer> createState() => _LookAtPointerState();
}

class _LookAtPointerState extends State<LookAtPointer> {
  Timer? _release;

  @override
  void dispose() {
    _release?.cancel();
    super.dispose();
  }

  void _pressed(PointerEvent event) {
    _release?.cancel();
    widget.lookAt.value = event.position;
  }

  void _released(PointerEvent event) {
    _release?.cancel();
    _release = Timer(LookAtPointer.releaseAfter, () {
      if (mounted && !(widget.keep?.call() ?? false)) {
        widget.lookAt.value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _pressed,
    onPointerMove: _pressed,
    onPointerUp: _released,
    onPointerCancel: _released,
    child: widget.child,
  );
}
