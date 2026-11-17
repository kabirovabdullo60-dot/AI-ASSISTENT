import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../models/store_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/stores_view_model.dart';

/// Add / edit a store → POST /stores or PUT /stores/{id}.
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
  static const _regions = ['Dushanbe', 'Sughd', 'Khatlon', 'GBAO', 'RRS'];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.store?.name);
  late final _type = TextEditingController(text: widget.store?.type ?? 'Branch');
  late final _address = TextEditingController(text: widget.store?.address);
  late final _city = TextEditingController(text: widget.store?.city ?? 'Dushanbe');
  late final _phone = TextEditingController(text: widget.store?.phone ?? '+992 ');
  late final _hours = TextEditingController(text: widget.store?.openingHours ?? 'Mon-Sun: 08:00 - 22:00');
  late String _region = _regions.contains(widget.store?.region) ? widget.store!.region : _regions.first;
  late bool _active = widget.store?.isActive ?? true;

  bool get _isNew => widget.store == null;

  @override
  void dispose() {
    for (final c in [_name, _type, _address, _city, _phone, _hours]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final base =
        widget.store ?? const StoreModel(id: '', name: '', type: '', address: '', city: '', region: '', phone: '');
    final store = base.copyWith(
      name: _name.text.trim(),
      type: _type.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      region: _region,
      phone: _phone.text.trim(),
      openingHours: _hours.text.trim(),
      isActive: _active,
    );
    final tr = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final ok = await context.read<StoresViewModel>().save(store, isNew: _isNew);
    if (!mounted) return;
    if (ok) {
      dashboard.load();
      navigator.pop();
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? (_isNew ? tr.storeAdded(store.name) : tr.storeSaved(store.name)) : tr.storeSaveFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final saving = context.select<StoresViewModel, bool>((s) => s.isSaving);
    String? required(String? v) => (v == null || v.trim().isEmpty) ? tr.required : null;

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
                  decoration: InputDecoration(labelText: tr.storeName),
                  validator: required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _type,
                  decoration: InputDecoration(labelText: tr.storeType),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('store-address'),
                  controller: _address,
                  decoration: InputDecoration(labelText: tr.address),
                  validator: required,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('store-city'),
                        controller: _city,
                        decoration: InputDecoration(labelText: tr.city),
                        validator: required,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _region,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: tr.region),
                        items: [for (final r in _regions) DropdownMenuItem(value: r, child: Text(r))],
                        onChanged: (v) => setState(() => _region = v ?? _region),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('store-phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: tr.phone),
                  validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 9 ? tr.enterPhone : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hours,
                  decoration: InputDecoration(labelText: tr.operatingHours),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
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
