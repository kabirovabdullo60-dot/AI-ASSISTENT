/// Income, expense, or a transfer between own accounts.
enum MoneyTransactionKind {
  income,
  expense,
  transfer;

  static MoneyTransactionKind fromName(String name) =>
      values.firstWhere((k) => k.name == name, orElse: () => expense);
}
