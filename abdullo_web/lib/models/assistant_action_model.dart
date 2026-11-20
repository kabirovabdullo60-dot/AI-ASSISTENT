/// Status of a change the AI assistant proposed (`AssistantActionOut.status`).
enum ActionStatus { proposed, done, failed, cancelled, expired }

/// A change the AI assistant wants to make (e.g. CREATE_STORE). Nothing happens until the
/// user confirms it: POST /api/assistant/actions/{id}/confirm.
class AssistantActionModel {
  const AssistantActionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.summary,
    this.danger = false,
    this.params = const {},
    this.result,
    this.errorCode,
    this.createdAt,
    this.expiresAt,
  });

  factory AssistantActionModel.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    return AssistantActionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: switch (json['status']) {
        'DONE' => ActionStatus.done,
        'FAILED' => ActionStatus.failed,
        'CANCELLED' => ActionStatus.cancelled,
        'EXPIRED' => ActionStatus.expired,
        _ => ActionStatus.proposed,
      },
      summary: json['summary'] as String? ?? '',
      danger: json['danger'] == true,
      params: json['params'] is Map<String, dynamic> ? json['params'] as Map<String, dynamic> : const {},
      result: json['result'] is Map<String, dynamic> ? json['result'] as Map<String, dynamic> : null,
      errorCode: error is Map ? error['code'] as String? : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toLocal(),
    );
  }

  final String id;

  /// CREATE_STORE, UPDATE_SALE, DELETE_EMPLOYEE, CREATE_PAYROLL, SET_TARGET …
  final String type;
  final ActionStatus status;

  /// One sentence in the question's language: "Add store «Central Plaza», 45 Rudaki Ave".
  final String summary;

  /// Deletes something → red confirm button.
  final bool danger;

  /// Body of the matching normal endpoint (+ `id` for update/delete).
  final Map<String, dynamic> params;

  /// The record the normal endpoint returned, when [ActionStatus.done].
  final Map<String, dynamic>? result;

  /// Backend error code, when [ActionStatus.failed] (e.g. STORE_NAME_TAKEN).
  final String? errorCode;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  /// Still waiting for the user (and not past [expiresAt]).
  bool isPending({DateTime? now}) =>
      status == ActionStatus.proposed && (expiresAt == null || (now ?? DateTime.now()).isBefore(expiresAt!));

  /// What the action works on: STORE, SALE, EMPLOYEE, PAYROLL, EXPENSE, TARGET, PROFILE, NOTIFICATIONS.
  String get subject {
    final parts = type.split('_');
    return parts.length > 1 ? parts.sublist(1).join('_') : type;
  }

  AssistantActionModel copyWith({ActionStatus? status}) => AssistantActionModel(
    id: id,
    type: type,
    status: status ?? this.status,
    summary: summary,
    danger: danger,
    params: params,
    result: result,
    errorCode: errorCode,
    createdAt: createdAt,
    expiresAt: expiresAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'status': status.name.toUpperCase(),
    'summary': summary,
    'danger': danger,
    'params': params,
    'result': result,
    'error': errorCode == null ? null : {'code': errorCode},
    'createdAt': createdAt?.toUtc().toIso8601String(),
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
  };
}
