import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/app_dialog.dart';
import '../core/motion/motion.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../models/assistant_action_model.dart';

/// A change the AI assistant proposed, under its answer: what it will do, then
/// Cancel / Confirm (red for deletes). After that: done, failed, cancelled or expired.
class AssistantActionCard extends StatelessWidget {
  const AssistantActionCard({
    super.key,
    required this.action,
    required this.busy,
    required this.onConfirm,
    required this.onCancel,
    this.requestError,
    this.onOpen,
  });

  final AssistantActionModel action;

  /// Confirm / cancel request is running.
  final bool busy;

  /// The confirm / cancel request itself failed (e.g. NETWORK_ERROR).
  final String? requestError;

  /// [params] = only the fields the user corrected in Edit (null = confirm as proposed).
  final void Function(Map<String, dynamic>? params) onConfirm;
  final VoidCallback onCancel;

  /// Opens the page of the changed data (shown when done).
  final ValueChanged<AppSection>? onOpen;

  static AppSection? sectionOf(AssistantActionModel a) => switch (a.subject) {
    'STORE' => AppSection.stores,
    'SALE' => AppSection.sales,
    'EMPLOYEE' => AppSection.employees,
    'PAYROLL' => AppSection.salaries,
    'EXPENSE' => AppSection.expenses,
    'TARGET' => AppSection.dashboard,
    'PROFILE' => AppSection.profile,
    _ => null,
  };

  static IconData iconOf(AssistantActionModel a) => switch (a.subject) {
    'STORE' => Icons.storefront_outlined,
    'SALE' => Icons.receipt_long_outlined,
    'EMPLOYEE' => Icons.badge_outlined,
    'PAYROLL' => Icons.account_balance_wallet_outlined,
    'EXPENSE' => Icons.request_quote_outlined,
    'TARGET' => Icons.flag_outlined,
    'PROFILE' => Icons.account_circle_outlined,
    'NOTIFICATIONS' => Icons.notifications_none,
    _ => Icons.auto_awesome_outlined,
  };

  /// "name: Central Plaza · address: 45 Rudaki Ave" — ids and empty values left out.
  static String detailsOf(AssistantActionModel a) => [
    for (final e in a.params.entries)
      if (e.value != null && e.value is! Map && e.value is! List && '${e.value}'.isNotEmpty && !_isId(e.key))
        '${e.key}: ${e.value}',
  ].join(' · ');

  static bool _isId(String key) => key == 'id' || key.endsWith('Id');

  /// Fields the user may correct: plain values, not ids (those come from the assistant's lookup).
  static Map<String, Object?> editableOf(AssistantActionModel a) => {
    for (final e in a.params.entries)
      if (!_isId(e.key) && e.value is! Map && e.value is! List) e.key: e.value,
  };

