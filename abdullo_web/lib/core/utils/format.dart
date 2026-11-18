// Month / weekday names per language (en, ru, tg). Set by SettingsViewModel.
String _lang = 'en';

/// Called when the user switches language.
void setFormatLanguage(String code) => _lang = const {'en', 'ru', 'tg'}.contains(code) ? code : 'en';

const _monthsShort = {
  'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  'ru': ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],
  'tg': ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],
};
const _monthsLong = {
  'en': [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ],
  'ru': [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ],
  'tg': ['Январ', 'Феврал', 'Март', 'Апрел', 'Май', 'Июн', 'Июл', 'Август', 'Сентябр', 'Октябр', 'Ноябр', 'Декабр'],
};
const _weekdays = {
  'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  'ru': ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
  'tg': ['Дш', 'Сш', 'Чш', 'Пш', 'Ҷм', 'Шб', 'Яш'],
};
const _words = {
  'en': {'today': 'Today', 'yesterday': 'Yesterday', 'now': 'just now', 'min': 'min ago', 'h': 'h ago', 'd': 'd ago'},
  'ru': {
    'today': 'Сегодня',
    'yesterday': 'Вчера',
    'now': 'только что',
    'min': 'мин назад',
    'h': 'ч назад',
    'd': 'дн. назад',
  },
  'tg': {'today': 'Имрӯз', 'yesterday': 'Дирӯз', 'now': 'ҳозир', 'min': 'дақ. пеш', 'h': 'соат пеш', 'd': 'рӯз пеш'},
};

List<String> get _months => _monthsShort[_lang]!;

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

/// "Nov 17, 2026" / "17 ноя 2026"
String formatDate(DateTime d) =>
    _lang == 'en' ? '${_months[d.month - 1]} ${d.day}, ${d.year}' : '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Nov 06" / "6 ноя"
String formatDay(DateTime d) =>
    _lang == 'en' ? '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}' : '${d.day} ${_months[d.month - 1]}';

/// "Fri" / "Пт" / "Ҷм"
String formatWeekday(DateTime d) => _weekdays[_lang]![d.weekday - 1];

/// "Nov"
String formatMonth(DateTime d) => _months[d.month - 1];

/// "14:05"
String formatTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "12 mins ago", "3 hours ago"
String formatTimeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  final w = _words[_lang]!;
  if (diff.inMinutes < 1) return w['now']!;
  if (diff.inMinutes < 60) return '${diff.inMinutes} ${w['min']}';
  if (diff.inHours < 24) return '${diff.inHours} ${w['h']}';
  return '${diff.inDays} ${w['d']}';
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
  if (day == today) return _words[_lang]!['today']!;
  if (day == today.subtract(const Duration(days: 1))) return _words[_lang]!['yesterday']!;
  return formatDay(d);
}

/// "11/17/2026"
String formatNumericDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

/// "November 2026"
String formatMonthYear(DateTime d) => '${_monthsLong[_lang]![d.month - 1]} ${d.year}';

/// "2026-11" — the payroll period sent to the backend.
String periodKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// Percent change from [previous] to [current]; 0 when there is no previous value.
double percentChange(double current, double previous) => previous == 0 ? 0 : (current - previous) / previous * 100;
