import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_lock_storage.dart';

class SecureAppLockStorage implements AppLockStorage {
  const SecureAppLockStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'ofar.appLock';
  final FlutterSecureStorage _storage;

  @override
  Future<bool> read() async => await _storage.read(key: _key) == 'on';

  @override
  Future<void> write({required bool enabled}) => enabled
      ? _storage.write(key: _key, value: 'on')
      : _storage.delete(key: _key);
}
