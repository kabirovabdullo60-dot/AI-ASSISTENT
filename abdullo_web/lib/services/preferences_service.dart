import 'package:shared_preferences/shared_preferences.dart';

/// Small settings saved in the browser (localStorage on web).
class PreferencesService {
  static const _languageKey = 'language';

  Future<String?> loadLanguage() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_languageKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLanguage(String code) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_languageKey, code);
    } catch (_) {
      // Storage blocked (private mode) — the choice just isn't remembered.
    }
  }
}
