import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../core/utils/local_date.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import '../viewmodels/sale_form_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/options_sheet.dart';

/// `POST /api/sales`, or `PUT` / `DELETE /api/sales/{id}` for [initial].
/// Pops `true` when something was saved.
class SaleFormView extends StatelessWidget {
  const SaleFormView({this.initial, super.key});

  final SaleModel? initial;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => SaleFormViewModel(
      context.read<SalesService>(),
      context.read<StoreService>(),
      initial: initial,
    )..loadStores(),
    child: _SaleForm(initial: initial),
  );
}

class _SaleForm extends StatefulWidget {
  const _SaleForm({this.initial});

  final SaleModel? initial;

  @override
  State<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<_SaleForm> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.initial == null
        ? ''
        : widget.initial!.amount.toStringAsFixed(2),
  );
  late final _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );
  late String? _storeId = widget.initial?.storeId;
  late DateTime _date = widget.initial?.saleDate ?? today();
  bool _storeMissing = false;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickStore(SaleFormViewModel vm) async {
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(SaleFormViewModel vm) async {
    final valid = _form.currentState?.validate() ?? false;
    setState(() => _storeMissing = _storeId == null);
    if (!valid || _storeId == null) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final l10n = context.l10n;
    final ok = await vm.save(
      storeId: _storeId!,
      amount: Validators.parseAmount(_amount.text)!,
      saleDate: _date,
      description: _description.text,
    );
    if (ok) {
      feedback.showSuccess(vm.isEdit ? l10n.saleUpdated : l10n.saleSaved);
      navigator.pop(true);
    }
  }

  Future<void> _delete(SaleFormViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.saleDeleteTitle,
      message: l10n.saleDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    if (await vm.delete()) {
      feedback.showSuccess(l10n.saleDeleted);
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<SaleFormViewModel>();
    final storeName = vm.stores
        .where((s) => s.id == _storeId)
        .map((s) => s.name)
        .firstOrNull;
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isEdit ? l10n.saleEditTitle : l10n.saleNewTitle),
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
              label: l10n.fieldStore,
              value: storeName ?? widget.initial?.storeName,
              placeholder: vm.storesLoading
                  ? l10n.commonLoading
                  : l10n.fieldChooseStore,
              leading: const Icon(Icons.storefront_outlined),
              errorText: _storeMissing
                  ? l10n.validationRequired
                  : vm.storesError == null
                  ? null
                  : errorText(l10n, vm.storesError!),
              helper:
                  !vm.storesLoading &&
                      vm.storesError == null &&
                      vm.stores.isEmpty
                  ? l10n.saleNoStores
                  : null,
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
