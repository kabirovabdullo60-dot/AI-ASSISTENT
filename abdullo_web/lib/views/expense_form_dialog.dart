import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/utils/format.dart';
import '../models/expense_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/expenses_view_model.dart';
import '../viewmodels/stores_view_model.dart';

/// Add / edit an expense → POST /api/expenses or PUT /api/expenses/{id}.
class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({super.key, this.expense});

  final ExpenseModel? expense;

  static Future<void> show(BuildContext context, {ExpenseModel? expense}) => showDialog<void>(
    context: context,
    builder: (_) => ExpenseFormDialog(expense: expense),
  );

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  /// Dropdown value for "whole business" (`storeId: null`).
  static const _business = '';

  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.expense == null ? '' : widget.expense!.amount.toStringAsFixed(2),
  );
  late final _description = TextEditingController(text: widget.expense?.description);
  late ExpenseCategory _category = widget.expense?.category ?? ExpenseCategory.rent;
  late String _storeId = widget.expense?.storeId ?? _business;
  late DateTime _date = widget.expense?.expenseDate ?? DateTime.now();

  bool get _isNew => widget.expense == null;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final e = ExpenseModel(
      id: widget.expense?.id ?? '',
      storeId: _storeId == _business ? null : _storeId,
      category: _category,
      amount: double.parse(_amount.text.trim()),
      expenseDate: _date,
      description: _description.text,
    );
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<ExpensesViewModel>().save(e, isNew: _isNew);
    if (!mounted) return;
    if (error == null) {
      dashboard.load();
      navigator.pop();
    }
    showResult(context, error, success: tr.expenseSaved);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final saving = context.select<ExpensesViewModel, bool>((v) => v.isSaving);
    final stores = context.watch<StoresViewModel>().ranked;
    final storeId = _storeId == _business || stores.any((s) => s.id == _storeId) ? _storeId : _business;

    return AlertDialog(
      title: Text(_isNew ? tr.addExpense : tr.editExpense),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  key: const Key('expense-category'),
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: tr.expenseCategoryLabel),
                  items: [
                    for (final c in ExpenseCategory.values)
                      DropdownMenuItem(value: c, child: Text(tr.expenseCategory(c))),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('expense-store'),
                  initialValue: storeId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: tr.store),
                  items: [
                    DropdownMenuItem(value: _business, child: Text(tr.wholeBusiness)),
                    for (final s in stores)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _storeId = v ?? _business),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('expense-amount'),
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?'))],
                  decoration: InputDecoration(labelText: tr.expenseAmount, suffixText: 'TJS'),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    return n == null || n <= 0 ? tr.enterAmount : null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  key: const Key('expense-date'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: tr.expenseDate,
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(formatNumericDate(_date)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('expense-description'),
                  controller: _description,
                  maxLength: 500,
                  decoration: InputDecoration(labelText: tr.description, counterText: ''),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: Text(tr.cancel)),
        FilledButton(
          key: const Key('expense-save'),
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isNew ? tr.addExpense : tr.save),
        ),
      ],
    );
  }
}
