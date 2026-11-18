import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/store_status.dart';
import '../services/store_service.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/active_status_badge.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_text_field.dart';
import '../widgets/async_state_view.dart';
import '../widgets/load_more_button.dart';
import '../widgets/record_tile.dart';
import 'store_details_view.dart';
import 'store_form_view.dart';

/// Stores: search, page by page; tap for details.
class StoresView extends StatelessWidget {
  const StoresView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => StoresViewModel(context.read<StoreService>())..load(),
    child: const _Stores(),
  );
}

class _Stores extends StatelessWidget {
  const _Stores();

  Future<void> _open(BuildContext context, Widget screen) async {
    final vm = context.read<StoresViewModel>();
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed ?? false) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<StoresViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStores),
        actions: [
          IconButton(
            tooltip: l10n.actionNewStore,
            onPressed: () => _open(context, const StoreFormView()),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          isEmpty: vm.items.isEmpty && vm.search.isEmpty,
          empty: AppEmptyView(
            icon: Icons.storefront_outlined,
            title: l10n.storesEmptyTitle,
            message: l10n.storesEmptyMessage,
            actionLabel: l10n.actionNewStore,
            onAction: () => _open(context, const StoreFormView()),
          ),
          builder: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            children: [
              AppTextField(
                initialValue: vm.search,
                hint: l10n.storesSearch,
                prefixIcon: Icons.search_rounded,
                textInputAction: TextInputAction.search,
                onSubmitted: vm.setSearch,
              ),
              const SizedBox(height: AppSpacing.md),
              if (vm.items.isEmpty)
                AppCard(
                  child: Text(
                    l10n.commonNothingFound,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (final store in vm.items)
                        RecordTile(
                          icon: Icons.storefront_rounded,
                          iconColor: p.primary,
                          iconBackground: p.primaryLight,
                          title: store.name,
                          subtitle: [?store.address, ?store.phone].join(' · '),
                          badge: ActiveStatusBadge(
                            active: store.status == StoreStatus.active,
                          ),
                          onTap: () => _open(
                            context,
                            StoreDetailsView(storeId: store.id),
                          ),
                        ),
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
