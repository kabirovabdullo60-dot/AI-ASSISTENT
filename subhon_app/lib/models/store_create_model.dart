import 'store_status.dart';

/// `StoreCreate` from the API contract (API.md / Swagger).
class StoreCreateModel {
  const StoreCreateModel({
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.status = StoreStatus.active,
  });

  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final StoreStatus status;

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': ?address,
    'phone': ?phone,
    'description': ?description,
    'status': status.json,
  };
}
