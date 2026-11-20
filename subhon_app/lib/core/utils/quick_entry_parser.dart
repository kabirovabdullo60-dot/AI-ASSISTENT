import '../../models/money_account_kind.dart';
import '../../models/money_account_model.dart';
import '../../models/money_category.dart';
import '../../models/money_transaction_kind.dart';
import '../../models/quick_entry_model.dart';

/// Understands a short phrase in Russian, Tajik or English, typed or said:
/// "такси 50", "обед 35 картой", "получил зарплату 3 000 на карту",
/// "интернет 1,5к". The amount is the first number ("к" / "тыс" /
/// "ҳазор" / "k" = thousands), income is told by its words, the category
/// and the account by known words or an account's own name.
class QuickEntryParser {
  const QuickEntryParser._();

  static const _incomeWords = [
    'получил',
    'получила',
    'пришл',
    'пришёл',
    'зарплат',
    'аванс',
    'доход',
    'заработал',
    'подарили',
    'вернули',
    'кешбэк',
    'кэшбэк',
    'кешбек',
    'гирифтам',
    'маош',
    'даромад',
    'омад',
    'received',
    'got paid',
    'salary',
    'income',
    'earned',
    'cashback',
  ];

  static const _income = <MoneyCategory, List<String>>{
    MoneyCategory.salary: [
      'зарплат',
      'аванс',
      'оклад',
      'маош',
      'salary',
      'paycheck',
    ],
    MoneyCategory.sideJob: [
      'подработ',
      'фриланс',
      'халтур',
      'freelance',
      'side job',
    ],
    MoneyCategory.business: [
      'бизнес',
      'из магазина',
      'из кассы',
      'касса',
      'тиҷорат',
      'мағоза',
      'business',
      'shop',
    ],
    MoneyCategory.refund: [
      'вернули',
      'возврат',
      'кешбэк',
      'кэшбэк',
      'кешбек',
      'refund',
      'cashback',
    ],
    MoneyCategory.giftIn: ['подарили', 'подарок', 'тӯҳфа', 'gift'],
  };

  static const _expense = <MoneyCategory, List<String>>{
    MoneyCategory.transport: [
      'такси',
      'бензин',
      'заправ',
      'автобус',
      'маршрут',
      'метро',
      'парковк',
      'проезд',
      'нақлиёт',
      'taxi',
      'fuel',
      'petrol',
      'bus',
      'uber',
      'parking',
    ],
    MoneyCategory.cafe: [
      'кафе',
      'ресторан',
      'обед',
      'ужин',
      'завтрак',
      'кофе',
      'чайхан',
      'шаурм',
      'пицц',
      'бургер',
      'плов',
      'қаҳвахона',
      'cafe',
      'café',
      'coffee',
      'lunch',
      'dinner',
      'breakfast',
      'restaurant',
      'pizza',
    ],
    MoneyCategory.food: [
      'продукт',
      'хлеб',
      'молок',
      'мясо',
      'овощ',
      'фрукт',
      'базар',
      'супермаркет',
      'озуқа',
      'нон',
      'grocer',
      'food',
      'bread',
      'milk',
      'market',
    ],
    MoneyCategory.home: [
      'аренд',
      'квартир',
      'ипотек',
      'ремонт',
      'мебел',
      'иҷора',
      'rent',
      'mortgage',
      'furniture',
    ],
    MoneyCategory.utilities: [
      'свет',
      'электр',
      'вода',
      'воду',
      'коммунал',
      'отоплен',
      'газ',
      'barq',
      'барқ',
      'utilit',
      'electric',
      'water bill',
      'heating',
    ],
    MoneyCategory.phone: [
      'телефон',
      'интернет',
      'связь',
      'мобил',
      'баланс',
      'tcell',
      'мегафон',
      'вавилон',
      'зет',
      'internet',
      'phone',
      'mobile',
    ],
    MoneyCategory.health: [
      'аптек',
      'лекарств',
      'таблетк',
      'врач',
      'больниц',
      'стоматолог',
      'анализ',
      'дору',
      'духтур',
      'pharmacy',
      'medicine',
      'doctor',
      'dentist',
    ],
    MoneyCategory.clothes: [
      'одежд',
      'обув',
      'куртк',
      'кроссовк',
      'платье',
      'рубашк',
      'джинс',
      'либос',
      'пойафзол',
      'clothes',
      'shoes',
      'jacket',
    ],
    MoneyCategory.education: [
      'учеб',
      'курс',
      'школ',
      'универ',
      'книг',
      'репетитор',
      'контракт',
      'таҳсил',
      'китоб',
      'education',
      'course',
      'school',
      'book',
      'tuition',
    ],
    MoneyCategory.fun: [
      'кино',
      'игр',
      'развлеч',
      'отдых',
      'концерт',
      'подписк',
      'фароғат',
      'cinema',
      'movie',
      'game',
      'concert',
      'netflix',
      'subscription',
    ],
    MoneyCategory.gifts: [
      'подарок',
      'подарил',
      'цвет',
      'тӯҳфа',
      'gift',
      'flowers',
    ],
    MoneyCategory.family: [
      'дет',
      'ребён',
      'ребен',
      'сын',
      'дочь',
      'дочк',
      'маме',
      'папе',
      'жене',
      'мужу',
      'родител',
      'оила',
      'кӯдак',
      'family',
      'kids',
      'child',
    ],
  };

