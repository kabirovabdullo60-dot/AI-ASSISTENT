import 'package:flutter/material.dart';

import '../models/activity_model.dart';
import '../models/expense_category.dart';
import '../models/payment_method.dart';
import '../models/salary_payment_method.dart';
import '../models/statement_kind.dart';
import '../models/statement_total_kind.dart';
import 'expense_category_text.dart';
import 'generated/app_localizations.dart';
import 'operation_text.dart';
import 'payment_method_text.dart';

/// The name of a statement or certificate.
String statementTitle(AppLocalizations l10n, StatementKind kind) =>
    switch (kind) {
      StatementKind.sales => l10n.stmtSales,
      StatementKind.store => l10n.stmtStore,
      StatementKind.cash => l10n.stmtCash,
      StatementKind.card => l10n.stmtCard,
      StatementKind.expenses => l10n.stmtExpenses,
      StatementKind.salaries => l10n.stmtSalaries,
      StatementKind.operations => l10n.stmtOperations,
      StatementKind.salaryDebt => l10n.stmtSalaryDebt,
      StatementKind.profit => l10n.stmtProfit,
      StatementKind.stores => l10n.stmtStores,
    };

/// The line under the name in the list.
String statementHint(AppLocalizations l10n, StatementKind kind) =>
    switch (kind) {
      StatementKind.store => l10n.stmtStoreHint,
      StatementKind.cash => l10n.stmtCashHint,
      StatementKind.card => l10n.stmtCardHint,
      StatementKind.operations => l10n.stmtOperationsHint,
      StatementKind.salaryDebt => l10n.stmtSalaryDebtHint,
      StatementKind.profit => l10n.stmtProfitHint,
      StatementKind.stores => l10n.stmtStoresHint,
      _ => l10n.stmtForPeriod,
    };

IconData statementIcon(StatementKind kind) => switch (kind) {
  StatementKind.sales => Icons.point_of_sale_outlined,
  StatementKind.store => Icons.storefront_outlined,
  StatementKind.cash => Icons.payments_outlined,
  StatementKind.card => Icons.credit_card_rounded,
  StatementKind.expenses => Icons.receipt_long_outlined,
  StatementKind.salaries => Icons.account_balance_wallet_outlined,
  StatementKind.operations => Icons.history_rounded,
  StatementKind.salaryDebt => Icons.request_quote_outlined,
  StatementKind.profit => Icons.trending_up_rounded,
  StatementKind.stores => Icons.leaderboard_outlined,
};

/// The Excel column headers, in the order of `StatementRowModel.cells`.
List<String> statementHeaders(AppLocalizations l10n, StatementKind kind) =>
    switch (kind) {
      StatementKind.sales || StatementKind.store => [
        l10n.colDate,
        l10n.colStore,
        l10n.colMethod,
        l10n.colCash,
        l10n.colCard,
        l10n.colAmount,
        l10n.colReceipt,
        l10n.colDescription,
      ],
      StatementKind.cash => [
        l10n.colDate,
        l10n.colStore,
        l10n.colAmount,
        l10n.colReceipt,
        l10n.colDescription,
      ],
      StatementKind.card => [
        l10n.colDate,
        l10n.colStore,
        l10n.colMethod,
        l10n.colAmount,
        l10n.colReceipt,
        l10n.colDescription,
      ],
      StatementKind.expenses => [
        l10n.colDate,
        l10n.colCategory,
        l10n.colStore,
        l10n.colDescription,
        l10n.colAmount,
      ],
      StatementKind.salaries => [
        l10n.colDate,
        l10n.colEmployee,
        l10n.colForMonth,
        l10n.colMethod,
        l10n.colAmount,
        l10n.colNote,
      ],
      StatementKind.operations => [
        l10n.colDate,
        l10n.colWhat,
        l10n.colWho,
        l10n.colUser,
        l10n.colAmount,
      ],
      StatementKind.salaryDebt => [
        l10n.colEmployee,
        l10n.colStore,
        l10n.colUnpaidMonths,
        l10n.stmtDue,
        l10n.stmtPaid,
        l10n.stmtRemaining,
      ],
      StatementKind.profit => [l10n.colItem, l10n.colAmount],
      StatementKind.stores => [
        l10n.colPlace,
        l10n.colStore,
        l10n.colAmount,
        l10n.colShare,
        l10n.colSalesCount,
      ],
    };

String statementTotalLabel(AppLocalizations l10n, StatementTotalKind kind) =>
    switch (kind) {
      StatementTotalKind.total => l10n.stmtTotal,
      StatementTotalKind.count => l10n.stmtCount,
      StatementTotalKind.cash => l10n.stmtCashTotal,
      StatementTotalKind.card => l10n.stmtCardTotal,
      StatementTotalKind.qr => l10n.stmtQrTotal,
      StatementTotalKind.noMethod => l10n.stmtNoMethod,
      StatementTotalKind.sales => l10n.stmtSalesTotal,
      StatementTotalKind.expenses => l10n.stmtExpensesTotal,
      StatementTotalKind.salaries => l10n.stmtSalariesTotal,
      StatementTotalKind.profit => l10n.stmtProfitTotal,
      StatementTotalKind.due => l10n.stmtDue,
      StatementTotalKind.paid => l10n.stmtPaid,
      StatementTotalKind.remaining => l10n.stmtRemaining,
    };

/// A value that is not a plain string or number, as text (enums, an
/// activity); `null` when it is plain.
String? statementValueText(AppLocalizations l10n, Object? value) =>
    switch (value) {
      final PaymentMethod m => paymentMethodText(l10n, m),
      final ExpenseCategory c => expenseCategoryText(l10n, c),
      SalaryPaymentMethod.bankTransfer => l10n.salaryMethodBank,
      SalaryPaymentMethod.cash => l10n.salaryMethodCash,
      final StatementTotalKind t => statementTotalLabel(l10n, t),
      final ActivityModel a => operationText(l10n, a).$2,
      _ => null,
    };
