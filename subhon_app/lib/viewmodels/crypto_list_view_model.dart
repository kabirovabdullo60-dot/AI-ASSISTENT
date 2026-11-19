import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/crypto_coin_model.dart';
import '../services/market_service.dart';

/// "Все криптовалюты": the top 100 coins with live prices, searchable by
/// name or ticker.
class CryptoListViewModel extends ChangeNotifier {
  CryptoListViewModel(this._market);

  final MarketService _market;

  static const int count = 100;

  List<CryptoCoinModel> _coins = const [];
  bool _isLoading = false;
  bool _loaded = false;
  Object? _error;
  String _search = '';

  bool get isLoading => _isLoading;
  bool get hasData => _loaded;
  Object? get error => _error;

  List<CryptoCoinModel> get coins => _search.isEmpty
      ? _coins
      : [
          for (final c in _coins)
            if (c.name.toLowerCase().contains(_search) ||
                c.symbol.toLowerCase().contains(_search))
              c,
        ];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _coins = await _market.coins(count: count);
      _loaded = true;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String text) {
    _search = text.trim().toLowerCase();
    notifyListeners();
  }
}
