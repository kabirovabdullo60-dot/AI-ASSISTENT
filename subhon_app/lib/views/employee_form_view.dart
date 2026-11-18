import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../core/utils/local_date.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/employee_model.dart';
import '../models/employee_status.dart';
import '../services/employee_service.dart';
import '../services/store_service.dart';
import '../viewmodels/employee_form_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/options_sheet.dart';
import 'employee_payroll_view.dart';

/// `POST /api/employees`, or `PUT` / `DELETE /api/employees/{id}` for
/// [initial]. Pops `true` when something was saved.
class EmployeeFormView extends StatelessWidget {
  const EmployeeFormView({this.initial, super.key});

  final EmployeeModel? initial;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => EmployeeFormViewModel(
      context.read<EmployeeService>(),
      context.read<StoreService>(),
      initial: initial,
    )..loadStores(),
    child: _EmployeeForm(initial: initial),
  );
}

class _EmployeeForm extends StatefulWidget {
  const _EmployeeForm({this.initial});

  final EmployeeModel? initial;

  @override
  State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.fullName);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _position = TextEditingController(text: widget.initial?.position);
  late final _salary = TextEditingController(
    text: widget.initial?.monthlySalary.toStringAsFixed(2),
  );
  late String? _storeId = widget.initial?.storeId;
  late DateTime _hiredAt = widget.initial?.hiredAt ?? today();
  late DateTime? _terminatedAt = widget.initial?.terminatedAt;
  late EmployeeStatus _status = widget.initial?.status ?? EmployeeStatus.active;
  bool _storeMissing = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _position, _salary]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStore(EmployeeFormViewModel vm) async {
    final picked = await showOptionsSheet<String>(
      context,
      title: context.l10n.fieldStore,
      selected: _storeId,
      options: [for (final s in vm.stores) (s.id, s.name)],
    );
    if (picked != null) {
      setState(() {
        _storeId = picked;
        _storeMissing = false;
      });
    }
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  Future<void> _save(EmployeeFormViewModel vm) async {
    final valid = _form.currentState?.validate() ?? false;
    setState(() => _storeMissing = _storeId == null);
    if (!valid || _storeId == null) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final l10n = context.l10n;
    final ok = await vm.save(
      fullName: _name.text,
      phone: _phone.text,
      position: _position.text,
      storeId: _storeId!,
      monthlySalary: Validators.parseAmount(_salary.text)!,
      hiredAt: _hiredAt,
      terminatedAt: _terminatedAt,
      status: _status,
    );
    if (ok) {
      feedback.showSuccess(l10n.employeeSaved);
      navigator.pop(true);
    }
  }

  Future<void> _delete(EmployeeFormViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.employeeDeleteTitle,
      message: l10n.employeeDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    if (await vm.delete()) {
      feedback.showSuccess(l10n.employeeDeleted);
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<EmployeeFormViewModel>();
    final storeName = vm.stores
        .where((s) => s.id == _storeId)
        .map((s) => s.name)
        .firstOrNull;
    const gap = SizedBox(height: AppSpacing.lg);
    final initial = widget.initial;
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isEdit ? l10n.employeeEditTitle : l10n.employeeNewTitle),
        actions: [
          if (initial != null) ...[
            IconButton(
              tooltip: l10n.payrollHistory,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EmployeePayrollView(employeeId: initial.id),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
            ),
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: vm.isSaving ? null : () => _delete(vm),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
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
            AppTextField(
              controller: _name,
              label: l10n.fieldFullName,
              maxLength: 150,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _position,
              label: l10n.fieldPosition,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _phone,
              label: l10n.fieldPhone,
              hint: l10n.fieldPhoneHint,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.phone(v, l10n),
            ),
            gap,
            AppPickerField(
              label: l10n.fieldStore,
              value: storeName ?? initial?.storeName,
              placeholder: vm.storesLoading
                  ? l10n.commonLoading
                  : l10n.fieldChooseStore,
              leading: const Icon(Icons.storefront_outlined),
              errorText: _storeMissing
                  ? l10n.validationRequired
                  : vm.storesError == null
                  ? null
                  : errorText(l10n, vm.storesError!),
              enabled: !vm.storesLoading && vm.stores.isNotEmpty,
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
              controller: _salary,
              label: l10n.fieldMonthlySalary,
              hint: '0,00',
              suffix: const Text('TJS'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            gap,
            AppPickerField(
              label: l10n.fieldHiredAt,
              value: context.formatDate(_hiredAt),
              leading: const Icon(Icons.event_outlined),
              onTap: () async {
                final picked = await _pickDate(_hiredAt);
                if (picked != null) setState(() => _hiredAt = picked);
              },
            ),
            gap,
            AppPickerField(
              label: l10n.fieldTerminatedAt,
              value: _terminatedAt == null
                  ? null
                  : context.formatDate(_terminatedAt!),
              placeholder: l10n.fieldOptional,
              leading: const Icon(Icons.event_busy_outlined),
              onTap: () async {
                final picked = await _pickDate(_terminatedAt ?? today());
                if (picked != null) setState(() => _terminatedAt = picked);
              },
            ),
            if (_terminatedAt != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _terminatedAt = null),
                  child: Text(l10n.commonClear),
                ),
              ),
            gap,
            Text(
              l10n.fieldStatus,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<EmployeeStatus>(
              segments: [
                ButtonSegment(
                  value: EmployeeStatus.active,
                  label: Text(l10n.statusActive),
                ),
                ButtonSegment(
                  value: EmployeeStatus.inactive,
                  label: Text(l10n.statusInactive),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
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
