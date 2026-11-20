import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../core/utils/local_date.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/debt_kind.dart';
import '../models/debt_model.dart';
import '../viewmodels/debts_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/debt_account_picker.dart';
import 'personal_lookup.dart';

/// Add or edit a debt (who, how much, phone, repay by, note) or a credit /
/// installment plan (bank or shop, type, total, monthly payment, end).
class DebtFormView extends StatefulWidget {
  const DebtFormView({required this.kind, this.initial, super.key});

  final DebtKind kind;
  final DebtModel? initial;

  @override
  State<DebtFormView> createState() => _DebtFormViewState();
}

class _DebtFormViewState extends State<DebtFormView> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _amount = TextEditingController(
    text: widget.initial?.amount.toStringAsFixed(2),
  );
  late final _monthly = TextEditingController(
    text: widget.initial?.monthlyPayment?.toStringAsFixed(2),
  );
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _note = TextEditingController(text: widget.initial?.note);
  late DebtKind _kind = widget.initial?.kind ?? widget.kind;
  late DateTime? _due = widget.initial?.dueDate;
  bool _saving = false;

  /// A new debt: the personal account its money goes from / to (the first
  /// one by default); `null`: not written.
  late String? _account = widget.initial == null
      ? personalOrNull(context)?.accounts.firstOrNull?.id
      : null;

  @override
  void dispose() {
    for (final c in [_name, _amount, _monthly, _phone, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? today().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final vm = context.read<DebtsViewModel>();
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.debtSaved;
    setState(() => _saving = true);
    final amount = Validators.parseAmount(_amount.text)!;
    final monthly = _kind.isLoan ? Validators.parseAmount(_monthly.text) : null;
    final initial = widget.initial;
    if (initial == null) {
      final personal = personalOrNull(context);
      await vm.add(
        kind: _kind,
        name: _name.text,
        amount: amount,
        phone: _kind.isLoan ? null : _phone.text,
        dueDate: _due,
        monthlyPayment: monthly,
        note: _note.text,
      );
      final account = _account;
      if (personal != null && account != null) {
        await personal.recordDebt(
          kind: _kind,
          repayment: false,
          amount: amount,
          accountId: account,
          name: _name.text.trim(),
        );
      }
    } else {
      await vm.update(
        initial.id,
        name: _name.text,
        amount: amount,
        phone: _kind.isLoan ? null : _phone.text,
        dueDate: _due,
        monthlyPayment: monthly,
        note: _note.text,
      );
    }
    feedback.showSuccess(saved);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loan = _kind.isLoan;
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial != null
              ? l10n.debtEditTitle
              : switch (_kind) {
                  DebtKind.owedToMe => l10n.debtNewOwed,
                  DebtKind.iOwe => l10n.debtNewIOwe,
                  _ => l10n.debtNewLoan,
                },
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxxl,
          ),
          children: [
            if (loan) ...[
              SegmentedButton<DebtKind>(
                segments: [
                  ButtonSegment(
                    value: DebtKind.credit,
                    label: Text(l10n.debtCredit),
                  ),
                  ButtonSegment(
                    value: DebtKind.installment,
                    label: Text(l10n.debtInstallment),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              gap,
            ],
            AppTextField(
              controller: _name,
              label: loan ? l10n.debtBank : l10n.debtWho,
              hint: loan ? null : l10n.debtWhoHint,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _amount,
              label: loan ? l10n.debtAmountTotal : l10n.fieldAmount,
              hint: '0,00',
              suffix: const Text('TJS'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            if (loan) ...[
              gap,
              AppTextField(
                controller: _monthly,
                label: l10n.debtMonthly,
                hint: l10n.fieldOptional,
                suffix: const Text('TJS'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? null
                    : Validators.amount(v, l10n),
              ),
            ] else ...[
              gap,
              AppTextField(
                controller: _phone,
                label: l10n.fieldPhone,
                hint: l10n.fieldOptional,
                keyboardType: TextInputType.phone,
              ),
            ],
            gap,
            AppPickerField(
              label: l10n.debtDueDate,
              value: _due == null
                  ? l10n.debtNoDueDate
                  : context.formatDate(_due!),
              leading: const Icon(Icons.event_outlined),
              onTap: _pickDue,
            ),
            if (_due != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _due = null),
                  child: Text(l10n.debtNoDueDate),
                ),
              ),
            gap,
            AppTextField(
              controller: _note,
              label: l10n.fieldNote,
              hint: l10n.fieldOptional,
              maxLines: 3,
              maxLength: 500,
            ),
            if (widget.initial == null &&
                (personalOrNull(context)?.accounts.isNotEmpty ?? false)) ...[
              gap,
              DebtAccountPicker(
                accounts: personalOrNull(context)!.accounts,
                value: _account,
                onChanged: (v) => setState(() => _account = v),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.commonSave,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
