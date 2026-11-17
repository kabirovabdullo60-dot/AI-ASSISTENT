import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../models/store_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/stores_view_model.dart';

/// Add / edit a store → POST /api/stores or PUT /api/stores/{id}.
class StoreFormDialog extends StatefulWidget {
  const StoreFormDialog({super.key, this.store});

  /// `null` = new store.
  final StoreModel? store;

  static Future<void> show(BuildContext context, {StoreModel? store}) => showDialog<void>(
    context: context,
    builder: (_) => StoreFormDialog(store: store),
  );

  @override
  State<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.store?.name);
  late final _address = TextEditingController(text: widget.store?.address);
  late final _phone = TextEditingController(text: widget.store?.phone);
  late final _description = TextEditingController(text: widget.store?.description);
  late bool _active = widget.store?.isActive ?? true;

  bool get _isNew => widget.store == null;

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final store = StoreModel(
      id: widget.store?.id ?? '',
      name: _name.text.trim(),
      address: _address.text,
      phone: _phone.text,
      description: _description.text,
      isActive: _active,
    );
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<StoresViewModel>().save(store, isNew: _isNew);
    if (!mounted) return;
    if (error == null) {
      dashboard.load();
      navigator.pop();
    }
    showResult(context, error, success: _isNew ? tr.storeAdded(store.name) : tr.storeSaved(store.name));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final saving = context.select<StoresViewModel, bool>((s) => s.isSaving);

    return AlertDialog(
      title: Text(_isNew ? tr.addNewStore : tr.editStore),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('store-name'),
                  controller: _name,
                  maxLength: 150,
                  decoration: InputDecoration(labelText: tr.storeName, counterText: ''),
                  validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('store-address'),
                  controller: _address,
                  maxLength: 255,
                  decoration: InputDecoration(labelText: tr.address, counterText: ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('store-phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: tr.phoneOptional, hintText: '+992901234567'),
                  validator: (v) {
                    final s = cleanPhone(v);
                    return s == null || RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s) ? null : tr.invalidPhone;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('store-description'),
                  controller: _description,
                  maxLength: 1000,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: tr.description,
                    hintText: tr.storeDescriptionHint,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  key: const Key('store-active'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.storeOpen),
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
          key: const Key('store-save'),
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isNew ? tr.addStore : tr.save),
        ),
      ],
    );
  }
}
