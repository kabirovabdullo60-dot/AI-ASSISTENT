import 'format.dart';

/// Amounts are stored in TJS; USD is shown by converting with the server rate
/// (GET /api/settings/exchange-rates → [Currency.setRates]).
enum Currency {
  tjs('TJS', 'TJS (Сомонӣ)'),
  usd('USD', 'USD (\$)');

  const Currency(this.code, this.label);

  final String code;
  final String label;

  /// TJS per 1 unit. Fallback until the server answers.
  static final Map<String, double> _rates = {'USD': 10.95};

  /// From GET /api/settings/exchange-rates: `{"USD": 10.95, ...}`.
  static void setRates(Map<String, double> rates) => _rates.addAll(rates);

  double get tjsPerUnit => this == tjs ? 1 : _rates[code] ?? 1;

  double fromTjs(double tjs) => tjs / tjsPerUnit;

  /// Number only: "38,450"
  String amount(double tjs) => formatAmount(fromTjs(tjs));

  /// Number + code: "38,450 TJS"
  String format(double tjs) => '${amount(tjs)} $code';
}
