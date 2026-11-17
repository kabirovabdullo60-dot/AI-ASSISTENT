import '../models/activity_model.dart';
import '../models/chart_point_model.dart';
import '../models/overview_model.dart';
import '../services/dashboard_service.dart';
import 'base_view_model.dart';

enum ChartRange { weekly, monthly }

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this._service);

  final DashboardService _service;

  OverviewModel? _overview;
  List<ActivityModel> _activity = const [];
  String? _storeId;
  ChartRange _range = ChartRange.monthly;
  ActivityType? _activityFilter;

  OverviewModel? get overview => _overview;
  String? get selectedStoreId => _storeId;
  ChartRange get range => _range;
  ActivityType? get activityFilter => _activityFilter;

  List<ChartPointModel> get chartPoints {
    final all = _overview?.dailyRevenue ?? const <ChartPointModel>[];
    return _range == ChartRange.weekly && all.length > 7 ? all.sublist(all.length - 7) : all;
  }

  /// Index of the best day in [chartPoints], -1 if empty.
  int get peakIndex {
    final points = chartPoints;
    var best = -1;
    for (var i = 0; i < points.length; i++) {
      if (best < 0 || points[i].revenue > points[best].revenue) best = i;
    }
    return best;
  }

  List<ActivityModel> activity(String query) => _activity
      .where((a) => _activityFilter == null || a.type == _activityFilter)
      .where((a) => query.isEmpty || a.searchText.contains(query))
      .toList();

  Future<void> load() => runTask(() async {
    final (overview, activity) = await (_service.fetchOverview(storeId: _storeId), _service.fetchActivity()).wait;
    _overview = overview;
    _activity = activity;
  }, errorMessage: 'Could not load the dashboard. Check the connection and try again.');

  /// `null` = all stores.
  Future<void> selectStore(String? storeId) async {
    if (storeId == _storeId) return;
    _storeId = storeId;
    await load();
  }

  void setRange(ChartRange range) {
    if (range == _range) return;
    _range = range;
    notifySafe();
  }

  void setActivityFilter(ActivityType? type) {
    _activityFilter = type;
    notifySafe();
  }
}
