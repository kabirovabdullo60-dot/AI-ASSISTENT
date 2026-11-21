import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import 'app_button.dart';
import 'app_feedback.dart';
import 'app_inline_message.dart';
import 'app_text_field.dart';

/// The sheet that sets a sales target: the amount (the [current] one
/// filled in) and "Сохранить". [onSave] sends it and returns the error, if
/// any; the sheet closes on success.
class TargetAmountSheet extends StatefulWidget {
  const TargetAmountSheet({
    required this.hint,
    required this.onSave,
    this.current,
    super.key,
  });

  /// Who the target is for (the whole business or one store).
  final String hint;
  final Future<Object?> Function(double amount) onSave;
  final double? current;

  @override
  State<TargetAmountSheet> createState() => _TargetAmountSheetState();
}

class _TargetAmountSheetState extends State<TargetAmountSheet> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.current?.toStringAsFixed(2) ?? '',
  );
  bool _saving = false;
  Object? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.targetSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSave(Validators.parseAmount(_amount.text)!);
    if (!mounted) return;
    if (error == null) {
      feedback.showSuccess(saved);
      navigator.pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.hint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              hint: '0,00',
              suffix: const Text('TJS'),
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
              onSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppInlineMessage(
                type: InlineMessageType.error,
                message: errorText(l10n, _error!),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.commonSave,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
