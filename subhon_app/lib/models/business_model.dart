/// `BusinessOut` from the API contract (API.md / Swagger).
class BusinessModel {
  const BusinessModel({required this.id, required this.name});

  factory BusinessModel.fromJson(Map<String, dynamic> json) =>
      BusinessModel(id: json['id'] as String, name: json['name'] as String);

  final String id;
  final String name;
}
