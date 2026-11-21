/// Where a change the assistant proposed is (`ActionStatus`).
enum AssistantActionStatus {
  proposed,
  done,
  failed,
  cancelled,
  expired;

  static AssistantActionStatus fromApi(String value) => switch (value) {
    'DONE' => done,
    'FAILED' => failed,
    'CANCELLED' => cancelled,
    'EXPIRED' => expired,
    _ => proposed,
  };

  /// Can't be confirmed any more: greyed out, "ask the assistant again".
  bool get isClosed => this == cancelled || this == expired;
}
