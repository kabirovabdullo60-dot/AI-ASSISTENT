import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the access + refresh tokens in memory and in the browser (localStorage).
class TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';
  static const _startKey = 'sessionStartedAt';

  /// How long a sign-in lasts on this browser before the login is asked again.
  static const sessionLength = Duration(days: 7);

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
      await prefs.remove(_startKey);
    } catch (_) {}
  }

  /// The refresh token as saved right now, re-read from the browser: another tab of the web may
  /// have rotated it since this tab loaded.
  Future<String?> storedRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      return prefs.getString(_refreshKey);
    } catch (_) {
      return _refresh;
    }
  }

  /// Marks the moment of signing in (login / register); refreshing the tokens keeps it.
  Future<void> startSession([DateTime? at]) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_startKey, (at ?? DateTime.now()).toIso8601String());
    } catch (_) {}
  }

  /// When this browser signed in, or null for a session saved before this was recorded.
  Future<DateTime?> sessionStartedAt() async {
    try {
      return DateTime.tryParse((await SharedPreferences.getInstance()).getString(_startKey) ?? '');
    } catch (_) {
      return null;
    }
  }
}
