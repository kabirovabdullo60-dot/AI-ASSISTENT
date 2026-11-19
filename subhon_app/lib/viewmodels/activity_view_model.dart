import '../models/activity_model.dart';
import '../models/page_model.dart';
import '../services/activity_service.dart';
import 'paged_list_view_model.dart';

/// The activity log page by page, newest first; one store's operations
/// log when [storeId] is given.
class ActivityViewModel extends PagedListViewModel<ActivityModel> {
  ActivityViewModel(this._activity, {this.storeId});

  final ActivityService _activity;
  final String? storeId;

  @override
  Future<PageModel<ActivityModel>> fetch(int page) =>
      _activity.list(storeId: storeId, page: page);
}
