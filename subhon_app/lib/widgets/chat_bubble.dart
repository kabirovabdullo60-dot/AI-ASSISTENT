import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// One chat message: the person's on the right in the brand colour, the
/// assistant's on the left on a card. Text can be selected and copied.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.text, required this.fromUser, super.key});

  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    const corner = Radius.circular(AppRadius.lg);
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: fromUser ? p.primary : p.surface,
            border: fromUser ? null : Border.all(color: p.border),
            borderRadius: BorderRadius.only(
              topLeft: corner,
              topRight: corner,
              bottomLeft: fromUser ? corner : const Radius.circular(4),
              bottomRight: fromUser ? const Radius.circular(4) : corner,
            ),
          ),
          child: SelectableText(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: fromUser ? p.onPrimary : p.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
