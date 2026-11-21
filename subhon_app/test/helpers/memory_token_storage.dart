import 'package:subhon_app/core/storage/token_storage.dart';

/// In memory (tests).
class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage({this.accessToken, this.refreshToken, this.signedInAt});

  String? accessToken;
  String? refreshToken;
  DateTime? signedInAt;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    signedInAt = null;
  }

  @override
  Future<DateTime?> readSignedInAt() async => signedInAt;

  @override
  Future<void> saveSignedInAt(DateTime time) async => signedInAt = time;
}
