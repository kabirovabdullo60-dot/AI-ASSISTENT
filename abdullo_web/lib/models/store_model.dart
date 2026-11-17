import '../core/utils/json.dart';

/// GET /stores — one branch.
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.region,
    required this.phone,
    this.counters = 1,
    this.staffCount = 0,
    this.todaySales = 0,
    this.todayChange = 0,
    this.weeklySales = 0,
    this.monthlySales = 0,
    this.monthlyChange = 0,
    this.note = '',
    this.openingHours = 'Mon-Sun: 08:00 - 22:00',
    this.isActive = true,
    this.statusNote = '',
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    id: asString(json['id']),
    name: asString(json['name']),
    type: asString(json['type']),
    address: asString(json['address']),
    city: asString(json['city']),
    region: asString(json['region']),
    phone: asString(json['phone']),
    counters: asInt(json['counters']),
    staffCount: asInt(json['staffCount']),
    todaySales: asDouble(json['todaySales']),
    todayChange: asDouble(json['todayChange']),
    weeklySales: asDouble(json['weeklySales']),
    monthlySales: asDouble(json['monthlySales']),
    monthlyChange: asDouble(json['monthlyChange']),
    note: asString(json['note']),
    openingHours: asString(json['openingHours'], 'Mon-Sun: 08:00 - 22:00'),
    isActive: json['isActive'] == null || asBool(json['isActive']),
    statusNote: asString(json['statusNote']),
  );

  final String id;
  final String name;
  final String type;
  final String address;
  final String city;

  /// Dushanbe / Sughd / Khatlon … used for "Regional Sales Distribution".
  final String region;
  final String phone;
  final int counters;
  final int staffCount;
  final double todaySales;
  final double todayChange;
  final double weeklySales;
  final double monthlySales;
  final double monthlyChange;

  /// Short label under the monthly volume, e.g. "High footfall".
  final String note;
  final String openingHours;
  final bool isActive;

  /// Why the store is inactive, e.g. "Renovation".
  final String statusNote;

  String get statusLabel => isActive ? 'Active' : 'Inactive${statusNote.isEmpty ? '' : ' ($statusNote)'}';

  String get fullAddress => city.isEmpty ? address : '$address, $city';

  StoreModel copyWith({
    String? name,
    String? type,
    String? address,
    String? city,
    String? region,
    String? phone,
    int? staffCount,
    double? todaySales,
    double? weeklySales,
    double? monthlySales,
    String? openingHours,
    bool? isActive,
  }) => StoreModel(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    address: address ?? this.address,
    city: city ?? this.city,
    region: region ?? this.region,
    phone: phone ?? this.phone,
    counters: counters,
    staffCount: staffCount ?? this.staffCount,
    todaySales: todaySales ?? this.todaySales,
    todayChange: todayChange,
    weeklySales: weeklySales ?? this.weeklySales,
    monthlySales: monthlySales ?? this.monthlySales,
    monthlyChange: monthlyChange,
    note: note,
    openingHours: openingHours ?? this.openingHours,
    isActive: isActive ?? this.isActive,
    statusNote: statusNote,
  );

  /// Body for POST /stores and PUT /stores/{id}.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'address': address,
    'city': city,
    'region': region,
    'phone': phone,
    'counters': counters,
    'staffCount': staffCount,
    'todaySales': todaySales,
    'todayChange': todayChange,
    'weeklySales': weeklySales,
    'monthlySales': monthlySales,
    'monthlyChange': monthlyChange,
    'note': note,
    'openingHours': openingHours,
    'isActive': isActive,
    'statusNote': statusNote,
  };
}
