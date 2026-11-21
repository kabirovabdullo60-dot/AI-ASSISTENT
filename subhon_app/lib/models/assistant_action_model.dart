import 'assistant_action_status.dart';

/// `AssistantActionOut`: a change the assistant proposed ("add a store…").
/// Nothing changes until the person confirms it.
class AssistantActionModel {
  const AssistantActionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.summary,
    required this.danger,
    required this.params,
    this.errorCode,
    this.expiresAt,
  });

  factory AssistantActionModel.fromJson(Map<String, dynamic> json) =>
      AssistantActionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        status: AssistantActionStatus.fromApi(json['status'] as String),
        summary: json['summary'] as String,
        danger: json['danger'] as bool? ?? false,
        params: json['params'] as Map<String, dynamic>? ?? const {},
        errorCode: (json['error'] as Map<String, dynamic>?)?['code'] as String?,
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.parse(json['expiresAt'] as String).toLocal(),
      );

  final String id;

  /// `CREATE_STORE`, `DELETE_SALE`… (`ActionType`).
  final String type;
  final AssistantActionStatus status;

  /// One sentence in the question's language, shown as it is.
  final String summary;

  /// A delete: red Confirm and "Are you sure?".
  final bool danger;
  final Map<String, dynamic> params;

  /// Why it failed (`FAILED`): the endpoint's own code, shown translated.
  final String? errorCode;
  final DateTime? expiresAt;

  AssistantActionModel copyWith({AssistantActionStatus? status}) =>
      AssistantActionModel(
        id: id,
        type: type,
        status: status ?? this.status,
        summary: summary,
        danger: danger,
        params: params,
        errorCode: errorCode,
        expiresAt: expiresAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'status': status.name.toUpperCase(),
    'summary': summary,
    'danger': danger,
    'params': params,
    if (errorCode != null) 'error': {'code': errorCode, 'message': ''},
    if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
  };
}
