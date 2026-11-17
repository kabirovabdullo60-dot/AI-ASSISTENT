import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/utils/format.dart';
import 'sale_entry_form_view.dart';

/// "Record Sale" from the dashboard: the same form as on the Sales page, in a dialog.
class RecordSaleDialog extends StatelessWidget {
  const RecordSaleDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const RecordSaleDialog());

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SaleEntryFormView(
            onSaved: () {
              Navigator.of(context).pop();
              messenger.showSnackBar(SnackBar(content: Text(tr.saleRecorded(formatDate(DateTime.now())))));
            },
          ),
        ),
      ),
    );
  }
}
