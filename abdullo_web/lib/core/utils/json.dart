/// Tolerant JSON readers, so small differences in Mehroj's DTOs don't crash the web.
double asDouble(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

int asInt(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

String asString(Object? v, [String fallback = '']) => v == null ? fallback : '$v';

bool asBool(Object? v) => v == true || v == 'true' || v == 1;

DateTime asDate(Object? v) => DateTime.tryParse('${v ?? ''}')?.toLocal() ?? DateTime.now();

/// Accepts `[...]` or `{data: [...]}` / `{items: [...]}` / `{content: [...]}`.
List<Map<String, dynamic>> asJsonList(Object? v) {
  final raw = v is Map ? (v['data'] ?? v['items'] ?? v['content']) : v;
  if (raw is! List) return const [];
  return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

/// Accepts `{...}` or `{data: {...}}`.
Map<String, dynamic> asJsonMap(Object? v) {
  if (v is! Map) return {};
  final inner = v['data'];
  return inner is Map ? Map<String, dynamic>.from(inner) : Map<String, dynamic>.from(v);
}
