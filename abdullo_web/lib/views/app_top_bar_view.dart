import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/app_language.dart';
import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/status_badge.dart';

/// White bar above every page: business, search, API status, language, notifications, user.
class AppTopBarView extends StatelessWidget {
  const AppTopBarView({super.key, this.compact = false});

  /// Phone layout (two rows).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        color: AppColors.card,
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 10),
        child: const Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: _BusinessChip()),
                ),
                _LanguageButton(),
                _NotificationsButton(),
                _UserMenu(showName: false),
              ],
            ),
            SizedBox(height: 8),
            Padding(padding: EdgeInsets.only(right: 4), child: _SearchField()),
          ],
        ),
      );
    }

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Flexible(
              flex: 2,
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 260), child: const _BusinessChip()),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: const _SearchField()),
              ),
            ),
            const SizedBox(width: 12),
            if (constraints.maxWidth >= 1000) ...[
              const Flexible(flex: 2, child: _ApiStatus()),
              const SizedBox(width: 8),
            ],
            const _LanguageButton(),
            const _NotificationsButton(),
            const SizedBox(width: 6),
            _UserMenu(showName: constraints.maxWidth >= 860),
          ],
        ),
      ),
    );
  }
}

class _BusinessChip extends StatelessWidget {
  const _BusinessChip();

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthViewModel, String>((a) => a.user?.businessName ?? '');
    return Container(
      key: const Key('business-chip'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, size: 16, color: AppColors.navy),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('global-search'),
      onChanged: context.read<HomeViewModel>().setQuery,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: context.l10n.searchHint,
        prefixIcon: const Icon(Icons.search, size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

class _ApiStatus extends StatelessWidget {
  const _ApiStatus();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final online = context.select<DashboardViewModel, bool?>((d) => d.apiOnline);
    if (online == null) return const SizedBox.shrink();
    return Tooltip(
      message: ApiConstants.baseUrl,
      child: StatusBadge(
        online ? '${tr.apiOnline} (/api)' : tr.apiOffline,
        tone: online ? BadgeTone.positive : BadgeTone.negative,
        dot: true,
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    return PopupMenuButton<AppLanguage>(
      key: const Key('language-menu'),
      tooltip: context.l10n.language,
      initialValue: settings.language,
      onSelected: settings.setLanguage,
      itemBuilder: (_) => [
        for (final l in AppLanguage.values)
          PopupMenuItem(value: l, key: Key('language-${l.name}'), child: Text(l.nativeName)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 18, color: AppColors.navy),
            const SizedBox(width: 4),
            Text(settings.language.short, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final pending = context.select<PayrollViewModel, int>((p) => p.isCurrentMonth ? p.pendingCount : 0);
    final recent = context.watch<DashboardViewModel>().activity('').take(4).toList();

    return PopupMenuButton<AppSection>(
      key: const Key('notifications'),
      tooltip: tr.notifications,
      onSelected: context.read<HomeViewModel>().select,
      icon: Badge(
        isLabelVisible: pending > 0,
        backgroundColor: AppColors.orange,
        label: Text('$pending'),
        child: const Icon(Icons.notifications_none, color: AppColors.navy),
      ),
      itemBuilder: (_) => [
        if (pending > 0)
          PopupMenuItem(
            value: AppSection.salaries,
            child: Text(
              tr.salariesWaiting(pending),
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.orange),
            ),
          ),
        for (final a in recent)
          PopupMenuItem(
            value: switch (a.type) {
              ActivityType.sale => AppSection.sales,
              ActivityType.payroll => AppSection.salaries,
              ActivityType.store => AppSection.stores,
              ActivityType.employee => AppSection.employees,
              ActivityType.profile => AppSection.profile,
            },
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      '${tr.activityType(a.type)}: ${a.title}',
                      if (a.action != null) tr.activityAction(a.action!),
                      if (a.amount != null) '${formatAmount(a.amount!.abs())} TJS',
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(formatTimeAgo(a.time), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        if (pending == 0 && recent.isEmpty) PopupMenuItem(enabled: false, child: Text(tr.noNotifications)),
      ],
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.showName});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final user = context.select<AuthViewModel, ({String name, String email})?>(
      (a) => a.user == null ? null : (name: a.user!.fullName, email: a.user!.email),
    );
    final name = user?.name ?? '…';

    return PopupMenuButton<String>(
      key: const Key('user-chip'),
      tooltip: name,
      onSelected: (v) {
        if (v == 'profile') context.read<HomeViewModel>().select(AppSection.profile);
        if (v == 'logout') context.read<AuthViewModel>().logout();
      },
      itemBuilder: (_) => [
        PopupMenuItem(enabled: false, child: Text(tr.signedInAs(user?.email ?? ''))),
        PopupMenuItem(value: 'profile', child: Text(tr.navProfile)),
        PopupMenuItem(value: 'logout', key: const Key('logout'), child: Text(tr.signOut)),
      ],
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.orangeSoft,
              child: Text(
                initials(name),
                style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            if (showName && user != null) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
