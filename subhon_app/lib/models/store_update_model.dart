import 'store_status.dart';

/// `StoreUpdate` from the API contract (API.md / Swagger).
class StoreUpdateModel {
  const StoreUpdateModel({
    this.name,
    this.address,
    this.phone,
    this.description,
    this.status,
    this.city,
    this.region,
    this.type,
    this.counters,
    this.openingHours,
    this.statusNote,
  });

  final String? name;
  final String? address;
  final String? phone;
  final String? description;
  final StoreStatus? status;
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

  /// Fields sent as `null` to clear them (optional fields only).
  static const clearable = {
    'address',
    'phone',
    'description',
    'city',
    'region',
    'type',
    'counters',
    'openingHours',
    'statusNote',
  };

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    'name': ?name,
    if (address != null || clear.contains('address')) 'address': address,
    if (phone != null || clear.contains('phone')) 'phone': phone,
    if (description != null || clear.contains('description'))
      'description': description,
    if (status != null) 'status': status!.json,
    for (final (key, value) in [
      ('city', city),
      ('region', region),
      ('type', type),
      ('counters', counters),
      ('openingHours', openingHours),
      ('statusNote', statusNote),
    ])
      if (value != null || clear.contains(key)) key: value,
  };
}
