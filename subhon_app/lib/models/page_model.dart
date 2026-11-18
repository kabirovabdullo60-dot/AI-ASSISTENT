import '../core/utils/money.dart';

/// A page of a list: `{items, total, page, limit, pages}`; sales and
/// payments also carry `totalAmount` (API.md).
class PageModel<T> {
  const PageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    this.totalAmount,
  });

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) item,
  ) => PageModel(
    items: [
      for (final e in json['items'] as List<dynamic>)
        item(e as Map<String, dynamic>),
    ],
    total: json['total'] as int,
    page: json['page'] as int,
    limit: json['limit'] as int,
    pages: json['pages'] as int,
    totalAmount: json['totalAmount'] == null
        ? null
        : parseMoney(json['totalAmount'] as String),
  );

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  /// Sales and payments only.
  final double? totalAmount;

  bool get hasMore => page < pages;
}
