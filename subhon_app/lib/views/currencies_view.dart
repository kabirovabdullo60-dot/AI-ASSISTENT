import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/app_empty_view.dart';

/// The "Валюты" tab: empty for now.
class CurrenciesView extends StatelessWidget {
  const CurrenciesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCurrencies)),
      body: AppEmptyView(
        icon: Icons.currency_exchange_rounded,
        title: l10n.navCurrencies,
        message: l10n.currenciesSoon,
      ),
    );
  }
}
