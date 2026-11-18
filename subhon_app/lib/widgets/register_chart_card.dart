import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import 'register_chart_painter.dart';
import 'register_colors.dart';

/// The illustration card of the register screen: a legend (income,
/// profit), a "month" chip and two curves that draw in once.
///
/// Decorative only — before sign-up there is no data to show, so it has
/// no numbers and is hidden from screen readers.
class RegisterChartCard extends StatelessWidget {
  const RegisterChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final small = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: p.textSecondary);
    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 8),
        ),
        const SizedBox(width: 6),
        Text(label, style: small),
      ],
    );
    final animate = !MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: RegisterColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: RegisterColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                legend(RegisterColors.income, l10n.registerChartIncome),
                const SizedBox(width: AppSpacing.lg),
                legend(RegisterColors.profit, l10n.registerChartProfit),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(99)),
                    border: Border.all(color: RegisterColors.cardBorder),
                  ),
                  child: Text(l10n.periodMonth, style: small),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 68,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: animate ? 0 : 1, end: 1),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) =>
                    CustomPaint(painter: RegisterChartPainter(t)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
