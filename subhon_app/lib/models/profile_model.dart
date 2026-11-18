import 'business_model.dart';
import 'user_role.dart';

/// `ProfileOut` from the API contract (API.md / Swagger).
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.business,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    avatar: json['avatar'] as String?,
    role: UserRole.fromJson(json['role'] as String),
    business: BusinessModel.fromJson(json['business'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final BusinessModel business;
  final DateTime createdAt;
}
