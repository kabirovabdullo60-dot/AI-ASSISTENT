import '../core/network/api_client.dart';
import '../models/page_model.dart';
import '../models/target_model.dart';
import '../models/target_put_model.dart';

/// `Targets` (API.md): weekly and monthly sales targets.
class TargetService {
  TargetService(this._api);

  final ApiClient _api;

  /// Creates the target or changes its amount (same period and store).
  Future<TargetModel> put(TargetPutModel target) async => TargetModel.fromJson(
    await _api.put('/api/targets', body: target.toJson())
        as Map<String, dynamic>,
  );

  /// The whole business first, then stores by name; WEEK before MONTH.
  Future<PageModel<TargetModel>> list({int page = 1, int limit = 100}) async =>
      PageModel.fromJson(
        await _api.get('/api/targets', query: {'page': page, 'limit': limit})
            as Map<String, dynamic>,
        TargetModel.fromJson,
      );
}
