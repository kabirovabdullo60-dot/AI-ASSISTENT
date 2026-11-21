import '../core/utils/money.dart';
import 'category_expense_model.dart';
import 'period_model.dart';
import 'store_profit_model.dart';

/// `ProfitOut` from the API contract (API.md / Swagger): sales minus
/// expenses minus salary due, in total, per category and per store.
class ProfitModel {
  const ProfitModel({
    required this.period,
    required this.salesTotal,
    required this.expensesTotal,
    required this.salaryDue,
    required this.grossProfit,
    required this.marginPercent,
    required this.byCategory,
    required this.byStore,
  });

  factory ProfitModel.fromJson(Map<String, dynamic> json) => ProfitModel(
    period: PeriodModel.fromJson(json['period'] as Map<String, dynamic>),
    salesTotal: parseMoney(json['salesTotal'] as String),
    expensesTotal: parseMoney(json['expensesTotal'] as String),
    salaryDue: parseMoney(json['salaryDue'] as String),
    grossProfit: parseMoney(json['grossProfit'] as String),
    marginPercent: (json['marginPercent'] as num?)?.toDouble(),
    byCategory: [
      for (final e in json['byCategory'] as List<dynamic>)
        CategoryExpenseModel.fromJson(e as Map<String, dynamic>),
    ],
    byStore: [
      for (final e in json['byStore'] as List<dynamic>)
        StoreProfitModel.fromJson(e as Map<String, dynamic>),
    ],
  );

  final PeriodModel period;
  final double salesTotal;
  final double expensesTotal;
  final double salaryDue;
  final double grossProfit;

  /// `null` without sales.
  final double? marginPercent;
  final List<CategoryExpenseModel> byCategory;
  final List<StoreProfitModel> byStore;
}
