/// Where the access and refresh tokens are kept.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();

  /// Saves both tokens together (a refresh returns a new pair).
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clear();
}
