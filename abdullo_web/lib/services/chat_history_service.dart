import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/conversation_model.dart';

/// Saved AI chats of the signed-in user, on the server (`/api/assistant/conversations`),
/// so they show on every device. Chats are saved by POST /api/assistant/chat itself.
class ChatHistoryService {
  ChatHistoryService(this._api, {required String userId}) : _localKey = 'chatHistory.$userId';

  final ApiClient _api;

  /// Where older web versions kept chats in the browser (uploaded once by [importLocal]).
  final String _localKey;

  /// Newest (last updated) first, without messages. Throws `ApiException`.
  Future<List<ConversationModel>> list({int limit = 50}) async {
    final json = asJsonMap(await _api.get(ApiConstants.assistantConversations, query: {'page': 1, 'limit': limit}));
    return [
      for (final item in (json['items'] as List? ?? const []))
        if (item is Map<String, dynamic>) ConversationModel.fromJson(item),
    ];
  }

  /// One chat with all its messages (actions with their current status).
  Future<ConversationModel> get(String id) async =>
      ConversationModel.fromJson(asJsonMap(await _api.get('${ApiConstants.assistantConversations}/$id')));

  Future<void> delete(String id) => _api.delete('${ApiConstants.assistantConversations}/$id');

  Future<void> rename(String id, String title) =>
      _api.patch('${ApiConstants.assistantConversations}/$id', {'title': title});

  /// Uploads chats an older version kept in this browser (no AI call), then removes each one
  /// from the browser so it is never uploaded twice. Returns how many were uploaded.
  Future<int> importLocal() async {
    final SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return 0;
    }
    final raw = prefs.getString(_localKey);
    if (raw == null) return 0;
    List<ConversationModel> pending;
    try {
      pending = [
        for (final item in jsonDecode(raw) as List)
          if (item is Map<String, dynamic>) ConversationModel.fromJson(item),
      ];
    } catch (e) {
      debugPrint('ChatHistoryService.importLocal: unreadable, dropped: $e');
      await prefs.remove(_localKey);
      return 0;
    }
    var uploaded = 0;
    // Oldest first, so the server's "last updated" order matches what the user saw.
    pending.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    for (final c in List.of(pending)) {
      final messages = [
        for (final m in c.messages)
          if (m.text.trim().isNotEmpty)
            {
              'role': m.role.name,
              'text': m.text.length > 2000 ? m.text.substring(0, 2000) : m.text,
              'time': m.time.toUtc().toIso8601String(),
            },
      ];
      if (messages.isNotEmpty) {
        await _api.post(ApiConstants.assistantConversations, {
          if (c.title.trim().isNotEmpty) 'title': ConversationModel.titleFrom(c.title),
          'messages': messages.length > ConversationModel.maxMessages
              ? messages.sublist(messages.length - ConversationModel.maxMessages)
              : messages,
        });
        uploaded++;
      }
      // Remove each chat as soon as it is on the server: a failure later keeps only the rest.
      pending.remove(c);
      if (pending.isEmpty) {
        await prefs.remove(_localKey);
      } else {
        await prefs.setString(_localKey, jsonEncode([for (final p in pending) p.toJson()]));
      }
    }
    return uploaded;
  }
}
