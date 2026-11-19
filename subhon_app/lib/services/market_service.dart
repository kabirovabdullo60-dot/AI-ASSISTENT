import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/network/api_exception.dart';
import '../models/crypto_coin_model.dart';
import '../models/fiat_rates_model.dart';

/// Public market data, not from our backend: world exchange rates
/// (open.er-api.com, daily) and live crypto prices (CoinGecko, about every
/// minute; Binance when CoinGecko is busy). Only prices are asked for; no
/// business data is sent.
class MarketService {
  MarketService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _ratesUrl = 'https://open.er-api.com/v6/latest/USD';
  static const _coinsUrl = 'https://api.coingecko.com/api/v3/coins/markets';
  static const _binanceUrl = 'https://api.binance.com/api/v3/ticker/24hr';

  /// The biggest coins (ticker → name) for the Binance fallback, priced in
  /// USDT (≈ 1 USD); Tether itself is 1 USD.
  static const _fallbackCoins = {
    'BTC': 'Bitcoin', 'ETH': 'Ethereum', 'USDT': 'Tether', 'BNB': 'BNB', //
    'SOL': 'Solana', 'USDC': 'USDC', 'XRP': 'XRP', 'DOGE': 'Dogecoin',
    'TRX': 'TRON', 'ADA': 'Cardano', 'TON': 'Toncoin', 'AVAX': 'Avalanche',
    'LINK': 'Chainlink', 'DOT': 'Polkadot', 'LTC': 'Litecoin',
    'BCH': 'Bitcoin Cash', 'SHIB': 'Shiba Inu', 'XLM': 'Stellar',
    'NEAR': 'NEAR Protocol', 'UNI': 'Uniswap',
  };
  static const _timeout = Duration(seconds: 20);

  Future<FiatRatesModel> fiatRates() async => FiatRatesModel.fromJson(
    await _get(Uri.parse(_ratesUrl)) as Map<String, dynamic>,
  );

  /// The [count] biggest coins by market value, biggest first; from
  /// Binance (fewer coins, no logos) when CoinGecko can't answer.
  Future<List<CryptoCoinModel>> coins({int count = 10}) async {
    try {
      return await _coinGecko(count);
    } on ApiException {
      return _binance(count);
    }
  }

  Future<List<CryptoCoinModel>> _binance(int count) async {
    final tickers = _fallbackCoins.keys.where((t) => t != 'USDT').take(count);
    final symbols = jsonEncode([for (final t in tickers) '${t}USDT']);
    final data = await _get(
      Uri.parse(_binanceUrl).replace(queryParameters: {'symbols': symbols}),
    );
    final bySymbol = {
      for (final t in data as List<dynamic>)
        (t as Map<String, dynamic>)['symbol'] as String: t,
    };
    return [
      for (final MapEntry(key: ticker, value: name)
          in _fallbackCoins.entries.take(count))
        if (ticker == 'USDT')
          const CryptoCoinModel(
            id: 'tether',
            symbol: 'USDT',
            name: 'Tether',
            priceUsd: 1,
            change24h: 0,
          )
        else if (bySymbol['${ticker}USDT'] case final t?)
          CryptoCoinModel(
            id: ticker.toLowerCase(),
            symbol: ticker,
            name: name,
            priceUsd: double.parse(t['lastPrice'] as String),
            change24h: double.tryParse(t['priceChangePercent'] as String),
          ),
    ];
  }

  Future<List<CryptoCoinModel>> _coinGecko(int count) async {
    final data = await _get(
      Uri.parse(_coinsUrl).replace(
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': '$count',
          'page': '1',
          'price_change_percentage': '24h',
        },
      ),
    );
    return [
      for (final c in data as List<dynamic>)
        CryptoCoinModel.fromJson(c as Map<String, dynamic>),
    ];
  }

  Future<Object?> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
      if (response.statusCode == 429) {
        throw const ApiException(429, 'RATE_LIMITED');
      }
      if (response.statusCode != 200) {
        throw ApiException(response.statusCode, ApiException.unknownError);
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on TimeoutException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on http.ClientException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on FormatException {
      throw const ApiException(0, ApiException.unknownError);
    }
  }
}
