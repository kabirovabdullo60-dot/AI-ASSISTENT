import '../models/page_model.dart';
import '../models/payment_method.dart';
import '../models/statement_kind.dart';
import '../models/statement_model.dart';
import '../models/statement_row_model.dart';
import '../models/statement_total_kind.dart';
import 'activity_service.dart';
import 'expense_service.dart';
import 'payroll_service.dart';
import 'reports_service.dart';
import 'sales_service.dart';

/// Builds statements (выписки) and certificates (справки) from the API:
/// it reads every page of the period and adds up the totals. Nothing is
/// invented: every line is a real record.
class StatementService {
  StatementService(
    this._sales,
    this._expenses,
    this._payroll,
    this._activity,
    this._reports,
  );

  final SalesService _sales;
  final ExpenseService _expenses;
  final PayrollService _payroll;
  final ActivityService _activity;
  final ReportsService _reports;

  /// Pages of 100 read at most per statement (5 000 lines).
  static const int maxPages = 50;

  Future<StatementModel> build(
    StatementKind kind, {
    DateTime? startDate,
    DateTime? endDate,
    String? storeId,
    String? storeName,
  }) => switch (kind) {
    StatementKind.sales ||
    StatementKind.store ||
    StatementKind.cash ||
    StatementKind.card => _salesStatement(
      kind,
      startDate,
      endDate,
      storeId,
      storeName,
    ),
    StatementKind.expenses => _expensesStatement(startDate, endDate),
    StatementKind.salaries => _salaries(startDate, endDate),
    StatementKind.operations => _operations(startDate, endDate),
    StatementKind.salaryDebt => _salaryDebt(),
    StatementKind.profit => _profit(startDate, endDate),
    StatementKind.stores => _stores(startDate, endDate),
  };

  /// Every page of a list (up to [maxPages]); `true` when cut.
  Future<(List<T>, bool)> _all<T>(
    Future<PageModel<T>> Function(int page) fetch,
  ) async {
    final items = <T>[];
    var page = 1;
    while (true) {
      final result = await fetch(page);
      items.addAll(result.items);
      if (!result.hasMore) return (items, false);
      if (page >= maxPages) return (items, true);
      page++;
    }
  }

  /// Sales, all or one store's; for cash / card only that part of each
  /// sale (a mixed payment is split).
  Future<StatementModel> _salesStatement(
    StatementKind kind,
    DateTime? start,
    DateTime? end,
    String? storeId,
    String? storeName,
  ) async {
    final (sales, cut) = await _all(
      (page) => _sales.list(
        storeId: storeId,
        startDate: start,
        endDate: end,
        page: page,
        limit: 100,
      ),
    );
    double cash = 0, card = 0, qr = 0, none = 0;
    final rows = <StatementRowModel>[];
    for (final s in sales) {
      final method = s.paymentMethod;
      // How much of this sale was cash and how much by card (QR counts
      // with cards: it is not cash).
      final saleCash = switch (method) {
        PaymentMethod.cash => s.amount,
        PaymentMethod.mixed => s.cashAmount ?? 0,
        _ => 0.0,
      };
      final saleCard = switch (method) {
        PaymentMethod.card || PaymentMethod.qr => s.amount,
        PaymentMethod.mixed => s.cardAmount ?? 0,
        _ => 0.0,
      };
      cash += saleCash;
      if (method == PaymentMethod.qr) {
        qr += s.amount;
      } else {
        card += saleCard;
      }
      if (method == null) none += s.amount;
      final amount = switch (kind) {
        StatementKind.cash => saleCash,
        StatementKind.card => saleCard,
        _ => s.amount,
      };
      if (amount <= 0) continue;
      rows.add(
        StatementRowModel(
          date: s.saleDate,
          title: s.storeName,
          detail: method,
          amount: amount,
          cells: switch (kind) {
            StatementKind.cash => [
              s.saleDate,
              s.storeName,
              amount,
              s.receiptNumber,
              s.description,
            ],
            StatementKind.card => [
              s.saleDate,
              s.storeName,
              method,
              amount,
              s.receiptNumber,
              s.description,
            ],
            _ => [
              s.saleDate,
              s.storeName,
              method,
              saleCash,
              saleCard,
              s.amount,
              s.receiptNumber,
              s.description,
            ],
          },
        ),
      );
    }
    final sum = rows.fold<double>(0, (t, r) => t + r.amount);
    return StatementModel(
      kind: kind,
      startDate: start,
      endDate: end,
      storeName: storeName,
      rows: rows,
      truncated: cut,
      totals: switch (kind) {
        StatementKind.cash => [
          (StatementTotalKind.cash, sum),
          (StatementTotalKind.count, rows.length.toDouble()),
        ],
        StatementKind.card => [
          (StatementTotalKind.card, card),
          (StatementTotalKind.qr, qr),
          (StatementTotalKind.total, sum),
        ],
        _ => [
          (StatementTotalKind.total, sum),
          (StatementTotalKind.cash, cash),
          (StatementTotalKind.card, card),
          (StatementTotalKind.qr, qr),
          if (none > 0) (StatementTotalKind.noMethod, none),
          (StatementTotalKind.count, rows.length.toDouble()),
        ],
      },
    );
  }

