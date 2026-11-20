import 'debt_model.dart';
import 'personal_finance_model.dart';

/// A backup file of what is kept only on the phone: the personal
/// accountant (accounts, operations, regular payments, goals) and debts.
class BackupModel {
  const BackupModel({
    required this.personal,
    required this.debts,
    required this.createdAt,
  });

  /// Throws [FormatException] when it isn't this app's backup.
  factory BackupModel.fromJson(Map<String, dynamic> json) {
    if (json['app'] != app || json['version'] is! int) {
      throw const FormatException('not a backup');
    }
    return BackupModel(
      personal: PersonalFinanceModel.fromJson(
        json['personal'] as Map<String, dynamic>? ?? const {},
      ),
      debts: [
        for (final d in json['debts'] as List<dynamic>? ?? const [])
          DebtModel.fromJson(d as Map<String, dynamic>),
      ],
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  static const app = 'ai-accountant-backup';
  static const version = 1;

  final PersonalFinanceModel personal;
  final List<DebtModel> debts;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'app': app,
    'version': version,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'personal': personal.toJson(),
    'debts': [for (final d in debts) d.toJson()],
  };
}
