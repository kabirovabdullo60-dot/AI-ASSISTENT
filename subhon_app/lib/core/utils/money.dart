import 'package:intl/intl.dart';

/// Money arrives from the API as a decimal string in TJS (`"1250.50"`).
double parseMoney(String value) => double.parse(value);

/// Money is sent to the API as a string with two decimals.
String moneyToApi(double amount) => amount.toStringAsFixed(2);

/// `1 250,50 TJS` (ru / tg), `1,250.50 TJS` (en). Whole amounts without
/// decimals, as in OFAR: `4 048 TJS`.
String formatMoney(
  double amount,
  String locale, {
  bool signed = false,
  String currency = 'TJS',
}) {
  final whole = amount == amount.roundToDouble();
  final format = NumberFormat.decimalPatternDigits(
    locale: _numberLocale(locale),
    decimalDigits: whole ? 0 : 2,
  );
  final sign = signed && amount > 0 ? '+' : '';
  // A real minus sign, as in OFAR.
  return '$sign${format.format(amount).replaceFirst('-', '−')} $currency';
}

/// Tajik uses the Russian number format (intl has no `tg` data).
String _numberLocale(String locale) => locale == 'tg' ? 'ru' : locale;
