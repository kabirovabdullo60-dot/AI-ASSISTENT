import 'package:flutter/foundation.dart';

import '../core/navigation/app_section.dart';

/// Open page + the global search text from the top bar.
/// [initial] = the page open before the browser reloaded; [onSectionChanged] remembers each change.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({AppSection? initial, this.onSectionChanged}) : _section = initial ?? AppSection.dashboard;

  final void Function(AppSection section)? onSectionChanged;

  AppSection _section;
  String _query = '';

  bool _sidebarCollapsed = false;

  AppSection get section => _section;

  /// Desktop: the menu folded to icons only (button next to the logo).
  bool get sidebarCollapsed => _sidebarCollapsed;

  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    notifyListeners();
  }

  String get query => _query;

  void select(AppSection section) {
    if (section == _section) return;
    _section = section;
    onSectionChanged?.call(section);
    notifyListeners();
  }

  void setQuery(String value) {
    final q = value.trim().toLowerCase();
    if (q == _query) return;
    _query = q;
    notifyListeners();
  }
}
