import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers that the launch intro was shown, so it plays only the first
/// time the app is opened.
class IntroStorage {
  const IntroStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'ofar.introSeen';
  final FlutterSecureStorage _storage;

  /// `true` only on the very first launch (and marks it as seen).
  Future<bool> firstLaunch() async {
    try {
      if (await _storage.read(key: _key) == 'yes') return false;
      await _storage.write(key: _key, value: 'yes');
      return true;
    } on Object {
      return false;
    }
  }
}
