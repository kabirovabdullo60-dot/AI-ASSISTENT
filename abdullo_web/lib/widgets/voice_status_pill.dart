import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/voice_view_model.dart';

/// Floating pill at the top of the page: what the mic hears, which page a command opened,
/// or why listening failed. Tap to hide.
class VoiceStatusPill extends StatelessWidget {
  const VoiceStatusPill({super.key});

  String _errorText(BuildContext context, String? code) {
    final tr = context.l10n;
    return switch (code) {
      'not-allowed' || 'service-not-allowed' => tr.voiceDenied,
      'no-speech' => tr.voiceNoSpeech,
      'audio-capture' => tr.voiceNoMic,
      'unsupported' || 'language-not-supported' => tr.voiceUnsupported,
      'network' => tr.voiceNetwork,
      _ => tr.voiceError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VoiceViewModel>();
    final tr = context.l10n;

    final (IconData icon, Color color, String text) = switch (vm.status) {
      VoiceStatus.listening => (Icons.mic, AppColors.red, vm.heard.isEmpty ? tr.voiceListening : vm.heard),
      VoiceStatus.opened => (Icons.check_circle_outline, AppColors.teal, tr.voiceOpened(tr.section(vm.opened!))),
      VoiceStatus.failed => (Icons.mic_off_outlined, AppColors.red, _errorText(context, vm.errorCode)),
      VoiceStatus.idle => (Icons.mic, AppColors.teal, ''),
    };
    final visible = vm.status != VoiceStatus.idle;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -0.4),
        duration: Motion.reduced(context) ? Duration.zero : Motion.base,
        curve: Motion.easeOut,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: Motion.base,
          child: GestureDetector(
            onTap: vm.dismiss,
            child: Container(
              key: const Key('voice-pill'),
              constraints: const BoxConstraints(maxWidth: 520),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: AppColors.navy.withValues(alpha: 0.14), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
