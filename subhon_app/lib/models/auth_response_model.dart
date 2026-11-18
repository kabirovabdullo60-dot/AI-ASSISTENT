import 'profile_model.dart';

/// `AuthResponse` from the API contract (API.md / Swagger).
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        tokenType: (json['tokenType'] ?? 'Bearer') as String,
        expiresIn: json['expiresIn'] as int,
        refreshExpiresIn: json['refreshExpiresIn'] as int,
        user: ProfileModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int refreshExpiresIn;
  final ProfileModel user;
}
