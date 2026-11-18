import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/store_model.dart';
import '../models/store_status.dart';
import '../services/store_service.dart';
import '../viewmodels/store_form_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';

/// `POST /api/stores`, or `PUT /api/stores/{id}` for [initial].
/// Pops `true` when saved.
class StoreFormView extends StatelessWidget {
  const StoreFormView({this.initial, super.key});

  final StoreModel? initial;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        StoreFormViewModel(context.read<StoreService>(), initial: initial),
    child: _StoreForm(initial: initial),
  );
}

class _StoreForm extends StatefulWidget {
  const _StoreForm({this.initial});

  final StoreModel? initial;

  @override
  State<_StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends State<_StoreForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late StoreStatus _status = widget.initial?.status ?? StoreStatus.active;

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(StoreFormViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final l10n = context.l10n;
    final ok = await vm.save(
      name: _name.text,
      address: _address.text,
      phone: _phone.text,
      description: _description.text,
      status: _status,
    );
    if (ok) {
      feedback.showSuccess(l10n.storeSaved);
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<StoreFormViewModel>();
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isEdit ? l10n.storeEditTitle : l10n.storeNewTitle),
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
              label: l10n.fieldStoreName,
              maxLength: 150,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _address,
              label: l10n.fieldAddress,
              hint: l10n.fieldOptional,
              maxLength: 255,
              textInputAction: TextInputAction.next,
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
            AppTextField(
              controller: _description,
              label: l10n.fieldDescription,
              hint: l10n.fieldOptional,
              maxLines: 3,
              maxLength: 1000,
            ),
            gap,
            Text(
              l10n.fieldStatus,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<StoreStatus>(
              segments: [
                ButtonSegment(
                  value: StoreStatus.active,
                  label: Text(l10n.statusActive),
                ),
                ButtonSegment(
                  value: StoreStatus.inactive,
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
