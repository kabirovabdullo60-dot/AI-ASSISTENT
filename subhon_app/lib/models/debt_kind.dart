/// What a debt is: money owed to me, money I owe a person, or a bank
/// credit / an installment plan.
enum DebtKind {
  owedToMe,
  iOwe,
  credit,
  installment;

  bool get isLoan => this == credit || this == installment;

  static DebtKind fromName(String name) =>
      values.firstWhere((k) => k.name == name, orElse: () => owedToMe);
}
