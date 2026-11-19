import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';

/// `WEEK` (Monday–Sunday) or `MONTH`.
enum TargetPeriod { week, month }

class TargetService {
  TargetService(this._api);

  final ApiClient _api;

  /// PUT /api/targets — creates the target or changes its amount (`storeId: null` = whole business).
  Future<void> put(TargetPeriod period, double amount, {String? storeId}) => _api.put(ApiConstants.targets, {
    'period': period.name.toUpperCase(),
    'storeId': storeId,
    'amount': money(amount),
  });
}
