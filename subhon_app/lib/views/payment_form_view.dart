import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/utils/local_date.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/monthly_payroll_row_model.dart';
import '../models/payroll_status.dart';
import '../models/salary_payment_method.dart';
import '../services/payroll_service.dart';
import '../viewmodels/payment_form_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/figure_card.dart';
import '../widgets/options_sheet.dart';
import '../widgets/payroll_status_badge.dart';
import 'employee_payroll_view.dart';

/// `POST /api/payroll`: a salary payment for [row]'s employee and month.
/// The remaining amount is suggested. Pops `true` when paid.
class PaymentFormView extends StatelessWidget {
  const PaymentFormView({
    required this.row,
    required this.month,
    required this.year,
    super.key,
  });

  final MonthlyPayrollRowModel row;
  final int month;
  final int year;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => PaymentFormViewModel(context.read<PayrollService>()),
    child: _PaymentForm(row: row, month: month, year: year),
  );
}

class _PaymentForm extends StatefulWidget {
  const _PaymentForm({
    required this.row,
    required this.month,
    required this.year,
  });

  final MonthlyPayrollRowModel row;
  final int month;
  final int year;

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.row.remainingAmount > 0
        ? widget.row.remainingAmount.toStringAsFixed(2)
        : '',
  );
  final _note = TextEditingController();
  SalaryPaymentMethod? _method;
  DateTime _date = today();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pay(PaymentFormViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final l10n = context.l10n;
    final ok = await vm.pay(
      employeeId: widget.row.employeeId,
      month: widget.month,
      year: widget.year,
      amount: Validators.parseAmount(_amount.text)!,
      paymentDate: _date,
      note: _note.text,
      method: _method,
    );
    if (ok) {
      feedback.showSuccess(l10n.paymentSaved);
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<PaymentFormViewModel>();
    final row = widget.row;
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentTitle),
        actions: [
          IconButton(
            tooltip: l10n.payrollHistory,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EmployeePayrollView(employeeId: row.employeeId),
              ),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
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
            Text(row.fullName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${row.position} · ${row.storeName} · '
                    '${context.monthYear(widget.month, widget.year)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                PayrollStatusBadge(status: row.status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FigureCard(
                    label: l10n.payrollDue,
                    value: context.money(row.dueAmount),
                    caption: l10n.payrollWorkedDays(row.workedDays),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FigureCard(
                    label: l10n.payrollRemaining,
                    value: context.money(row.remainingAmount),
                    valueColor: row.remainingAmount > 0 ? p.error : p.success,
                    caption: l10n.payrollPaidSoFar(
                      context.money(row.paidAmount),
                    ),
                  ),
                ),
              ],
            ),
            gap,
            if (row.status == PayrollStatus.paid) ...[
              AppInlineMessage(message: l10n.paymentAlreadyPaid),
              gap,
            ],
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
              label: l10n.fieldPaymentDate,
              value: context.formatDate(_date),
              leading: const Icon(Icons.event_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: today(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            gap,
            AppPickerField(
              label: l10n.fieldSalaryMethod,
              value: switch (_method) {
                SalaryPaymentMethod.bankTransfer => l10n.salaryMethodBank,
                SalaryPaymentMethod.cash => l10n.salaryMethodCash,
                null => l10n.paymentNotSet,
              },
              leading: const Icon(Icons.account_balance_wallet_outlined),
              onTap: () async {
                final picked = await showOptionsSheet<String>(
                  context,
                  title: l10n.fieldSalaryMethod,
                  selected: _method?.json ?? '',
                  options: [
                    ('', l10n.paymentNotSet),
                    (
                      SalaryPaymentMethod.bankTransfer.json,
                      l10n.salaryMethodBank,
                    ),
                    (SalaryPaymentMethod.cash.json, l10n.salaryMethodCash),
                  ],
                );
                if (picked != null) {
                  setState(
                    () => _method = SalaryPaymentMethod.fromJson(picked),
                  );
                }
              },
            ),
            gap,
            AppTextField(
              controller: _note,
              label: l10n.fieldNote,
              hint: l10n.fieldOptional,
              maxLines: 2,
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
              label: l10n.paymentSubmit,
              icon: Icons.payments_outlined,
              isLoading: vm.isSaving,
              onPressed: () => _pay(vm),
            ),
          ],
        ),
      ),
    );
  }
}
