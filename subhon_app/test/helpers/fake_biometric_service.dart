import 'package:subhon_app/core/storage/app_lock_storage.dart';
import 'package:subhon_app/models/biometric_kind.dart';
import 'package:subhon_app/services/biometric_service.dart';

/// Face ID for tests: [answer] is what the next prompts return.
class FakeBiometricService implements BiometricService {
  FakeBiometricService({this.available = BiometricKind.face});

  final BiometricKind available;
  bool answer = true;
  int prompts = 0;

  @override
  Future<BiometricKind> kind() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return answer;
  }
}

class MemoryAppLockStorage implements AppLockStorage {
  MemoryAppLockStorage({this.enabled = false});

  bool enabled;

  @override
  Future<bool> read() async => enabled;

  @override
  Future<void> write({required bool enabled}) async => this.enabled = enabled;
}
