import 'store_status.dart';

/// `StoreUpdate` from the API contract (API.md / Swagger).
class StoreUpdateModel {
  const StoreUpdateModel({
    this.name,
    this.address,
    this.phone,
    this.description,
    this.status,
  });

  final String? name;
  final String? address;
  final String? phone;
  final String? description;
  final StoreStatus? status;

  /// Fields sent as `null` to clear them (optional fields only).
  static const clearable = {'address', 'phone', 'description'};

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    'name': ?name,
    if (address != null || clear.contains('address')) 'address': address,
    if (phone != null || clear.contains('phone')) 'phone': phone,
    if (description != null || clear.contains('description'))
      'description': description,
    if (status != null) 'status': status!.json,
  };
}
