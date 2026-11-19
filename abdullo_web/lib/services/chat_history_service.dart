import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_model.dart';

/// Saved AI chats of one user, kept in this browser (localStorage).
///
/// The backend has no history endpoints yet. When Mehroj adds `/api/assistant/conversations`,
/// only this service changes: same methods, calls through `ApiClient` instead of storage.
class ChatHistoryService {
  ChatHistoryService({required String userId}) : _key = 'chatHistory.$userId';

  final String _key;

  /// Newest (last updated) first.
  Future<List<ConversationModel>> list() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return [];
      return [
        for (final item in jsonDecode(raw) as List)
          if (item is Map<String, dynamic>) ConversationModel.fromJson(item),
      ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('ChatHistoryService.list: $e');
      return [];
    }
  }

  /// Adds or replaces [conversation]; returns the new list (newest first).
  Future<List<ConversationModel>> save(ConversationModel conversation) async {
    final all = (await list()).where((c) => c.id != conversation.id).toList()..insert(0, conversation);
    final trimmed = all.take(ConversationModel.maxConversations).toList();
    await _write(trimmed);
    return trimmed;
  }

  /// Removes one chat; returns the new list.
  Future<List<ConversationModel>> delete(String id) async {
    final rest = (await list()).where((c) => c.id != id).toList();
    await _write(rest);
    return rest;
  }

  Future<void> _write(List<ConversationModel> list) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_key, jsonEncode([for (final c in list) c.toJson()]));
    } catch (e) {
      // Storage full or blocked (private mode): the chat still works, it just isn't remembered.
      debugPrint('ChatHistoryService._write: $e');
    }
  }
}
