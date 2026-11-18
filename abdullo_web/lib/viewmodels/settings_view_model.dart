import 'package:flutter/foundation.dart';

import '../core/l10n/app_language.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../services/exchange_rate_service.dart';
import '../services/preferences_service.dart';

/// Language + display currency (the business name lives in the profile on the server).
class SettingsViewModel extends ChangeNotifier {
  // ignore: prefer_initializing_formals
  SettingsViewModel(this._prefs, {String? systemLanguage, ApiClient? api}) : _api = api {
    _apply(AppLanguage.fromCode(systemLanguage));
  }

  final PreferencesService _prefs;
  final ApiClient? _api;
  Currency _currency = Currency.tjs;
  late AppLanguage _language;

  Currency get currency => _currency;

  /// The look (Midnight Aurora / Zinc / Emerald). Saved in the browser.
  AppPalette get palette => AppColors.palette;

  void setPalette(AppPalette p) {
    if (p == AppColors.palette) return;
    AppColors.use(p);
    _prefs.savePalette(p.name);
    notifyListeners();
  }

  AppLanguage get language => _language;

  Future<void> load() async {
    final savedPalette = await _prefs.loadPalette();
    if (savedPalette != null && AppPalette.fromName(savedPalette) != AppColors.palette) {
      AppColors.use(AppPalette.fromName(savedPalette));
      notifyListeners();
    }
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
    _api?.language = language.name;
  }

  /// GET /api/settings/exchange-rates (after sign-in) — USD amounts use the server rate.
  Future<void> loadRates() async {
    final api = _api;
    if (api == null) return;
    try {
      Currency.setRates(await ExchangeRateService(api).rates());
      notifyListeners();
    } on ApiException {
      // Keep the fallback rate.
    }
  }

  void setCurrency(Currency currency) {
    if (currency == _currency) return;
    _currency = currency;
    notifyListeners();
  }
}
