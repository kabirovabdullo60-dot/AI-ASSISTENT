import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../viewmodels/chat_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/jelly_blob.dart';

/// Talking with the AI assistant by voice: the jelly mascot is its face —
/// it listens, thinks (eyes closed) and reads the answer aloud, then
/// listens again. Uses the same conversation as the chat
/// ([ChatViewModel] from the chat screen).
class VoiceChatView extends StatefulWidget {
  const VoiceChatView({super.key});

  @override
  State<VoiceChatView> createState() => _VoiceChatViewState();
}

class _VoiceChatViewState extends State<VoiceChatView> {
  final _lookAt = ValueNotifier<Offset?>(null);
  late final ChatViewModel _vm = context.read<ChatViewModel>();

  String get _language => Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    // Start listening once the page is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.startVoice(_language);
    });
  }

  @override
  void dispose() {
    _vm.stopVoice(notify: false);
    _lookAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<ChatViewModel>();
    final state = vm.voiceState;
    final status = switch (state) {
      VoiceState.listening => l10n.voiceListening,
      VoiceState.thinking => l10n.assistantThinking,
      VoiceState.speaking => l10n.voiceSpeaking,
      VoiceState.off => l10n.voiceTapToTalk,
    };
    final busy = state == VoiceState.listening || state == VoiceState.thinking;
    final answer = vm.lastAnswer?.text;
    final error = vm.voiceUnavailable
        ? l10n.voiceUnavailable
        : vm.micFailed
        ? l10n.voiceMicFailed
        : vm.error == null
        ? null
        : errorText(l10n, vm.error!);
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppBar(title: Text(l10n.voiceTitle)),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),
              JellyBlob(
                lookAt: _lookAt,
                eyesClosed: state == VoiceState.thinking,
                size: 190,
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                liveRegion: true,
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (busy && vm.heard.isNotEmpty)
                Text(
                  '«${vm.heard}»',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: p.textSecondary,
                  ),
                )
              else if (!busy && answer != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: AppCard(
                    child: SingleChildScrollView(
                      child: Text(answer, style: theme.textTheme.bodyMedium),
                    ),
                  ),
                )
              else if (vm.messages.isEmpty)
                Text(
                  l10n.voiceHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              if (error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: p.error),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(
                    tooltip: l10n.voiceMic,
                    icon: state == VoiceState.listening
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_rounded,
                    color: p.onPrimary,
                    background: busy ? p.secondary : p.primary,
                    size: 76,
                    onPressed: busy ? null : () => vm.startVoice(_language),
                  ),
                  const SizedBox(width: AppSpacing.xxxl),
                  _RoundButton(
                    tooltip: l10n.voiceEnd,
                    icon: Icons.call_end_rounded,
                    color: Colors.white,
                    background: p.error,
                    size: 60,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.background,
    required this.size,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: color, size: size * 0.42),
          ),
        ),
      ),
    ),
  );
}
