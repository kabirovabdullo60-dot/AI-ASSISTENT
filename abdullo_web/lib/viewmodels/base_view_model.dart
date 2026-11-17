import 'package:flutter/foundation.dart';

/// Shared loading / error handling for every ViewModel.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Runs [task] with isLoading/error handling. Returns `true` on success.
  @protected
  Future<bool> runTask(Future<void> Function() task, {required String errorMessage}) async {
    _isLoading = true;
    _error = null;
    notifySafe();
    try {
      await task();
      return true;
    } catch (e) {
      _error = errorMessage;
      debugPrint('$runtimeType: $e');
      return false;
    } finally {
      _isLoading = false;
      notifySafe();
    }
  }

  @protected
  void notifySafe() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
