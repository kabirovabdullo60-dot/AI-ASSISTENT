import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/market_service.dart';
import '../viewmodels/currencies_view_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_row.dart';
import 'business_reports_view.dart';
import 'chat_view.dart';
import 'currencies_view.dart';
import 'employees_view.dart';
import 'expenses_view.dart';
import 'money_accounts_view.dart';
import 'money_transactions_view.dart';
import 'profile_view.dart';
import 'recurring_payments_view.dart';
import 'savings_goals_view.dart';
import 'store_form_view.dart';
import 'stores_view.dart';

/// "Ещё": stores, employees, reports, profile and settings, sign out.
class MoreView extends StatelessWidget {
  const MoreView({
    required this.onChanged,
    required this.onOpenHistory,
    this.hasBusiness = true,
    super.key,
  });

  /// The business's history of changes (its view model lives in the shell).
  final VoidCallback onOpenHistory;

  /// Data may have changed in a section: the tabs reload.
  final VoidCallback onChanged;

  /// The business section shows once there is a store.
  final bool hasBusiness;

  Future<void> _openPersonal(BuildContext context, Widget page) {
    final vm = context.read<PersonalFinanceViewModel>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(value: vm, child: page),
      ),
    );
  }

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
          SectionHeader(title: l10n.morePersonal),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.pfAccounts,
                hint: l10n.pfAccountsHint,
                onTap: () => _openPersonal(context, const MoneyAccountsView()),
              ),
              SettingsRow(
                icon: Icons.receipt_long_outlined,
                title: l10n.pfOperations,
                hint: l10n.moreOperationsHint,
                onTap: () =>
                    _openPersonal(context, const MoneyTransactionsView()),
              ),
              SettingsRow(
                icon: Icons.event_repeat_rounded,
                title: l10n.pfRecurring,
                hint: l10n.pfRecurringHint,
                onTap: () =>
                    _openPersonal(context, const RecurringPaymentsView()),
              ),
              SettingsRow(
                icon: Icons.savings_outlined,
                title: l10n.goalTitle,
                hint: l10n.goalHint,
                onTap: () => _openPersonal(context, const SavingsGoalsView()),
              ),
              SettingsRow(
                icon: Icons.currency_exchange_rounded,
                title: l10n.navCurrencies,
                hint: l10n.moreCurrenciesHint,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChangeNotifierProvider(
                      create: (c) =>
                          CurrenciesViewModel(c.read<MarketService>())..load(),
                      child: const CurrenciesView(),
                    ),
                  ),
                ),
              ),
              SettingsRow(
                icon: Icons.auto_awesome_outlined,
                title: l10n.assistantTitle,
                hint: l10n.moreAssistantHint,
                onTap: () => _open(
                  context,
                  ChatView(
                    personalContext: context
                        .read<PersonalFinanceViewModel>()
                        .summary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: hasBusiness
                ? user?.business.name ?? l10n.moreBusiness
                : l10n.phMyBusiness,
          ),
          if (!hasBusiness)
            SettingsCard(
              children: [
                SettingsRow(
                  icon: Icons.add_business_outlined,
                  title: l10n.phAddStore,
                  hint: l10n.phStartBusinessMessage,
                  onTap: () => _open(context, const StoreFormView()),
                ),
              ],
            )
          else
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
                  icon: Icons.insights_outlined,
                  title: l10n.navReports,
                  hint: l10n.moreReportsAllHint,
                  onTap: () => _open(
                    context,
                    BusinessReportsView(onOpenHistory: onOpenHistory),
                  ),
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
