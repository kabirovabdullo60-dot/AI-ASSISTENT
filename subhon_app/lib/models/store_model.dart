import 'store_status.dart';

/// `StoreOut` from the API contract (API.md / Swagger).
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    description: json['description'] as String?,
    status: StoreStatus.fromJson(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String).toLocal(),
  );

  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final StoreStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
