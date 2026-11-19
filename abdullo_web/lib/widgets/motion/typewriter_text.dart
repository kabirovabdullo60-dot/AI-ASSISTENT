import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';

/// A fresh assistant answer "types itself out" (quickly — at most ~1.6 s, whatever its
/// length), with a blinking caret, then becomes normal selectable text.
/// Old messages and reduced motion show the full text at once.
class TypewriterText extends StatefulWidget {
  const TypewriterText({super.key, required this.text, required this.style, this.animate = true});

  final String text;
  final TextStyle style;
  final bool animate;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<String> _chars = widget.text.characters.toList();

  @override
  void initState() {
    super.initState();
    final ms = (_chars.length * 14).clamp(350, 1600);
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    );
    if (widget.animate) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return SelectableText(widget.text, style: widget.style);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        if (_c.isCompleted) return SelectableText(widget.text, style: widget.style);
        final n = (Curves.easeOutCubic.transform(_c.value) * _chars.length).round();
        final caretOn = (_c.value * 10).floor().isEven;
        return Text.rich(
          TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: _chars.take(n).join()),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  width: 2,
                  height: (widget.style.fontSize ?? 14) * 1.15,
                  margin: const EdgeInsets.only(left: 2),
                  color: widget.style.color?.withValues(alpha: caretOn ? 0.8 : 0.15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
