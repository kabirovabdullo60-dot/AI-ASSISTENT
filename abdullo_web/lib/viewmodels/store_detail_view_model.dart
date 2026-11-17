import '../models/store_analytics_model.dart';
import '../services/store_service.dart';
import 'base_view_model.dart';

/// Data for the "View Analytics" side panel of one store.
class StoreDetailViewModel extends BaseViewModel {
  StoreDetailViewModel(this._service, this.storeId);

  final StoreService _service;
  final String storeId;
  StoreAnalyticsModel? _analytics;

  StoreAnalyticsModel? get analytics => _analytics;

  Future<void> load() => runTask(() async {
    _analytics = await _service.fetchAnalytics(storeId);
  }, errorMessage: 'Could not load store analytics.');
}
