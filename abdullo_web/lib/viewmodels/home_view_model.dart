import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  void select(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // TODO: call a service from lib/services
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
