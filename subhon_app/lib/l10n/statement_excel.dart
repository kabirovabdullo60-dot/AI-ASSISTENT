import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/statement_model.dart';
import 'generated/app_localizations.dart';
import 'statement_text.dart';
import 'tajik_dates.dart';

/// The statement as an Excel workbook (.xlsx): its name and period on top,
/// the table with headers, then the totals. Dates are real dates and
/// amounts real numbers, so Excel can sum and sort them.
Uint8List statementToExcel(StatementModel s, AppLocalizations l10n) {
  final excel = Excel.createExcel();
  final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
  final sheet = excel[sheetName];
  final dateLocale = l10n.localeName == 'tg' ? 'ru' : l10n.localeName;
  String day(DateTime d) => l10n.localeName == 'tg'
      ? TajikDates.shortDate(d)
      : DateFormat.yMd(dateLocale).format(d);

  final bold = CellStyle(bold: true);
  void put(int row, int col, CellValue value, {CellStyle? style}) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = value;
    if (style != null) cell.cellStyle = style;
  }

  CellValue value(Object? v) => switch (v) {
    null => TextCellValue(''),
    final DateTime d => DateCellValue(year: d.year, month: d.month, day: d.day),
    final int i => IntCellValue(i),
    final double d => DoubleCellValue(double.parse(d.toStringAsFixed(2))),
    final String t => TextCellValue(t),
    _ => TextCellValue(statementValueText(l10n, v) ?? '$v'),
  };

  var row = 0;
  put(row++, 0, TextCellValue(statementTitle(l10n, s.kind)), style: bold);
  final period = [
    if (s.startDate != null) day(s.startDate!),
    if (s.endDate != null) day(s.endDate!),
  ].join(' – ');
  if (period.isNotEmpty || s.storeName != null) {
    put(
      row++,
      0,
      TextCellValue(
        [?s.storeName, period].where((t) => t.isNotEmpty).join(' · '),
      ),
    );
  }
  row++;
  final headers = statementHeaders(l10n, s.kind);
  for (var c = 0; c < headers.length; c++) {
    put(row, c, TextCellValue(headers[c]), style: bold);
  }
  row++;
  for (final r in s.rows) {
    for (var c = 0; c < r.cells.length; c++) {
      put(row, c, value(r.cells[c]));
    }
    row++;
  }
  row++;
  for (final (kind, amount) in s.totals) {
    put(row, 0, TextCellValue(statementTotalLabel(l10n, kind)), style: bold);
    put(row, 1, value(amount), style: bold);
    row++;
  }
  for (var c = 0; c < headers.length; c++) {
    sheet.setColumnWidth(c, c == 0 ? 18 : 22);
  }
  return Uint8List.fromList(excel.encode()!);
}
