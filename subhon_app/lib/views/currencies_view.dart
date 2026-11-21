import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../viewmodels/currencies_view_model.dart';
import '../widgets/async_state_view.dart';
import '../widgets/crypto_tile.dart';
import '../widgets/options_sheet.dart';
import 'crypto_list_view.dart';

/// The "Валюты" tab: when the rates were updated, a converter between
/// world currencies, and live crypto prices in somoni (top 10, "Все" for
/// more). Prices refresh every 30 s while the tab is on screen.
class CurrenciesView extends StatefulWidget {
  const CurrenciesView({super.key});

  @override
  State<CurrenciesView> createState() => _CurrenciesViewState();
}

class _CurrenciesViewState extends State<CurrenciesView> {
  late final _amount = TextEditingController(text: '1');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden tabs have tickers muted: refresh live only when shown.
    context.read<CurrenciesViewModel>().setLive(
      live: TickerMode.valuesOf(context).enabled,
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pick(
    BuildContext context,
    CurrenciesViewModel vm, {
    required bool from,
  }) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: from ? l10n.fxFrom : l10n.fxTo,
      selected: from ? vm.from : vm.to,
      options: [for (final c in vm.currencies) (c, c)],
    );
    if (picked == null) return;
    from ? vm.setFrom(picked) : vm.setTo(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<CurrenciesViewModel>();
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.navCurrencies),
        actions: [
          IconButton(
            tooltip: l10n.fxRefresh,
            onPressed: vm.isLoading ? null : vm.load,
            icon: const Icon(Icons.refresh_rounded),
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
          builder: (context) {
            final rates = vm.rates!;
            final result = vm.result;
            final rate = vm.rate;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl * 2,
              ),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: p.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.fxUpdated(context.formatDateTime(rates.updatedAt)),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.fxConverter, style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.fxAmount,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: p.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: theme.textTheme.headlineMedium,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (text) => vm.setAmount(
                                Validators.parseAmount(text) ?? 0,
                              ),
                            ),
                          ),
                          _CurrencyButton(
                            code: vm.from,
                            onTap: () => _pick(context, vm, from: true),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: p.border)),
                            const SizedBox(width: AppSpacing.md),
                            IconButton.filled(
                              tooltip: l10n.fxSwap,
                              onPressed: vm.swap,
                              icon: const Icon(Icons.swap_vert_rounded),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Divider(color: p.border)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                result == null ? '—' : context.rate(result),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: p.success,
                                ),
                              ),
                            ),
                          ),
                          _CurrencyButton(
                            code: vm.to,
                            onTap: () => _pick(context, vm, from: false),
                          ),
                        ],
                      ),
                      if (rate != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '1 ${vm.from} = ${context.rate(rate)} ${vm.to}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.fxCrypto,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CryptoListView(usdToTjs: rates.perUsd['TJS']),
                        ),
                      ),
                      child: Text(l10n.fxAll),
                    ),
                  ],
                ),
                Text(l10n.fxCryptoNote, style: theme.textTheme.bodySmall),
                if (vm.coinsUpdatedAt != null)
                  Text(
                    l10n.fxLive(context.formatDateTime(vm.coinsUpdatedAt!)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: p.success,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                _Card(
                  child: vm.coins.isEmpty
                      ? Text(
                          l10n.fxCryptoUnavailable,
                          style: theme.textTheme.bodySmall,
                        )
                      : Column(
                          children: [
                            for (final (i, coin) in vm.coins.indexed) ...[
                              if (i > 0) Divider(height: 1, color: p.border),
                              CryptoTile(
                                coin: coin,
                                priceTjs: vm.priceInTjs(coin),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.fxSources,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: context.palette.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      border: Border.all(color: context.palette.border),
    ),
    child: child,
  );
}

/// "USD ⌄": opens the list of currencies.
class _CurrencyButton extends StatelessWidget {
  const _CurrencyButton({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surfaceMuted,
      borderRadius: const BorderRadius.all(Radius.circular(99)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(99)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(code, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
