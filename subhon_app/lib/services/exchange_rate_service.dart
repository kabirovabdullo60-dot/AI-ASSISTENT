import '../core/network/api_client.dart';
import '../models/exchange_rates_model.dart';

/// `Settings` (API.md): exchange rates set on the server.
class ExchangeRateService {
  ExchangeRateService(this._api);

  final ApiClient _api;

  Future<ExchangeRatesModel> get() async => ExchangeRatesModel.fromJson(
    await _api.get('/api/settings/exchange-rates') as Map<String, dynamic>,
  );
}
