/// A savings goal ("На машину 50 000"): the money is kept on its own
/// account, so the progress is that account's balance.
class SavingsGoalModel {
  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.target,
    required this.accountId,
    required this.createdAt,
    this.deadline,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      SavingsGoalModel(
        id: json['id'] as String,
        name: json['name'] as String,
        target: (json['target'] as num).toDouble(),
        accountId: json['accountId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
      );

  final String id;
  final String name;

  /// In the account's currency.
  final double target;
  final String accountId;
  final DateTime createdAt;
  final DateTime? deadline;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target': target,
    'accountId': accountId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (deadline != null)
      'deadline':
          '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-'
          '${deadline!.day.toString().padLeft(2, '0')}',
  };
}
