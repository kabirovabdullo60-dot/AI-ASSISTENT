import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';

/// "Showing 1 to 6 of 148 entries   ‹ Prev 1 2 3 … 25 Next ›"
class Pager extends StatelessWidget {
  const Pager({
    super.key,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.itemCount,
    required this.onPage,
    this.noun = 'entries',
    this.extra,
  });

  final int page;
  final int pageCount;
  final int pageSize;
  final int itemCount;
  final ValueChanged<int> onPage;
  final String noun;

  /// Extra text after the summary, e.g. "Filtered Batch: October 2024".
  final String? extra;

  List<int?> get _pages {
    if (pageCount <= 5) return [for (var i = 0; i < pageCount; i++) i];
    final set = <int>{0, pageCount - 1, page - 1, page, page + 1}.where((p) => p >= 0 && p < pageCount).toList()
      ..sort();
    final out = <int?>[];
    for (final p in set) {
      if (out.isNotEmpty && p - out.last! > 1) out.add(null);
      out.add(p);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final from = itemCount == 0 ? 0 : page * pageSize + 1;
    final to = ((page + 1) * pageSize).clamp(0, itemCount);
    Widget btn(String label, int? target, {bool selected = false, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? AppColors.teal : AppColors.card,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(6),
          onTap: target == null || selected ? null : () => onPage(target),
          child: Container(
            constraints: const BoxConstraints(minWidth: 32),
            height: 32,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: selected ? AppColors.teal : AppColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : target == null
                    ? AppColors.barGray
                    : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Text(
          '${tr.showingRange(from, to, itemCount)}${extra == null ? '' : '   |   $extra'}',
          style: TextStyle(fontSize: 12.5, color: AppColors.muted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(tr.pagerPrev, page > 0 ? page - 1 : null, key: const Key('pager-prev')),
            for (final p in _pages)
              p == null ? btn('…', null) : btn('${p + 1}', p, selected: p == page, key: Key('pager-$p')),
            btn(tr.pagerNext, page < pageCount - 1 ? page + 1 : null, key: const Key('pager-next')),
          ],
        ),
      ],
    );
  }
}
