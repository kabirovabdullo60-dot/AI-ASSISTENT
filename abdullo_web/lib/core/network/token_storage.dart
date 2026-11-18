import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the access + refresh tokens in memory and in the browser (localStorage).
class TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  String? _access;
  String? _refresh;

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  bool get hasSession => _refresh != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _access = prefs.getString(_accessKey);
      _refresh = prefs.getString(_refreshKey);
    } catch (_) {}
  }

  Future<void> save(String access, String refresh) async {
    _access = access;
    _refresh = refresh;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, access);
      await prefs.setString(_refreshKey, refresh);
    } catch (_) {}
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessKey);
      await prefs.remove(_refreshKey);
    } catch (_) {}
  }
}
