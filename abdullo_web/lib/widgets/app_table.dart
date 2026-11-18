import 'package:flutter/material.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';

/// DataTable that scrolls sideways on narrow screens instead of overflowing.
class AppTable extends StatelessWidget {
  const AppTable({super.key, required this.columns, required this.rows, this.numeric = const {}, this.empty});

  final List<String> columns;
  final List<List<Widget>> rows;

  /// Indexes of right-aligned (number) columns.
  final Set<int> numeric;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.surfaceSoft, shape: BoxShape.circle),
                child: const Icon(Icons.inbox_outlined, size: 22, color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              Text(empty ?? tr.nothingFound, style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
            ],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            horizontalMargin: 12,
            columnSpacing: 28,
            headingRowHeight: 42,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            columns: [
              for (var i = 0; i < columns.length; i++)
                DataColumn(label: Text(columns[i]), numeric: numeric.contains(i)),
            ],
            rows: [
              for (final cells in rows) DataRow(cells: [for (final c in cells) DataCell(c)]),
            ],
          ),
        ),
      ),
    );
  }
}
