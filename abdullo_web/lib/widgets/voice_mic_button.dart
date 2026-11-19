import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/voice_view_model.dart';

/// Microphone button. While listening it turns red and a soft ring pulses around it.
/// Hidden in browsers without speech recognition (e.g. Firefox).
class VoiceMicButton extends StatefulWidget {
  const VoiceMicButton({super.key, this.size = 40, this.filled = false});

  final double size;

  /// Filled teal circle (chat input) instead of a plain icon (top bar).
  final bool filled;

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse(bool listening) {
    final animate = listening && !Motion.reduced(context);
    if (animate && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!animate && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VoiceViewModel>();
    if (!vm.canListen) return const SizedBox.shrink();
    final tr = context.l10n;
    final listening = vm.isListening;
    _syncPulse(listening);
    final size = widget.size;
    final bg = listening ? AppColors.red : (widget.filled ? AppColors.tealSoft : Colors.transparent);
    final fg = listening ? Colors.white : (widget.filled ? AppColors.teal : AppColors.muted);

    return Tooltip(
      message: listening ? tr.voiceStop : tr.voiceSpeak,
      child: SizedBox(
        width: size + 8,
        height: size + 8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = _pulse.value;
                return Opacity(
                  opacity: listening ? (1 - t) * 0.5 : 0,
                  child: Container(
                    width: size + 8 * t,
                    height: size + 8 * t,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                  ),
                );
              },
            ),
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                child: InkWell(
                  key: Key(widget.filled ? 'voice-mic-chat' : 'voice-mic'),
                  onTap: () => vm.toggleListening(language: Localizations.localeOf(context).languageCode),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: AnimatedSwitcher(
                      duration: Motion.fast,
                      child: Icon(
                        listening ? Icons.mic : Icons.mic_none_rounded,
                        key: ValueKey(listening),
                        size: size * 0.5,
                        color: fg,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
