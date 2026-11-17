import '../core/utils/json.dart';

/// GET /stores
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.counters,
    required this.monthlySales,
    required this.manager,
    required this.staffCount,
    this.isActive = true,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: asString(json['id']),
    name: asString(json['name']),
    type: asString(json['type']),
    area: asString(json['area']),
    counters: asInt(json['counters']),
    monthlySales: asDouble(json['monthlySales']),
    manager: asString(json['manager']),
    staffCount: asInt(json['staffCount']),
    isActive: json['isActive'] == null || asBool(json['isActive']),
  );

  final String id;
  final String name;
  final String type;
  final String area;
  final int counters;
  final double monthlySales;
  final String manager;
  final int staffCount;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'area': area,
    'counters': counters,
    'monthlySales': monthlySales,
    'manager': manager,
    'staffCount': staffCount,
    'isActive': isActive,
  };
}
