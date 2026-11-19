import 'store_status.dart';

/// `StoreCreate` from the API contract (API.md / Swagger).
class StoreCreateModel {
  const StoreCreateModel({
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.status = StoreStatus.active,
    this.city,
    this.region,
    this.type,
    this.counters,
    this.openingHours,
    this.statusNote,
  });

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

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': ?address,
    'phone': ?phone,
    'description': ?description,
    'status': status.json,
    'city': ?city,
    'region': ?region,
    'type': ?type,
    'counters': ?counters,
    'openingHours': ?openingHours,
    'statusNote': ?statusNote,
  };
}
