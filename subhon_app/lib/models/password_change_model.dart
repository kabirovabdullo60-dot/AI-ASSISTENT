/// `PasswordChange` from the API contract (API.md / Swagger).
class PasswordChangeModel {
  const PasswordChangeModel({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