  static const _cardWords = [
    'карт',
    'корт',
    'card',
    'алиф',
    'душанбе сити',
    'эсхата',
  ];
  static const _cashWords = ['налич', 'нақд', 'cash', 'кэш', 'кеш'];

  static final _number = RegExp(
    r'(\d[\d\s ]*(?:[.,]\d+)?)\s*(тыс\w*|ҳазор|к|k)?(?![\p{L}\d])',
    unicode: true,
    caseSensitive: false,
  );

  static final _currency = RegExp(
    r'(?<![\p{L}\d])(сомони|сомон|сом|смн|tjs|somoni)(?![\p{L}\d])',
    unicode: true,
    caseSensitive: false,
  );

  static QuickEntryModel? parse(String text, List<MoneyAccountModel> accounts) {
    final raw = text.trim();
    if (raw.isEmpty) return null;
    final lower = raw.toLowerCase();

    double? amount;
    var rest = raw;
    final m = _number.firstMatch(raw);
    if (m != null) {
      final digits = m.group(1)!.replaceAll(RegExp(r'[\s ]'), '');
      amount = double.tryParse(digits.replaceAll(',', '.'));
      if (amount != null && m.group(2) != null) amount *= 1000;
      rest = raw.replaceRange(m.start, m.end, ' ');
    }

    final income = _incomeWords.any(lower.contains);
    final kind = income
        ? MoneyTransactionKind.income
        : MoneyTransactionKind.expense;
    final category =
        _find(lower, income ? _income : _expense) ??
        (income ? MoneyCategory.otherIncome : null);

    return QuickEntryModel(
      kind: kind,
      amount: amount,
      category: category,
      accountId: _account(lower, accounts),
      note: _note(rest),
    );
  }

  static MoneyCategory? _find(
    String lower,
    Map<MoneyCategory, List<String>> words,
  ) {
    for (final e in words.entries) {
      if (e.value.any(lower.contains)) return e.key;
    }
    return null;
  }

  static String? _account(String lower, List<MoneyAccountModel> accounts) {
    // The account's own name first ("Алиф", "Сбережения").
    for (final a in accounts) {
      final name = a.name.toLowerCase().trim();
      if (name.length >= 3 && lower.contains(name)) return a.id;
    }
    MoneyAccountModel? ofKind(MoneyAccountKind k) =>
        accounts.where((a) => a.kind == k).firstOrNull;
    if (_cardWords.any(lower.contains)) {
      return (ofKind(MoneyAccountKind.card) ?? ofKind(MoneyAccountKind.bank))
          ?.id;
    }
    if (_cashWords.any(lower.contains)) {
      return ofKind(MoneyAccountKind.cash)?.id;
    }
    return null;
  }

  static String? _note(String rest) {
    final note = rest
        .replaceAll(_currency, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (note.isEmpty) return null;
    return note[0].toUpperCase() + note.substring(1);
  }
}
