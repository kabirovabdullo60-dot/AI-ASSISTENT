/// One day on the revenue chart: bar = revenue, line = number of sales.
class ChartPointModel {
  const ChartPointModel({required this.date, required this.revenue, this.count = 0});

  final DateTime date;
  final double revenue;
  final int count;
}
