/// 48250 -> "48,250"
String formatAmount(double value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}

/// 48250 -> "48.3k"
String formatCompact(double value) =>
    value.abs() >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.round().toString();

/// 12.4 -> "+12.4%"
String formatPercent(double value) => '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
