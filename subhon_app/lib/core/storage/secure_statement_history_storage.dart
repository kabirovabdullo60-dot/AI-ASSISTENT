import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/statement_request_model.dart';
import 'statement_history_storage.dart';

class SecureStatementHistoryStorage implements StatementHistoryStorage {
  const SecureStatementHistoryStorage([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  static String _key(String userId) => 'ofar.statements.$userId';

  @override
  Future<List<StatementRequestModel>> read(String userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List<dynamic>)
          ?StatementRequestModel.fromJson(e as Map<String, dynamic>),
      ];
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  Future<void> write(String userId, List<StatementRequestModel> items) =>
      items.isEmpty
      ? _storage.delete(key: _key(userId))
      : _storage.write(
          key: _key(userId),
          value: jsonEncode([for (final i in items) i.toJson()]),
        );
}
