import '../core/utils/json.dart';
import 'expense_model.dart';

/// `StoreProfitOut` — one row of the profit report; [storeId] null = expenses of the whole business.
typedef StoreProfit = ({
  String? storeId,
  String? storeName,
  double sales,
  double expenses,
  double salaryDue,
  double profit,
});

/// `ProfitOut` from GET /api/reports/profit: sales − expenses − salary due.
class ProfitModel {
  const ProfitModel({
    required this.startDate,
    required this.endDate,
    required this.salesTotal,
    required this.expensesTotal,
    required this.salaryDue,
    required this.grossProfit,
    required this.byCategory,
    required this.byStore,
    this.marginPercent,
  });

  factory ProfitModel.fromJson(Map<String, dynamic> json) {
    final period = asJsonMap(json['period']);
    return ProfitModel(
      startDate: asDay(period['startDate']),
      endDate: asDay(period['endDate']),
      salesTotal: asDouble(json['salesTotal']),
      expensesTotal: asDouble(json['expensesTotal']),
      salaryDue: asDouble(json['salaryDue']),
      grossProfit: asDouble(json['grossProfit']),
      marginPercent: asDoubleOrNull(json['marginPercent']),
      byCategory: [
        for (final c in asJsonList(json['byCategory']))
          (category: ExpenseCategory.fromApi(c['category']), total: asDouble(c['totalAmount'])),
      ],
      byStore: [
        for (final s in asJsonList(json['byStore']))
          (
            storeId: s['storeId'] as String?,
            storeName: s['storeName'] as String?,
            sales: asDouble(s['salesTotal']),
            expenses: asDouble(s['expensesTotal']),
            salaryDue: asDouble(s['salaryDue']),
            profit: asDouble(s['profit']),
          ),
      ],
    );
  }

  final DateTime startDate;
  final DateTime endDate;
  final double salesTotal;
  final double expensesTotal;
  final double salaryDue;
  final double grossProfit;

  /// `grossProfit / salesTotal` in %; null when there are no sales.
  final double? marginPercent;
  final List<({ExpenseCategory category, double total})> byCategory;
  final List<StoreProfit> byStore;
}
