import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'locale_storage.dart';

class SecureLocaleStorage implements LocaleStorage {
  const SecureLocaleStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'ofar.locale';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? code) => code == null
      ? _storage.delete(key: _key)
      : _storage.write(key: _key, value: code);
}
