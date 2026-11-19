import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/debt_model.dart';
import 'debt_storage.dart';

/// [DebtStorage] in the phone's secure storage (encrypted).
class SecureDebtStorage implements DebtStorage {
  const SecureDebtStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static String _key(String userId) => 'ofar.debts.$userId';

  @override
  Future<List<DebtModel>> read(String userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null) return [];
    try {
      return [
        for (final d in jsonDecode(raw) as List<dynamic>)
          DebtModel.fromJson(d as Map<String, dynamic>),
      ];
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  Future<void> write(String userId, List<DebtModel> debts) => debts.isEmpty
      ? _storage.delete(key: _key(userId))
      : _storage.write(
          key: _key(userId),
          value: jsonEncode([for (final d in debts) d.toJson()]),
        );
}
