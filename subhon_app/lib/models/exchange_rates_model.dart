import '../core/utils/money.dart';

/// `ExchangeRatesOut` from the API contract (API.md / Swagger): how many
/// TJS one unit of each currency is worth. Amounts in the API stay in TJS.
class ExchangeRatesModel {
  const ExchangeRatesModel({
    required this.rates,
    required this.updatedAt,
    this.base = 'TJS',
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) =>
      ExchangeRatesModel(
        base: (json['base'] ?? 'TJS') as String,
        rates: {
          for (final MapEntry(:key, :value)
              in (json['rates'] as Map<String, dynamic>).entries)
            key: parseMoney('$value'),
        },
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );

  final String base;

  /// Currency code → TJS for one unit.
  final Map<String, double> rates;
  final DateTime updatedAt;

  /// [tjs] in [currency], or `null` when there is no rate for it.
  double? convert(double tjs, String currency) {
    final rate = rates[currency];
    return rate == null || rate <= 0 ? null : tjs / rate;
  }
}
