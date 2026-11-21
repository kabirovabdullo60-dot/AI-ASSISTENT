import 'package:shared_preferences/shared_preferences.dart';

/// Small settings saved in the browser (localStorage on web).
class PreferencesService {
  static const _languageKey = 'language';
  static const _paletteKey = 'palette';
  static const _sectionKey = 'section';

  /// The open page, so a reload comes back to it.
  Future<void> saveSection(String name) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_sectionKey, name);
    } catch (_) {}
  }

  Future<String?> loadSection() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_sectionKey);
    } catch (_) {
      return null;
    }
  }

  static const _voiceRepliesKey = 'voiceReplies';

  /// Read assistant answers aloud after a spoken question (default on).
  Future<bool> loadVoiceReplies() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_voiceRepliesKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> saveVoiceReplies(bool on) async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_voiceRepliesKey, on);
    } catch (_) {}
  }

  Future<String?> loadPalette() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_paletteKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePalette(String name) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_paletteKey, name);
    } catch (_) {}
  }

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
