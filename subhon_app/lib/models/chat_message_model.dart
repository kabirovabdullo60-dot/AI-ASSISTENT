/// `ChatMessage` / `ChatReplyOut` from the API contract (API.md / Swagger):
/// one message of the conversation with the AI assistant.
class ChatMessageModel {
  const ChatMessageModel({
    required this.fromUser,
    required this.text,
    this.time,
    this.prompt,
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

  /// What is sent instead of [text] (a short request made into a clear
  /// question); the screen shows [text].
  final String? prompt;

  /// Saved on the phone (chat history): also keeps [prompt].
  factory ChatMessageModel.fromStorageJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        fromUser: json['role'] == 'user',
        text: json['text'] as String,
        time: json['time'] == null
            ? null
            : DateTime.parse(json['time'] as String).toLocal(),
        prompt: json['prompt'] as String?,
      );

  Map<String, dynamic> toStorageJson() => {
    'role': fromUser ? 'user' : 'assistant',
    'text': text,
    if (time != null) 'time': time!.toUtc().toIso8601String(),
    'prompt': ?prompt,
  };

  /// What is sent to `POST /api/assistant/chat`.
  Map<String, dynamic> toJson() => {
    'role': fromUser ? 'user' : 'assistant',
    'text': prompt ?? text,
    if (time != null) 'time': time!.toUtc().toIso8601String(),
  };
}
