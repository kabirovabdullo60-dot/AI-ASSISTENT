import '../core/network/api_client.dart';
import '../models/activity_model.dart';
import '../models/page_model.dart';
import '../models/profit_model.dart';
import '../services/activity_service.dart';
import '../services/reports_service.dart';
import 'history_range.dart';
import 'paged_list_view_model.dart';

/// The "История" tab: every operation of the business, newest first, page
/// by page, for all time / today / yesterday / the last 7 days, searchable
/// by name; grouped by day. On top: this month's expenses (from the
/// profit report), which can be hidden.
class HistoryViewModel extends PagedListViewModel<ActivityModel> {
  HistoryViewModel(this._activity, this._reports, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ActivityService _activity;
  final ReportsService _reports;
  final DateTime Function() _clock;

  HistoryRange _range = HistoryRange.all;
  String _search = '';
  bool _amountHidden = false;
  ProfitModel? _month;

  HistoryRange get range => _range;
  String get search => _search;
  bool get amountHidden => _amountHidden;

  /// This month so far: expenses and sales; `null` when not loaded.
  ProfitModel? get month => _month;

  Future<void> setRange(HistoryRange range) {
    _range = range;
    return load();
  }

  void setSearch(String text) {
    _search = text.trim().toLowerCase();
    notifyListeners();
  }

  void toggleAmount() {
    _amountHidden = !_amountHidden;
    notifyListeners();
  }

  /// The loaded operations matching the search, grouped by day (newest
  /// first).
  List<(DateTime, List<ActivityModel>)> get days {
    final groups = <DateTime, List<ActivityModel>>{};
    for (final a in items) {
      if (_search.isNotEmpty &&
          ![
            a.entityName,
            a.storeName ?? '',
            a.actorName,
            a.note ?? '',
          ].any((s) => s.toLowerCase().contains(_search))) {
        continue;
      }
      final t = a.createdAt;
      (groups[DateTime(t.year, t.month, t.day)] ??= []).add(a);
    }
    return [for (final e in groups.entries) (e.key, e.value)];
  }

  @override
  Future<PageModel<ActivityModel>> fetch(int page) async {
    if (page == 1) {
      try {
        _month = await _reports.profit();
      } on ApiException {
        // The list matters more; the card is shown when available.
      }
    }
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final (DateTime? start, DateTime? end) = switch (_range) {
      HistoryRange.all => (null, null),
      HistoryRange.today => (today, today),
      HistoryRange.yesterday => (
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 1)),
      ),
      HistoryRange.week => (today.subtract(const Duration(days: 6)), today),
    };
    return _activity.list(startDate: start, endDate: end, page: page);
  }
}
