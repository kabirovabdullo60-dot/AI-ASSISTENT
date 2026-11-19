import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/utils/format.dart';
import '../models/employee_model.dart';
import '../models/store_model.dart' show cleanPhone;
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/employees_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../core/motion/app_dialog.dart';

/// Add / edit an employee → POST /api/employees or PUT /api/employees/{id}.
class EmployeeFormDialog extends StatefulWidget {
  const EmployeeFormDialog({super.key, this.employee});

  final EmployeeModel? employee;

  static Future<void> show(BuildContext context, {EmployeeModel? employee}) => showAppDialog<void>(
    context: context,
    builder: (_) => EmployeeFormDialog(employee: employee),
  );

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.employee?.fullName);
  late final _phone = TextEditingController(text: widget.employee?.phone);
  late final _position = TextEditingController(text: widget.employee?.position);
  late final _salary = TextEditingController(
    text: widget.employee == null ? '' : widget.employee!.monthlySalary.toStringAsFixed(2),
  );
  late String? _storeId = widget.employee?.storeId;
  late DateTime _hiredAt = widget.employee?.hiredAt ?? DateTime.now();
  late DateTime? _terminatedAt = widget.employee?.terminatedAt;
  late bool _active = widget.employee?.isActive ?? true;

  bool get _isNew => widget.employee == null;

  @override
  void dispose() {
    for (final c in [_name, _phone, _position, _salary]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  Future<void> _save(String? storeId) async {
    if (!_formKey.currentState!.validate() || storeId == null) return;
    final tr = context.l10n;
    final e = EmployeeModel(
      id: widget.employee?.id ?? '',
      fullName: _name.text.trim(),
      phone: _phone.text,
      position: _position.text.trim(),
      storeId: storeId,
      storeName: '',
      monthlySalary: double.parse(_salary.text.trim()),
      hiredAt: _hiredAt,
      terminatedAt: _terminatedAt,
      isActive: _active,
    );
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final payroll = context.read<PayrollViewModel>();
    final stores = context.read<StoresViewModel>();
    final error = await context.read<EmployeesViewModel>().save(e, isNew: _isNew);
    if (!mounted) return;
    if (error == null) {
      dashboard.load();
      payroll.load();
      stores.load();
      navigator.pop();
    }
    showResult(context, error, success: tr.employeeSaved(e.fullName));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final saving = context.select<EmployeesViewModel, bool>((v) => v.isSaving);
    final stores = context.watch<StoresViewModel>().ranked;
    final storeId = stores.any((s) => s.id == _storeId) ? _storeId : (stores.isEmpty ? null : stores.first.id);

    Widget dateField(
      Key key,
      String label,
      DateTime? value,
      ValueChanged<DateTime?> onChanged, {
      bool clearable = false,
    }) => InkWell(
      key: key,
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final d = await _pick(value ?? DateTime.now());
        if (d != null) setState(() => onChanged(d));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: clearable && value != null
              ? IconButton(
                  tooltip: tr.clearDate,
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => onChanged(null)),
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(value == null ? '—' : formatNumericDate(value)),
      ),
    );

    return AlertDialog(
      title: Text(_isNew ? tr.addEmployee : tr.editEmployee),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('employee-name'),
                  controller: _name,
                  maxLength: 150,
                  decoration: InputDecoration(labelText: tr.fullName, counterText: ''),
                  validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('employee-position'),
                  controller: _position,
                  maxLength: 100,
                  decoration: InputDecoration(labelText: tr.position, counterText: ''),
                  validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
                ),
                const SizedBox(height: 12),
                if (stores.isEmpty)
                  Text(tr.selectStoreFirst)
                else
                  DropdownButtonFormField<String>(
                    key: const Key('employee-store'),
                    initialValue: storeId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: tr.store),
                    items: [
                      for (final s in stores)
                        DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() => _storeId = v),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('employee-salary'),
                  controller: _salary,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?'))],
                  decoration: InputDecoration(labelText: tr.monthlySalary),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    return n == null || n < 0 ? tr.enterAmount : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('employee-phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: tr.phoneOptional, hintText: '+992901234567'),
                  validator: (v) {
                    final s = cleanPhone(v);
                    return s == null || RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s) ? null : tr.invalidPhone;
                  },
                ),
                const SizedBox(height: 12),
                dateField(const Key('employee-hired'), tr.hiredAt, _hiredAt, (d) => _hiredAt = d ?? _hiredAt),
                const SizedBox(height: 12),
                dateField(
                  const Key('employee-terminated'),
                  tr.terminatedAt,
                  _terminatedAt,
                  (d) => _terminatedAt = d,
                  clearable: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.employeeActive),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: Text(tr.cancel)),
        FilledButton(
          key: const Key('employee-save'),
          onPressed: saving || stores.isEmpty ? null : () => _save(storeId),
          child: saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isNew ? tr.addEmployee : tr.save),
        ),
      ],
    );
  }
}
