import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_row.dart';
import 'chat_view.dart';
import 'employees_view.dart';
import 'expenses_view.dart';
import 'profile_view.dart';
import 'reports_view.dart';
import 'statements_view.dart';
import 'stores_view.dart';

/// "Ещё": stores, employees, reports, profile and settings, sign out.
class MoreView extends StatelessWidget {
  const MoreView({required this.onChanged, super.key});

  /// Data may have changed in a section: the tabs reload.
  final VoidCallback onChanged;

  Future<void> _open(BuildContext context, Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    onChanged();
  }

  Future<void> _signOut(BuildContext context) async {
    final l10n = context.l10n;
    final session = context.read<SessionViewModel>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.authSignOutConfirmTitle,
      message: l10n.authSignOutConfirmMessage,
      confirmLabel: l10n.authSignOut,
      destructive: true,
    );
    if (confirmed) await session.logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<SessionViewModel>().user;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          SectionHeader(title: user?.business.name ?? l10n.moreBusiness),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.storefront_outlined,
                title: l10n.navStores,
                hint: l10n.moreStoresHint,
                onTap: () => _open(context, const StoresView()),
              ),
              SettingsRow(
                icon: Icons.badge_outlined,
                title: l10n.navEmployees,
                hint: l10n.moreEmployeesHint,
                onTap: () => _open(context, const EmployeesView()),
              ),
              SettingsRow(
                icon: Icons.receipt_long_outlined,
                title: l10n.navExpenses,
                hint: l10n.moreExpensesHint,
                onTap: () => _open(context, const ExpensesView()),
              ),
              SettingsRow(
                icon: Icons.auto_awesome_outlined,
                title: l10n.assistantTitle,
                hint: l10n.moreAssistantHint,
                onTap: () => _open(context, const ChatView()),
              ),
              SettingsRow(
                icon: Icons.description_outlined,
                title: l10n.stmtTitle,
                hint: l10n.moreStatementsHint,
                onTap: () => _open(context, const StatementsView()),
              ),
              SettingsRow(
                icon: Icons.insights_outlined,
                title: l10n.navReports,
                hint: l10n.moreReportsHint,
                onTap: () => _open(context, const ReportsView()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: l10n.moreAccount),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.settings_rounded,
                title: l10n.navProfile,
                value: user?.email,
                onTap: () => _open(context, const ProfileView()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.authSignOut,
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.destructive,
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
