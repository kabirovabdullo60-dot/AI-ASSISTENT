import 'package:subhon_app/core/storage/locale_storage.dart';

/// In memory (tests).
class MemoryLocaleStorage implements LocaleStorage {
  String? code;

  @override
  Future<String?> read() async => code;

  @override
  Future<void> write(String? code) async => this.code = code;
}
