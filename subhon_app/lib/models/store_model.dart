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
    this.city,
    this.region,
    this.type,
    this.counters,
    this.openingHours,
    this.statusNote,
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
    city: json['city'] as String?,
    region: json['region'] as String?,
    type: json['type'] as String?,
    counters: json['counters'] as int?,
    openingHours: json['openingHours'] as String?,
    statusNote: json['statusNote'] as String?,
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
  final String? city;

  /// E.g. `Dushanbe`, `Sughd`, `Khatlon`, `GBAO`, `RRS`; groups the store
  /// comparison.
  final String? region;

  /// Store format, e.g. `Flagship`, `Supermarket`, `Kiosk`.
  final String? type;

  /// Checkout counters, 0–999.
  final int? counters;
  final String? openingHours;

  /// Why the store has its status, e.g. `Renovation`.
  final String? statusNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
