import 'assistant_action_model.dart';

/// `ChatMessage` / `ChatReplyOut` / `ConversationMessageOut` (API.md): one
/// message of the conversation with the AI assistant.
class ChatMessageModel {
  const ChatMessageModel({
    required this.fromUser,
    required this.text,
    this.time,
    this.prompt,
    this.actions = const [],
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final fromUser = json['role'] == 'user';
    final text = json['text'] as String;
    return ChatMessageModel(
      fromUser: fromUser,
      text: fromUser ? withoutNote(text) : text,
      time: json['time'] == null
          ? null
          : DateTime.parse(json['time'] as String).toLocal(),
      actions: [
        for (final a in json['actions'] as List<dynamic>? ?? const [])
          AssistantActionModel.fromJson(a as Map<String, dynamic>),
      ],
    );
  }

  /// The note of personal finances that goes before a question ends with
  /// this line; a saved question is shown without it.
  static const noteEnd = '[Question]\n';

  static String withoutNote(String text) {
    final at = text.indexOf(noteEnd);
    return text.startsWith('[') && at >= 0
        ? text.substring(at + noteEnd.length)
        : text;
  }

  /// Changes the assistant proposed in this answer, with their status.
  final List<AssistantActionModel> actions;

  ChatMessageModel withActions(List<AssistantActionModel> actions) =>
      ChatMessageModel(
        fromUser: fromUser,
        text: text,
        time: time,
        prompt: prompt,
        actions: actions,
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
