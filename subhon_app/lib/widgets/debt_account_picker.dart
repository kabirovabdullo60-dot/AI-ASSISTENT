import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/money_account_model.dart';
import 'app_picker_field.dart';
import 'options_sheet.dart';

/// "Записать в счёт": which personal account the debt's money goes from or
/// to, or "Не записывать" (`null`).
class DebtAccountPicker extends StatelessWidget {
  const DebtAccountPicker({
    required this.accounts,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<MoneyAccountModel> accounts;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = accounts.where((a) => a.id == value).firstOrNull;
    return AppPickerField(
      label: l10n.debtAccount,
      value: account?.name ?? l10n.debtNoAccount,
      leading: const Icon(Icons.account_balance_wallet_outlined),
      onTap: () async {
        final picked = await showOptionsSheet<String>(
          context,
          title: l10n.debtAccount,
          selected: value ?? '',
          options: [
            for (final a in accounts) (a.id, a.name),
            ('', l10n.debtNoAccount),
          ],
        );
        if (picked != null) onChanged(picked.isEmpty ? null : picked);
      },
    );
  }
}
