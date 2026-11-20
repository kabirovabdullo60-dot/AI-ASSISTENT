import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/utils/money.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _language => l10n.localeName;

  /// `1 250,50 TJS`.
  String money(double amount, {bool signed = false, String currency = 'TJS'}) =>
      formatMoney(amount, _language, signed: signed, currency: currency);

  /// A rate or converted amount: 2 decimals from 100, 4 from 1, up to 8
  /// below 1 (`0,00012345`), trailing zeros dropped.
  String rate(double value) {
    final abs = value.abs();
    final digits = abs >= 100
        ? 2
        : abs >= 1
        ? 4
        : 8;
    final text = NumberFormat.decimalPatternDigits(
      locale: _dateLocale,
      decimalDigits: digits,
    ).format(value);
    // Big amounts keep their kopecks (`586 887,20`), unless they are whole.
    if (abs >= 100) {
      return text.endsWith(',00') || text.endsWith('.00')
          ? text.substring(0, text.length - 3)
          : text;
    }
    // Drop trailing zeros after the decimal separator (and the separator).
    final match = RegExp(r'^(.*?[.,]\d*?)0+$').firstMatch(text);
    final trimmed = match == null ? text : match.group(1)!;
    return trimmed.endsWith(',') || trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  /// `+12,5 %` (one decimal, the sign when [signed]).
  String percent(double value, {bool signed = false, int digits = 1}) {
    final text = NumberFormat.decimalPatternDigits(
      locale: _dateLocale,
      decimalDigits: digits,
    ).format(value.abs());
    final sign = !signed || value == 0 ? '' : (value > 0 ? '+' : '−');
    return '$sign$text %';
  }

  /// `18 ноября 2026`.
  String formatDate(DateTime date) =>
      DateFormat.yMMMMd(_dateLocale).format(date);

  /// `18.11.2026`.
  String formatShortDate(DateTime date) =>
      DateFormat.yMd(_dateLocale).format(date);

  /// `18.11.2026, 14:05` (local time).
  String formatDateTime(DateTime time) =>
      DateFormat.yMd(_dateLocale).add_Hm().format(time);

  /// `5 октября, понедельник` (a day header in the history).
  String formatDayHeader(DateTime date) =>
      DateFormat('d MMMM, EEEE', _dateLocale).format(date);

  /// `ноябрь` (the month alone, as in "Расходы за ноябрь").
  String monthName(DateTime date) => DateFormat.LLLL(_dateLocale).format(date);

  /// `Ноябрь 2026`.
  String monthYear(int month, int year) {
    final text = DateFormat.yMMMM(_dateLocale).format(DateTime(year, month));
    return text[0].toUpperCase() + text.substring(1);
  }

  /// intl has no Tajik date data: dates use the Russian forms.
  String get _dateLocale => _language == 'tg' ? 'ru' : _language;
}
