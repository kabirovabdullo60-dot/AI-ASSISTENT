/// Categories of personal income and expenses.
enum MoneyCategory {
  // Expenses.
  food(income: false),
  cafe(income: false),
  transport(income: false),
  home(income: false),
  utilities(income: false),
  phone(income: false),
  health(income: false),
  clothes(income: false),
  education(income: false),
  fun(income: false),
  gifts(income: false),
  family(income: false),
  debtOut(income: false),
  debtPay(income: false),
  otherExpense(income: false),
  // Income.
  salary(income: true),
  business(income: true),
  sideJob(income: true),
  giftIn(income: true),
  refund(income: true),
  debtIn(income: true),
  debtBack(income: true),
  otherIncome(income: true);

  const MoneyCategory({required this.income});

  final bool income;

  static List<MoneyCategory> forIncome({required bool income}) => [
    for (final c in values)
      if (c.income == income) c,
  ];

  static MoneyCategory fromName(String name) =>
      values.firstWhere((c) => c.name == name, orElse: () => otherExpense);
}
