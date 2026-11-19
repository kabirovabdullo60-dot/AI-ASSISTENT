import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/profile_model.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  bool get hasSession => _api.tokens.hasSession;

  Future<ProfileModel> login({required String email, required String password}) async {
    final json = asJsonMap(await _api.post(ApiConstants.login, {'email': email.trim(), 'password': password}, false));
    return _saveSession(json);
  }

  Future<ProfileModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) async {
    final json = asJsonMap(
      await _api.post(ApiConstants.register, {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (businessName != null && businessName.trim().isNotEmpty) 'businessName': businessName.trim(),
      }, false),
    );
    return _saveSession(json);
  }

  Future<ProfileModel> _saveSession(Map<String, dynamic> json) async {
    await _api.tokens.save(asString(json['accessToken']), asString(json['refreshToken']));
    return ProfileModel.fromJson(asJsonMap(json['user']));
  }

  /// Restores the saved session (tokens in the browser). `null` = must log in.
  Future<ProfileModel?> restore() async {
    await _api.tokens.load();
    if (!_api.tokens.hasSession) return null;
    try {
      return ProfileModel.fromJson(asJsonMap(await _api.get(ApiConstants.me)));
    } on ApiException catch (e) {
      if (e.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<void> logout() async {
    final refresh = _api.tokens.refreshToken;
    try {
      if (refresh != null) await _api.post(ApiConstants.logout, {'refreshToken': refresh});
    } catch (_) {
      // Even if the server is unreachable, forget the tokens locally.
    } finally {
      await _api.tokens.clear();
    }
  }
}
