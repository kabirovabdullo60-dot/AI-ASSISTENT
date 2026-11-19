import '../core/utils/local_date.dart';
import 'debt_kind.dart';
import 'debt_payment_model.dart';

/// A debt or a credit kept on the phone (the API has no debts yet): who
/// (a person or a bank), how much, what was repaid and when it is due.
class DebtModel {
  const DebtModel({
    required this.id,
    required this.kind,
    required this.name,
    required this.amount,
    required this.createdAt,
    this.payments = const [],
    this.phone,
    this.dueDate,
    this.monthlyPayment,
    this.note,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
    id: json['id'] as String,
    kind: DebtKind.fromName(json['kind'] as String),
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    payments: [
      for (final p in json['payments'] as List<dynamic>? ?? const [])
        DebtPaymentModel.fromJson(p as Map<String, dynamic>),
    ],
    phone: json['phone'] as String?,
    dueDate: json['dueDate'] == null
        ? null
        : parseLocalDate(json['dueDate'] as String),
    monthlyPayment: (json['monthlyPayment'] as num?)?.toDouble(),
    note: json['note'] as String?,
  );

  final String id;
  final DebtKind kind;

  /// The person, or the bank / shop for a credit.
  final String name;

  /// The whole debt (for a credit: everything to repay).
  final double amount;
  final DateTime createdAt;

  /// Newest last.
  final List<DebtPaymentModel> payments;
  final String? phone;

  /// When it must be repaid (a credit: when it ends).
  final DateTime? dueDate;

  /// A credit or installment plan: the monthly payment.
  final double? monthlyPayment;
  final String? note;

  double get paid => payments.fold(0, (sum, p) => sum + p.amount);
  double get remaining => (amount - paid).clamp(0, double.infinity);
  bool get isClosed => remaining <= 0.004;

  /// 0…1 of the debt repaid.
  double get progress => amount <= 0 ? 1 : (paid / amount).clamp(0, 1);

  /// Due and not repaid.
  bool isOverdue(DateTime today) =>
      !isClosed && dueDate != null && dueDate!.isBefore(today);

  DebtModel copyWith({
    String? name,
    double? amount,
    List<DebtPaymentModel>? payments,
    String? phone,
    DateTime? dueDate,
    double? monthlyPayment,
    String? note,
    DebtKind? kind,
    bool clearOptional = false,
  }) => DebtModel(
    id: id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    createdAt: createdAt,
    payments: payments ?? this.payments,
    phone: clearOptional ? phone : phone ?? this.phone,
    dueDate: clearOptional ? dueDate : dueDate ?? this.dueDate,
    monthlyPayment: clearOptional
        ? monthlyPayment
        : monthlyPayment ?? this.monthlyPayment,
    note: clearOptional ? note : note ?? this.note,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'name': name,
    'amount': amount,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'payments': [for (final p in payments) p.toJson()],
    'phone': ?phone,
    if (dueDate != null) 'dueDate': formatLocalDate(dueDate!),
    'monthlyPayment': ?monthlyPayment,
    'note': ?note,
  };
}
