import 'package:flutter/foundation.dart';

import '../core/navigation/app_section.dart';

/// Open page + the global search text from the top bar.
class HomeViewModel extends ChangeNotifier {
  AppSection _section = AppSection.dashboard;
  String _query = '';

  AppSection get section => _section;
  String get query => _query;

  void select(AppSection section) {
    if (section == _section) return;
    _section = section;
    notifyListeners();
  }

  void setQuery(String value) {
    final q = value.trim().toLowerCase();
    if (q == _query) return;
    _query = q;
    notifyListeners();
  }
}
