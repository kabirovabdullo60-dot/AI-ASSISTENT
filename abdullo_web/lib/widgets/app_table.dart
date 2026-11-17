import 'package:flutter/material.dart';

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
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(empty ?? 'Nothing found')),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            horizontalMargin: 8,
            columnSpacing: 24,
            headingRowHeight: 40,
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
