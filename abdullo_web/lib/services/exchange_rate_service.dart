import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';

class ExchangeRateService {
  ExchangeRateService(this._api);

  final ApiClient _api;

  /// GET /api/settings/exchange-rates → `{"USD": 10.95}` (TJS per 1 unit).
  Future<Map<String, double>> rates() async {
    final rates = asJsonMap(await _api.get(ApiConstants.exchangeRates))['rates'];
    if (rates is! Map) return const {};
    return {
      for (final e in rates.entries)
        if (asDouble(e.value) > 0) '${e.key}': asDouble(e.value),
    };
  }
}
