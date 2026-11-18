import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/status_badge.dart';

/// "New Daily Sales Record" → POST /api/sales; with [sale] it edits → PUT /api/sales/{id}.
/// Used on the Sales page and in the Record Sale / Edit dialogs.
class SaleEntryFormView extends StatefulWidget {
  const SaleEntryFormView({super.key, this.sale, this.onSaved});

  final SaleModel? sale;

  /// Called after a successful save (dialogs close themselves here).
  final VoidCallback? onSaved;

  @override
  State<SaleEntryFormView> createState() => _SaleEntryFormViewState();
}

class _SaleEntryFormViewState extends State<SaleEntryFormView> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(text: widget.sale == null ? '' : widget.sale!.amount.toStringAsFixed(2));
  late final _notes = TextEditingController(text: widget.sale?.description);
  late String? _storeId = widget.sale?.storeId;
  late DateTime _date = widget.sale?.saleDate ?? DateTime.now();

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
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(String? storeId) async {
    if (!_formKey.currentState!.validate() || storeId == null) return;
    final tr = context.l10n;
    final dashboard = context.read<DashboardViewModel>();
    final stores = context.read<StoresViewModel>();
    final sales = context.read<SalesViewModel>();
    final amount = double.parse(_amount.text.trim());
    final error = widget.sale == null
        ? await sales.recordSale(storeId: storeId, amount: amount, date: _date, description: _notes.text)
        : await sales.updateSale(widget.sale!, storeId: storeId, amount: amount, date: _date, description: _notes.text);
    if (!mounted) return;
    if (error != null) {
      showResult(context, error, success: '');
      return;
    }
    dashboard.load();
    stores.load();
    if (widget.sale == null) {
      _amount.clear();
      _notes.clear();
    } else {
      showResult(context, null, success: tr.saleUpdated);
    }
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final stores = context.watch<StoresViewModel>();
    final options = stores.ranked.where((s) => s.isActive || s.id == widget.sale?.storeId).toList();
    final saving = context.select<SalesViewModel, bool>((s) => s.isSaving);
    final storeId = options.any((s) => s.id == _storeId) ? _storeId : (options.isEmpty ? null : options.first.id);
    const label = TextStyle(fontWeight: FontWeight.w600, fontSize: 13);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(widget.sale == null ? Icons.add_circle_outline : Icons.edit_outlined, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.sale == null ? tr.newDailySale : tr.editSale,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(tr.posTerminal, tone: BadgeTone.info),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text(tr.selectStore, style: label)),
              Text(
                tr.activeBranches(stores.activeCount),
                style: const TextStyle(fontSize: 11.5, color: AppColors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (options.isEmpty)
            Text(tr.selectStoreFirst, style: const TextStyle(color: AppColors.red))
          else
            DropdownButtonFormField<String>(
              key: const Key('sale-store'),
              initialValue: storeId,
              isExpanded: true,
              items: [
                for (final s in options)
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
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?'))],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: tr.amountHint,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text('TJS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
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
          Text.rich(
            TextSpan(
              text: tr.notesLabel,
              style: label,
              children: [
                TextSpan(
                  text: tr.optional,
                  style: const TextStyle(fontWeight: FontWeight.w400),
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
            maxLength: 500,
            decoration: InputDecoration(hintText: tr.notesHint, counterText: ''),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('sale-save'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: saving || options.isEmpty ? null : () => _save(storeId),
            icon: saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              widget.sale == null ? tr.saveSaleRecord : tr.saveChanges,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              children: [
                const WidgetSpan(child: Icon(Icons.sync, size: 13, color: AppColors.green)),
                TextSpan(text: tr.syncsTo),
                const TextSpan(
                  text: ApiConstants.sales,
                  style: TextStyle(color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
