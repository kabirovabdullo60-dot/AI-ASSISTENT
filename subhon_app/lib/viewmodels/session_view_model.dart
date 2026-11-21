import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/profile_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_service.dart';

/// [offline]: a session is saved but the server could not be reached
/// (network, 5xx) — the person stays signed in and can try again.
enum SessionStatus { unknown, signedOut, signedIn, offline }

/// Who is signed in. Restores the session at start (`GET /api/auth/me`),
/// signs in / up / out, and returns to the login screen when the backend
/// ends the session.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(
    this._auth,
    ApiClient api, {
    this.retryDelay = const Duration(seconds: 1),
  }) {
    api.onSessionExpired = _expired;
  }

  final AuthService _auth;

  /// Between start-up attempts (×1, ×2); tests pass zero.
  final Duration retryDelay;

  /// The saved session was older than 7 days: the login says why.
  bool _tooOld = false;
  bool get sessionTooOld => _tooOld;

  SessionStatus _status = SessionStatus.unknown;
  ProfileModel? _user;
  bool _isSubmitting = false;
  Object? _error;

  SessionStatus get status => _status;
  ProfileModel? get user => _user;

  /// Login / register in progress.
  bool get isSubmitting => _isSubmitting;

  /// Why the last login / register failed.
  Object? get error => _error;

  /// App start: a saved session is checked with the backend
  /// (`GET /api/auth/me`), up to 3 times. A network error or a 5xx never
  /// signs the person out ([SessionStatus.offline]); only the server ending
  /// the session does. After 7 days the login is asked for again.
  Future<void> restore() async {
    if (_status == SessionStatus.offline) _set(SessionStatus.unknown);
    if (!await _auth.hasSession()) {
      _set(SessionStatus.signedOut);
      return;
    }
    if (await _auth.isSessionTooOld()) {
      await _auth.logout();
      _tooOld = true;
      _set(SessionStatus.signedOut);
      return;
    }
    for (var attempt = 1; ; attempt++) {
      try {
        _user = await _auth.me();
        _error = null;
        _set(SessionStatus.signedIn);
        return;
      } on ApiException catch (e) {
        final temporary =
            e.code == ApiException.networkError || e.statusCode >= 500;
        if (!temporary) {
          // 401: the client has already ended the session.
          _set(SessionStatus.signedOut);
          return;
        }
        if (attempt == 3) {
          _error = e;
          _set(SessionStatus.offline);
          return;
        }
        await Future<void>.delayed(retryDelay * attempt);
      }
    }
  }

  Future<bool> login(String email, String password) {
    _tooOld = false;
    return _login(email, password);
  }

  Future<bool> _login(String email, String password) => _submit(
    () =>
        _auth.login(LoginRequestModel(email: email.trim(), password: password)),
  );

  Future<bool> register(RegisterRequestModel request) =>
      _submit(() => _auth.register(request));

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    _set(SessionStatus.signedOut);
  }

  /// The profile changed (name, business, avatar…).
  void updateUser(ProfileModel user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _submit(Future<ProfileModel> Function() action) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      _status = SessionStatus.signedIn;
      return true;
    } on ApiException catch (e) {
      _error = e;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _expired() {
    _user = null;
    _set(SessionStatus.signedOut);
  }

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }
}
