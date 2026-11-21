import 'package:flutter/foundation.dart';

import '../core/storage/app_lock_storage.dart';
import '../models/biometric_kind.dart';
import '../services/biometric_service.dart';

/// "Вход по Face ID": whether it is on, what the phone has, and whether
/// the app is locked now (at start and after going to the background).
class AppLockViewModel extends ChangeNotifier {
  AppLockViewModel(this._storage, this._biometric);

  final AppLockStorage _storage;
  final BiometricService _biometric;

  bool _enabled = false;
  bool _locked = false;
  bool _loaded = false;
  bool _busy = false;
  BiometricKind _kind = BiometricKind.none;

  bool get enabled => _enabled;
  bool get locked => _enabled && _locked;
  bool get loaded => _loaded;
  bool get isAuthenticating => _busy;
  BiometricKind get kind => _kind;
  bool get available => _kind != BiometricKind.none;

  /// Reads the setting; the app starts locked when it is on.
  Future<void> load() async {
    _enabled = await _storage.read();
    _locked = _enabled;
    _kind = await _biometric.kind();
    // Face ID was removed from the phone: the lock can't be opened, so it
    // is switched off rather than shutting the owner out.
    if (_enabled && !available) {
      _enabled = false;
      _locked = false;
      await _storage.write(enabled: false);
    }
    _loaded = true;
    notifyListeners();
  }

  /// Turns the lock on (after a successful Face ID, so it surely works) or
  /// off. `false` when Face ID was not confirmed.
  Future<bool> setEnabled({required bool value, required String reason}) async {
    if (value && !await _ask(reason)) return false;
    _enabled = value;
    _locked = false;
    await _storage.write(enabled: value);
    notifyListeners();
    return true;
  }

  /// The app went to the background.
  void lock() {
    if (!_enabled || _locked || _busy) return;
    _locked = true;
    notifyListeners();
  }

  /// Face ID to open the app; `true` when unlocked.
  Future<bool> unlock(String reason) async {
    if (!locked) return true;
    if (!await _ask(reason)) return false;
    _locked = false;
    notifyListeners();
    return true;
  }

  Future<bool> _ask(String reason) async {
    if (_busy) return false;
    _busy = true;
    notifyListeners();
    try {
      return await _biometric.authenticate(reason);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
