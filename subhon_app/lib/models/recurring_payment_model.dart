import '../core/utils/local_date.dart';
import 'money_category.dart';

/// A payment that comes back every month (rent, phone, a subscription):
/// when it is due next and from which account it is usually paid.
class RecurringPaymentModel {
  const RecurringPaymentModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.nextDate,
    this.accountId,
    this.everyMonths = 1,
  });

  factory RecurringPaymentModel.fromJson(Map<String, dynamic> json) =>
      RecurringPaymentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: MoneyCategory.fromName(json['category'] as String),
        nextDate: parseLocalDate(json['nextDate'] as String),
        accountId: json['accountId'] as String?,
        everyMonths: json['everyMonths'] as int? ?? 1,
      );

  final String id;
  final String name;
  final double amount;
  final MoneyCategory category;
  final DateTime nextDate;
  final String? accountId;

  /// 1 every month, 3 every quarter, 12 every year.
  final int everyMonths;

  /// The date after [nextDate] (the same day, [everyMonths] later; the end
  /// of the month when that day does not exist).
  DateTime get followingDate {
    final target = DateTime(nextDate.year, nextDate.month + everyMonths);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(
      target.year,
      target.month,
      nextDate.day > lastDay ? lastDay : nextDate.day,
    );
  }

  RecurringPaymentModel copyWith({
    String? name,
    double? amount,
    MoneyCategory? category,
    DateTime? nextDate,
    String? accountId,
    int? everyMonths,
  }) => RecurringPaymentModel(
    id: id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    nextDate: nextDate ?? this.nextDate,
    accountId: accountId ?? this.accountId,
    everyMonths: everyMonths ?? this.everyMonths,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category.name,
    'nextDate': formatLocalDate(nextDate),
    'accountId': ?accountId,
    'everyMonths': everyMonths,
  };
}
