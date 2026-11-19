import 'chat_message_model.dart';

/// One saved chat with the AI assistant.
/// Same shape as the planned `ConversationOut` of `/api/assistant/conversations` (see the prompt for Mehroj).
class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    messages: [
      for (final m in (json['messages'] as List? ?? const []))
        if (m is Map<String, dynamic>) ChatMessageModel.fromJson(m),
    ],
  );

  /// Most chats a browser keeps; the oldest ones drop off.
  static const maxConversations = 50;

  /// Most messages kept per chat (the backend accepts at most 200).
  static const maxMessages = 200;

  /// Titles are the first question, cut to this length.
  static const maxTitle = 80;

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;

  int get messageCount => messages.length;

  static String titleFrom(String question) {
    final t = question.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length <= maxTitle ? t : '${t.substring(0, maxTitle - 1)}…';
  }

  ConversationModel copyWith({String? title, DateTime? updatedAt, List<ChatMessageModel>? messages}) =>
      ConversationModel(
        id: id,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        messages: messages ?? this.messages,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'messages': [for (final m in messages) m.toJson()],
  };
}
