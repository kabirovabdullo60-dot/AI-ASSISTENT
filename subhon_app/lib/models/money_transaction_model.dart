import '../core/utils/local_date.dart';
import 'money_category.dart';
import 'money_transaction_kind.dart';

/// One personal operation, kept on the phone.
class MoneyTransactionModel {
  const MoneyTransactionModel({
    required this.id,
    required this.kind,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.createdAt,
    this.category,
    this.toAccountId,
    this.note,
    this.recurringId,
  });

  factory MoneyTransactionModel.fromJson(Map<String, dynamic> json) =>
      MoneyTransactionModel(
        id: json['id'] as String,
        kind: MoneyTransactionKind.fromName(json['kind'] as String),
        amount: (json['amount'] as num).toDouble(),
        date: parseLocalDate(json['date'] as String),
        accountId: json['accountId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        category: json['category'] == null
            ? null
            : MoneyCategory.fromName(json['category'] as String),
        toAccountId: json['toAccountId'] as String?,
        note: json['note'] as String?,
        recurringId: json['recurringId'] as String?,
      );

  final String id;
  final MoneyTransactionKind kind;

  /// Always positive; the kind tells the direction.
  final double amount;
  final DateTime date;

  /// The account the money left (expense, transfer) or came to (income).
  final String accountId;

  /// A transfer: the account it went to.
  final String? toAccountId;

  /// Income / expense only.
  final MoneyCategory? category;
  final String? note;

  /// Made by paying a regular payment.
  final String? recurringId;
  final DateTime createdAt;

  /// Signed for the totals: income +, expense −, transfer 0.
  double get signed => switch (kind) {
    MoneyTransactionKind.income => amount,
    MoneyTransactionKind.expense => -amount,
    MoneyTransactionKind.transfer => 0,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'amount': amount,
    'date': formatLocalDate(date),
    'accountId': accountId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (category != null) 'category': category!.name,
    'toAccountId': ?toAccountId,
    'note': ?note,
    'recurringId': ?recurringId,
  };
}
