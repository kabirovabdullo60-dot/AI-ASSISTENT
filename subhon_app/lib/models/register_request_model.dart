/// `RegisterRequest` from the API contract (API.md / Swagger).
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.businessName,
  });

  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String? businessName;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'phone': ?phone,
    'businessName': ?businessName,
  };
}
