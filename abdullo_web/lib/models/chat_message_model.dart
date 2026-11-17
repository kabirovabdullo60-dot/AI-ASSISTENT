enum ChatRole { user, assistant }

class ChatMessageModel {
  const ChatMessageModel({required this.role, required this.text, required this.time});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    role: json['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
    text: json['text'] as String? ?? '',
    time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
  );

  final ChatRole role;
  final String text;
  final DateTime time;

  bool get isUser => role == ChatRole.user;

  Map<String, dynamic> toJson() => {'role': role.name, 'text': text, 'time': time.toIso8601String()};
}
