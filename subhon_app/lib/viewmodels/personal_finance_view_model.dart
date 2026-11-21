import 'package:flutter/foundation.dart';

import '../core/storage/personal_finance_storage.dart';
import '../models/debt_kind.dart';
import '../models/fiat_rates_model.dart';
import '../models/money_account_kind.dart';
import '../models/money_account_model.dart';
import '../models/money_category.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';
import '../models/personal_finance_model.dart';
import '../models/recurring_payment_model.dart';
import '../models/savings_goal_model.dart';

/// The personal accountant: accounts and their balances, income and
/// expenses (by month and category), transfers, and regular payments.
/// Kept on the phone for the signed-in account (the API has none of it).
class PersonalFinanceViewModel extends ChangeNotifier {
  PersonalFinanceViewModel(
    this._storage,
    this._userId, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final now = _clock();
    _month = DateTime(now.year, now.month);
  }

  final PersonalFinanceStorage _storage;
  final String? _userId;
  final DateTime Function() _clock;

  PersonalFinanceModel _data = const PersonalFinanceModel();
  bool _loaded = false;
  late DateTime _month;
  int _seq = 0;

  bool get hasData => _loaded;
  List<MoneyAccountModel> get accounts => _data.accounts;
  List<RecurringPaymentModel> get recurring =>
      [..._data.recurring]..sort((a, b) => a.nextDate.compareTo(b.nextDate));

