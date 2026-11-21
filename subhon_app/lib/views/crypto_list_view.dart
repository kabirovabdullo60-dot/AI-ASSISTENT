import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/market_service.dart';
import '../viewmodels/crypto_list_view_model.dart';
import '../widgets/async_state_view.dart';
import '../widgets/crypto_tile.dart';
import '../widgets/search_field.dart';

/// The top 100 cryptocurrencies with live prices in somoni, searchable.
class CryptoListView extends StatelessWidget {
  const CryptoListView({this.usdToTjs, super.key});

  /// Somoni for 1 USD (prices in dollars when unknown).
  final double? usdToTjs;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        CryptoListViewModel(context.read<MarketService>())..load(),
    child: _CryptoList(usdToTjs: usdToTjs),
  );
}

class _CryptoList extends StatelessWidget {
  const _CryptoList({this.usdToTjs});

  final double? usdToTjs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<CryptoListViewModel>();
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text(l10n.fxAllCrypto)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          builder: (context) => ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              SearchField(
                hint: l10n.fxSearchCoin,
                clearTooltip: l10n.commonClear,
                onChanged: vm.setSearch,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Column(
                  children: [
                    for (final (i, coin) in vm.coins.indexed) ...[
                      if (i > 0) Divider(height: 1, color: p.border),
                      CryptoTile(
                        coin: coin,
                        priceTjs: usdToTjs == null
                            ? null
                            : coin.priceUsd * usdToTjs!,
                      ),
                    ],
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
