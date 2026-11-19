/// Turns a short request ("сотрудники", "сколько сотрудников", "sales
/// today") into a clear question for the AI assistant, so it knows what
/// the person means and answers with the business's main figures. Full
/// questions are sent as they are.
///
/// [language]: `en`, `ru` or `tg` — the language of the added words.
String expandQuestion(String text, String language) {
  final question = text.trim();
  if (question.isEmpty || !_isShort(question)) return question;
  final topic = _topicOf(question.toLowerCase());
  final hint = topic == null ? '' : _hints[language]?[topic] ?? '';
  return switch (language) {
    'en' =>
      'Answer briefly about “$question” in my business: '
          'give the main figures$hint.',
    'tg' =>
      'Дар бораи «$question» дар тиҷорати ман кӯтоҳ ҷавоб деҳ: '
          'рақамҳои асосиро гӯй$hint.',
    _ =>
      'Коротко ответь про «$question» в моём бизнесе: '
          'дай главные цифры$hint.',
  };
}

/// A few words without a question mark: a keyword or a half-sentence.
bool _isShort(String text) =>
    !text.contains('?') && text.split(RegExp(r'\s+')).length <= 4;

enum _Topic { employees, sales, salary, stores, expenses, profit }

/// Word roots in Russian, Tajik and English, checked in this order: the
/// first match wins ("зарплата сотрудников" is about salary, "продажи
/// магазина" about sales).
const _roots = <_Topic, List<String>>{
  _Topic.salary: ['зарплат', 'оклад', 'маош', 'salar', 'payroll', 'wage'],
  _Topic.expenses: ['расход', 'трат', 'хароҷот', 'expense', 'cost'],
  _Topic.profit: ['прибыл', 'маржа', 'фоида', 'profit', 'margin'],
  _Topic.sales: ['продаж', 'выручк', 'фурӯш', 'sale', 'revenue'],
  _Topic.employees: [
    'сотрудник',
    'работник',
    'персонал',
    'штат',
    'корманд',
    'employee',
    'staff',
    'worker',
  ],
  _Topic.stores: ['магазин', 'точк', 'мағоза', 'store', 'shop'],
};

_Topic? _topicOf(String text) {
  for (final MapEntry(key: topic, value: roots) in _roots.entries) {
    if (roots.any(text.contains)) return topic;
  }
  return null;
}

/// What to include for each topic, so the answer is useful.
const _hints = <String, Map<_Topic, String>>{
  'ru': {
    _Topic.employees:
        ' (сколько всего сотрудников, сколько работают, по магазинам и '
        'фонд зарплаты)',
    _Topic.sales: ' (сегодня, за неделю и за месяц, лучший магазин)',
    _Topic.salary:
        ' (сколько начислено и выплачено в этом месяце, сколько осталось)',
    _Topic.stores: ' (сколько магазинов, какие работают, кто продаёт лучше)',
    _Topic.expenses: ' (сколько потрачено в этом месяце и на что)',
    _Topic.profit: ' (прибыль и маржа за этот месяц)',
  },
  'en': {
    _Topic.employees:
        ' (how many employees in total, how many work, by store and the '
        'salary fund)',
    _Topic.sales: ' (today, this week and this month, the best store)',
    _Topic.salary: ' (due and paid this month, how much is left)',
    _Topic.stores: ' (how many stores, which work, which sells best)',
    _Topic.expenses: ' (how much was spent this month and on what)',
    _Topic.profit: ' (profit and margin this month)',
  },
  'tg': {
    _Topic.employees:
        ' (ҳамагӣ чанд корманд, чандто кор мекунанд, аз рӯи мағозаҳо ва '
        'фонди маош)',
    _Topic.sales: ' (имрӯз, дар ҳафта ва дар моҳ, беҳтарин мағоза)',
    _Topic.salary: ' (дар ин моҳ чӣ қадар ҳисоб ва пардохт шуд, чӣ қадар монд)',
    _Topic.stores: ' (чанд мағоза, кадомҳо кор мекунанд, кӣ беҳтар мефурӯшад)',
    _Topic.expenses: ' (дар ин моҳ чӣ қадар ва барои чӣ сарф шуд)',
    _Topic.profit: ' (фоида ва маржа дар ин моҳ)',
  },
};
