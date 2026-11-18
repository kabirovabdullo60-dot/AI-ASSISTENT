/// `LoginRequest` from the API contract (API.md / Swagger).
class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
