import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/profile_model.dart';
import '../models/register_request_model.dart';

/// `Auth` (API.md): register, log in, current user, log out. Both tokens
/// are saved on the device after register / login.
class AuthService {
  AuthService(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<ProfileModel> login(LoginRequestModel request) async => _signedIn(
    await _api.post('/api/auth/login', body: request.toJson(), auth: false),
  );

  Future<ProfileModel> register(RegisterRequestModel request) async =>
      _signedIn(
        await _api.post(
          '/api/auth/register',
          body: request.toJson(),
          auth: false,
        ),
      );

  Future<ProfileModel> _signedIn(dynamic json) async {
    final auth = AuthResponseModel.fromJson(json as Map<String, dynamic>);
    await _tokens.save(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    return auth.user;
  }

  /// Whether a session was saved on this device.
  Future<bool> hasSession() async => await _tokens.readRefreshToken() != null;

  /// `GET /api/auth/me`: the signed-in user (also used at app start).
  Future<ProfileModel> me() async => ProfileModel.fromJson(
    await _api.get('/api/auth/me') as Map<String, dynamic>,
  );

  /// Ends the session on the server, then forgets the tokens — also when
  /// the server cannot be reached.
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    try {
      if (refreshToken != null) {
        await _api.post(
          '/api/auth/logout',
          body: {'refreshToken': refreshToken},
          auth: false,
        );
      }
    } on ApiException {
      // The device forgets the session anyway.
    } finally {
      await _tokens.clear();
    }
  }
}
