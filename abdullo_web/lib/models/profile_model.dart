import '../core/utils/json.dart';

/// ProfileOut — GET /api/auth/me, GET/PUT /api/profile.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'OWNER',
    required this.businessId,
    required this.businessName,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final business = json['business'] is Map ? Map<String, dynamic>.from(json['business'] as Map) : const {};
    return ProfileModel(
      id: asString(json['id']),
      fullName: asString(json['fullName']),
      email: asString(json['email']),
      phone: json['phone'] == null ? null : asString(json['phone']),
      avatar: json['avatar'] == null ? null : asString(json['avatar']),
      role: asString(json['role'], 'OWNER'),
      businessId: asString(business['id']),
      businessName: asString(business['name']),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String? phone;

  /// Avatar URL (may be relative to the API host).
  final String? avatar;
  final String role;
  final String businessId;
  final String businessName;
}
