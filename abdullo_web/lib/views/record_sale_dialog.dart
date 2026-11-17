import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../viewmodels/stores_view_model.dart';

/// "Record Sale" form → POST /sales, then refreshes the dashboard.
class RecordSaleDialog extends StatefulWidget {
  const RecordSaleDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const RecordSaleDialog());

  @override
  State<RecordSaleDialog> createState() => _RecordSaleDialogState();
}

class _RecordSaleDialogState extends State<RecordSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String? _storeId;
  PaymentMethod _method = PaymentMethod.card;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(String? storeId) async {
    if (!_formKey.currentState!.validate() || storeId == null) return;
    final amount = double.parse(_amount.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();

    final ok = await context.read<SalesViewModel>().recordSale(
      storeId: storeId,
      amount: amount,
      method: _method,
    );
    if (!mounted) return;
    if (ok) {
      dashboard.load();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Sale recorded: ${formatAmount(amount)} TJS')));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Could not save the sale. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<StoresViewModel>().ranked;
    final saving = context.select<SalesViewModel, bool>((s) => s.isSaving);
    final storeId = _storeId ?? (stores.isEmpty ? null : stores.first.id);

    return AlertDialog(
      title: const Text('Record Sale'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                key: const Key('sale-store'),
                initialValue: storeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Store'),
                items: [
                  for (final s in stores)
                    DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _storeId = v),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('sale-amount'),
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Amount (TJS)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  return n == null || n <= 0 ? 'Enter an amount above 0' : null;
                },
              ),
              const SizedBox(height: 14),
              SegmentedButton<PaymentMethod>(
                showSelectedIcon: false,
                segments: [
                  for (final m in PaymentMethod.values) ButtonSegment(value: m, label: Text(m.label)),
                ],
                selected: {_method},
                onSelectionChanged: (s) => setState(() => _method = s.first),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          key: const Key('sale-save'),
          onPressed: saving ? null : () => _save(storeId),
          child: saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
