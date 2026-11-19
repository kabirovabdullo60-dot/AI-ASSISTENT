import 'package:flutter/material.dart';

import 'jelly_blob.dart';

/// The AI-assistant button pinned to the bottom-right corner: the living
/// jelly mascot (it wobbles and blinks) instead of a static icon. Still
/// with "reduce motion".
class AssistantFab extends StatefulWidget {
  const AssistantFab({
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;

  /// The tap area; the jelly is drawn a little larger so it reads as a
  /// round button with its soft shadow.
  static const double size = 64;

  @override
  State<AssistantFab> createState() => _AssistantFabState();
}

class _AssistantFabState extends State<AssistantFab> {
  /// The eyes look straight ahead; nothing to follow here.
  final _lookAt = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _lookAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: Semantics(
      button: true,
      label: widget.tooltip,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: SizedBox.square(
          dimension: AssistantFab.size,
          child: OverflowBox(
            maxWidth: AssistantFab.size * 1.35,
            maxHeight: AssistantFab.size * 1.35,
            child: JellyBlob(lookAt: _lookAt, size: AssistantFab.size * 1.35),
          ),
        ),
      ),
    ),
  );
}
