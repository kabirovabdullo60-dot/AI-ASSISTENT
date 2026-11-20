import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../models/chat_message_model.dart';
import 'motion/ai_orb.dart';
import 'motion/fade_slide_in.dart';
import 'motion/typewriter_text.dart';

/// One chat message. The user's question is a dark bubble on the right; the assistant's
/// answer is a white card on the left next to the AI orb. A [fresh] message slides in from
/// its own side, and a fresh answer types itself out.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.maxWidth, this.fresh = false});

  final ChatMessageModel message;
  final double maxWidth;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final width = math.min(maxWidth * (isUser ? 0.78 : 0.86), 680.0);
    const radius = Radius.circular(18);
    const corner = Radius.circular(5);

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppColors.navy : AppColors.card,
          border: isUser ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: isUser ? radius : corner,
            topRight: isUser ? corner : radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
        ),
        child: isUser
            ? SelectableText(message.text, style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 14))
            : TypewriterText(
                text: message.text,
                animate: fresh,
                style: TextStyle(color: AppColors.ink, height: 1.55, fontSize: 14),
              ),
      ),
    );

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[const AiOrb(size: 30), const SizedBox(width: 10)],
          Flexible(child: bubble),
        ],
      ),
    );

    if (!fresh) return row;
    return FadeSlideIn(
      duration: Motion.slow,
      offset: Offset(isUser ? 16 : -16, 6),
      beginScale: 0.96,
      alignment: isUser ? Alignment.bottomRight : Alignment.topLeft,
      child: row,
    );
  }
}
