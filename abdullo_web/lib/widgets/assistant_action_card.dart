import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
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
  final VoidCallback onConfirm;
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

    final footer = switch (status) {
      ActionStatus.proposed => Row(
        key: const ValueKey('pending'),
        children: [
          Expanded(
            child: Text(
              requestError != null ? tr.error(requestError!) : tr.actionWaiting,
              style: TextStyle(fontSize: 12, color: requestError != null ? AppColors.red : AppColors.muted),
            ),
          ),
          TextButton(key: Key('action-cancel-${action.id}'), onPressed: busy ? null : onCancel, child: Text(tr.cancel)),
          const SizedBox(width: 6),
          FilledButton(
            key: Key('action-confirm-${action.id}'),
            style: FilledButton.styleFrom(backgroundColor: action.danger ? AppColors.red : AppColors.teal),
            onPressed: busy ? null : onConfirm,
            child: AnimatedSwitcher(
              duration: Motion.fast,
              child: busy
                  ? const SizedBox(
                      key: ValueKey('busy'),
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(action.danger ? tr.delete : tr.actionConfirm, key: const ValueKey('label')),
            ),
          ),
        ],
      ),
      _ => Row(
        key: ValueKey(status),
        children: [
          Icon(
            switch (status) {
              ActionStatus.done => Icons.check_circle,
              ActionStatus.failed => Icons.error_outline,
              ActionStatus.cancelled => Icons.block,
              _ => Icons.schedule,
            },
            size: 16,
            color: accent,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              switch (status) {
                ActionStatus.done => tr.actionDone,
                ActionStatus.failed => tr.error(action.errorCode ?? 'INTERNAL_ERROR'),
                ActionStatus.cancelled => tr.actionCancelled,
                _ => tr.actionExpired,
              },
              key: Key('action-status-${action.id}'),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: accent),
            ),
          ),
          if (status == ActionStatus.done && section != null && onOpen != null)
            TextButton(
              key: Key('action-open-${action.id}'),
              onPressed: () => onOpen!(section),
              child: Text(tr.actionOpen(tr.section(section))),
            ),
        ],
      ),
    };

    return AnimatedContainer(
      key: Key('action-${action.id}'),
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
  }
}
