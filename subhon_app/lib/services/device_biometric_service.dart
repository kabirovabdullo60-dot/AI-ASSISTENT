import 'package:local_auth/local_auth.dart';

import '../models/biometric_kind.dart';
import 'biometric_service.dart';

/// [BiometricService] with the phone's Face ID / Touch ID / fingerprint
/// (`local_auth`). Biometrics only: no device passcode fallback.
class DeviceBiometricService implements BiometricService {
  late final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<BiometricKind> kind() async {
    try {
      if (!await _auth.isDeviceSupported() || !await _auth.canCheckBiometrics) {
        return BiometricKind.none;
      }
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.contains(BiometricType.fingerprint)) {
        return BiometricKind.fingerprint;
      }
      return types.isEmpty ? BiometricKind.none : BiometricKind.other;
    } on Exception {
      return BiometricKind.none;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Exception {
      // Cancelled, locked out, not enrolled…: not unlocked.
      return false;
    }
  }
}
