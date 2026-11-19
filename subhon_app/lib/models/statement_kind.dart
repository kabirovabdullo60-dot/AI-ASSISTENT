/// The statements (выписки) and certificates (справки) the app can make.
enum StatementKind {
  // Statements: every operation of a kind for a period.
  sales,
  store,
  cash,
  card,
  expenses,
  salaries,
  operations,
  // Certificates: a summary.
  salaryDebt,
  profit,
  stores;

  bool get isCertificate =>
      this == salaryDebt || this == profit || this == stores;

  /// The store statement asks which store.
  bool get needsStore => this == store;

  /// The salary debt is "as of today", the rest is for a period.
  bool get hasPeriod => this != salaryDebt;

  static StatementKind? fromName(String name) =>
      values.where((k) => k.name == name).firstOrNull;
}
