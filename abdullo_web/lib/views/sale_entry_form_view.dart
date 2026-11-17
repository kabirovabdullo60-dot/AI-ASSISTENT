import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/status_badge.dart';

/// "New Daily Sales Record" form → POST /sales. Used on the Sales page and in the Record Sale dialog.
class SaleEntryFormView extends StatefulWidget {
  const SaleEntryFormView({super.key, this.onSaved});

  /// Called after a successful save (the dialog closes itself here).
  final VoidCallback? onSaved;

  @override
  State<SaleEntryFormView> createState() => _SaleEntryFormViewState();
}

class _SaleEntryFormViewState extends State<SaleEntryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String? _storeId;
  DateTime _date = DateTime.now();
  BalanceSplit _split = BalanceSplit.balanced;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(String? storeId) async {
    if (!_formKey.currentState!.validate() || storeId == null) return;
    final tr = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final stores = context.read<StoresViewModel>();
    final ok = await context.read<SalesViewModel>().recordSale(
      storeId: storeId,
      amount: double.parse(_amount.text.trim()),
      date: _date,
      split: _split,
      notes: _notes.text,
    );
    if (!mounted) return;
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(tr.saleFailed)));
      return;
    }
    dashboard.load();
    stores.load();
    _amount.clear();
    _notes.clear();
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final stores = context.watch<StoresViewModel>();
    final active = stores.ranked.where((s) => s.isActive).toList();
    final saving = context.select<SalesViewModel, bool>((s) => s.isSaving);
    final storeId = active.any((s) => s.id == _storeId) ? _storeId : (active.isEmpty ? null : active.first.id);
    const label = TextStyle(fontWeight: FontWeight.w600, fontSize: 13);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(tr.newDailySale, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              StatusBadge(tr.posTerminal, tone: BadgeTone.info),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text(tr.selectStore, style: label)),
              Text(
                tr.activeBranches(active.length),
                style: const TextStyle(fontSize: 11.5, color: AppColors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: const Key('sale-store'),
            initialValue: storeId,
            isExpanded: true,
            items: [
              for (final s in active)
                DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _storeId = v),
          ),
          const SizedBox(height: 14),
          Text(tr.dailySalesAmount, style: label),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('sale-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: tr.amountHint,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text('TJS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0),
              helperText: tr.amountHelper,
            ),
            validator: (v) {
              final n = double.tryParse(v?.trim() ?? '');
              return n == null || n <= 0 ? tr.enterAmount : null;
            },
          ),
          const SizedBox(height: 14),
          Text(tr.accountingDate, style: label),
          const SizedBox(height: 6),
          InkWell(
            key: const Key('sale-date'),
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
              child: Text(formatNumericDate(_date)),
            ),
          ),
          const SizedBox(height: 14),
          Text(tr.balanceSplit, style: label),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final s in BalanceSplit.values) ...[
                if (s.index > 0) const SizedBox(width: 6),
                Expanded(
                  child: Material(
                    color: s == _split ? AppColors.navy : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      key: Key('split-${s.name}'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _split = s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                        child: Text(
                          tr.split(s),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: s == _split ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: tr.notesLabel,
              style: label,
              children: [
                TextSpan(
                  text: tr.optional,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('sale-notes'),
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: tr.notesHint),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('sale-save'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: saving ? null : () => _save(storeId),
            icon: saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle_outline, size: 18),
            label: Text(tr.saveSaleRecord, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              children: [
                const WidgetSpan(child: Icon(Icons.sync, size: 13, color: AppColors.green)),
                TextSpan(text: tr.syncsTo),
                TextSpan(
                  text: ApiConstants.sales,
                  style: const TextStyle(fontFamily: 'monospace', color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
