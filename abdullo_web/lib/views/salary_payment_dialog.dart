import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/payroll_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/payroll_view_model.dart';

/// "Record Salary Payment" → POST /payroll/{id}/payments.
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
  static const _methods = ['Bank Transfer', 'Cash Disbursement'];

  final _formKey = GlobalKey<FormState>();
  late String? _payrollId = widget.payroll?.id;
  late final _amount = TextEditingController(
    text: widget.payroll == null ? '' : widget.payroll!.remaining.round().toString(),
  );
  String _method = _methods.first;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(PayrollModel p) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final ok = await context.read<PayrollViewModel>().recordPayment(p.id, amount, method: _method);
    if (!mounted) return;
    if (ok) {
      dashboard.load();
      navigator.pop();
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Paid ${formatAmount(amount)} TJS to ${p.employeeName}' : 'Payment failed. Try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PayrollViewModel>();
    final owed = vm.items.where((p) => p.remaining > 0).toList();
    final selected = _payrollId == null ? (owed.isEmpty ? null : owed.first) : vm.byId(_payrollId!);

    return AlertDialog(
      title: const Text('Record Salary Payment'),
      content: SizedBox(
        width: 440,
        child: selected == null
            ? const Text('Everyone is fully paid for this month.')
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.payroll == null)
                      DropdownButtonFormField<String>(
                        key: const Key('payment-employee'),
                        initialValue: selected.id,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Employee'),
                        items: [
                          for (final p in owed)
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.employeeName} — owed ${formatAmount(p.remaining)} TJS',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) => setState(() {
                          _payrollId = id;
                          final p = id == null ? null : vm.byId(id);
                          if (p != null) _amount.text = p.remaining.round().toString();
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
                      'Salary ${formatAmount(selected.salary)} TJS · paid ${formatAmount(selected.disbursed)} · '
                      'remaining ${formatAmount(selected.remaining)} TJS',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('payment-amount'),
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      decoration: const InputDecoration(
                        labelText: 'Amount (TJS)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return 'Enter an amount above 0';
                        if (n > selected.remaining) return 'Max ${formatAmount(selected.remaining)} TJS';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [for (final m in _methods) ButtonSegment(value: m, label: Text(m))],
                      selected: {_method},
                      onSelectionChanged: (s) => setState(() => _method = s.first),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        if (selected != null)
          FilledButton(
            key: const Key('payment-save'),
            onPressed: vm.payingId != null ? null : () => _save(selected),
            child: vm.payingId != null
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Record Payment'),
          ),
      ],
    );
  }
}
