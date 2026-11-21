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

  /// When the person last signed in (login or register, not a refresh):
  /// the app asks for the login again 7 days later.
  Future<DateTime?> readSignedInAt();
  Future<void> saveSignedInAt(DateTime time);
}
