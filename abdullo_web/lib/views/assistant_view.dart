import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/app_dialog.dart';
import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/assistant_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../models/chat_message_model.dart';
import '../viewmodels/voice_view_model.dart';
import '../widgets/assistant_action_card.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_history_list.dart';
import '../widgets/motion/ai_orb.dart';
import '../widgets/motion/border_beam.dart';
import '../widgets/motion/gradient_text.dart';
import '../widgets/motion/fade_slide_in.dart';
import '../widgets/motion/pressable.dart';
import '../widgets/motion/typing_indicator.dart';
import '../widgets/voice_mic_button.dart';

/// AI assistant — POST /api/assistant/chat (answers in the selected language).
class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _shownCount = 0;

  /// Wide page: the history panel on the right is open (hide/show with its top button).
  bool _historyOpen = true;

  /// Messages from this index on arrived while the page is open → they animate in.
  int? _freshFrom;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(AssistantViewModel vm, [String? text]) {
    final value = text ?? _input.text;
    if (value.trim().isEmpty) return;
    _input.clear();
    vm.send(value, language: Localizations.localeOf(context).languageCode);
  }

  void _scrollToBottomIfNew(int count) {
    if (count == _shownCount) return;
    _shownCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: Motion.slow, curve: Motion.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<AssistantViewModel>();
    final messages = vm.messages;
    _freshFrom ??= messages.length;
    if (messages.isEmpty) _freshFrom = 0;
    final itemCount = messages.length + (vm.isSending ? 1 : 0);
    _scrollToBottomIfNew(itemCount);

    Widget chat(bool showHistoryButton) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _chatWidth + 40),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: Motion.base,
                  switchInCurve: Motion.easeOut,
                  child: messages.isEmpty
                      ? _EmptyChat(key: const ValueKey('empty'), onSuggestion: (s) => _send(vm, s))
                      : ListView.builder(
                          key: const Key('chat-list'),
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          itemCount: itemCount,
                          itemBuilder: (context, i) => i < messages.length
                              ? _MessageWithActions(
                                  key: ValueKey('m$i'),
                                  vm: vm,
                                  message: messages[i],
                                  maxWidth: constraints.maxWidth,
                                  fresh: i >= _freshFrom! && i >= messages.length - 2,
                                )
                              : _Thinking(label: tr.assistantThinking, slowLabel: tr.assistantSlow),
                        ),
                ),
              ),
              AnimatedSize(
                duration: Motion.base,
                curve: Motion.easeOut,
                child: vm.error == null
                    ? const SizedBox(width: double.infinity)
                    : FadeSlideIn(
                        offset: const Offset(0, 6),
                        duration: Motion.base,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, size: 18, color: AppColors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(switch (vm.error) {
                                  'RATE_LIMITED' when vm.retryAfter != null => tr.assistantBusyWait(vm.retryAfter!),
                                  'RATE_LIMITED' => tr.assistantBusy,
                                  'ASSISTANT_UNAVAILABLE' => tr.assistantUnavailable,
                                  'NETWORK_ERROR' => tr.assistantError,
                                  final code? => tr.error(code),
                                  null => '',
                                }, style: TextStyle(color: AppColors.red, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _chatWidth + 40),
                child: _InputBar(
                  controller: _input,
                  enabled: !vm.isSending,
                  sending: vm.isSending,
                  canClear: messages.isNotEmpty && !vm.isSending,
                  onSend: () => _send(vm),
                  onClear: vm.clear,
                  onHistory: showHistoryButton ? () => _openHistorySheet(vm) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wide page: history panel on the right, full height, with a hide button at its top.
    // Hiding slides it out to the right while it fades, and the chat widens with it;
    // then a small history button fades in at the top-right corner. Narrow: a sheet.
    return LayoutBuilder(
      builder: (context, page) {
        if (page.maxWidth < _historyPanelMinWidth) return chat(true);
        final duration = Motion.reduced(context) ? Duration.zero : const Duration(milliseconds: 300);
        final open = _historyOpen;
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: chat(false)),
                AnimatedContainer(
                  key: const Key('history-slot'),
                  duration: duration,
                  curve: Motion.easeInOut,
                  width: open ? _historyPanelWidth + 12 : 0,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: _historyPanelWidth + 12,
                      maxWidth: _historyPanelWidth + 12,
                      child: AnimatedSlide(
                        duration: duration,
                        curve: Motion.easeInOut,
                        offset: open ? Offset.zero : const Offset(0.25, 0),
                        child: AnimatedOpacity(
                          duration: duration,
                          curve: Motion.easeOut,
                          opacity: open ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: !open,
                            child: Container(
                              key: const Key('history-panel'),
                              margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: _history(vm, onHide: () => setState(() => _historyOpen = false)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IgnorePointer(
                ignoring: open,
                child: AnimatedOpacity(
                  // Waits for the panel to leave before appearing; leaves at once when it opens.
                  duration: open ? Motion.fast : duration,
                  curve: open ? Curves.linear : const Interval(0.5, 1, curve: Curves.easeOut),
                  opacity: open ? 0 : 1,
                  child: AnimatedScale(
                    duration: duration,
                    curve: Motion.easeOut,
                    scale: open ? 0.85 : 1,
                    child: Material(
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: IconButton(
                        key: const Key('history-show'),
                        tooltip: context.l10n.showHistory,
                        onPressed: () => setState(() => _historyOpen = true),
                        icon: Icon(Icons.history, color: AppColors.muted),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _history(AssistantViewModel vm, {VoidCallback? onPicked, VoidCallback? onHide}) => ChatHistoryList(
    onHide: onHide,
    conversations: vm.conversations,
    currentId: vm.currentId,
    enabled: !vm.isSending,
    onOpen: (id) async {
      onPicked?.call();
      _freshFrom = 1 << 30; // nothing loaded animates…
      await vm.open(id);
      // Loaded messages appear at once; only new ones animate in.
      if (mounted) setState(() => _freshFrom = null);
    },
    onDelete: (id) => _confirmDelete(vm, id),
    onNewChat: () {
      vm.clear();
      onPicked?.call();
    },
  );

  void _openHistorySheet(AssistantViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      builder: (sheet) => SafeArea(
        // Rebuilds when a chat is deleted while the sheet is open.
        child: ListenableBuilder(
          listenable: vm,
          builder: (_, _) => _history(vm, onPicked: () => Navigator.of(sheet).pop()),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AssistantViewModel vm, String id) async {
    final tr = context.l10n;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(tr.deleteChat),
        content: Text(tr.deleteChatConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(tr.cancel)),
          FilledButton(
            key: const Key('history-delete-confirm'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (ok == true) await vm.delete(id);
  }
}

/// Page width from which the history sits beside the chat instead of in a sheet.
const double _historyPanelMinWidth = 900;

/// Width of the history panel on the right.
const double _historyPanelWidth = 280;

/// Empty chat: orb + one line of intro + a "live data" pill, then four example questions
/// in a 2×2 grid (one column on phones). Faint Pamir ridgelines sit at the bottom.
class _EmptyChat extends StatelessWidget {
  const _EmptyChat({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final theme = Theme.of(context);
    final suggestions = [
      (Icons.trending_up, tr.suggestSales, tr.askSales),
      (Icons.storefront_outlined, tr.suggestStores, tr.askStores),
      (Icons.account_balance_wallet_outlined, tr.suggestSalaries, tr.askSalaries),
      (Icons.campaign_outlined, tr.suggestMarketing, tr.askMarketing),
    ];

    return LayoutBuilder(
      builder: (context, viewport) => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight - 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _chatWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FadeSlideIn(
                        beginScale: 0.9,
                        offset: Offset(0, 6),
                        duration: Motion.slow,
                        child: AiOrb(size: 64),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: Motion.staggerAt(1),
                        child: AnimatedGradientText(
                          tr.askAssistant,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeSlideIn(
                        delay: Motion.staggerAt(2),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Text(
                            tr.assistantIntro,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.5),
                          ),
                        ),
                      ),
                      if (context.select<VoiceViewModel, bool>((v) => v.canListen)) ...[
                        const SizedBox(height: 10),
                        FadeSlideIn(
                          delay: Motion.staggerAt(3),
                          child: Row(
                            key: const Key('voice-hint'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_none_rounded, size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  tr.voiceHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, c) {
                          final two = c.maxWidth >= 520;
                          final cardWidth = two ? (c.maxWidth - 12) / 2 : c.maxWidth;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var i = 0; i < suggestions.length; i++)
                                SizedBox(
                                  width: cardWidth,
                                  child: FadeSlideIn(
                                    // Shrinking gaps (not a metronome): 140, 175, 200, 215 ms.
                                    delay: Duration(milliseconds: const [140, 175, 200, 215][i]),
                                    child: _SuggestionCard(
                                      icon: suggestions[i].$1,
                                      title: suggestions[i].$2,
                                      question: suggestions[i].$3,
                                      onTap: () => onSuggestion(suggestions[i].$3),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 56),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Max width of the chat column — the empty screen, messages and input bar line up on it.
const double _chatWidth = 720;

/// One example: topic on top, the actual question it sends underneath.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.icon, required this.title, required this.question, required this.onTap});

  final IconData icon;
  final String title;
  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      radius: 14,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.tealSoft.withValues(alpha: 0.45),
          child: SizedBox(
            height: 76,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.north_east, size: 16, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.canClear,
    required this.onSend,
    required this.onClear,
    this.onHistory,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final bool canClear;
  final VoidCallback onSend;
  final VoidCallback onClear;

  /// Null when the history panel is already on screen.
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      child: BorderBeam(
        radius: 28,
        loops: 1,
        active: sending,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: AppColors.navy.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                key: const Key('chat-new'),
                tooltip: tr.newChat,
                onPressed: canClear ? onClear : null,
                icon: Icon(Icons.add_comment_outlined, color: AppColors.muted),
              ),
              if (onHistory != null)
                IconButton(
                  key: const Key('chat-history'),
                  tooltip: tr.chatHistory,
                  onPressed: enabled ? onHistory : null,
                  icon: Icon(Icons.history, color: AppColors.muted),
                ),
              const _SpeakRepliesButton(),
              Expanded(
                child: TextField(
                  key: const Key('chat-input'),
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: tr.askHint,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  ),
                ),
              ),
              const VoiceMicButton(size: 40, filled: true),
              const SizedBox(width: 2),
              Pressable(
                lift: false,
                radius: 22,
                child: Tooltip(
                  message: tr.send,
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
                      child: InkWell(
                        key: const Key('chat-send'),
                        onTap: enabled ? onSend : null,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: AnimatedSwitcher(
                            duration: Motion.fast,
                            transitionBuilder: (child, a) => FadeTransition(
                              opacity: a,
                              child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
                            ),
                            child: sending
                                ? const SizedBox(
                                    key: ValueKey('busy'),
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.arrow_upward_rounded, key: ValueKey('send'), color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Speaker toggle: read answers to spoken questions aloud. While an answer is being read,
/// it stops the reading instead.
class _SpeakRepliesButton extends StatelessWidget {
  const _SpeakRepliesButton();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VoiceViewModel>();
    if (!vm.canSpeak || !vm.canListen) return const SizedBox.shrink();
    final tr = context.l10n;
    final (IconData icon, String tip, VoidCallback onTap) = vm.isSpeaking
        ? (Icons.stop_circle_outlined, tr.voiceStopSpeaking, vm.stopSpeaking)
        : vm.speakReplies
        ? (Icons.volume_up_outlined, tr.voiceRepliesOn, vm.toggleSpeakReplies)
        : (Icons.volume_off_outlined, tr.voiceRepliesOff, vm.toggleSpeakReplies);
    return IconButton(
      key: const Key('voice-replies'),
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon, color: vm.isSpeaking || vm.speakReplies ? AppColors.teal : AppColors.muted),
    );
  }
}

/// An answer plus the changes it proposes (each with Confirm / Cancel), lined up under the bubble.
class _MessageWithActions extends StatelessWidget {
  const _MessageWithActions({
    super.key,
    required this.vm,
    required this.message,
    required this.maxWidth,
    required this.fresh,
  });

  final AssistantViewModel vm;
  final ChatMessageModel message;
  final double maxWidth;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final bubble = ChatBubble(message: message, maxWidth: maxWidth, fresh: fresh);
    if (message.actions.isEmpty) return bubble;
    final card = Padding(
      // Under the bubble, past the orb (30) + gap (10).
      padding: const EdgeInsets.only(left: 40, bottom: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final a in message.actions)
              AssistantActionCard(
                action: a,
                busy: vm.isActionBusy(a.id),
                requestError: vm.actionError(a.id),
                onConfirm: (params) => vm.confirmAction(a.id, params: params),
                onCancel: () => vm.cancelAction(a.id),
                onOpen: context.read<HomeViewModel>().select,
              ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bubble,
        fresh ? FadeSlideIn(delay: Motion.staggerAt(4), offset: const Offset(0, 8), child: card) : card,
      ],
    );
  }
}

/// "Thinking…" dots; after a few seconds a note that answers which use tools can take up to 30 s.
class _Thinking extends StatefulWidget {
  const _Thinking({required this.label, required this.slowLabel});

  final String label;
  final String slowLabel;

  @override
  State<_Thinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<_Thinking> {
  bool _slow = false;
  late final Timer _timer = Timer(const Duration(seconds: 6), () {
    if (mounted) setState(() => _slow = true);
  });

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TypingIndicator(label: widget.label),
      AnimatedSize(
        duration: Motion.base,
        curve: Motion.easeOut,
        child: _slow
            ? FadeSlideIn(
                offset: const Offset(0, 4),
                child: Padding(
                  key: const Key('assistant-slow'),
                  padding: const EdgeInsets.only(left: 40, top: 2, bottom: 6),
                  child: Text(widget.slowLabel, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}
