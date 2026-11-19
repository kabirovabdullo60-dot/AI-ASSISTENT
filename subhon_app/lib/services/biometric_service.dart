import '../models/biometric_kind.dart';

/// Face ID / Touch ID / fingerprint on the phone. Abstract so tests can
/// use a fake.
abstract class BiometricService {
  /// What the phone has (and has set up); [BiometricKind.none] otherwise.
  Future<BiometricKind> kind();

  /// Shows the system prompt with [reason]; `true` when it is the owner.
  Future<bool> authenticate(String reason);
}
