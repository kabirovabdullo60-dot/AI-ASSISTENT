/// API dates (`YYYY-MM-DD`, business calendar Asia/Dushanbe) are calendar
/// days: they are kept as local dates and never shifted through UTC.
DateTime parseLocalDate(String value) {
  final parts = value.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// The calendar day of [date] as `YYYY-MM-DD` (its local fields, no UTC
/// conversion).
String formatLocalDate(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-'
      '${two(date.day)}';
}

/// Today as a calendar day.
DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
