/// `ActivityAction` (API.md): how it was changed.
enum ActivityAction {
  created('CREATED'),
  updated('UPDATED'),
  deleted('DELETED'),
  statusChanged('STATUS_CHANGED'),
  paid('PAID'),
  cancelled('CANCELLED'),
  unknown('');

  const ActivityAction(this.json);

  final String json;

  static ActivityAction fromJson(String value) =>
      values.firstWhere((v) => v.json == value, orElse: () => unknown);
}
