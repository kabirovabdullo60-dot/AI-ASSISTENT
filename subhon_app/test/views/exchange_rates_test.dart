import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/models/exchange_rates_model.dart';
import 'package:subhon_app/services/exchange_rate_service.dart';

import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  test('rates come as decimal strings; TJS are converted', () {
    final rates = ExchangeRatesModel.fromJson({
      'base': 'TJS',
      'rates': {'USD': '10.93', 'EUR': '11.80'},
      'updatedAt': '2026-11-18T06:00:00Z',
    });
    expect(rates.rates['USD'], 10.93);
    expect(rates.convert(109.30, 'USD'), closeTo(10, 0.0001));
    expect(rates.convert(100, 'RUB'), isNull);
  });

  test('the service reads GET /api/settings/exchange-rates', () async {
    final backend = FakeBackend()
      ..json('GET', '/api/settings/exchange-rates', {
        'base': 'TJS',
        'rates': {'USD': '10.95'},
        'updatedAt': '2026-11-18T06:00:00Z',
      });
    final rates = await ExchangeRateService(
      ApiClient(
        tokens: MemoryTokenStorage(accessToken: 'a'),
        client: backend.client,
      ),
    ).get();
    expect(rates.rates['USD'], 10.95);
  });
}
