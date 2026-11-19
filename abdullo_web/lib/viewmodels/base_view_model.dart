import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';

/// Shared loading / error handling for every ViewModel.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  /// Error code of the last failed load (shown as a translated message).
  String? get error => _error;

  @protected
  Future<bool> runTask(Future<void> Function() task) async {
    _isLoading = true;
    _error = null;
    notifySafe();
    try {
      await task();
      return true;
    } on ApiException catch (e) {
      _error = e.code;
      debugPrint('$runtimeType: $e');
      return false;
    } catch (e) {
      _error = 'UNKNOWN';
      debugPrint('$runtimeType: $e');
      return false;
    } finally {
      _isLoading = false;
      notifySafe();
    }
  }

  /// Runs a save/delete action. Returns `null` on success or the error code.
  @protected
  Future<String?> runAction(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on ApiException catch (e) {
      debugPrint('$runtimeType: $e');
      return e.code;
    } catch (e) {
      debugPrint('$runtimeType: $e');
      return 'UNKNOWN';
    } finally {
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
