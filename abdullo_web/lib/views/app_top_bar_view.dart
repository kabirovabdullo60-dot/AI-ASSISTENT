import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/status_badge.dart';

/// White bar above every page: store filter, search, API status, notifications, user.
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
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: _StoreSelector()),
                ),
                const _NotificationsButton(),
                const _UserChip(showName: false),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(padding: EdgeInsets.only(right: 4), child: _SearchField()),
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
            const _StoreSelector(),
            const SizedBox(width: 14),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: const _SearchField(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (constraints.maxWidth >= 1000) ...[const _ApiStatus(), const SizedBox(width: 8)],
            const _NotificationsButton(),
            const SizedBox(width: 6),
            _UserChip(showName: constraints.maxWidth >= 860),
          ],
        ),
      ),
    );
  }
}

class _StoreSelector extends StatelessWidget {
  const _StoreSelector();

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<StoresViewModel>();
    final selected = context.select<DashboardViewModel, String?>((d) => d.selectedStoreId);
    final label = selected == null
        ? 'All Stores (${stores.activeCount} Active)'
        : stores.nameOf(selected) ?? 'Store';

    return PopupMenuButton<String>(
      key: const Key('store-selector'),
      tooltip: 'Choose store',
      initialValue: selected ?? '',
      onSelected: (id) {
        context.read<DashboardViewModel>().selectStore(id.isEmpty ? null : id);
        context.read<HomeViewModel>().select(AppSection.dashboard);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: '', child: Text('All stores')),
        for (final s in stores.ranked) PopupMenuItem(value: s.id, child: Text(s.name)),
      ],
      child: Container(
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
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.muted),
          ],
        ),
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
      decoration: const InputDecoration(
        hintText: 'Search transactions, stores, staff…',
        prefixIcon: Icon(Icons.search, size: 18),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

class _ApiStatus extends StatelessWidget {
  const _ApiStatus();

  @override
  Widget build(BuildContext context) {
    return ApiConstants.useMock
        ? const StatusBadge('Demo data · API not connected', tone: BadgeTone.warning, dot: true)
        : StatusBadge(
            'REST API (${Uri.parse(ApiConstants.baseUrl).path})',
            tone: BadgeTone.positive,
            dot: true,
          );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    final pending = context.select<PayrollViewModel, int>((p) => p.pendingCount);
    final recent = context.watch<DashboardViewModel>().activity('').take(3).toList();

    return PopupMenuButton<AppSection>(
      key: const Key('notifications'),
      tooltip: 'Notifications',
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
              '$pending salaries waiting to be paid',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.orange),
            ),
          ),
        for (final a in recent)
          PopupMenuItem(
            value: AppSection.dashboard,
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${a.text} ${a.highlight}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(formatTimeAgo(a.time), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        if (pending == 0 && recent.isEmpty)
          const PopupMenuItem(enabled: false, child: Text('No notifications')),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.showName});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    final profile = context.select<ProfileViewModel, ({String name, String role})?>(
      (p) => p.profile == null ? null : (name: p.profile!.name, role: p.profile!.role),
    );
    final name = profile?.name ?? '…';

    return InkWell(
      key: const Key('user-chip'),
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.read<HomeViewModel>().select(AppSection.profile),
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
            if (showName && profile != null) ...[
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(profile.role, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
