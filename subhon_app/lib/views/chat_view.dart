import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../models/assistant_action_model.dart';
import '../models/assistant_action_status.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';
import '../services/voice_service.dart';
import '../viewmodels/chat_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/assistant_action_card.dart';
import '../widgets/assistant_action_labels.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/jelly_blob.dart';
import 'chat_history_view.dart';
import 'voice_chat_view.dart';

/// The AI assistant: ask about your money and the business and get answers
/// built from the real figures, in the language you write in. It can
/// propose changes ("add a store…") that run only after Confirm. Chats are
/// saved and show up on every device. The jelly mascot thinks while the
/// answer is coming.
class ChatView extends StatelessWidget {
  const ChatView({this.personalContext, this.onDataChanged, super.key});

  /// My personal finances as a note for the assistant.
  final String? Function()? personalContext;

  /// A confirmed change: the other screens reload.
  final VoidCallback? onDataChanged;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ChatViewModel(
      context.read<AssistantService>(),
      voice: context.read<VoiceService>(),
      userId: context.read<SessionViewModel>().user?.id,
      personalContext: personalContext,
      onDataChanged: onDataChanged,
    ),
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

  Future<void> _openHistory() async {
    final vm = context.read<ChatViewModel>();
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ChatHistoryView(
          userId: vm.userId,
          currentId: vm.conversationId,
          onDeleted: vm.forget,
        ),
      ),
    );
    if (id != null) await vm.open(id);
  }

  Future<void> _confirm(AssistantActionModel action) async {
    final vm = context.read<ChatViewModel>();
    if (action.danger) {
      final l10n = context.l10n;
      final sure = await showAppConfirmDialog(
        context,
        title: l10n.actSureTitle,
        message: l10n.actSureMessage(action.summary),
        confirmLabel: l10n.actConfirm,
        destructive: true,
      );
      if (!sure) return;
    }
    await vm.confirmAction(action.id);
  }

  /// One assistant message with its proposed changes under it.
  Widget _message(ChatViewModel vm, ChatMessageModel m) {
    final bubble = ChatBubble(text: m.text, fromUser: m.fromUser);
    if (m.actions.isEmpty) return bubble;
    final l10n = context.l10n;
    final labels = AssistantActionLabels(
      confirm: l10n.actConfirm,
      confirmAgain: l10n.actConfirmAgain,
      cancel: l10n.actCancel,
      done: l10n.actDone,
      cancelled: l10n.actCancelled,
      expired: l10n.actExpired,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bubble,
        for (final a in m.actions)
          AssistantActionCard(
            summary: a.summary,
            status: a.status,
            danger: a.danger,
            busy: vm.isActionBusy(a.id),
            labels: labels,
            problem: vm.actionError(a.id) != null
                ? errorText(l10n, vm.actionError(a.id)!)
                : a.status == AssistantActionStatus.failed
                ? l10n.actFailed(
                    errorText(
                      l10n,
                      ApiException(422, a.errorCode ?? 'VALIDATION_ERROR'),
                    ),
                  )
                : null,
            onConfirm: () => _confirm(a),
            onCancel: () => vm.cancelAction(a.id),
          ),
      ],
    );
  }

  void _openVoice() {
    final vm = context.read<ChatViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VoiceChatView(),
        ),
      ),
    );
  }

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
      appBar: AppBar(
        title: Text(l10n.assistantTitle),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: l10n.chatNew,
              onPressed: vm.isSending || vm.isOpening ? null : vm.newChat,
              icon: const Icon(Icons.edit_square),
            ),
          IconButton(
            tooltip: l10n.chatHistory,
            onPressed: vm.isSending ? null : _openHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: vm.isOpening
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? _Welcome(lookAt: _lookAt, onAsk: vm.canSend ? _send : null)
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
                        return _message(vm, m);
                      },
                    ),
            ),
            if (vm.waitSeconds > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.sm,
                ),
                child: AppInlineMessage(
                  type: InlineMessageType.warning,
                  message: l10n.chatWaitSeconds(vm.waitSeconds),
                ),
              )
            else if (vm.error != null)
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
                        onPressed: vm.canSend ? vm.retry : null,
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
                    IconButton(
                      tooltip: l10n.voiceOpen,
                      onPressed: vm.canSend ? _openVoice : null,
                      icon: const Icon(Icons.mic_none_rounded),
                    ),
                    IconButton.filled(
                      tooltip: l10n.assistantSend,
                      onPressed: vm.canSend ? _send : null,
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
      l10n.assistantSuggestSpending,
      l10n.assistantSuggestMonth,
      l10n.assistantSuggestToday,
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
