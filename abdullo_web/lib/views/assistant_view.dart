import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/assistant_view_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/motion/ai_orb.dart';
import '../widgets/motion/fade_slide_in.dart';
import '../widgets/motion/pressable.dart';
import '../widgets/motion/typing_indicator.dart';

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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
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
                              ? ChatBubble(
                                  key: ValueKey('m$i'),
                                  message: messages[i],
                                  maxWidth: constraints.maxWidth,
                                  fresh: i >= _freshFrom! && i >= messages.length - 2,
                                )
                              : TypingIndicator(label: tr.assistantThinking),
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
                              const Icon(Icons.error_outline, size: 18, color: AppColors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vm.rateLimited ? tr.assistantBusy : tr.assistantError,
                                  style: const TextStyle(color: AppColors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              _InputBar(
                controller: _input,
                enabled: !vm.isSending,
                sending: vm.isSending,
                canClear: messages.isNotEmpty && !vm.isSending,
                onSend: () => _send(vm),
                onClear: vm.clear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final theme = Theme.of(context);
    final suggestions = [
      (Icons.trending_up, tr.suggestSales),
      (Icons.storefront_outlined, tr.suggestStores),
      (Icons.account_balance_wallet_outlined, tr.suggestSalaries),
      (Icons.campaign_outlined, tr.suggestMarketing),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const FadeSlideIn(beginScale: 0.9, offset: Offset(0, 6), duration: Motion.slow, child: AiOrb(size: 76)),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: Motion.staggerAt(1),
            child: Text(
              tr.askAssistant,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: Motion.staggerAt(2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Text(
                    tr.assistantIntro,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr.assistantNote,
                    key: const Key('assistant-note'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: LayoutBuilder(
              builder: (context, c) {
                final two = c.maxWidth >= 480;
                final cardWidth = two ? (c.maxWidth - 12) / 2 : c.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < suggestions.length; i++)
                      SizedBox(
                        width: cardWidth,
                        child: FadeSlideIn(
                          delay: Motion.staggerAt(3 + i),
                          child: _SuggestionCard(
                            icon: suggestions[i].$1,
                            text: suggestions[i].$2,
                            onTap: () => onSuggestion(suggestions[i].$2),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.icon, required this.text, required this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      radius: 14,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.orangeSoft.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.orangeSoft, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: AppColors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.ink),
                  ),
                ),
                const Icon(Icons.arrow_outward, size: 16, color: AppColors.muted),
              ],
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
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final bool canClear;
  final VoidCallback onSend;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
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
              tooltip: tr.newChat,
              onPressed: canClear ? onClear : null,
              icon: const Icon(Icons.add_comment_outlined, color: AppColors.muted),
            ),
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
            const SizedBox(width: 6),
            Pressable(
              lift: false,
              radius: 22,
              child: Tooltip(
                message: tr.send,
                child: Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8A57), AppColors.orange],
                      ),
                    ),
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
    );
  }
}
