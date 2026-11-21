import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/chat_history_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../models/conversation_summary_model.dart';
import '../services/assistant_service.dart';
import '../viewmodels/chat_history_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_feedback.dart';
import '../widgets/record_tile.dart';
import '../widgets/status_badge.dart';

/// The saved chats with the AI assistant (the same on every device), most
/// recently updated first. Tap one to open it; the menu renames or deletes
/// it. Pops the chosen chat's id.
class ChatHistoryView extends StatelessWidget {
  const ChatHistoryView({
    this.userId,
    this.currentId,
    this.onDeleted,
    super.key,
  });

  /// Whose phone-only chats (old version) are moved to the server.
  final String? userId;

  /// The chat open now (marked in the list).
  final String? currentId;

  /// A chat was deleted (the open one starts over).
  final ValueChanged<String>? onDeleted;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ChatHistoryViewModel(
      context.read<AssistantService>(),
      legacy: context.read<ChatHistoryStorage>(),
      userId: userId,
    )..load(),
    child: _History(currentId: currentId, onDeleted: onDeleted),
  );
}

enum _ChatMenu { rename, delete }

class _History extends StatelessWidget {
  const _History({this.currentId, this.onDeleted});

  final String? currentId;
  final ValueChanged<String>? onDeleted;

  Future<void> _rename(
    BuildContext context,
    ConversationSummaryModel chat,
  ) async {
    final l10n = context.l10n;
    final vm = context.read<ChatHistoryViewModel>();
    final feedback = AppSnackbar.of(context);
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(title: chat.title),
    );
    if (title == null || title.trim().isEmpty) return;
    if (!await vm.rename(chat.id, title)) {
      feedback.showError(errorText(l10n, vm.error!));
    }
  }

  Future<void> _delete(
    BuildContext context,
    ConversationSummaryModel chat,
  ) async {
    final l10n = context.l10n;
    final vm = context.read<ChatHistoryViewModel>();
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.chatDeleteTitle,
      message: l10n.chatDeleteMessage,
      confirmLabel: l10n.chatDelete,
      destructive: true,
    );
    if (!confirmed) return;
    if (await vm.delete(chat.id)) {
      onDeleted?.call(chat.id);
      feedback.showSuccess(l10n.chatDeleted);
    } else {
      feedback.showError(errorText(l10n, vm.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<ChatHistoryViewModel>();
    final Widget body;
    if (!vm.hasData && vm.error != null) {
      body = AppErrorView(error: vm.error!, onRetry: vm.load);
    } else if (!vm.hasData) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.chats.isEmpty) {
      body = AppEmptyView(
        icon: Icons.forum_outlined,
        title: l10n.chatHistory,
        message: l10n.chatHistoryServerEmpty,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxxl,
          ),
          children: [
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  for (final chat in vm.chats)
                    Row(
                      children: [
                        Expanded(
                          child: RecordTile(
                            icon: Icons.forum_outlined,
                            iconColor: p.primary,
                            iconBackground: p.primaryLight,
                            title: chat.title,
                            subtitle:
                                '${context.formatDateTime(chat.updatedAt)}'
                                ' · ${chat.lastMessage}',
                            badge: chat.id == currentId
                                ? StatusBadge(
                                    label: l10n.chatCurrent,
                                    color: p.primary,
                                    background: p.primaryLight,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(chat.id),
                          ),
                        ),
                        PopupMenuButton<_ChatMenu>(
                          tooltip: l10n.chatOptions,
                          onSelected: (choice) => switch (choice) {
                            _ChatMenu.rename => _rename(context, chat),
                            _ChatMenu.delete => _delete(context, chat),
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: _ChatMenu.rename,
                              child: Text(l10n.chatRename),
                            ),
                            PopupMenuItem(
                              value: _ChatMenu.delete,
                              child: Text(
                                l10n.chatDelete,
                                style: TextStyle(color: p.error),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (vm.hasMore) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: vm.isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: vm.loadMore,
                        child: Text(l10n.chatMore),
                      ),
              ),
            ],
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatHistory)),
      body: body,
    );
  }
}

/// The new name of a chat (pops it, or nothing on Cancel).
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.title});

  final String title;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _text = TextEditingController(text: widget.title);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.chatRenameTitle),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: 80,
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
