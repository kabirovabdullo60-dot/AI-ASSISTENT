/// One cryptocurrency with its live price (CoinGecko, in US dollars).
class CryptoCoinModel {
  const CryptoCoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    this.imageUrl,
  });

  factory CryptoCoinModel.fromJson(Map<String, dynamic> json) =>
      CryptoCoinModel(
        id: json['id'] as String,
        symbol: (json['symbol'] as String).toUpperCase(),
        name: json['name'] as String,
        priceUsd: (json['current_price'] as num?)?.toDouble() ?? 0,
        change24h: (json['price_change_percentage_24h'] as num?)?.toDouble(),
        imageUrl: json['image'] as String?,
      );

  final String id;
  final String symbol;
  final String name;
  final double priceUsd;

  /// Change over the last 24 hours, in %; `null` when unknown.
  final double? change24h;
  final String? imageUrl;
}
