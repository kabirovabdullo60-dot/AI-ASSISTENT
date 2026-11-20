import 'chat_message_model.dart';

/// One saved chat with the AI assistant.
/// `ConversationSummaryOut` / `ConversationOut` of `/api/assistant/conversations`.
class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this._messageCount,
    this.lastMessage = '',
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
    messageCount: (json['messageCount'] as num?)?.toInt(),
    lastMessage: json['lastMessage'] as String? ?? '',
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

  /// Empty in list items (`ConversationSummaryOut`); filled by GET /api/assistant/conversations/{id}.
  final List<ChatMessageModel> messages;

  final int? _messageCount;

  /// First 120 characters of the newest message.
  final String lastMessage;

  int get messageCount => _messageCount ?? messages.length;

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
