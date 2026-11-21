/// `ConversationSummaryOut`: one saved chat in the history list.
class ConversationSummaryModel {
  const ConversationSummaryModel({
    required this.id,
    required this.title,
    required this.messageCount,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) =>
      ConversationSummaryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        messageCount: json['messageCount'] as int,
        lastMessage: json['lastMessage'] as String? ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );

  final String id;
  final String title;
  final int messageCount;

  /// The first 120 characters of the newest message.
  final String lastMessage;

  /// When a message was last added (the list is sorted by it).
  final DateTime updatedAt;
}
