import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/personal_finance_model.dart';
import 'personal_finance_storage.dart';

/// [PersonalFinanceStorage] in the phone's secure storage (encrypted).
class SecurePersonalFinanceStorage implements PersonalFinanceStorage {
  const SecurePersonalFinanceStorage([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  static String _key(String userId) => 'ofar.personal.$userId';

  @override
  Future<PersonalFinanceModel> read(String userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null) return const PersonalFinanceModel();
    try {
      return PersonalFinanceModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on FormatException {
      return const PersonalFinanceModel();
    } on TypeError {
      return const PersonalFinanceModel();
    }
  }

  @override
  Future<void> write(String userId, PersonalFinanceModel data) =>
      _storage.write(key: _key(userId), value: jsonEncode(data.toJson()));
}
