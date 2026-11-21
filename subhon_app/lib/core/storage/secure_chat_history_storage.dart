import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/chat_conversation_model.dart';
import 'chat_history_storage.dart';

/// [ChatHistoryStorage] in the phone's secure storage (Keychain /
/// encrypted on Android): the answers contain business figures.
class SecureChatHistoryStorage implements ChatHistoryStorage {
  const SecureChatHistoryStorage([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  static String _key(String userId) => 'ofar.chats.$userId';

  @override
  Future<List<ChatConversationModel>> read(String userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null) return [];
    try {
      return [
        for (final c in jsonDecode(raw) as List<dynamic>)
          ChatConversationModel.fromJson(c as Map<String, dynamic>),
      ];
    } on FormatException {
      return [];
    } on TypeError {
      // Saved by an older version in another shape: start fresh.
      return [];
    }
  }

  @override
  Future<void> write(String userId, List<ChatConversationModel> chats) =>
      chats.isEmpty
      ? _storage.delete(key: _key(userId))
      : _storage.write(
          key: _key(userId),
          value: jsonEncode([for (final c in chats) c.toJson()]),
        );
}
