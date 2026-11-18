import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';

/// A form that sends something to the API: in progress, the last error,
/// and nothing sent twice while a request is running.
abstract class FormViewModel extends ChangeNotifier {
  bool _isSaving = false;
  Object? _error;

  bool get isSaving => _isSaving;

  /// Why the last request failed ([ApiException]); `null` after success.
  Object? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Runs [action]; `true` when it succeeded.
  @protected
  Future<bool> submit(Future<void> Function() action) async {
    if (_isSaving) return false;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _error = e;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
