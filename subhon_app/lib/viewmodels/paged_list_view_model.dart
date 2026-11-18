import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/page_model.dart';

/// A list loaded page by page (`{items, total, page, limit, pages}`):
/// first load, pull-to-refresh, "load more", and the standard states.
abstract class PagedListViewModel<T> extends ChangeNotifier {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _loaded = false;
  Object? _error;
  int _page = 0;
  int _pages = 1;
  int _total = 0;
  double? _totalAmount;

  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  /// The first page has arrived (it may be empty).
  bool get hasData => _loaded;
  Object? get error => _error;
  bool get hasMore => _page < _pages;
  int get total => _total;

  /// Sales and payments: the sum over every page.
  double? get totalAmount => _totalAmount;

  @protected
  Future<PageModel<T>> fetch(int page);

  /// Loads the first page again (also after a filter change).
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final first = await fetch(1);
      _items
        ..clear()
        ..addAll(first.items);
      _accept(first);
      _loaded = true;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final next = await fetch(_page + 1);
      _items.addAll(next.items);
      _accept(next);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Removes an item locally after it was deleted on the server.
  @protected
  void removeWhere(bool Function(T item) test) {
    final before = _items.length;
    _items.removeWhere(test);
    _total -= before - _items.length;
    notifyListeners();
  }

  void _accept(PageModel<T> page) {
    _page = page.page;
    _pages = page.pages;
    _total = page.total;
    _totalAmount = page.totalAmount;
  }
}
