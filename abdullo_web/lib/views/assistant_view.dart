import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/assistant_view_model.dart';
import '../widgets/chat_bubble.dart';

class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _shownCount = 0;

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
    vm.send(value);
  }

  void _scrollToBottomIfNew(int count) {
    if (count == _shownCount) return;
    _shownCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssistantViewModel>();
    final messages = vm.messages;
    final itemCount = messages.length + (vm.isSending ? 1 : 0);
    _scrollToBottomIfNew(itemCount);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _EmptyChat(onSuggestion: (s) => _send(vm, s))
                    : ListView.builder(
                        key: const Key('chat-list'),
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: itemCount,
                        itemBuilder: (context, i) => i < messages.length
                            ? ChatBubble(message: messages[i], maxWidth: constraints.maxWidth)
                            : const _Typing(),
                      ),
              ),
              if (vm.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(vm.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              _InputBar(
                controller: _input,
                enabled: !vm.isSending,
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
  const _EmptyChat({required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.smart_toy_outlined, size: 32, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          Text('Ask your business assistant', textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Sales, expenses, profit, customers or marketing — ask in Tajik, Russian or English.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in AssistantViewModel.suggestions)
                ActionChip(label: Text(s), onPressed: () => onSuggestion(s)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: SizedBox(
          key: Key('chat-typing'),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.canClear,
    required this.onSend,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool canClear;
  final VoidCallback onSend;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'New chat',
            onPressed: canClear ? onClear : null,
            icon: const Icon(Icons.add_comment_outlined),
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
              decoration: const InputDecoration(
                hintText: 'Ask about your business…',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            key: const Key('chat-send'),
            tooltip: 'Send',
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
