import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../l10n/validators.dart';
import '../models/money_category.dart';
import '../models/recurring_payment_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/options_sheet.dart';
import 'recurring_payment_tile.dart';

/// Regular payments (rent, internet, subscriptions): the next date (red
/// when overdue) and "Оплатить", which writes the expense and moves the
/// date on. Add, edit or delete one.
class RecurringPaymentsView extends StatelessWidget {
  const RecurringPaymentsView({super.key});

  static Future<void> openForm(
    BuildContext context, {
    RecurringPaymentModel? payment,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PersonalFinanceViewModel>(),
        child: _RecurringForm(initial: payment),
      ),
    ),
  );

  static Future<void> pay(
    BuildContext context,
    RecurringPaymentModel payment,
  ) async {
    final vm = context.read<PersonalFinanceViewModel>();
    final feedback = AppSnackbar.of(context);
    final paid = context.l10n.pfPaid;
    await vm.payRecurring(payment.id);
    feedback.showSuccess(paid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.pfRecurring),
        actions: [
          IconButton(
            tooltip: l10n.pfNewRecurring,
            onPressed: () => openForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          if (vm.recurring.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    l10n.pfNoRecurring,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: l10n.pfNewRecurring,
                    icon: Icons.add_rounded,
                    onPressed: () => openForm(context),
                  ),
                ],
              ),
            ),
          for (final r in vm.recurring) ...[
            RecurringPaymentTile(payment: r),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _RecurringForm extends StatefulWidget {
  const _RecurringForm({this.initial});

  final RecurringPaymentModel? initial;

  @override
  State<_RecurringForm> createState() => _RecurringFormState();
}

class _RecurringFormState extends State<_RecurringForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _amount = TextEditingController(
    text: widget.initial?.amount.toStringAsFixed(2),
  );
  late MoneyCategory _category =
      widget.initial?.category ?? MoneyCategory.phone;
  late DateTime? _next = widget.initial?.nextDate;
  late String? _account = widget.initial?.accountId;
  late int _every = widget.initial?.everyMonths ?? 1;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(PersonalFinanceViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.pfSaved;
    await vm.saveRecurring(
      id: widget.initial?.id,
      name: _name.text,
      amount: Validators.parseAmount(_amount.text)!,
      category: _category,
      nextDate: _next ?? vm.today,
      accountId: _account,
      everyMonths: _every,
    );
    feedback.showSuccess(saved);
    navigator.pop();
  }

  Future<void> _delete(PersonalFinanceViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.commonDelete,
      message: widget.initial!.name,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await vm.deleteRecurring(widget.initial!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<PersonalFinanceViewModel>();
    final account = vm.account(_account);
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial?.name ?? l10n.pfNewRecurring),
        actions: [
          if (widget.initial != null)
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
              label: l10n.pfRecurringName,
              hint: l10n.pfRecurringNameHint,
              maxLength: 60,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              suffix: const Text('TJS'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            gap,
            AppPickerField(
              label: l10n.fieldCategory,
              value: moneyCategoryText(l10n, _category),
              leading: Icon(moneyCategoryIcon(_category)),
              onTap: () async {
                final picked = await showOptionsSheet<String>(
                  context,
                  title: l10n.fieldCategory,
                  selected: _category.name,
                  options: [
                    for (final c in MoneyCategory.forIncome(income: false))
                      (c.name, moneyCategoryText(l10n, c)),
                  ],
                );
                if (picked != null) {
                  setState(() => _category = MoneyCategory.fromName(picked));
                }
              },
            ),
            gap,
            AppPickerField(
              label: l10n.pfNextDate,
              value: context.formatDate(_next ?? vm.today),
              leading: const Icon(Icons.event_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _next ?? vm.today,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _next = picked);
              },
            ),
            gap,
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 1, label: Text(l10n.pfEveryMonth)),
                ButtonSegment(value: 3, label: Text(l10n.pfEveryQuarter)),
                ButtonSegment(value: 12, label: Text(l10n.pfEveryYear)),
              ],
              selected: {_every},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _every = s.first),
            ),
            gap,
            AppPickerField(
              label: l10n.pfAccount,
              value: account?.name ?? l10n.pfAnyAccount,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              onTap: () async {
                final picked = await showOptionsSheet<String>(
                  context,
                  title: l10n.pfAccount,
                  selected: _account ?? '',
                  options: [
                    ('', l10n.pfAnyAccount),
                    for (final a in vm.accounts) (a.id, a.name),
                  ],
                );
                if (picked != null) {
                  setState(() => _account = picked.isEmpty ? null : picked);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.commonSave, onPressed: () => _save(vm)),
          ],
        ),
      ),
    );
  }
}
