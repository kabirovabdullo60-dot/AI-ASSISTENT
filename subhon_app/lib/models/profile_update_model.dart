/// `ProfileUpdate` from the API contract (API.md / Swagger).
class ProfileUpdateModel {
  const ProfileUpdateModel({
    this.fullName,
    this.email,
    this.phone,
    this.businessName,
  });

  final String? fullName;
  final String? email;
  final String? phone;
  final String? businessName;

  /// Fields sent as `null` to clear them (optional fields only).
  static const clearable = {'phone'};

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    'fullName': ?fullName,
    'email': ?email,
    if (phone != null || clear.contains('phone')) 'phone': phone,
    'businessName': ?businessName,
  };
}
