import '../core/utils/money.dart';

import 'day_sales_model.dart';
import 'hour_sales_model.dart';
import 'payment_method_sales_model.dart';
import 'period_model.dart';
import 'store_sales_model.dart';

/// `SalesReportOut` from the API contract (API.md / Swagger).
class SalesReportModel {
  const SalesReportModel({
    this.currency = 'TJS',
    required this.period,
    required this.previousPeriod,
    required this.totalAmount,
    required this.salesCount,
    required this.averageSaleAmount,
    required this.previousTotalAmount,
    required this.previousSalesCount,
    required this.changeAmount,
    this.changePercent,
    required this.storesCount,
    required this.stores,
    required this.byDay,
    this.byPaymentMethod = const [],
    this.byHour,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) =>
      SalesReportModel(
        currency: (json['currency'] ?? 'TJS') as String,
        period: PeriodModel.fromJson(json['period'] as Map<String, dynamic>),
        previousPeriod: PeriodModel.fromJson(
          json['previousPeriod'] as Map<String, dynamic>,
        ),
        totalAmount: parseMoney(json['totalAmount'] as String),
        salesCount: json['salesCount'] as int,
        averageSaleAmount: parseMoney(json['averageSaleAmount'] as String),
        previousTotalAmount: parseMoney(json['previousTotalAmount'] as String),
        previousSalesCount: json['previousSalesCount'] as int,
        changeAmount: parseMoney(json['changeAmount'] as String),
        changePercent: json['changePercent'] == null
            ? null
            : (json['changePercent'] as num).toDouble(),
        storesCount: json['storesCount'] as int,
        stores: [
          for (final e in json['stores'] as List<dynamic>)
            StoreSalesModel.fromJson(e as Map<String, dynamic>),
        ],
        byDay: [
          for (final e in json['byDay'] as List<dynamic>)
            DaySalesModel.fromJson(e as Map<String, dynamic>),
        ],
        byPaymentMethod: [
          for (final e in json['byPaymentMethod'] as List<dynamic>? ?? const [])
            PaymentMethodSalesModel.fromJson(e as Map<String, dynamic>),
        ],
        byHour: (json['byHour'] as List<dynamic>?)
            ?.map((e) => HourSalesModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String currency;
  final PeriodModel period;
  final PeriodModel previousPeriod;
  final double totalAmount;
  final int salesCount;
  final double averageSaleAmount;
  final double previousTotalAmount;
  final int previousSalesCount;
  final double changeAmount;
  final double? changePercent;
  final int storesCount;
  final List<StoreSalesModel> stores;
  final List<DaySalesModel> byDay;

  /// CASH, CARD, QR, MIXED (zeros included), plus `null` for sales without
  /// a method.
  final List<PaymentMethodSalesModel> byPaymentMethod;

  /// Daily reports only: 24 hours.
  final List<HourSalesModel>? byHour;
}
