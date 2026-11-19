import '../core/utils/money.dart';

/// `StoreProfitOut` from the API contract (API.md / Swagger).
class StoreProfitModel {
  const StoreProfitModel({
    required this.storeId,
    required this.storeName,
    required this.salesTotal,
    required this.expensesTotal,
    required this.salaryDue,
    required this.profit,
  });

  factory StoreProfitModel.fromJson(Map<String, dynamic> json) =>
      StoreProfitModel(
        storeId: json['storeId'] as String?,
        storeName: json['storeName'] as String?,
        salesTotal: parseMoney(json['salesTotal'] as String),
        expensesTotal: parseMoney(json['expensesTotal'] as String),
        salaryDue: parseMoney(json['salaryDue'] as String),
        profit: parseMoney(json['profit'] as String),
      );

  /// `null`: expenses of the whole business.
  final String? storeId;
  final String? storeName;
  final double salesTotal;
  final double expensesTotal;
  final double salaryDue;

  /// May be negative.
  final double profit;
}
