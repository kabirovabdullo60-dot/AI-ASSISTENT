/// `ChatMessage` / `ChatReplyOut` from the API contract (API.md / Swagger):
/// one message of the conversation with the AI assistant.
class ChatMessageModel {
  const ChatMessageModel({
    required this.fromUser,
    required this.text,
    this.time,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        fromUser: json['role'] == 'user',
        text: json['text'] as String,
        time: json['time'] == null
            ? null
            : DateTime.parse(json['time'] as String).toLocal(),
      );

  /// `role: user` (the person) or `assistant` (an answer).
  final bool fromUser;

  /// 1–2000 characters.
  final String text;
  final DateTime? time;

  Map<String, dynamic> toJson() => {
    'role': fromUser ? 'user' : 'assistant',
    'text': text,
    if (time != null) 'time': time!.toUtc().toIso8601String(),
  };
}
