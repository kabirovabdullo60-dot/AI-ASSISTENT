import 'package:flutter/foundation.dart';

import '../core/storage/locale_storage.dart';

/// The app language: English, Russian or Tajik. Follows the phone until
/// the user picks one; the choice is remembered.
class LocaleViewModel extends ChangeNotifier {
  LocaleViewModel(this._storage);

  static const supported = ['en', 'ru', 'tg'];

  final LocaleStorage _storage;
  String? _code;

  /// `null`: the phone's language (when supported).
  String? get code => _code;

  Future<void> load() async {
    final saved = await _storage.read();
    if (supported.contains(saved)) {
      _code = saved;
      notifyListeners();
    }
  }

  Future<void> select(String? code) async {
    _code = code;
    notifyListeners();
    await _storage.write(code);
  }
}
