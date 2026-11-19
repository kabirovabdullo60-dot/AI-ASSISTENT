import '../core/utils/json.dart';

/// List response: `{items, total, page, limit, pages, totalAmount?}`.
class PageModel<T> {
  const PageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    this.totalAmount,
  });

  factory PageModel.fromJson(Object? raw, T Function(Map<String, dynamic>) item) {
    final json = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return PageModel(
      items: asJsonList(json['items']).map(item).toList(),
      total: asInt(json['total']),
      page: asInt(json['page']),
      limit: asInt(json['limit']),
      pages: asInt(json['pages']),
      totalAmount: asDoubleOrNull(json['totalAmount']),
    );
  }

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  /// Sum of all matching rows (sales / payments lists).
  final double? totalAmount;
}
