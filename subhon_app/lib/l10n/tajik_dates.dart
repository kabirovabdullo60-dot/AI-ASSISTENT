/// Dates in Tajik, made by hand: intl's DateFormat has no `tg` data (it
/// throws), and the Russian forms are wrong in a Tajik screen.
class TajikDates {
  const TajikDates._();

  static const _months = [
    'январ', 'феврал', 'март', 'апрел', 'май', 'июн', //
    'июл', 'август', 'сентябр', 'октябр', 'ноябр', 'декабр',
  ];

  /// Monday first, as `DateTime.weekday` (1 = Monday).
  static const _weekdays = [
    'душанбе',
    'сешанбе',
    'чоршанбе',
    'панҷшанбе',
    'ҷумъа',
    'шанбе',
    'якшанбе',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// `ноябр`.
  static String month(int month) => _months[month - 1];

  /// `ноябри` — the month joined to the day (izofat): "18 ноябри".
  static String _ofMonth(int month) {
    return '${_months[month - 1]}и';
  }

  /// `18 ноябри 2026`.
  static String date(DateTime d) => '${d.day} ${_ofMonth(d.month)} ${d.year}';

  /// `18.11.2026`.
  static String shortDate(DateTime d) =>
      '${_two(d.day)}.${_two(d.month)}.${d.year}';

  /// `18.11.2026, 14:05`.
  static String dateTime(DateTime d) =>
      '${shortDate(d)}, ${_two(d.hour)}:${_two(d.minute)}';

  /// `5 октябри, душанбе`.
  static String dayHeader(DateTime d) =>
      '${d.day} ${_ofMonth(d.month)}, ${_weekdays[d.weekday - 1]}';

  /// `Ноябри 2026`.
  static String monthYear(int month, int year) {
    final name = _ofMonth(month);
    return '${name[0].toUpperCase()}${name.substring(1)} $year';
  }
}
