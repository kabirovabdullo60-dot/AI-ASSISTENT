import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/activity_service.dart';
import '../viewmodels/activity_view_model.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/async_state_view.dart';
import '../widgets/load_more_button.dart';

/// The whole activity log (`GET /api/activity`), or one store's operations
/// log when [storeId] is given; newest first, page by page.
class ActivityView extends StatelessWidget {
  const ActivityView({this.storeId, this.title, super.key});

  final String? storeId;
  final String? title;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        ActivityViewModel(context.read<ActivityService>(), storeId: storeId)
          ..load(),
    child: _ActivityScreen(title: title),
  );
}

class _ActivityScreen extends StatelessWidget {
  const _ActivityScreen({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ActivityViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.activityTitle)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          isEmpty: vm.items.isEmpty,
          empty: AppEmptyView(
            icon: Icons.history_rounded,
            title: l10n.commonEmptyTitle,
            message: l10n.activityEmpty,
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
                    for (final a in vm.items) ActivityTile(activity: a),
                  ],
                ),
              ),
              if (vm.hasMore)
                LoadMoreButton(
                  label: l10n.commonShowMore,
                  isLoading: vm.isLoadingMore,
                  onPressed: vm.loadMore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
