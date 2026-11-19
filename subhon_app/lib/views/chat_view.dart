import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../services/assistant_service.dart';
import '../viewmodels/chat_view_model.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/jelly_blob.dart';

/// The AI assistant (`POST /api/assistant/chat`): ask about the business
/// and get answers built from its real figures, in the app's language.
/// The jelly mascot greets you and thinks while the answer is coming.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ChatViewModel(context.read<AssistantService>()),
    child: const _Chat(),
  );
}

class _Chat extends StatefulWidget {
  const _Chat();

  @override
  State<_Chat> createState() => _ChatState();
}

class _ChatState extends State<_Chat> {
  final _input = TextEditingController();
  final _lookAt = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _input.dispose();
    _lookAt.dispose();
    super.dispose();
  }

  String get _language => Localizations.localeOf(context).languageCode;

  Future<void> _send([String? text]) async {
    final vm = context.read<ChatViewModel>();
    final question = text ?? _input.text;
    if (await vm.send(question, _language)) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<ChatViewModel>();
    final messages = vm.messages;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistantTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _Welcome(
                      lookAt: _lookAt,
                      onAsk: vm.isSending ? null : _send,
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.md,
                        AppSpacing.screen,
                        AppSpacing.md,
                      ),
                      itemCount: messages.length + (vm.isSending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (vm.isSending && i == 0) {
                          return _Thinking(lookAt: _lookAt);
                        }
                        final m =
                            messages[messages.length -
                                1 -
                                (i - (vm.isSending ? 1 : 0))];
                        return ChatBubble(text: m.text, fromUser: m.fromUser);
                      },
                    ),
            ),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppInlineMessage(
                        type: InlineMessageType.error,
                        message: errorText(l10n, vm.error!),
                      ),
                    ),
                    if (vm.canRetry)
                      TextButton(
                        onPressed: () => vm.retry(_language),
                        child: Text(l10n.commonRetry),
                      ),
                  ],
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: p.surface,
                border: Border(top: BorderSide(color: p.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: ChatViewModel.maxLength,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: l10n.assistantHint,
                          counterText: '',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton.filled(
                      tooltip: l10n.assistantSend,
                      onPressed: vm.isSending ? null : _send,
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// No messages yet: the mascot, what it can do and a few questions to tap.
class _Welcome extends StatelessWidget {
  const _Welcome({required this.lookAt, required this.onAsk});

  final ValueNotifier<Offset?> lookAt;
  final ValueChanged<String>? onAsk;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final suggestions = [
      l10n.assistantSuggestToday,
      l10n.assistantSuggestBestStore,
      l10n.assistantSuggestSalary,
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(child: JellyBlob(lookAt: lookAt, size: 120)),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.assistantIntro,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final s in suggestions)
              ActionChip(
                label: Text(s),
                onPressed: onAsk == null ? null : () => onAsk!(s),
              ),
          ],
        ),
      ],
    );
  }
}

/// The answer is on its way: a small mascot and "Думаю…".
class _Thinking extends StatelessWidget {
  const _Thinking({required this.lookAt});

  final ValueNotifier<Offset?> lookAt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        JellyBlob(lookAt: lookAt, size: 44),
        const SizedBox(width: AppSpacing.sm),
        Text(
          context.l10n.assistantThinking,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.palette.textSecondary),
        ),
      ],
    ),
  );
}
