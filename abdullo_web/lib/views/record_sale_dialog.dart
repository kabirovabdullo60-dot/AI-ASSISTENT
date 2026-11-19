import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/utils/format.dart';
import '../models/sale_model.dart';
import 'sale_entry_form_view.dart';
import '../core/motion/app_dialog.dart';

/// Record a sale (dashboard) or edit one (sales table) — the same form as on the Sales page.
class RecordSaleDialog extends StatelessWidget {
  const RecordSaleDialog({super.key, this.sale});

  final SaleModel? sale;

  static Future<void> show(BuildContext context, {SaleModel? sale}) => showAppDialog<void>(
    context: context,
    builder: (_) => RecordSaleDialog(sale: sale),
  );

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
            sale: sale,
            onSaved: () {
              Navigator.of(context).pop();
              if (sale == null) {
                messenger.showSnackBar(SnackBar(content: Text(tr.saleRecorded(formatDate(DateTime.now())))));
              }
            },
          ),
        ),
      ),
    );
  }
}
