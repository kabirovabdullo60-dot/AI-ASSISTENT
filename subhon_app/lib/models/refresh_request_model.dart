/// `RefreshRequest` from the API contract (API.md / Swagger).
class RefreshRequestModel {
  const RefreshRequestModel({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
