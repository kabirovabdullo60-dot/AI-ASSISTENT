const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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

/// "Nov 17, 2026"
String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "Nov 06"
String formatDay(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';

/// "Fri"
String formatWeekday(DateTime d) => _weekdays[d.weekday - 1];

/// "Nov"
String formatMonth(DateTime d) => _months[d.month - 1];

/// "14:05"
String formatTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "12 mins ago", "3 hours ago"
String formatTimeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
  if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
}

/// "Alisher Rahimov" -> "AR"
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

/// 12400 -> "12,400.00"
String formatAmount2(double value) {
  final cents = (value.abs() * 100).round();
  return '${value < 0 ? '-' : ''}${formatAmount((cents ~/ 100).toDouble())}.${(cents % 100).toString().padLeft(2, '0')}';
}

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "Today", "Yesterday" or "Nov 06"
String formatRelativeDay(DateTime d, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final day = dateOnly(d);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return formatDay(d);
}

/// "11/17/2026"
String formatNumericDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

/// "November 2026"
String formatMonthYear(DateTime d) => '${_monthsLong[d.month - 1]} ${d.year}';

/// "2026-11" — the payroll period sent to the backend.
String periodKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// 1 -> "1 mo", 18 -> "18 mos"
String formatTenure(int months) => '$months mo${months == 1 ? '' : 's'}';

/// Percent change from [previous] to [current]; 0 when there is no previous value.
double percentChange(double current, double previous) => previous == 0 ? 0 : (current - previous) / previous * 100;
