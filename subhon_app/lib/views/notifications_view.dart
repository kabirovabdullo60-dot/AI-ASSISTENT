import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/notification_text.dart';
import '../models/notification_kind.dart';
import '../models/notification_link.dart';
import '../viewmodels/notifications_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/async_state_view.dart';
import '../widgets/record_tile.dart';
import '../widgets/status_badge.dart';

/// Notifications (`GET /api/notifications`): overdue and unpaid salaries,
/// stores without sales today. Opening it marks everything as read
/// (`POST /api/notifications/read-all`); a tap opens the related screen.
class NotificationsView extends StatefulWidget {
  const NotificationsView({required this.onOpenLink, super.key});

  /// Opens the app screen of a notification (after this page closes).
  final ValueChanged<NotificationLink> onOpenLink;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // After the first frame: loading notifies listeners, which must not
    // happen while this page is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<NotificationsViewModel>();
      await vm.load();
      await vm.markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<NotificationsViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading && !vm.hasData,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          isEmpty: vm.items.isEmpty,
          empty: AppEmptyView(
            icon: Icons.notifications_none_rounded,
            title: l10n.notificationsTitle,
            message: l10n.notificationsEmpty,
          ),
          builder: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    for (final n in vm.items)
                      Builder(
                        builder: (context) {
                          final (title, body) = notificationText(
                            l10n,
                            n,
                            context.money,
                          );
                          return RecordTile(
                            icon: switch (n.kind) {
                              NotificationKind.storeNoSalesToday =>
                                Icons.storefront_outlined,
                              _ => Icons.payments_outlined,
                            },
                            iconColor: n.isWarning ? p.error : p.primary,
                            iconBackground: n.isWarning
                                ? p.errorLight
                                : p.primaryLight,
                            title: title,
                            subtitle: body,
                            badge: n.read
                                ? null
                                : StatusBadge(
                                    label: l10n.notificationsNew,
                                    color: p.primary,
                                    background: p.primaryLight,
                                  ),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onOpenLink(n.link);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
