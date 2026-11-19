import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/crypto_coin_model.dart';

/// One coin: its logo, name and ticker, price in somoni and the change
/// over 24 hours (green up, red down).
class CryptoTile extends StatelessWidget {
  const CryptoTile({required this.coin, required this.priceTjs, super.key});

  final CryptoCoinModel coin;
  final double? priceTjs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final change = coin.change24h;
    final fallback = CircleAvatar(
      radius: 22,
      backgroundColor: p.primaryLight,
      child: Text(
        coin.symbol.isEmpty ? '?' : coin.symbol.substring(0, 1),
        style: theme.textTheme.titleSmall?.copyWith(color: p.primary),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox.square(
              dimension: 44,
              child: coin.imageUrl == null
                  ? fallback
                  : Image.network(
                      coin.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => fallback,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coin.name, style: theme.textTheme.titleSmall),
                Text(
                  coin.symbol,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceTjs == null
                    ? '\$${context.rate(coin.priceUsd)}'
                    : '${context.rate(priceTjs!)} TJS',
                style: theme.textTheme.titleSmall,
              ),
              if (change != null)
                Text(
                  context.percent(change, signed: true, digits: 2),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: change >= 0 ? p.success : p.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
