import 'money_account_model.dart';
import 'money_transaction_model.dart';
import 'recurring_payment_model.dart';

/// Everything of the personal accountant, saved together on the phone.
class PersonalFinanceModel {
  const PersonalFinanceModel({
    this.accounts = const [],
    this.transactions = const [],
    this.recurring = const [],
  });

  factory PersonalFinanceModel.fromJson(Map<String, dynamic> json) =>
      PersonalFinanceModel(
        accounts: [
          for (final a in json['accounts'] as List<dynamic>? ?? const [])
            MoneyAccountModel.fromJson(a as Map<String, dynamic>),
        ],
        transactions: [
          for (final t in json['transactions'] as List<dynamic>? ?? const [])
            MoneyTransactionModel.fromJson(t as Map<String, dynamic>),
        ],
        recurring: [
          for (final r in json['recurring'] as List<dynamic>? ?? const [])
            RecurringPaymentModel.fromJson(r as Map<String, dynamic>),
        ],
      );

  final List<MoneyAccountModel> accounts;
  final List<MoneyTransactionModel> transactions;
  final List<RecurringPaymentModel> recurring;

  Map<String, dynamic> toJson() => {
    'accounts': [for (final a in accounts) a.toJson()],
    'transactions': [for (final t in transactions) t.toJson()],
    'recurring': [for (final r in recurring) r.toJson()],
  };
}
