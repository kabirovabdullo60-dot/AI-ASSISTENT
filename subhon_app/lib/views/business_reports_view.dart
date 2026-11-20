import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_row.dart';
import 'reports_view.dart';
import 'statements_view.dart';

/// The business's reports in one place: profit and the stores compared,
/// statements in Excel, and the history of changes.
class BusinessReportsView extends StatelessWidget {
  const BusinessReportsView({required this.onOpenHistory, super.key});

  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open(Widget page) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.insights_outlined,
                title: l10n.reportProfit,
                hint: l10n.reportsProfitHint,
                onTap: () => open(const ReportsView()),
              ),
              SettingsRow(
                icon: Icons.description_outlined,
                title: l10n.stmtTitle,
                hint: l10n.moreStatementsHint,
                onTap: () => open(const StatementsView()),
              ),
              SettingsRow(
                icon: Icons.history_rounded,
                title: l10n.activityHistory,
                hint: l10n.reportsHistoryHint,
                onTap: onOpenHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
