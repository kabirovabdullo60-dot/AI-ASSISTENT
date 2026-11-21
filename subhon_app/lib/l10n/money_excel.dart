import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../models/money_account_model.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';
import 'generated/app_localizations.dart';
import 'money_text.dart';

/// Personal operations as an Excel workbook (.xlsx): a title, a table
/// (date, type, category, account, to account, amount, currency, note)
/// and the income and expenses in somoni. Dates are real dates and amounts
/// real numbers (expenses negative), so Excel can sum and sort them.
Uint8List operationsToExcel(
  List<MoneyTransactionModel> list,
  AppLocalizations l10n, {
  required MoneyAccountModel? Function(String? id) account,
  required double income,
  required double expense,
}) {
  final excel = Excel.createExcel();
  final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];
  final bold = CellStyle(bold: true);
  void put(int row, int col, CellValue value, {CellStyle? style}) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = value;
    if (style != null) cell.cellStyle = style;
  }

  var row = 0;
  put(row++, 0, TextCellValue(l10n.opsExcelTitle), style: bold);
  row++;
  final headers = [
    l10n.fieldDate,
    l10n.opsColType,
    l10n.fieldCategory,
    l10n.pfAccount,
    l10n.opsColTo,
    l10n.fieldAmount,
    l10n.pfCurrency,
    l10n.fieldNote,
  ];
  for (var c = 0; c < headers.length; c++) {
    put(row, c, TextCellValue(headers[c]), style: bold);
  }
  row++;
  for (final t in list) {
    final from = account(t.accountId);
    final cells = <CellValue>[
      DateCellValue(year: t.date.year, month: t.date.month, day: t.date.day),
      TextCellValue(switch (t.kind) {
        MoneyTransactionKind.expense => l10n.pfExpense,
        MoneyTransactionKind.income => l10n.pfIncome,
        MoneyTransactionKind.transfer => l10n.pfTransfer,
      }),
      TextCellValue(
        t.category == null
            ? ''
            : [moneyCategoryText(l10n, t.category!), ?t.label].join(': '),
      ),
      TextCellValue(from?.name ?? ''),
      TextCellValue(account(t.toAccountId)?.name ?? ''),
      DoubleCellValue(
        double.parse(
          (t.kind == MoneyTransactionKind.expense ? -t.amount : t.amount)
              .toStringAsFixed(2),
        ),
      ),
      TextCellValue(from?.currency ?? 'TJS'),
      TextCellValue(t.note ?? ''),
    ];
    for (var c = 0; c < cells.length; c++) {
      put(row, c, cells[c]);
    }
    row++;
  }
  row++;
  put(row, 0, TextCellValue(l10n.opsTotalIncome), style: bold);
  put(row++, 5, DoubleCellValue(double.parse(income.toStringAsFixed(2))));
  put(row, 0, TextCellValue(l10n.opsTotalExpense), style: bold);
  put(row, 5, DoubleCellValue(double.parse((-expense).toStringAsFixed(2))));
  for (final (c, width) in [
    (0, 14.0),
    (2, 22.0),
    (3, 18.0),
    (4, 18.0),
    (7, 30.0),
  ]) {
    sheet.setColumnWidth(c, width);
  }
  return Uint8List.fromList(excel.encode()!);
}