  Future<StatementModel> _expensesStatement(
    DateTime? start,
    DateTime? end,
  ) async {
    final (expenses, cut) = await _all(
      (page) => _expenses.list(
        startDate: start,
        endDate: end,
        page: page,
        limit: 100,
      ),
    );
    final rows = [
      for (final e in expenses)
        StatementRowModel(
          date: e.expenseDate,
          title: e.storeName ?? '',
          detail: e.category,
          amount: -e.amount,
          cells: [
            e.expenseDate,
            e.category,
            e.storeName,
            e.description,
            e.amount,
          ],
        ),
    ];
    final sum = expenses.fold<double>(0, (t, e) => t + e.amount);
    return StatementModel(
      kind: StatementKind.expenses,
      startDate: start,
      endDate: end,
      rows: rows,
      truncated: cut,
      totals: [
        (StatementTotalKind.expenses, sum),
        (StatementTotalKind.count, rows.length.toDouble()),
      ],
    );
  }

  Future<StatementModel> _salaries(DateTime? start, DateTime? end) async {
    final (payments, cut) = await _all(
      (page) => _payroll.payments(
        startDate: start,
        endDate: end,
        page: page,
        limit: 100,
      ),
    );
    final rows = [
      for (final p in payments)
        StatementRowModel(
          date: p.paymentDate,
          title: p.employeeName,
          detail: p.method,
          amount: -p.amount,
          cells: [
            p.paymentDate,
            p.employeeName,
            DateTime(p.year, p.month),
            p.method,
            p.amount,
            p.note,
          ],
        ),
    ];
    final sum = payments.fold<double>(0, (t, p) => t + p.amount);
    return StatementModel(
      kind: StatementKind.salaries,
      startDate: start,
      endDate: end,
      rows: rows,
      truncated: cut,
      totals: [
        (StatementTotalKind.salaries, sum),
        (StatementTotalKind.count, rows.length.toDouble()),
      ],
    );
  }

  Future<StatementModel> _operations(DateTime? start, DateTime? end) async {
    final (log, cut) = await _all(
      (page) => _activity.list(
        startDate: start,
        endDate: end,
        page: page,
        limit: 100,
      ),
    );
    final rows = [
      for (final a in log)
        StatementRowModel(
          date: a.createdAt,
          title: a.storeName ?? a.entityName,
          detail: a,
          amount: a.amount ?? 0,
          cells: [a.createdAt, a, a.entityName, a.actorName, a.amount],
        ),
    ];
    return StatementModel(
      kind: StatementKind.operations,
      startDate: start,
      endDate: end,
      rows: rows,
      truncated: cut,
      totals: [(StatementTotalKind.count, rows.length.toDouble())],
    );
  }

  Future<StatementModel> _salaryDebt() async {
    final summary = await _payroll.summary();
    final owed = [
      for (final e in summary.items)
        if (e.totalRemaining > 0) e,
    ]..sort((a, b) => b.totalRemaining.compareTo(a.totalRemaining));
    return StatementModel(
      kind: StatementKind.salaryDebt,
      endDate: summary.asOf,
      rows: [
        for (final e in owed)
          StatementRowModel(
            title: e.fullName,
            detail: e.storeName,
            amount: e.totalRemaining,
            cells: [
              e.fullName,
              e.storeName,
              e.unpaidMonths,
              e.totalDue,
              e.totalPaid,
              e.totalRemaining,
            ],
          ),
      ],
      totals: [
        (StatementTotalKind.due, summary.totalDue),
        (StatementTotalKind.paid, summary.totalPaid),
        (StatementTotalKind.remaining, summary.totalRemaining),
      ],
    );
  }

  Future<StatementModel> _profit(DateTime? start, DateTime? end) async {
    final p = await _reports.profit(startDate: start, endDate: end);
    return StatementModel(
      kind: StatementKind.profit,
      startDate: p.period.startDate,
      endDate: p.period.endDate,
      rows: [
        StatementRowModel(
          title: '',
          detail: StatementTotalKind.sales,
          amount: p.salesTotal,
          cells: [StatementTotalKind.sales, p.salesTotal],
        ),
        for (final c in p.byCategory)
          StatementRowModel(
            title: '',
            detail: c.category,
            amount: -c.total,
            cells: [c.category, -c.total],
          ),
        StatementRowModel(
          title: '',
          detail: StatementTotalKind.salaries,
          amount: -p.salaryDue,
          cells: [StatementTotalKind.salaries, -p.salaryDue],
        ),
      ],
      totals: [
        (StatementTotalKind.sales, p.salesTotal),
        (StatementTotalKind.expenses, p.expensesTotal),
        (StatementTotalKind.salaries, p.salaryDue),
        (StatementTotalKind.profit, p.grossProfit),
      ],
    );
  }

  Future<StatementModel> _stores(DateTime? start, DateTime? end) async {
    final report = await _reports.storeComparison(
      startDate: start,
      endDate: end,
    );
    final rows = [...report.stores]..sort((a, b) => a.rank.compareTo(b.rank));
    return StatementModel(
      kind: StatementKind.stores,
      startDate: report.period.startDate,
      endDate: report.period.endDate,
      rows: [
        for (final s in rows)
          StatementRowModel(
            title: s.storeName,
            detail: s.sharePercent,
            amount: s.totalAmount,
            cells: [
              s.rank,
              s.storeName,
              s.totalAmount,
              s.sharePercent,
              s.salesCount,
            ],
          ),
      ],
      totals: [
        (StatementTotalKind.total, report.totalAmount),
        (StatementTotalKind.count, report.salesCount.toDouble()),
      ],
    );
  }
}
