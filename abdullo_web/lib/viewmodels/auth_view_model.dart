import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

enum AuthStatus { checking, signedOut, signedIn }

/// Login / register / logout and the signed-in user's profile.
/// Action methods return `null` on success or the backend error code (e.g. `AUTH_INVALID_CREDENTIALS`).
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._auth, this._profile);

  final AuthService _auth;
  final ProfileService _profile;

  AuthStatus _status = AuthStatus.checking;
  ProfileModel? _user;
  bool _busy = false;
  bool _disposed = false;

  AuthStatus get status => _status;
  ProfileModel? get user => _user;
  bool get isBusy => _busy;

  /// On app start: use the saved tokens if they still work.
  Future<void> restore() async {
    try {
      _user = await _auth.restore();
    } catch (_) {
      _user = null;
    }
    _status = _user == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    _notify();
  }

  Future<String?> login(String email, String password) =>
      _run(() async => _user = await _auth.login(email: email, password: password), signIn: true);

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) => _run(
    () async => _user = await _auth.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      businessName: businessName,
    ),
    signIn: true,
  );

  Future<void> logout() async {
    await _auth.logout();
    sessionExpired();
  }

  /// Called by ApiClient when the refresh token stops working.
  void sessionExpired() {
    _user = null;
    _status = AuthStatus.signedOut;
    _notify();
  }

  Future<String?> updateProfile({String? fullName, String? email, String? phone, String? businessName}) => _run(
    () async =>
        _user = await _profile.update(fullName: fullName, email: email, phone: phone, businessName: businessName),
  );

  /// Reloads the signed-in user (e.g. after the AI assistant changed the profile).
  Future<void> refreshProfile() async {
    try {
      _user = await _profile.fetch();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthViewModel.refreshProfile: $e');
    }
  }

  Future<String?> changePassword(String current, String next) =>
      _run(() => _profile.changePassword(currentPassword: current, newPassword: next));

  Future<String?> uploadAvatar(List<int> bytes, String filename) =>
      _run(() async => _user = await _profile.uploadAvatar(bytes, filename));

  Future<String?> _run(Future<void> Function() task, {bool signIn = false}) async {
    if (_busy) return 'BUSY';
    _busy = true;
    _notify();
    try {
      await task();
      if (signIn) _status = AuthStatus.signedIn;
      return null;
    } on ApiException catch (e) {
      return e.code;
    } catch (e) {
      debugPrint('AuthViewModel: $e');
      return 'UNKNOWN';
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
