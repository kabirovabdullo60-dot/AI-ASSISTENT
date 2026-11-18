import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/payroll_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/payroll_view_model.dart';

/// "Record Salary Payment" → POST /api/payroll {employeeId, amount, month, year, paymentDate, note}.
/// With [payroll] the employee is fixed, otherwise the user picks one who is still owed money.
class SalaryPaymentDialog extends StatefulWidget {
  const SalaryPaymentDialog({super.key, this.payroll});

  final PayrollModel? payroll;

  static Future<void> show(BuildContext context, {PayrollModel? payroll}) => showDialog<void>(
    context: context,
    builder: (_) => SalaryPaymentDialog(payroll: payroll),
  );

  @override
  State<SalaryPaymentDialog> createState() => _SalaryPaymentDialogState();
}

class _SalaryPaymentDialogState extends State<SalaryPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _employeeId = widget.payroll?.employeeId;
  late final _amount = TextEditingController(
    text: widget.payroll == null ? '' : widget.payroll!.remaining.toStringAsFixed(2),
  );
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  bool _amountTouched = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save(PayrollModel p) async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final amount = double.parse(_amount.text.trim());
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<PayrollViewModel>().recordPayment(
      p.employeeId,
      amount,
      paymentDate: _date,
      note: _note.text,
    );
    if (!mounted) return;
    if (error == null) {
      dashboard.load();
      navigator.pop();
    }
    showResult(context, error, success: tr.paidTo('${formatAmount(amount)} TJS', p.employeeName));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<PayrollViewModel>();
    final owed = vm.items.where((p) => p.remaining > 0).toList();
    final selected = _employeeId == null ? (owed.isEmpty ? null : owed.first) : vm.byId(_employeeId!);
    if (selected != null && widget.payroll == null && !_amountTouched && _amount.text.isEmpty) {
      _amount.text = selected.remaining.toStringAsFixed(2);
    }

    return AlertDialog(
      title: Text(tr.recordSalaryPayment),
      content: SizedBox(
        width: 440,
        child: selected == null
            ? Text(tr.everyonePaid)
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.payFor(formatMonthYear(vm.month)),
                        style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (widget.payroll == null)
                        DropdownButtonFormField<String>(
                          key: const Key('payment-employee'),
                          initialValue: selected.employeeId,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: tr.employee),
                          items: [
                            for (final p in owed)
                              DropdownMenuItem(
                                value: p.employeeId,
                                child: Text(
                                  tr.owed(p.employeeName, '${formatAmount(p.remaining)} TJS'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (id) => setState(() {
                            _employeeId = id;
                            final p = id == null ? null : vm.byId(id);
                            if (p != null) _amount.text = p.remaining.toStringAsFixed(2);
                          }),
                        )
                      else
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(selected.employeeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${selected.role} · ${selected.storeName}'),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        tr.salarySummary(
                          '${formatAmount(selected.salary)} TJS',
                          '${formatAmount(selected.disbursed)} TJS',
                          '${formatAmount(selected.remaining)} TJS',
                        ),
                        style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('payment-amount'),
                        controller: _amount,
                        onChanged: (_) => _amountTouched = true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?'))],
                        decoration: InputDecoration(
                          labelText: tr.amountTjs,
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) return tr.enterAmount;
                          if (n > selected.remaining + 0.001) {
                            return tr.maxAmount('${formatAmount(selected.remaining)} TJS');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        key: const Key('payment-date'),
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
                            labelText: tr.paymentDate,
                            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          ),
                          child: Text(formatNumericDate(_date)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('payment-note'),
                        controller: _note,
                        maxLength: 500,
                        decoration: InputDecoration(labelText: tr.noteOptional, counterText: ''),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.cancel)),
        if (selected != null)
          FilledButton(
            key: const Key('payment-save'),
            onPressed: vm.payingId != null ? null : () => _save(selected),
            child: vm.payingId != null
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(tr.recordPayment),
          ),
      ],
    );
  }
}
