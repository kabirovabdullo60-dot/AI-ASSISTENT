import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';

class SettingsViewModel extends ChangeNotifier {
  String _businessName = 'My Business';
  ThemeMode _themeMode = ThemeMode.light;

  String get businessName => _businessName;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setBusinessName(String name) {
    final value = name.trim().isEmpty ? 'My Business' : name.trim();
    if (value == _businessName) return;
    _businessName = value;
    notifyListeners();
  }

  void setDark(bool dark) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
