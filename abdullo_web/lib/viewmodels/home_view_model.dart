import 'package:flutter/foundation.dart';

/// Which section of the web is open (Dashboard, Assistant, Reports, Settings).
class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void select(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
