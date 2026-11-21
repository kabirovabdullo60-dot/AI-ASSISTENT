import 'chat_message_model.dart';

/// One saved conversation with the AI assistant (chat history on the
/// phone).
class ChatConversationModel {
  const ChatConversationModel({
    required this.id,
    required this.messages,
    required this.updatedAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) =>
      ChatConversationModel(
        id: json['id'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
        messages: [
          for (final m in json['messages'] as List<dynamic>)
            ChatMessageModel.fromStorageJson(m as Map<String, dynamic>),
        ],
      );

  final String id;
  final List<ChatMessageModel> messages;
  final DateTime updatedAt;

  /// The first question, shortened: the name in the history list.
  String get title {
    final first = messages.where((m) => m.fromUser).firstOrNull?.text ?? '';
    final line = first.replaceAll(RegExp(r'\s+'), ' ').trim();
    return line.length <= 60 ? line : '${line.substring(0, 57)}…';
  }

  /// The last answer (or question), shortened: the line under the title.
  String get preview {
    final last = messages.lastOrNull?.text ?? '';
    final line = last.replaceAll(RegExp(r'\s+'), ' ').trim();
    return line.length <= 90 ? line : '${line.substring(0, 87)}…';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'messages': [for (final m in messages) m.toStorageJson()],
  };
}
