/// `TargetPeriod` (API.md): a Monday–Sunday week or a calendar month.
enum TargetPeriod {
  week('WEEK'),
  month('MONTH');

  const TargetPeriod(this.json);

  final String json;

  static TargetPeriod fromJson(String value) =>
      values.firstWhere((v) => v.json == value);
}
