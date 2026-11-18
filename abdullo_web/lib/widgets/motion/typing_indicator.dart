import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import 'ai_orb.dart';
import 'fade_slide_in.dart';

/// "The assistant is thinking": swirling orb + three dots rising in a wave + a label.
/// Shown only while a question is being answered.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, required this.label});

  final String label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return FadeSlideIn(
      offset: const Offset(-10, 0),
      duration: Motion.base,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            key: const Key('chat-typing'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const AiOrb(size: 30, thinking: true),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) => Row(
                        children: [
                          for (var i = 0; i < 3; i++)
                            _dot(reduced ? 0.5 : (math.sin((_c.value - i * 0.16) * 2 * math.pi) + 1) / 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(widget.label, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [v] 0..1 — height and brightness of one dot in the wave.
  Widget _dot(double v) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.5),
    child: Transform.translate(
      offset: Offset(0, -4 * v),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(AppColors.barGray, AppColors.gold, v)),
      ),
    ),
  );
}
