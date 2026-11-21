import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_language.dart';
import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/voice_mic_button.dart';

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
                VoiceMicButton(size: 36),
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

    // Desktop / tablet: no bar chrome. Search on the left on the canvas's edge, tools on the right;
    // the page's own title (the h1) sits under it, so no greeting here.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 20, 0),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: const _SearchField()),
              ),
            ),
            const SizedBox(width: 12),
            const VoiceMicButton(),
            const _LanguageButton(),
            const _NotificationsButton(),
            const SizedBox(width: 6),
            _UserMenu(showName: constraints.maxWidth >= 1100),
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
          Icon(Icons.storefront_outlined, size: 16, color: AppColors.ink),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        fillColor: AppColors.card,
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
            Icon(Icons.translate, size: 18, color: AppColors.ink),
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
    final vm = context.watch<NotificationsViewModel>();
    final recent = context.watch<DashboardViewModel>().activity('').take(3).toList();

    String text(NotificationModel n) => switch (n.kind) {
      NotificationKind.unpaidSalaries => tr.noticeUnpaid(n.count, formatAmount(n.amount ?? 0)),
      NotificationKind.salaryOverdue => tr.noticeOverdue(n.count, formatAmount(n.amount ?? 0)),
      NotificationKind.storeNoSalesToday => tr.noticeNoSales(n.storeName ?? ''),
    };

    return PopupMenuButton<AppSection>(
      key: const Key('notifications'),
      tooltip: tr.notifications,
      onOpened: () {
        vm.load().then((_) => vm.markAllRead());
      },
      onSelected: context.read<HomeViewModel>().select,
      icon: Badge(
        key: const Key('notifications-badge'),
        isLabelVisible: vm.unreadCount > 0,
        backgroundColor: AppColors.red,
        textColor: Colors.white,
        label: Text('${vm.unreadCount}'),
        child: Icon(Icons.notifications_none, color: AppColors.ink),
      ),
      itemBuilder: (_) => [
        for (final n in vm.items)
          PopupMenuItem(
            value: switch (n.link) {
              NotificationLink.stores => AppSection.stores,
              NotificationLink.sales => AppSection.sales,
              NotificationLink.payroll => AppSection.salaries,
            },
            child: SizedBox(
              width: 280,
              child: Row(
                children: [
                  Icon(
                    n.warning ? Icons.warning_amber_rounded : Icons.info_outline,
                    size: 18,
                    color: n.warning ? AppColors.red : AppColors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text(n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: n.read ? FontWeight.w400 : FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (vm.items.isNotEmpty && recent.isNotEmpty) const PopupMenuDivider(),
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
                  Text(formatTimeAgo(a.time), style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        if (vm.items.isEmpty && recent.isEmpty) PopupMenuItem(enabled: false, child: Text(tr.noNotifications)),
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
                style: TextStyle(color: AppColors.accentText, fontWeight: FontWeight.w700, fontSize: 13),
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
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
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
