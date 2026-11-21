import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/money_account_model.dart';
import '../models/savings_goal_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';

/// A new savings goal (it gets its own savings account) or an existing one
/// to change or delete.
class SavingsGoalFormView extends StatefulWidget {
  const SavingsGoalFormView({this.initial, super.key});

  final SavingsGoalModel? initial;

  @override
  State<SavingsGoalFormView> createState() => _SavingsGoalFormViewState();
}

class _SavingsGoalFormViewState extends State<SavingsGoalFormView> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _target = TextEditingController(
    text: widget.initial?.target.toStringAsFixed(2),
  );
  late DateTime? _deadline = widget.initial?.deadline;
  String _currency = 'TJS';

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  /// A second tap while saving is ignored (no double records).
  bool _busy = false;

  Future<void> _save(PersonalFinanceViewModel vm) async {
    if (_busy) return;
    _busy = true;
    try {
      await _saveNow(vm);
    } finally {
      _busy = false;
    }
  }

  Future<void> _saveNow(PersonalFinanceViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.pfSaved;
    await vm.saveGoal(
      id: widget.initial?.id,
      name: _name.text,
      target: Validators.parseAmount(_target.text)!,
      accountId: widget.initial?.accountId,
      currency: _currency,
      deadline: _deadline,
    );
    feedback.showSuccess(saved);
    navigator.pop();
  }

  Future<void> _delete(PersonalFinanceViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.goalDeleteTitle,
      message: l10n.goalDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await vm.deleteGoal(widget.initial!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final initial = widget.initial;
    final currency = initial == null
        ? _currency
        : vm.currencyOf(initial.accountId);
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(initial?.name ?? l10n.goalNew),
        actions: [
          if (initial != null)
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: () => _delete(vm),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            AppTextField(
              controller: _name,
              label: l10n.goalName,
              hint: l10n.goalNameHint,
              maxLength: 60,
              autofocus: initial == null,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _target,
              label: l10n.goalTarget,
              suffix: Text(currency),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            if (initial == null) ...[
              gap,
              Text(l10n.pfCurrency, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final c in MoneyAccountModel.currencies)
                    ChoiceChip(
                      label: Text(c),
                      selected: _currency == c,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _currency = c),
                    ),
                ],
              ),
            ],
            gap,
            AppPickerField(
              label: l10n.goalDeadline,
              value: _deadline == null
                  ? l10n.goalNoDeadline
                  : context.formatDate(_deadline!),
              leading: const Icon(Icons.flag_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _deadline ?? vm.today.add(const Duration(days: 365)),
                  firstDate: vm.today,
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            if (_deadline != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _deadline = null),
                  child: Text(l10n.goalNoDeadline),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.commonSave, onPressed: () => _save(vm)),
          ],
        ),
      ),
    );
  }
}
