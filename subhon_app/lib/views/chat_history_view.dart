import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/chat_history_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/chat_conversation_model.dart';
import '../viewmodels/chat_history_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_feedback.dart';
import '../widgets/record_tile.dart';
import '../widgets/status_badge.dart';

/// The saved conversations with the AI assistant (on this phone, for this
/// account), newest first. Tap one to open it; swipe or the bin to delete.
/// Pops the chosen [ChatConversationModel].
class ChatHistoryView extends StatelessWidget {
  const ChatHistoryView({required this.userId, this.currentId, super.key});

  final String userId;

  /// The conversation open in the chat now (marked in the list).
  final String? currentId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        ChatHistoryViewModel(context.read<ChatHistoryStorage>(), userId)
          ..load(),
    child: _History(currentId: currentId),
  );
}

class _History extends StatelessWidget {
  const _History({this.currentId});

  final String? currentId;

  Future<void> _deleteAll(BuildContext context) async {
    final l10n = context.l10n;
    final vm = context.read<ChatHistoryViewModel>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.chatDeleteAllTitle,
      message: l10n.chatDeleteAllMessage,
      confirmLabel: l10n.chatDeleteAll,
      destructive: true,
    );
    if (confirmed) await vm.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<ChatHistoryViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatHistory),
        actions: [
          if (vm.chats.isNotEmpty)
            IconButton(
              tooltip: l10n.chatDeleteAll,
              onPressed: () => _deleteAll(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: !vm.hasData
          ? const Center(child: CircularProgressIndicator())
          : vm.chats.isEmpty
          ? AppEmptyView(
              icon: Icons.forum_outlined,
              title: l10n.chatHistory,
              message: l10n.chatHistoryEmpty,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (final chat in vm.chats)
                        Dismissible(
                          key: ValueKey(chat.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSpacing.lg,
                            ),
                            color: p.errorLight,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: p.error,
                            ),
                          ),
                          onDismissed: (_) {
                            vm.delete(chat.id);
                            AppSnackbar.success(context, l10n.chatDeleted);
                          },
                          child: RecordTile(
                            icon: Icons.forum_outlined,
                            iconColor: p.primary,
                            iconBackground: p.primaryLight,
                            title: chat.title,
                            subtitle:
                                '${context.formatDateTime(chat.updatedAt)}'
                                ' · ${chat.preview}',
                            badge: chat.id == currentId
                                ? StatusBadge(
                                    label: l10n.chatCurrent,
                                    color: p.primary,
                                    background: p.primaryLight,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(chat),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
