import '../core/utils/json.dart';

/// "+992 90 123 45 67" → "+992901234567" (the API accepts only `^\+?[0-9]{7,15}$`).
String? cleanPhone(String? v) {
  final s = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
  return s.isEmpty || s == '+' ? null : s;
}

/// StoreOut — GET /api/stores.
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: asString(json['id']),
    name: asString(json['name']),
    address: json['address'] == null ? null : asString(json['address']),
    phone: json['phone'] == null ? null : asString(json['phone']),
    description: json['description'] == null ? null : asString(json['description']),
    isActive: asString(json['status'], 'ACTIVE') == 'ACTIVE',
    createdAt: json['createdAt'] == null ? null : asDate(json['createdAt']),
    updatedAt: json['updatedAt'] == null ? null : asDate(json['updatedAt']),
  );

  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Body for POST /api/stores and PUT /api/stores/{id}.
  Map<String, dynamic> toJson() => {
    'name': name,
    'address': _orNull(address),
    'phone': cleanPhone(phone),
    'description': _orNull(description),
    'status': isActive ? 'ACTIVE' : 'INACTIVE',
  };

  static String? _orNull(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
}