  /// Newest first.
  List<MoneyTransactionModel> get transactions =>
      [..._data.transactions]..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });

  DateTime get today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// The 1st of the month shown on home.
  DateTime get month => _month;
  bool get isCurrentMonth =>
      _month.year == today.year && _month.month == today.month;

  MoneyAccountModel? account(String? id) =>
      _data.accounts.where((a) => a.id == id).firstOrNull;

  // Currencies.

  FiatRatesModel? _rates;

  /// World exchange rates, for accounts kept in other currencies.
  void setRates(FiatRatesModel rates) {
    _rates = rates;
    notifyListeners();
  }

  /// Some account is not in somoni.
  bool get hasForeign => _data.accounts.any((a) => a.currency != 'TJS');

  /// Totals in somoni can't count the other currencies yet.
  bool get ratesMissing => hasForeign && _rates == null;

  String currencyOf(String? accountId) => account(accountId)?.currency ?? 'TJS';

  /// [amount] of [currency] in somoni (as is while the rates are unknown).
  double inTjs(double amount, String currency) => currency == 'TJS'
      ? amount
      : _rates?.convert(amount, currency, 'TJS') ?? amount;

  /// [amount] of [from] in [to], when the rates are known.
  double? convert(double amount, String from, String to) =>
      from == to ? amount : _rates?.convert(amount, from, to);

  /// Opening balance + income − expenses ± transfers.
  double balance(String accountId) {
    var sum = account(accountId)?.openingBalance ?? 0;
    for (final t in _data.transactions) {
      if (t.accountId == accountId) {
        sum += switch (t.kind) {
          MoneyTransactionKind.income => t.amount,
          _ => -t.amount,
        };
      }
      if (t.kind == MoneyTransactionKind.transfer &&
          t.toAccountId == accountId) {
        sum += t.received;
      }
    }
    return sum;
  }

  /// An operation's amount in somoni.
  double _tjs(MoneyTransactionModel t) =>
      inTjs(t.amount, currencyOf(t.accountId));

  /// All accounts, in somoni.
  double get totalBalance =>
      _data.accounts.fold(0, (s, a) => s + inTjs(balance(a.id), a.currency));

  bool _inMonth(DateTime d) => d.year == _month.year && d.month == _month.month;

  List<MoneyTransactionModel> get monthTransactions => [
    for (final t in transactions)
      if (_inMonth(t.date)) t,
  ];

  double _monthSum(MoneyTransactionKind kind) => monthTransactions
      .where((t) => t.kind == kind)
      .fold(0, (s, t) => s + _tjs(t));

  double get monthIncome => _monthSum(MoneyTransactionKind.income);
  double get monthExpense => _monthSum(MoneyTransactionKind.expense);

  /// The month's expenses per category, largest first.
  List<(MoneyCategory, double)> get monthExpensesByCategory {
    final sums = <MoneyCategory, double>{};
    for (final t in monthTransactions) {
      if (t.kind == MoneyTransactionKind.expense && t.category != null) {
        sums[t.category!] = (sums[t.category!] ?? 0) + _tjs(t);
      }
    }
    return [for (final e in sums.entries) (e.key, e.value)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
  }

  // Search and filters of "Операции".

  String _query = '';
  MoneyTransactionKind? _kindFilter;
  String? _accountFilter;
  MoneyCategory? _categoryFilter;

  String get query => _query;
  MoneyTransactionKind? get kindFilter => _kindFilter;
  String? get accountFilter => _accountFilter;
  MoneyCategory? get categoryFilter => _categoryFilter;
  bool get isFiltered =>
      _query.isNotEmpty ||
      _kindFilter != null ||
      _accountFilter != null ||
      _categoryFilter != null;

  void setQuery(String value) {
    _query = value.trim().toLowerCase();
    notifyListeners();
  }

  void setKindFilter(MoneyTransactionKind? kind) {
    _kindFilter = kind;
    if (kind == MoneyTransactionKind.transfer ||
        (_categoryFilter != null &&
            kind != null &&
            _categoryFilter!.income != (kind == MoneyTransactionKind.income))) {
      _categoryFilter = null;
    }
    notifyListeners();
  }

  void setAccountFilter(String? accountId) {
    _accountFilter = accountId;
    notifyListeners();
  }

  void setCategoryFilter(MoneyCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _kindFilter = null;
    _accountFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  /// The operations that match the search and filters, newest first.
  /// [categoryText] gives a category's name on screen, so it can be
  /// searched too.
  List<MoneyTransactionModel> filtered({
    String Function(MoneyCategory)? categoryText,
  }) => [
    for (final t in transactions)
      if ((_kindFilter == null || t.kind == _kindFilter) &&
          (_accountFilter == null ||
              t.accountId == _accountFilter ||
              t.toAccountId == _accountFilter) &&
          (_categoryFilter == null || t.category == _categoryFilter) &&
          (_query.isEmpty || _matches(t, categoryText)))
        t,
  ];

  bool _matches(
    MoneyTransactionModel t,
    String Function(MoneyCategory)? categoryText,
  ) {
    final words = [
      t.label,
      t.note,
      account(t.accountId)?.name,
      account(t.toAccountId)?.name,
      if (t.category != null) categoryText?.call(t.category!),
      t.amount.toStringAsFixed(2),
    ];
    return words.any((w) => w != null && w.toLowerCase().contains(_query));
  }

  /// [list]'s income and expenses, in somoni.
  (double income, double expense) totals(List<MoneyTransactionModel> list) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in list) {
      if (t.kind == MoneyTransactionKind.income) income += _tjs(t);
      if (t.kind == MoneyTransactionKind.expense) expense += _tjs(t);
    }
    return (income, expense);
  }

  /// [list] grouped by day, newest first.
  List<(DateTime, List<MoneyTransactionModel>)> groupByDay(
    List<MoneyTransactionModel> list,
  ) {
    final groups = <DateTime, List<MoneyTransactionModel>>{};
    for (final t in list) {
      (groups[t.date] ??= []).add(t);
    }
    return [for (final e in groups.entries) (e.key, e.value)];
  }

  /// All operations grouped by day, newest first.
  List<(DateTime, List<MoneyTransactionModel>)> get days {
    final groups = <DateTime, List<MoneyTransactionModel>>{};
    for (final t in transactions) {
      (groups[t.date] ??= []).add(t);
    }
    return [for (final e in groups.entries) (e.key, e.value)];
  }

  /// Regular payments due within [days] days or overdue.
  List<RecurringPaymentModel> upcoming({int days = 7}) => [
    for (final r in recurring)
      if (!r.nextDate.isAfter(today.add(Duration(days: days)))) r,
  ];

  bool isOverdue(RecurringPaymentModel r) => r.nextDate.isBefore(today);

  void shiftMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    notifyListeners();
  }

  Future<void> load() async {
    final user = _userId;
    _data = user == null
        ? const PersonalFinanceModel()
        : await _storage.read(user);
    _loaded = true;
    notifyListeners();
  }

  /// The first time: one cash wallet named [name], so money can be
  /// written down at once.
  Future<void> ensureDefaultAccount(String name) async {
    if (!_loaded || _data.accounts.isNotEmpty) return;
    await addAccount(name: name, kind: MoneyAccountKind.cash);
  }

  String _id() => '${_clock().microsecondsSinceEpoch}-${_seq++}';

  Future<void> _save(PersonalFinanceModel data) async {
    _data = data;
    notifyListeners();
    final user = _userId;
    if (user != null) await _storage.write(user, data);
  }

  PersonalFinanceModel _with({
    List<MoneyAccountModel>? accounts,
    List<MoneyTransactionModel>? transactions,
    List<RecurringPaymentModel>? recurring,
    List<SavingsGoalModel>? goals,
  }) => PersonalFinanceModel(
    accounts: accounts ?? _data.accounts,
    transactions: transactions ?? _data.transactions,
    recurring: recurring ?? _data.recurring,
    goals: goals ?? _data.goals,
  );

  // Accounts.

  Future<MoneyAccountModel> addAccount({
    required String name,
    required MoneyAccountKind kind,
    double openingBalance = 0,
    String currency = 'TJS',
  }) async {
    final account = MoneyAccountModel(
      id: _id(),
      name: name.trim(),
      kind: kind,
      openingBalance: openingBalance,
      createdAt: _clock(),
      currency: currency,
    );
    await _save(_with(accounts: [..._data.accounts, account]));
    return account;
  }

  Future<void> updateAccount(
    String id, {
    required String name,
    required MoneyAccountKind kind,
    required double openingBalance,
    String? currency,
  }) => _save(
    _with(
      accounts: [
        for (final a in _data.accounts)
          if (a.id == id)
            a.copyWith(
              name: name.trim(),
              kind: kind,
              openingBalance: openingBalance,
              // Not once it has operations: they are in the old currency.
              currency: isUsed(id) ? null : currency,
            )
          else
            a,
      ],
    ),
  );

  /// Has operations: it can't be deleted (they would lose their account).
  bool isUsed(String accountId) => _data.transactions.any(
    (t) => t.accountId == accountId || t.toAccountId == accountId,
  );

  /// `false` when the account has operations.
  Future<bool> deleteAccount(String id) async {
    if (isUsed(id)) return false;
    await _save(
      _with(
        accounts: [
          for (final a in _data.accounts)
            if (a.id != id) a,
        ],
        recurring: [
          for (final r in _data.recurring)
            if (r.accountId == id)
              RecurringPaymentModel(
                id: r.id,
                name: r.name,
                amount: r.amount,
                category: r.category,
                nextDate: r.nextDate,
                everyMonths: r.everyMonths,
              )
            else
              r,
        ],
        goals: [
          for (final g in _data.goals)
            if (g.accountId != id) g,
        ],
      ),
    );
    return true;
  }

  // Operations.

  Future<MoneyTransactionModel> addTransaction({
    required MoneyTransactionKind kind,
    required double amount,
    required String accountId,
    DateTime? date,
    MoneyCategory? category,
    String? toAccountId,
    String? note,
    String? recurringId,
    double? toAmount,
    String? label,
  }) async {
    final t = MoneyTransactionModel(
      id: _id(),
      kind: kind,
      amount: amount,
      date: date ?? today,
      accountId: accountId,
      createdAt: _clock(),
      category: kind == MoneyTransactionKind.transfer ? null : category,
      toAccountId: kind == MoneyTransactionKind.transfer ? toAccountId : null,
      note: _opt(note),
      recurringId: recurringId,
      toAmount: kind == MoneyTransactionKind.transfer ? toAmount : null,
      label: _otherLabel(category, label),
    );
    await _save(_with(transactions: [..._data.transactions, t]));
    return t;
  }

  Future<void> updateTransaction(
    String id, {
    required double amount,
    required String accountId,
    required DateTime date,
    MoneyCategory? category,
    String? toAccountId,
    String? note,
    double? toAmount,
    String? label,
  }) => _save(
    _with(
      transactions: [
        for (final t in _data.transactions)
          if (t.id == id)
            MoneyTransactionModel(
              id: t.id,
              kind: t.kind,
              amount: amount,
              date: date,
              accountId: accountId,
              createdAt: t.createdAt,
              category: t.kind == MoneyTransactionKind.transfer
                  ? null
                  : category,
              toAccountId: t.kind == MoneyTransactionKind.transfer
                  ? toAccountId
                  : null,
              note: _opt(note),
              recurringId: t.recurringId,
              toAmount: t.kind == MoneyTransactionKind.transfer
                  ? toAmount
                  : null,
              label: _otherLabel(category, label),
            )
          else
            t,
      ],
    ),
  );

  Future<void> deleteTransaction(String id) => _save(
    _with(
      transactions: [
        for (final t in _data.transactions)
          if (t.id != id) t,
      ],
    ),
  );

  // Regular payments.

  Future<void> saveRecurring({
    String? id,
    required String name,
    required double amount,
    required MoneyCategory category,
    required DateTime nextDate,
    String? accountId,
    int everyMonths = 1,
  }) {
    final item = RecurringPaymentModel(
      id: id ?? _id(),
      name: name.trim(),
      amount: amount,
      category: category,
      nextDate: nextDate,
      accountId: accountId,
      everyMonths: everyMonths,
    );
    return _save(
      _with(
        recurring: [
          for (final r in _data.recurring)
            if (r.id != item.id) r,
          item,
        ],
      ),
    );
  }

  Future<void> deleteRecurring(String id) => _save(
    _with(
      recurring: [
        for (final r in _data.recurring)
          if (r.id != id) r,
      ],
    ),
  );

  /// Paid: an expense is written (from its account, or [accountId]) and
  /// the next date moves on.
  Future<void> payRecurring(String id, {String? accountId}) async {
    final r = _data.recurring.where((x) => x.id == id).firstOrNull;
    final from = accountId ?? r?.accountId ?? _data.accounts.firstOrNull?.id;
    if (r == null || from == null) return;
    final expense = MoneyTransactionModel(
      id: _id(),
      kind: MoneyTransactionKind.expense,
      amount: r.amount,
      date: today,
      accountId: from,
      createdAt: _clock(),
      category: r.category,
      note: r.name,
      recurringId: r.id,
    );
    await _save(
      _with(
        transactions: [..._data.transactions, expense],
        recurring: [
          for (final x in _data.recurring)
            if (x.id == id) x.copyWith(nextDate: x.followingDate) else x,
        ],
      ),
    );
  }

  /// A short note of my personal finances for the AI assistant (English
  /// labels; it answers in the app's language): balances, this month's
  /// income and expenses, the largest categories, coming payments.
  String? summary() {
    if (!_loaded || (_data.accounts.isEmpty && _data.transactions.isEmpty)) {
      return null;
    }
    String m(double v) => v.toStringAsFixed(2);
    String d(DateTime v) =>
        '${v.year}-${v.month.toString().padLeft(2, '0')}-'
        '${v.day.toString().padLeft(2, '0')}';
    final now = today;
    final month = [
      for (final t in _data.transactions)
        if (t.date.year == now.year && t.date.month == now.month) t,
    ];
    double sum(MoneyTransactionKind k) =>
        month.where((t) => t.kind == k).fold(0, (s, t) => s + _tjs(t));
    final cats = <MoneyCategory, double>{};
    for (final t in month) {
      if (t.kind == MoneyTransactionKind.expense && t.category != null) {
        cats[t.category!] = (cats[t.category!] ?? 0) + _tjs(t);
      }
    }
    final top = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final coming = upcoming(days: 14);
    return [
      '[My personal finances, kept in the app on my phone; TJS; today ${d(now)}]',
      'Total balance: ${m(totalBalance)}. Accounts: '
          '${[for (final a in _data.accounts) '${a.name} ${m(balance(a.id))} ${a.currency}'].join(', ')}.',
      'This month: income ${m(sum(MoneyTransactionKind.income))}, '
          'expenses ${m(sum(MoneyTransactionKind.expense))}.',
      if (top.isNotEmpty)
        'Expenses by category: '
            '${[for (final e in top.take(6)) '${e.key.name} ${m(e.value)}'].join(', ')}.',
      if (_data.goals.isNotEmpty)
        'Savings goals: '
            '${[for (final g in _data.goals) '${g.name} ${m(goalSaved(g))} of ${m(g.target)} ${currencyOf(g.accountId)}'].join(', ')}.',
      if (coming.isNotEmpty)
        'Regular payments due: '
            '${[for (final r in coming.take(5)) '${r.name} ${m(r.amount)} on ${d(r.nextDate)}'].join(', ')}.',
      '[Question]',
    ].join('\n');
  }

  // Debts.

  /// Money of a debt on [accountId]: lending or repaying takes it from the
  /// account, borrowing or being repaid brings it in.
  Future<void> recordDebt({
    required DebtKind kind,
    required bool repayment,
    required double amount,
    required String accountId,
    required String name,
  }) {
    final mine = kind == DebtKind.owedToMe;
    final (txKind, category) = switch ((mine, repayment)) {
      (true, false) => (MoneyTransactionKind.expense, MoneyCategory.debtOut),
      (true, true) => (MoneyTransactionKind.income, MoneyCategory.debtBack),
      (false, false) => (MoneyTransactionKind.income, MoneyCategory.debtIn),
      (false, true) => (MoneyTransactionKind.expense, MoneyCategory.debtPay),
    };
    return addTransaction(
      kind: txKind,
      amount: amount,
      accountId: accountId,
      category: category,
      note: name,
    );
  }

  // Savings goals.

  List<SavingsGoalModel> get goals => _data.goals;

  /// Saved so far: the balance of the goal's account.
  double goalSaved(SavingsGoalModel g) => balance(g.accountId);

  /// 0…1.
  double goalProgress(SavingsGoalModel g) =>
      g.target <= 0 ? 0 : (goalSaved(g) / g.target).clamp(0, 1).toDouble();

  /// A new goal gets its own savings account (named after it, in
  /// [currency]) unless [accountId] is given.
  Future<void> saveGoal({
    String? id,
    required String name,
    required double target,
    String? accountId,
    String currency = 'TJS',
    DateTime? deadline,
  }) async {
    var account = accountId;
    if (account == null) {
      final created = await addAccount(
        name: name,
        kind: MoneyAccountKind.savings,
        currency: currency,
      );
      account = created.id;
    }
    final old = _data.goals.where((g) => g.id == id).firstOrNull;
    final goal = SavingsGoalModel(
      id: id ?? _id(),
      name: name.trim(),
      target: target,
      accountId: account,
      createdAt: old?.createdAt ?? _clock(),
      deadline: deadline,
    );
    await _save(
      _with(
        goals: [
          for (final g in _data.goals)
            if (g.id != goal.id) g,
          goal,
        ],
      ),
    );
  }

  /// The goal goes; its account and money stay.
  Future<void> deleteGoal(String id) => _save(
    _with(
      goals: [
        for (final g in _data.goals)
          if (g.id != id) g,
      ],
    ),
  );

  /// "Другое" / "Другой доход" keep what it was; other categories don't.
  static String? _otherLabel(MoneyCategory? category, String? label) =>
      category == MoneyCategory.otherExpense ||
          category == MoneyCategory.otherIncome
      ? _opt(label)
      : null;

  static String? _opt(String? text) =>
      text == null || text.trim().isEmpty ? null : text.trim();
}
