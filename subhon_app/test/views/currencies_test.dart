import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:subhon_app/models/fiat_rates_model.dart';
import 'package:subhon_app/services/market_service.dart';
import 'package:subhon_app/viewmodels/currencies_view_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

/// open.er-api.com and CoinGecko, faked.
MarketService _market({void Function(Uri)? onCall, double btc = 64000}) =>
    MarketService(
      client: MockClient((request) async {
        onCall?.call(request.url);
        if (request.url.host == 'open.er-api.com') {
          return http.Response(
            jsonEncode({
              'result': 'success',
              'time_last_update_unix': 1795737600,
              'rates': {'USD': 1, 'TJS': 10.5, 'RUB': 80, 'EUR': 0.9},
            }),
            200,
          );
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {
                'id': 'bitcoin',
                'symbol': 'btc',
                'name': 'Bitcoin',
                'current_price': btc,
                'price_change_percentage_24h': -1.12,
                'image': null,
              },
              {
                'id': 'tether',
                'symbol': 'usdt',
                'name': 'Tether',
                'current_price': 1.0,
                'price_change_percentage_24h': 0.02,
                'image': null,
              },
            ]),
          ),
          200,
        );
      }),
    );

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('converting goes through the dollar', () {
    final rates = FiatRatesModel(
      perUsd: const {'USD': 1, 'TJS': 10.5, 'RUB': 80},
      updatedAt: DateTime(2026, 11, 19),
    );
    expect(rates.convert(1, 'USD', 'TJS'), 10.5);
    expect(rates.convert(80, 'RUB', 'TJS'), closeTo(10.5, 1e-9));
    expect(rates.convert(1, 'USD', 'XXX'), isNull);
  });

  testWidgets('the "Валюты" tab: converter, swap, crypto in somoni', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      market: _market(),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Валюты');

    expect(find.text('Конвертер'), findsOneWidget);
    expect(find.text('1 USD = 10,5 TJS'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    expect(find.text('1 050'), findsOneWidget);

    await tester.tap(find.byTooltip('Поменять местами'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 TJS = 0,0952'), findsOneWidget);

    // 64 000 USD × 10.5 = 672 000 TJS.
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('672 000 TJS'), findsOneWidget);
    expect(find.text('−1,12 %'), findsOneWidget);
    expect(find.text('Tether'), findsOneWidget);
  });

  test('crypto prices are turned into somoni with the dollar rate', () async {
    var coinCalls = 0;
    final vm = CurrenciesViewModel(
      _market(
        onCall: (uri) {
          if (uri.host == 'api.coingecko.com') coinCalls++;
        },
      ),
    );
    await vm.load();
    expect(coinCalls, 1);
    expect(vm.priceInTjs(vm.coins.first), 672000);
    vm.setLive(live: false);
    vm.dispose();
  });

  test('CoinGecko busy (429): prices come from Binance', () async {
    final market = MarketService(
      client: MockClient((request) async {
        if (request.url.host == 'api.coingecko.com') {
          return http.Response('{}', 429);
        }
        final symbols =
            jsonDecode(request.url.queryParameters['symbols']!)
                as List<dynamic>;
        return http.Response(
          jsonEncode([
            for (final s in symbols)
              {
                'symbol': s,
                'lastPrice': s == 'BTCUSDT' ? '63854.20' : '1.50',
                'priceChangePercent': '-0.893',
              },
          ]),
          200,
        );
      }),
    );
    final coins = await market.coins(count: 3);
    expect(coins.map((c) => c.symbol), ['BTC', 'ETH', 'USDT']);
    expect(coins.first.priceUsd, 63854.20);
    expect(coins.first.change24h, -0.893);
    expect(coins.last.priceUsd, 1);
  });
}
