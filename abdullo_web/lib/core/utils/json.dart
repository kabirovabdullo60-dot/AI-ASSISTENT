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

/// Date-only "2026-11-17" (business calendar, no time zone shift).
DateTime asDay(Object? v) {
  final s = '${v ?? ''}';
  final d = DateTime.tryParse(s.length >= 10 ? s.substring(0, 10) : s);
  return d == null ? DateTime.now() : DateTime(d.year, d.month, d.day);
}

DateTime? asDayOrNull(Object? v) => v == null ? null : asDay(v);

/// 2026-11-17 → "2026-11-17"
String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Money is sent to the backend as a decimal string: 1250.5 → "1250.50".
String money(double v) => v.toStringAsFixed(2);

/// Nullable number (e.g. `changePercent` is null when there is nothing to compare).
double? asDoubleOrNull(Object? v) => v == null ? null : asDouble(v);
