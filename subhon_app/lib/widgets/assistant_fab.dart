import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The round AI-assistant button pinned to the bottom-right corner, in the
/// brand gradient with the ✨ icon.
class AssistantFab extends StatelessWidget {
  const AssistantFab({
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;

  static const double size = 56;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      label: tooltip,
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shadowColor: AppColors.primary.withValues(alpha: 0.5),
        child: Ink(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9B7BFF), AppColors.primary, Color(0xFF5A35D6)],
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    ),
  );
}
