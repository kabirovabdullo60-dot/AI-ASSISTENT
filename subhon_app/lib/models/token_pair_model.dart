/// `TokenPair` from the API contract (API.md / Swagger).
class TokenPairModel {
  const TokenPairModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) => TokenPairModel(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    tokenType: (json['tokenType'] ?? 'Bearer') as String,
    expiresIn: json['expiresIn'] as int,
    refreshExpiresIn: json['refreshExpiresIn'] as int,
  );

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int refreshExpiresIn;
}
