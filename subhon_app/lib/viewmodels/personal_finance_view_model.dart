import 'package:flutter/foundation.dart';

import '../core/storage/personal_finance_storage.dart';
import '../models/money_account_kind.dart';
import '../models/money_account_model.dart';
import '../models/money_category.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';
import '../models/personal_finance_model.dart';
import '../models/recurring_payment_model.dart';

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
        sum += t.amount;
      }
    }
    return sum;
  }

  double get totalBalance =>
      _data.accounts.fold(0, (s, a) => s + balance(a.id));

  bool _inMonth(DateTime d) => d.year == _month.year && d.month == _month.month;

  List<MoneyTransactionModel> get monthTransactions => [
    for (final t in transactions)
      if (_inMonth(t.date)) t,
  ];

  double _monthSum(MoneyTransactionKind kind) => monthTransactions
      .where((t) => t.kind == kind)
      .fold(0, (s, t) => s + t.amount);

  double get monthIncome => _monthSum(MoneyTransactionKind.income);
  double get monthExpense => _monthSum(MoneyTransactionKind.expense);

  /// The month's expenses per category, largest first.
  List<(MoneyCategory, double)> get monthExpensesByCategory {
    final sums = <MoneyCategory, double>{};
    for (final t in monthTransactions) {
      if (t.kind == MoneyTransactionKind.expense && t.category != null) {
        sums[t.category!] = (sums[t.category!] ?? 0) + t.amount;
      }
    }
    return [for (final e in sums.entries) (e.key, e.value)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
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
  }) => PersonalFinanceModel(
    accounts: accounts ?? _data.accounts,
    transactions: transactions ?? _data.transactions,
    recurring: recurring ?? _data.recurring,
  );

  // Accounts.

  Future<MoneyAccountModel> addAccount({
    required String name,
    required MoneyAccountKind kind,
    double openingBalance = 0,
  }) async {
    final account = MoneyAccountModel(
      id: _id(),
      name: name.trim(),
      kind: kind,
      openingBalance: openingBalance,
      createdAt: _clock(),
    );
    await _save(_with(accounts: [..._data.accounts, account]));
    return account;
  }

  Future<void> updateAccount(
    String id, {
    required String name,
    required MoneyAccountKind kind,
    required double openingBalance,
  }) => _save(
    _with(
      accounts: [
        for (final a in _data.accounts)
          if (a.id == id)
            a.copyWith(
              name: name.trim(),
              kind: kind,
              openingBalance: openingBalance,
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

  static String? _opt(String? text) =>
      text == null || text.trim().isEmpty ? null : text.trim();
}
