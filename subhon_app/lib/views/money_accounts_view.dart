import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../l10n/validators.dart';
import '../models/money_account_kind.dart';
import '../models/money_account_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_text_field.dart';

/// The personal accounts (cash, cards…) with their balances and the
/// total; add, edit or delete one (not while it has operations).
class MoneyAccountsView extends StatelessWidget {
  const MoneyAccountsView({super.key});

  static Future<void> openForm(
    BuildContext context, {
    MoneyAccountModel? account,
  }) {
    final vm = context.read<PersonalFinanceViewModel>();
    final l10n = context.l10n;
    return showAppBottomSheet<void>(
      context,
      title: account == null ? l10n.pfNewAccount : account.name,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _AccountSheet(initial: account),
      ),
    );
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
        title: Text(l10n.pfAccounts),
        actions: [
          IconButton(
            tooltip: l10n.pfNewAccount,
            onPressed: () => openForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(l10n.pfTotalBalance, style: theme.textTheme.bodySmall),
          Text(
            context.money(vm.totalBalance),
            style: theme.textTheme.headlineMedium,
          ),
          if (vm.hasForeign)
            Text(
              vm.ratesMissing ? l10n.pfRatesMissing : l10n.pfInTjsNote,
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: AppSpacing.lg),
          for (final a in vm.accounts) ...[
            Material(
              color: p.surface,
              borderRadius: AppRadius.lgAll,
              child: InkWell(
                borderRadius: AppRadius.lgAll,
                onTap: () => openForm(context, account: a),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: p.primaryLight,
                        child: Icon(accountKindIcon(a.kind), color: p.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name, style: theme.textTheme.titleSmall),
                            Text(
                              accountKindText(l10n, a.kind),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.money(
                              vm.balance(a.id),
                              currency: a.currency,
                            ),
                            style: theme.textTheme.titleSmall,
                          ),
                          if (a.currency != 'TJS' && !vm.ratesMissing)
                            Text(
                              '≈ ${context.money(vm.inTjs(vm.balance(a.id), a.currency))}',
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _AccountSheet extends StatefulWidget {
  const _AccountSheet({this.initial});

  final MoneyAccountModel? initial;

  @override
  State<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<_AccountSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _balance = TextEditingController(
    text: widget.initial?.openingBalance.toStringAsFixed(2) ?? '0',
  );
  late MoneyAccountKind _kind = widget.initial?.kind ?? MoneyAccountKind.card;
  late String _currency = widget.initial?.currency ?? 'TJS';

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final vm = context.read<PersonalFinanceViewModel>();
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.pfSaved;
    final balance = _parseBalance(_balance.text) ?? 0;
    final initial = widget.initial;
    if (initial == null) {
      await vm.addAccount(
        name: _name.text,
        kind: _kind,
        openingBalance: balance,
        currency: _currency,
      );
    } else {
      await vm.updateAccount(
        initial.id,
        name: _name.text,
        kind: _kind,
        openingBalance: balance,
        currency: _currency,
      );
    }
    feedback.showSuccess(saved);
    navigator.pop();
  }

  /// The opening balance may be 0 (or below, for a card in debt).
  static double? _parseBalance(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    final negative = t.startsWith('-') || t.startsWith('−');
    final value = Validators.parseAmount(negative ? t.substring(1) : t);
    if (value == null) return t == '0' ? 0 : null;
    return negative ? -value : value;
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final vm = context.read<PersonalFinanceViewModel>();
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.pfAccountDeleteTitle,
      message: widget.initial!.name,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    if (await vm.deleteAccount(widget.initial!.id)) {
      feedback.showSuccess(l10n.pfDeleted);
      navigator.pop();
    } else {
      feedback.showError(l10n.pfAccountUsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              label: l10n.pfAccountName,
              hint: l10n.pfAccountNameHint,
              maxLength: 60,
              validator: (v) => Validators.required(v, l10n),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.pfAccountKind,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final k in MoneyAccountKind.values)
                  ChoiceChip(
                    avatar: Icon(accountKindIcon(k), size: 18),
                    label: Text(accountKindText(l10n, k)),
                    selected: _kind == k,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _kind = k),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.pfCurrency,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Builder(
              builder: (context) {
                final locked =
                    widget.initial != null &&
                    context.read<PersonalFinanceViewModel>().isUsed(
                      widget.initial!.id,
                    );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final c in MoneyAccountModel.currencies)
                          ChoiceChip(
                            label: Text(c),
                            selected: _currency == c,
                            showCheckmark: false,
                            onSelected: locked
                                ? null
                                : (_) => setState(() => _currency = c),
                          ),
                      ],
                    ),
                    if (locked)
                      Text(
                        l10n.pfCurrencyLocked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _balance,
              label: l10n.pfOpeningBalance,
              suffix: Text(_currency),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (v) =>
                  _parseBalance(v ?? '') == null ? l10n.validationAmount : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.commonSave, onPressed: _save),
            if (widget.initial != null)
              TextButton(onPressed: _delete, child: Text(l10n.commonDelete)),
          ],
        ),
      ),
    );
  }
}
