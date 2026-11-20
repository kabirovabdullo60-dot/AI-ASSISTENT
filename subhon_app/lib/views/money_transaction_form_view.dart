import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../l10n/validators.dart';
import '../models/money_category.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';
import '../models/quick_entry_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/options_sheet.dart';

/// Write down an expense, an income or a transfer between own accounts
/// (or edit / delete one): the amount, a category (tap a tile), the
/// account, the date and a note.
class MoneyTransactionFormView extends StatefulWidget {
  const MoneyTransactionFormView({
    this.kind = MoneyTransactionKind.expense,
    this.initial,
    this.draft,
    this.toAccountId,
    super.key,
  });

  final MoneyTransactionKind kind;
  final MoneyTransactionModel? initial;

  /// Filled from a quick phrase ("такси 50"), to be checked and saved.
  final QuickEntryModel? draft;

  /// A transfer straight to this account (topping up a savings goal).
  final String? toAccountId;

  @override
  State<MoneyTransactionFormView> createState() =>
      _MoneyTransactionFormViewState();
}

class _MoneyTransactionFormViewState extends State<MoneyTransactionFormView> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: (widget.initial?.amount ?? widget.draft?.amount)?.toStringAsFixed(2),
  );
  late final _received = TextEditingController(
    text: widget.initial?.toAmount?.toStringAsFixed(2),
  );
  late final _note = TextEditingController(
    text: widget.initial?.note ?? widget.draft?.note,
  );
  late MoneyTransactionKind _kind =
      widget.initial?.kind ?? widget.draft?.kind ?? widget.kind;
  late MoneyCategory? _category =
      widget.initial?.category ?? widget.draft?.category;
  late String? _account = widget.initial?.accountId ?? widget.draft?.accountId;
  late String? _toAccount = widget.initial?.toAccountId ?? widget.toAccountId;
  late DateTime? _date = widget.initial?.date;
  bool _categoryMissing = false;

  @override
  void initState() {
    super.initState();
    // The suggested amount for a transfer between currencies follows it.
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _received.dispose();
    _note.dispose();
    super.dispose();
  }

  /// The chosen account, or the first one that isn't the transfer's
  /// destination.
  String? _fromAccount(PersonalFinanceViewModel vm) =>
      _account ??
      vm.accounts.where((a) => a.id != _toAccount).firstOrNull?.id ??
      vm.accounts.firstOrNull?.id;

  Future<void> _pickAccount(
    PersonalFinanceViewModel vm, {
    required bool to,
  }) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: to ? l10n.pfToAccount : l10n.pfFromAccount,
      selected: to ? _toAccount : _account,
      options: [
        for (final a in vm.accounts)
          (
            a.id,
            '${a.name} · '
                '${context.money(vm.balance(a.id), currency: a.currency)}',
          ),
      ],
    );
    if (picked == null) return;
    setState(() => to ? _toAccount = picked : _account = picked);
  }

  Future<void> _save(PersonalFinanceViewModel vm) async {
    final l10n = context.l10n;
    final valid = _form.currentState?.validate() ?? false;
    final needsCategory = _kind != MoneyTransactionKind.transfer;
    setState(() => _categoryMissing = needsCategory && _category == null);
    if (!valid || _categoryMissing) return;
    final account = _fromAccount(vm);
    if (account == null) return;
    if (_kind == MoneyTransactionKind.transfer &&
        (_toAccount == null || _toAccount == account)) {
      AppSnackbar.of(context).showError(l10n.pfSameAccount);
      return;
    }
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final amount = Validators.parseAmount(_amount.text)!;
    final crossCurrency =
        _kind == MoneyTransactionKind.transfer &&
        vm.currencyOf(account) != vm.currencyOf(_toAccount);
    final received = crossCurrency
        ? Validators.parseAmount(_received.text) ??
              vm.convert(
                amount,
                vm.currencyOf(account),
                vm.currencyOf(_toAccount),
              )
        : null;
    final initial = widget.initial;
    if (initial == null) {
      await vm.addTransaction(
        kind: _kind,
        amount: amount,
        accountId: account,
        date: _date,
        category: _category,
        toAccountId: _toAccount,
        note: _note.text,
        toAmount: received,
      );
    } else {
      await vm.updateTransaction(
        initial.id,
        amount: amount,
        accountId: account,
        date: _date ?? initial.date,
        category: _category,
        toAccountId: _toAccount,
        note: _note.text,
        toAmount: received,
      );
    }
    feedback.showSuccess(l10n.pfSaved);
    navigator.pop();
  }

  Future<void> _delete(PersonalFinanceViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.pfDeleteTitle,
      message: l10n.pfDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await vm.deleteTransaction(widget.initial!.id);
    feedback.showSuccess(l10n.pfDeleted);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final account = vm.account(_fromAccount(vm));
    final toAccount = vm.account(_toAccount);
    final transfer = _kind == MoneyTransactionKind.transfer;
    final currency = account?.currency ?? 'TJS';
    final crossCurrency =
        transfer && toAccount != null && toAccount.currency != currency;
    final suggested = crossCurrency
        ? vm.convert(
            Validators.parseAmount(_amount.text) ?? 0,
            currency,
            toAccount.currency,
          )
        : null;
    final color = switch (_kind) {
      MoneyTransactionKind.income => p.success,
      MoneyTransactionKind.expense => p.error,
      MoneyTransactionKind.transfer => p.primary,
    };
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial != null
              ? l10n.pfEditOperation
              : switch (_kind) {
                  MoneyTransactionKind.expense => l10n.pfNewExpense,
                  MoneyTransactionKind.income => l10n.pfNewIncome,
                  MoneyTransactionKind.transfer => l10n.pfNewTransfer,
                },
        ),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxxl,
          ),
          children: [
            if (widget.initial == null) ...[
              SegmentedButton<MoneyTransactionKind>(
                segments: [
                  ButtonSegment(
                    value: MoneyTransactionKind.expense,
                    label: Text(l10n.pfExpense),
                  ),
                  ButtonSegment(
                    value: MoneyTransactionKind.income,
                    label: Text(l10n.pfIncome),
                  ),
                  ButtonSegment(
                    value: MoneyTransactionKind.transfer,
                    label: Text(l10n.pfTransfer),
                  ),
                ],
                selected: {_kind},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() {
                  _kind = s.first;
                  _category = null;
                }),
              ),
              gap,
            ],
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              hint: '0',
              suffix: Text(currency),
              autofocus: widget.initial == null,
              style: theme.textTheme.headlineSmall?.copyWith(color: color),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            if (!transfer) ...[
              gap,
              Text(l10n.fieldCategory, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final c in MoneyCategory.forIncome(
                    income: _kind == MoneyTransactionKind.income,
                  ))
                    ChoiceChip(
                      avatar: Icon(
                        moneyCategoryIcon(c),
                        size: 18,
                        color: _category == c ? p.onPrimary : color,
                      ),
                      label: Text(moneyCategoryText(l10n, c)),
                      selected: _category == c,
                      showCheckmark: false,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: _category == c ? p.onPrimary : null,
                      ),
                      onSelected: (_) => setState(() {
                        _category = c;
                        _categoryMissing = false;
                      }),
                    ),
                ],
              ),
              if (_categoryMissing)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l10n.validationRequired,
                    style: theme.textTheme.bodySmall?.copyWith(color: p.error),
                  ),
                ),
            ],
            gap,
            AppPickerField(
              label: transfer ? l10n.pfFromAccount : l10n.pfAccount,
              value: account == null
                  ? null
                  : '${account.name} · '
                        '${context.money(vm.balance(account.id), currency: currency)}',
              leading: Icon(
                account == null
                    ? Icons.account_balance_wallet_outlined
                    : accountKindIcon(account.kind),
              ),
              onTap: () => _pickAccount(vm, to: false),
            ),
            if (transfer) ...[
              gap,
              AppPickerField(
                label: l10n.pfToAccount,
                value: toAccount == null
                    ? null
                    : '${toAccount.name} · '
                          '${context.money(vm.balance(toAccount.id), currency: toAccount.currency)}',
                placeholder: l10n.pfToAccount,
                leading: const Icon(Icons.call_received_rounded),
                onTap: () => _pickAccount(vm, to: true),
              ),
              if (crossCurrency) ...[
                gap,
                AppTextField(
                  controller: _received,
                  label: l10n.pfReceived,
                  hint: suggested == null || suggested == 0
                      ? '0'
                      : suggested.toStringAsFixed(2),
                  suffix: Text(toAccount.currency),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  // Empty: today's rate is used.
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) &&
                          suggested != null &&
                          suggested > 0
                      ? null
                      : Validators.amount(v, l10n),
                ),
              ],
            ],
            gap,
            AppPickerField(
              label: l10n.fieldDate,
              value: context.formatDate(_date ?? vm.today),
              leading: const Icon(Icons.event_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? vm.today,
                  firstDate: DateTime(2000),
                  lastDate: vm.today,
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            gap,
            AppTextField(
              controller: _note,
              label: l10n.fieldNote,
              hint: l10n.fieldOptional,
              maxLength: 200,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.commonSave, onPressed: () => _save(vm)),
          ],
        ),
      ),
    );
  }
}
