import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../core/utils/local_date.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/expense_category_text.dart';
import '../l10n/validators.dart';
import '../models/expense_category.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../services/store_service.dart';
import '../viewmodels/expense_form_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/options_sheet.dart';

/// `POST /api/expenses`, or `PUT` / `DELETE /api/expenses/{id}` for
/// [initial]. The store is optional: no store = the whole business.
/// Pops `true` when something was saved.
class ExpenseFormView extends StatelessWidget {
  const ExpenseFormView({this.initial, super.key});

  final ExpenseModel? initial;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ExpenseFormViewModel(
      context.read<ExpenseService>(),
      context.read<StoreService>(),
      initial: initial,
    )..loadStores(),
    child: _ExpenseForm(initial: initial),
  );
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({this.initial});

  final ExpenseModel? initial;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.initial == null
        ? ''
        : widget.initial!.amount.toStringAsFixed(2),
  );
  late final _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );

  /// `null`: the whole business.
  late String? _storeId = widget.initial?.storeId;
  late ExpenseCategory? _category = widget.initial?.category;
  late DateTime _date = widget.initial?.expenseDate ?? today();
  bool _categoryMissing = false;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickStore(ExpenseFormViewModel vm) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldStore,
      selected: _storeId ?? '',
      options: [
        ('', l10n.expenseWholeBusiness),
        for (final s in vm.stores) (s.id, s.name),
      ],
    );
    if (picked != null) {
      setState(() => _storeId = picked.isEmpty ? null : picked);
    }
  }

  Future<void> _pickCategory() async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldCategory,
      selected: _category?.json,
      options: [
        for (final c in ExpenseCategory.values)
          (c.json, expenseCategoryText(l10n, c)),
      ],
    );
    if (picked != null) {
      setState(() {
        _category = ExpenseCategory.fromJson(picked);
        _categoryMissing = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(ExpenseFormViewModel vm) async {
    final valid = _form.currentState?.validate() ?? false;
    setState(() => _categoryMissing = _category == null);
    if (!valid || _category == null) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final l10n = context.l10n;
    final ok = await vm.save(
      storeId: _storeId,
      category: _category!,
      amount: Validators.parseAmount(_amount.text)!,
      expenseDate: _date,
      description: _description.text,
    );
    if (ok) {
      feedback.showSuccess(vm.isEdit ? l10n.expenseUpdated : l10n.expenseSaved);
      navigator.pop(true);
    }
  }

  Future<void> _delete(ExpenseFormViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.expenseDeleteTitle,
      message: l10n.expenseDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    if (await vm.delete()) {
      feedback.showSuccess(l10n.expenseDeleted);
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ExpenseFormViewModel>();
    final storeName = _storeId == null
        ? l10n.expenseWholeBusiness
        : vm.stores
                  .where((s) => s.id == _storeId)
                  .map((s) => s.name)
                  .firstOrNull ??
              widget.initial?.storeName;
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isEdit ? l10n.expenseEditTitle : l10n.expenseNewTitle),
        actions: [
          if (vm.isEdit)
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: vm.isSaving ? null : () => _delete(vm),
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
            AppPickerField(
              label: l10n.fieldCategory,
              value: _category == null
                  ? null
                  : expenseCategoryText(l10n, _category!),
              placeholder: l10n.fieldCategory,
              leading: const Icon(Icons.category_outlined),
              errorText: _categoryMissing ? l10n.validationRequired : null,
              onTap: _pickCategory,
            ),
            gap,
            AppPickerField(
              label: l10n.fieldStore,
              value: storeName,
              leading: const Icon(Icons.storefront_outlined),
              errorText: vm.storesError == null
                  ? null
                  : errorText(l10n, vm.storesError!),
              enabled: !vm.storesLoading,
              onTap: () => _pickStore(vm),
            ),
            if (vm.storesError != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: vm.loadStores,
                  child: Text(l10n.commonRetry),
                ),
              ),
            gap,
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              hint: '0,00',
              suffix: const Text('TJS'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            gap,
            AppPickerField(
              label: l10n.fieldDate,
              value: context.formatDate(_date),
              leading: const Icon(Icons.event_outlined),
              onTap: _pickDate,
            ),
            gap,
            AppTextField(
              controller: _description,
              label: l10n.fieldDescription,
              hint: l10n.fieldOptional,
              maxLines: 3,
              maxLength: 500,
            ),
            if (vm.error != null) ...[
              gap,
              AppInlineMessage(
                type: InlineMessageType.error,
                message: errorText(l10n, vm.error!),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.commonSave,
              isLoading: vm.isSaving,
              onPressed: () => _save(vm),
            ),
          ],
        ),
      ),
    );
  }
}
