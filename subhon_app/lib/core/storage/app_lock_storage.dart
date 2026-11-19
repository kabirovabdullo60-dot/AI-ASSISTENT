/// Remembers whether the app is locked with Face ID / fingerprint.
abstract interface class AppLockStorage {
  Future<bool> read();
  Future<void> write({required bool enabled});
}
