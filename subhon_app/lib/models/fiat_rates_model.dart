/// Exchange rates of world currencies: how many units of each currency one
/// US dollar is worth (open.er-api.com, updated daily).
class FiatRatesModel {
  const FiatRatesModel({required this.perUsd, required this.updatedAt});

  factory FiatRatesModel.fromJson(Map<String, dynamic> json) => FiatRatesModel(
    perUsd: {
      for (final MapEntry(:key, :value)
          in (json['rates'] as Map<String, dynamic>).entries)
        key: (value as num).toDouble(),
    },
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['time_last_update_unix'] as int) * 1000,
      isUtc: true,
    ).toLocal(),
  );

  /// Currency code → units for 1 USD.
  final Map<String, double> perUsd;
  final DateTime updatedAt;

  /// [amount] of [from] in [to]; `null` when a currency is unknown.
  double? convert(double amount, String from, String to) {
    final a = perUsd[from];
    final b = perUsd[to];
    if (a == null || b == null || a == 0) return null;
    return amount / a * b;
  }
}
