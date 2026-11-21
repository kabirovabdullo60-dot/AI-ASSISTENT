import 'assistant_action_model.dart';

enum ChatRole { user, assistant }

class ChatMessageModel {
  const ChatMessageModel({required this.role, required this.text, required this.time, this.actions = const []});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    role: json['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
    text: json['text'] as String? ?? '',
    time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
    actions: [
      for (final a in (json['actions'] as List? ?? const []))
        if (a is Map<String, dynamic>) AssistantActionModel.fromJson(a),
    ],
  );

  final ChatRole role;
  final String text;
  final DateTime time;

  /// Changes the assistant proposed in this answer (confirm / cancel each).
  final List<AssistantActionModel> actions;

  bool get isUser => role == ChatRole.user;

  ChatMessageModel copyWith({List<AssistantActionModel>? actions}) =>
      ChatMessageModel(role: role, text: text, time: time, actions: actions ?? this.actions);

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'text': text,
    'time': time.toIso8601String(),
    if (actions.isNotEmpty) 'actions': [for (final a in actions) a.toJson()],
  };
}
