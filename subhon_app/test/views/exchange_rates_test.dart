import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/exchange_rates_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

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

  testWidgets('home shows the month sales in USD with the server rate', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/settings/exchange-rates', {
        'base': 'TJS',
        'rates': {'USD': '11.20'},
        'updatedAt': '2026-11-18T06:00:00Z',
      });
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    // 112 028 TJS / 11.20 = 10 002.5 → 10 003 USD.
    expect(find.textContaining('10 003 USD'), findsOneWidget);
    expect(find.textContaining('1 USD = 11,20 TJS'), findsOneWidget);
  });
}
