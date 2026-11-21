import '../navigation/app_section.dart';

/// What a spoken phrase means. Understands en / ru / tg (Cyrillic and Latin Tajik).
sealed class VoiceCommand {
  const VoiceCommand();

  static VoiceCommand parse(String text) {
    final phrase = text.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ').trim();
    final words = phrase.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return AskAssistant(text.trim());
    final joined = ' ${words.join(' ')} ';

    if (words.length <= 2 && words.any((w) => _stopWords.contains(w))) return const StopSpeaking();
    if (_newChat.any(joined.contains)) return const NewChat();

    final wantsOpen = words.any((w) => _openStems.any(w.startsWith)) || _openPhrases.any(joined.contains);
    // One word — "Sales", "Отчёты" — also opens the page.
    if (wantsOpen || words.length == 1) {
      for (final (section, stems) in _sections) {
        if (words.any((w) => stems.any(w.startsWith))) return OpenSection(section);
      }
    }
    return AskAssistant(text.trim());
  }

  static const _stopWords = {
    'stop',
    'enough',
    'quiet',
    'silence',
    'стоп',
    'хватит',
    'замолчи',
    'тише',
    'бас',
    'bas',
    'хомӯш',
    'хомуш',
  };

  static const _newChat = [
    ' new chat ',
    ' clear chat ',
    ' новый чат ',
    ' очисти чат ',
    ' очистить чат ',
    ' чати нав ',
    ' chati nav ',
  ];

  static const _openStems = [
    'open',
    'navigate',
    'откр',
    'перейд',
    'перейт',
    'кушо',
    'бикушо',
    'kusho',
    'bikusho',
    'гузар',
    'guzar',
  ];

  static const _openPhrases = [' go to ', ' take me to ', ' рав ба ', ' rav ba '];

  // Salaries before sales so "salary" never reads as "sale".
  static const _sections = [
    (AppSection.salaries, ['salar', 'payroll', 'зарплат', 'музд', 'muzd', 'маош', 'моаш', 'maosh']),
    (AppSection.sales, ['sale', 'продаж', 'фурӯш', 'фуруш', 'furush']),
    (AppSection.stores, ['store', 'shop', 'магазин', 'мағоза', 'магоза', 'magoza']),
    (AppSection.employees, ['employee', 'staff', 'сотрудник', 'персонал', 'корманд', 'kormand']),
    (AppSection.expenses, ['expense', 'расход', 'хароҷ', 'xaroj', 'kharoj']),
    (AppSection.reports, ['report', 'отчет', 'отчёт', 'ҳисобот', 'хисобот', 'hisobot']),
    (AppSection.assistant, ['assistant', 'ассистент', 'помощник', 'ёрдамчӣ', 'ёрдамчи', 'yordamchi', 'чат', 'chat']),
    (AppSection.profile, ['profile', 'профил', 'профайл']),
    (AppSection.settings, ['setting', 'настройк', 'танзим', 'tanzim']),
    (AppSection.dashboard, ['dashboard', 'home', 'main', 'главн', 'дашборд', 'асосӣ', 'асоси', 'asosi']),
  ];
}

/// "Open sales", "Открой отчёты", "Фурӯшро кушо".
class OpenSection extends VoiceCommand {
  const OpenSection(this.section);
  final AppSection section;
}

/// "New chat" / "Новый чат" / "Чати нав".
class NewChat extends VoiceCommand {
  const NewChat();
}

/// "Stop" / "Стоп" / "Бас" — stop reading the answer.
class StopSpeaking extends VoiceCommand {
  const StopSpeaking();
}

/// Anything else is a question for the AI assistant.
class AskAssistant extends VoiceCommand {
  const AskAssistant(this.question);
  final String question;
}
