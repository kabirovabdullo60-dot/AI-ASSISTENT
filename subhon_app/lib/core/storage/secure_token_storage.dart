import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

/// Keychain (iOS) / Keystore-backed storage (Android). On iOS the tokens
/// stay on this device only: they are not restored from a backup.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage([this._storage = _default]);

  static const _default = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const _accessKey = 'ofar.auth.access_token';
  static const _refreshKey = 'ofar.auth.refresh_token';
  static const _signedInKey = 'ofar.auth.signed_in_at';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _signedInKey);
  }

  @override
  Future<DateTime?> readSignedInAt() async {
    final value = await _storage.read(key: _signedInKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  @override
  Future<void> saveSignedInAt(DateTime time) =>
      _storage.write(key: _signedInKey, value: time.toUtc().toIso8601String());
}
