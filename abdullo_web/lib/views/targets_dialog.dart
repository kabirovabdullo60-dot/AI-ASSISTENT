import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../models/dashboard_model.dart';
import '../viewmodels/dashboard_view_model.dart';

/// Business-wide weekly + monthly sales targets → PUT /api/targets.
class TargetsDialog extends StatefulWidget {
  const TargetsDialog({super.key, required this.dashboard});

  final DashboardModel dashboard;

  static Future<void> show(BuildContext context, DashboardModel d) =>
      showDialog<void>(context: context, builder: (_) => TargetsDialog(dashboard: d));

  @override
  State<TargetsDialog> createState() => _TargetsDialogState();
}

class _TargetsDialogState extends State<TargetsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _week = TextEditingController(text: widget.dashboard.weekTarget?.toStringAsFixed(2) ?? '');
  late final _month = TextEditingController(text: widget.dashboard.monthTarget?.toStringAsFixed(2) ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _week.dispose();
    _month.dispose();
    super.dispose();
  }

  double? _value(TextEditingController c) => double.tryParse(c.text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    final error = await context.read<DashboardViewModel>().saveTargets(week: _value(_week), month: _value(_month));
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) navigator.pop();
    showResult(context, error, success: tr.targetsSaved);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    Widget field(Key key, String label, TextEditingController c) => TextFormField(
      key: key,
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?'))],
      decoration: InputDecoration(labelText: label, suffixText: 'TJS'),
      validator: (v) {
        if ((v ?? '').trim().isEmpty) return null;
        final n = double.tryParse(v!.trim());
        return n == null || n <= 0 ? tr.enterAmount : null;
      },
    );

    return AlertDialog(
      title: Text(tr.setTargets),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(const Key('target-week'), tr.weeklyTarget, _week),
              const SizedBox(height: 12),
              field(const Key('target-month'), tr.monthlyTarget, _month),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: Text(tr.cancel)),
        FilledButton(
          key: const Key('targets-save'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(tr.save),
        ),
      ],
    );
  }
}
