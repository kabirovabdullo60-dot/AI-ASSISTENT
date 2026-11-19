import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/conversation_model.dart';

/// Saved AI chats grouped by day (Today / Yesterday / Nov 06), newest first,
/// with a "New chat" button on top. Used as the side panel and inside the phone sheet.
class ChatHistoryList extends StatelessWidget {
  const ChatHistoryList({
    super.key,
    required this.conversations,
    required this.currentId,
    required this.onOpen,
    required this.onDelete,
    required this.onNewChat,
    this.enabled = true,
  });

  final List<ConversationModel> conversations;
  final String? currentId;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onDelete;
  final VoidCallback onNewChat;

  /// False while an answer is coming — switching chats then would lose it.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final rows = <Widget>[];
    String? day;
    for (final c in conversations) {
      final label = formatRelativeDay(c.updatedAt);
      if (label != day) {
        day = label;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.3),
            ),
          ),
        );
      }
      rows.add(
        _HistoryTile(
          conversation: c,
          selected: c.id == currentId,
          enabled: enabled,
          onOpen: () => onOpen(c.id),
          onDelete: () => onDelete(c.id),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          child: Row(
            children: [
              Icon(Icons.history, size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr.chatHistory,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
              TextButton.icon(
                key: const Key('history-new-chat'),
                onPressed: enabled && currentId != null ? onNewChat : null,
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.newChat),
              ),
            ],
          ),
        ),
        Flexible(
          child: conversations.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: Text(
                    tr.chatHistoryEmpty,
                    key: const Key('history-empty'),
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                )
              : ListView(
                  key: const Key('history-list'),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: rows,
                ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.conversation,
    required this.selected,
    required this.enabled,
    required this.onOpen,
    required this.onDelete,
  });

  final ConversationModel conversation;
  final bool selected;
  final bool enabled;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: selected ? AppColors.tealSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('history-${conversation.id}'),
          onTap: enabled ? onOpen : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? AppColors.accentText : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatTime(conversation.updatedAt)} · ${tr.chatMessages(conversation.messageCount)}',
                        style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: Key('history-delete-${conversation.id}'),
                  tooltip: tr.deleteChat,
                  visualDensity: VisualDensity.compact,
                  onPressed: enabled ? onDelete : null,
                  icon: Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
