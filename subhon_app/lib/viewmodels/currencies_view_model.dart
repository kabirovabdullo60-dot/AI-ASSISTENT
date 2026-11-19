import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/crypto_coin_model.dart';
import '../models/fiat_rates_model.dart';
import '../services/market_service.dart';

/// The "Валюты" tab: a converter between world currencies and live crypto
/// prices (in somoni), refreshed every [liveEvery] while the tab is shown.
class CurrenciesViewModel extends ChangeNotifier {
  CurrenciesViewModel(this._market, {this.coinCount = 10});

  final MarketService _market;
  final int coinCount;

  static const liveEvery = Duration(seconds: 30);

  /// Shown first in the currency lists.
  static const popular = [
    'TJS', 'USD', 'EUR', 'RUB', 'CNY', 'KZT', 'UZS', 'KGS', 'TRY', 'AED', //
    'GBP',
  ];

  FiatRatesModel? _rates;
  List<CryptoCoinModel> _coins = const [];
  DateTime? _coinsAt;
  bool _isLoading = false;
  Object? _error;
  Object? _coinsError;
  double _amount = 1;
  String _from = 'USD';
  String _to = 'TJS';
  Timer? _live;
  bool _disposed = false;

  FiatRatesModel? get rates => _rates;
  List<CryptoCoinModel> get coins => _coins;
  DateTime? get coinsUpdatedAt => _coinsAt;
  bool get isLoading => _isLoading;
  bool get hasData => _rates != null;
  Object? get error => _error;

  /// Crypto could not be loaded (the converter still works).
  Object? get coinsError => _coinsError;
  double get amount => _amount;
  String get from => _from;
  String get to => _to;

  /// Every currency: popular ones first, then A–Z.
  List<String> get currencies {
    final all = _rates?.perUsd.keys.toList() ?? const <String>[];
    return [
      for (final c in popular)
        if (all.contains(c)) c,
      ...(all.where((c) => !popular.contains(c)).toList()..sort()),
    ];
  }

  /// [amount] of [from] in [to].
  double? get result => _rates?.convert(_amount, _from, _to);

  /// 1 [from] in [to].
  double? get rate => _rates?.convert(1, _from, _to);

  /// A coin's price in somoni.
  double? priceInTjs(CryptoCoinModel coin) {
    final tjs = _rates?.perUsd['TJS'];
    return tjs == null ? null : coin.priceUsd * tjs;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      _rates = await _market.fiatRates();
    } on ApiException catch (e) {
      _error = e;
    }
    await refreshCoins();
    _isLoading = false;
    _notify();
  }

  Future<void> refreshCoins() async {
    try {
      _coins = await _market.coins(count: coinCount);
      _coinsAt = DateTime.now();
      _coinsError = null;
    } on ApiException catch (e) {
      _coinsError = e;
    }
    _notify();
  }

  void setAmount(double value) {
    _amount = value;
    _notify();
  }

  void setFrom(String code) {
    _from = code;
    _notify();
  }

  void setTo(String code) {
    _to = code;
    _notify();
  }

  void swap() {
    final from = _from;
    _from = _to;
    _to = from;
    _notify();
  }

  /// Live crypto prices while the tab is on screen.
  void setLive({required bool live}) {
    if (live && _live == null) {
      _live = Timer.periodic(liveEvery, (_) => refreshCoins());
    } else if (!live) {
      _live?.cancel();
      _live = null;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _live?.cancel();
    super.dispose();
  }
}
