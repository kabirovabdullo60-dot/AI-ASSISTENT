import 'package:flutter/foundation.dart';

import '../core/utils/currency.dart';

class SettingsViewModel extends ChangeNotifier {
  String _businessName = 'Apex Suite';
  Currency _currency = Currency.tjs;

  String get businessName => _businessName;
  Currency get currency => _currency;

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
