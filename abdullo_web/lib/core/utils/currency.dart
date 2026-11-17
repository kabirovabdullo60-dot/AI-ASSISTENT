import 'format.dart';

/// Amounts are stored in TJS; USD is shown by converting.
enum Currency {
  tjs('TJS', 'TJS (Сомонӣ)', 1),
  usd('USD', 'USD (\$)', 10.95); // TODO: take the rate from the backend

  const Currency(this.code, this.label, this.tjsPerUnit);

  final String code;
  final String label;
  final double tjsPerUnit;

  double fromTjs(double tjs) => tjs / tjsPerUnit;

  /// Number only: "38,450"
  String amount(double tjs) => formatAmount(fromTjs(tjs));

  /// Number + code: "38,450 TJS"
  String format(double tjs) => '${amount(tjs)} $code';
}
