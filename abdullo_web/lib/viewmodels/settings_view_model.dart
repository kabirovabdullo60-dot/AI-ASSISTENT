import 'package:flutter/foundation.dart';

import '../core/l10n/app_language.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../services/preferences_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._prefs, {String? systemLanguage}) {
    _apply(AppLanguage.fromCode(systemLanguage));
  }

  final PreferencesService _prefs;
  String _businessName = 'Apex Suite';
  Currency _currency = Currency.tjs;
  late AppLanguage _language;

  String get businessName => _businessName;
  Currency get currency => _currency;
  AppLanguage get language => _language;

  /// Loads the language the user picked last time.
  Future<void> load() async {
    final saved = await _prefs.loadLanguage();
    if (saved != null && saved != _language.name) {
      _apply(AppLanguage.fromCode(saved));
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage language) {
    if (language == _language) return;
    _apply(language);
    _prefs.saveLanguage(language.name);
    notifyListeners();
  }

  void _apply(AppLanguage language) {
    _language = language;
    setFormatLanguage(language.name);
  }

  void setBusinessName(String name) {
    final value = name.trim().isEmpty ? 'Apex Suite' : name.trim();
    if (value == _businessName) return;
    _businessName = value;
    notifyListeners();
  }

  void setCurrency(Currency currency) {
    if (currency == _currency) return;
    _currency = currency;
    notifyListeners();
  }
}
