import '../core/utils/json.dart';

/// GET /auth/me
class UserProfileModel {
  const UserProfileModel({required this.name, required this.role, required this.email, required this.phone});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    name: asString(json['name']),
    role: asString(json['role']),
    email: asString(json['email']),
    phone: asString(json['phone']),
  );

  final String name;
  final String role;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() => {'name': name, 'role': role, 'email': email, 'phone': phone};
}
