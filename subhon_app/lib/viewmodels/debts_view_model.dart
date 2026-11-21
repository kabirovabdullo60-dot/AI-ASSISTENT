import 'package:flutter/foundation.dart';

import '../core/storage/debt_storage.dart';
import '../models/debt_kind.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

/// "Долги и кредиты": the overview (owed to me, I owe, credits), the
/// "Мне должны | Я должен" switch, and adding, repaying, editing and
/// deleting. Kept on the phone for the signed-in account.
class DebtsViewModel extends ChangeNotifier {
  DebtsViewModel(this._storage, this._userId, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DebtStorage _storage;
  final String? _userId;
  final DateTime Function() _clock;

  List<DebtModel> _all = const [];
  bool _loaded = false;
  bool _showIOwe = false;

  /// Makes ids unique even when two debts are added at the same moment.
  int _seq = 0;

  bool get hasData => _loaded;
  bool get showIOwe => _showIOwe;
  DateTime get today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  List<DebtModel> _open(bool Function(DebtKind) test) => [
    for (final d in _all)
      if (test(d.kind) && !d.isClosed) d,
  ]..sort(_byDue);

  /// Overdue first, then by due date, then newest.
  static int _byDue(DebtModel a, DebtModel b) {
    final ad = a.dueDate, bd = b.dueDate;
    if (ad != null && bd != null) return ad.compareTo(bd);
    if (ad != null) return -1;
    if (bd != null) return 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  List<DebtModel> get owedToMe => _open((k) => k == DebtKind.owedToMe);
  List<DebtModel> get iOwe => _open((k) => k == DebtKind.iOwe);
  List<DebtModel> get loans => _open((k) => k.isLoan);

  /// The list under the switch.
  List<DebtModel> get shown => _showIOwe ? iOwe : owedToMe;

  /// Repaid debts, newest first.
  List<DebtModel> get closed => [
    for (final d in _all)
      if (d.isClosed) d,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static double _sum(List<DebtModel> list) =>
      list.fold(0, (s, d) => s + d.remaining);

  double get owedToMeTotal => _sum(owedToMe);
  double get iOweTotal => _sum(iOwe);
  double get loansTotal => _sum(loans);

  /// People who owe me (one person may owe twice).
  int get owedToMePeople =>
      owedToMe.map((d) => d.name.trim().toLowerCase()).toSet().length;

  DebtModel? byId(String id) => _all.where((d) => d.id == id).firstOrNull;

  void showTab({required bool iOwe}) {
    _showIOwe = iOwe;
    notifyListeners();
  }

  Future<void> load() async {
    final user = _userId;
    _all = user == null ? const [] : await _storage.read(user);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save(List<DebtModel> all) async {
    _all = all;
    notifyListeners();
    final user = _userId;
    if (user != null) await _storage.write(user, all);
  }

  Future<DebtModel> add({
    required DebtKind kind,
    required String name,
    required double amount,
    String? phone,
    DateTime? dueDate,
    double? monthlyPayment,
    String? note,
  }) async {
    final debt = DebtModel(
      id: '${_clock().microsecondsSinceEpoch}-${_seq++}',
      kind: kind,
      name: name.trim(),
      amount: amount,
      createdAt: _clock(),
      phone: _opt(phone),
      dueDate: dueDate,
      monthlyPayment: monthlyPayment,
      note: _opt(note),
    );
    await _save([..._all, debt]);
    return debt;
  }

  Future<void> update(
    String id, {
    required String name,
    required double amount,
    String? phone,
    DateTime? dueDate,
    double? monthlyPayment,
    String? note,
  }) => _save([
    for (final d in _all)
      if (d.id == id)
        d.copyWith(
          name: name.trim(),
          amount: amount,
          phone: _opt(phone),
          dueDate: dueDate,
          monthlyPayment: monthlyPayment,
          note: _opt(note),
          clearOptional: true,
        )
      else
        d,
  ]);

  /// Records a repayment (never more than what is left).
  Future<void> repay(String id, double amount, {String? note}) {
    final debt = byId(id);
    if (debt == null || amount <= 0) return Future.value();
    final part = amount > debt.remaining ? debt.remaining : amount;
    return _save([
      for (final d in _all)
        if (d.id == id)
          d.copyWith(
            payments: [
              ...d.payments,
              DebtPaymentModel(amount: part, date: today, note: _opt(note)),
            ],
          )
        else
          d,
    ]);
  }

  /// Repays all that is left.
  Future<void> close(String id) {
    final debt = byId(id);
    return debt == null ? Future.value() : repay(id, debt.remaining);
  }

  Future<void> delete(String id) => _save([
    for (final d in _all)
      if (d.id != id) d,
  ]);

  static String? _opt(String? text) =>
      text == null || text.trim().isEmpty ? null : text.trim();
}
