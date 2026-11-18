/// Remembers the chosen app language.
abstract interface class LocaleStorage {
  Future<String?> read();
  Future<void> write(String? code);
}
