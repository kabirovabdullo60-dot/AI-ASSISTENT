/// What kind of wallet an account is.
enum MoneyAccountKind {
  cash,
  card,
  bank,
  savings,
  other;

  static MoneyAccountKind fromName(String name) =>
      values.firstWhere((k) => k.name == name, orElse: () => other);
}