  Future<void> _confirm(BuildContext context) async {
    if (action.danger) {
      final tr = context.l10n;
      final sure = await showAppDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(tr.actionSureTitle),
          content: Text(tr.actionSureBody(action.summary)),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(tr.cancel)),
            FilledButton(
              key: const Key('action-sure'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(tr.delete),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    onConfirm(null);
  }

  Future<void> _edit(BuildContext context) async {
    final changed = await showAppDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditParamsDialog(action: action, fields: editableOf(action)),
    );
    if (changed != null) onConfirm(changed.isEmpty ? null : changed);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final pending = action.isPending();
    final status = pending
        ? ActionStatus.proposed
        : (action.status == ActionStatus.proposed ? ActionStatus.expired : action.status);
    final accent = switch (status) {
      ActionStatus.done => AppColors.green,
      ActionStatus.failed => AppColors.red,
      ActionStatus.proposed => action.danger ? AppColors.red : AppColors.teal,
      _ => AppColors.muted,
    };
    final details = detailsOf(action);
    final section = sectionOf(action);

    final canEdit = editableOf(action).isNotEmpty;
    Widget buttons({required bool retry}) => Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        TextButton(key: Key('action-cancel-${action.id}'), onPressed: busy ? null : onCancel, child: Text(tr.cancel)),
        if (canEdit)
          TextButton(
            key: Key('action-edit-${action.id}'),
            onPressed: busy ? null : () => _edit(context),
            child: Text(tr.actionEdit),
          ),
        FilledButton(
          key: Key('action-confirm-${action.id}'),
          style: FilledButton.styleFrom(backgroundColor: action.danger ? AppColors.red : AppColors.teal),
          onPressed: busy ? null : () => _confirm(context),
          child: AnimatedSwitcher(
            duration: Motion.fast,
            child: busy
                ? const SizedBox(
                    key: ValueKey('busy'),
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    retry ? tr.actionRetry : (action.danger ? tr.delete : tr.actionConfirm),
                    key: const ValueKey('label'),
                  ),
          ),
        ),
      ],
    );
    Widget note(String text, Color color, {IconData? icon, Key? key}) => Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 6)],
        Expanded(
          child: Text(
            text,
            key: key,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );

    final footer = switch (status) {
      ActionStatus.proposed || ActionStatus.failed => Column(
        key: ValueKey(status),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status == ActionStatus.failed)
            note(
              tr.error(action.errorCode ?? 'INTERNAL_ERROR'),
              AppColors.red,
              icon: Icons.error_outline,
              key: Key('action-status-${action.id}'),
            )
          else
            Text(
              requestError != null ? tr.error(requestError!) : tr.actionWaiting,
              style: TextStyle(fontSize: 12, color: requestError != null ? AppColors.red : AppColors.muted),
            ),
          if (status == ActionStatus.failed && requestError != null)
            Text(tr.error(requestError!), style: TextStyle(fontSize: 12, color: AppColors.red)),
          Align(
            alignment: Alignment.centerRight,
            child: buttons(retry: status == ActionStatus.failed),
          ),
        ],
      ),
      ActionStatus.done => Row(
        key: const ValueKey(ActionStatus.done),
        children: [
          Expanded(
            child: note(tr.actionDone, accent, icon: Icons.check_circle, key: Key('action-status-${action.id}')),
          ),
          if (section != null && onOpen != null)
            TextButton(
              key: Key('action-open-${action.id}'),
              onPressed: () => onOpen!(section),
              child: Text(tr.actionOpen(tr.section(section))),
            ),
        ],
      ),
      _ => note(
        status == ActionStatus.cancelled ? tr.actionCancelledAsk : tr.actionExpired,
        accent,
        icon: status == ActionStatus.cancelled ? Icons.block : Icons.schedule,
        key: Key('action-status-${action.id}'),
      ),
    };
    final faded = status == ActionStatus.cancelled || status == ActionStatus.expired;

    final card = AnimatedContainer(
      duration: Motion.base,
      curve: Motion.easeOut,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pending ? accent.withValues(alpha: 0.55) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(iconOf(action), size: 17, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.summary,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.35),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        details,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(duration: Motion.base, child: footer),
        ],
      ),
    );
    // Cancelled / expired: greyed out — the user asks the assistant again instead.
    return AnimatedOpacity(
      key: Key('action-${action.id}'),
      duration: Motion.base,
      opacity: faded ? 0.6 : 1,
      child: card,
    );
  }
}

/// Edit: the action's plain fields as text boxes. Returns only the changed ones, typed like the
/// original (numbers stay numbers), for `confirm {"params": …}`.
class _EditParamsDialog extends StatefulWidget {
  const _EditParamsDialog({required this.action, required this.fields});

  final AssistantActionModel action;
  final Map<String, Object?> fields;

  @override
  State<_EditParamsDialog> createState() => _EditParamsDialogState();
}

class _EditParamsDialogState extends State<_EditParamsDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final e in widget.fields.entries) e.key: TextEditingController(text: e.value == null ? '' : '${e.value}'),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Object? _typed(Object? original, String text) {
    final t = text.trim();
    if (original is bool) return t.toLowerCase() == 'true';
    if (original is int) return int.tryParse(t) ?? t;
    if (original is num) return num.tryParse(t) ?? t;
    return t.isEmpty && original == null ? null : t;
  }

  Map<String, dynamic> _changed() => {
    for (final e in widget.fields.entries)
      if (_controllers[e.key]!.text.trim() != (e.value == null ? '' : '${e.value}'))
        e.key: _typed(e.value, _controllers[e.key]!.text),
  };

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return AlertDialog(
      title: Text(tr.actionEditTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.action.summary, style: TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 12),
              for (final key in widget.fields.keys) ...[
                TextField(
                  key: Key('action-field-$key'),
                  controller: _controllers[key],
                  decoration: InputDecoration(labelText: key),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(tr.cancel)),
        FilledButton(
          key: const Key('action-edit-save'),
          onPressed: () => Navigator.of(context).pop(_changed()),
          child: Text(tr.actionSaveConfirm),
        ),
      ],
    );
  }
}
