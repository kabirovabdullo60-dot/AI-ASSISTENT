import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/profile_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_service.dart';

enum SessionStatus { unknown, signedOut, signedIn }

/// Who is signed in. Restores the session at start (`GET /api/auth/me`),
/// signs in / up / out, and returns to the login screen when the backend
/// ends the session.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._auth, ApiClient api) {
    api.onSessionExpired = _expired;
  }

  final AuthService _auth;

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

  /// App start: a saved session is checked with the backend.
  Future<void> restore() async {
    if (!await _auth.hasSession()) {
      _set(SessionStatus.signedOut);
      return;
    }
    try {
      _user = await _auth.me();
      _set(SessionStatus.signedIn);
    } on ApiException catch (e) {
      // Offline: the saved session stays; it is checked again next start.
      if (e.code == ApiException.networkError) {
        _error = e;
      }
      _set(SessionStatus.signedOut);
    }
  }

  Future<bool> login(String email, String password) => _submit(
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
