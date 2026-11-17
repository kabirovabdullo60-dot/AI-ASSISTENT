import '../core/constants/api_constants.dart';
import '../core/utils/format.dart';
import '../core/utils/json.dart';
import '../models/chat_message_model.dart';
import 'base_service.dart';
import 'mock/mock_database.dart';

class AssistantService extends BaseService {
  AssistantService({super.client, super.useMock});

  /// Sends the whole conversation, returns the assistant's reply in [language] ('en' / 'ru' / 'tg').
  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history, {String language = 'en'}) => mockOr(
    mock: (db) {
      final last = history.lastWhere((m) => m.isUser, orElse: () => history.last);
      return ChatMessageModel(
        role: ChatRole.assistant,
        text: mockReply(last.text, db, language: language),
        time: DateTime.now(),
      );
    },
    api: () async => ChatMessageModel.fromJson(
      asJsonMap(
        await client.post(ApiConstants.assistantChat, {
          'language': language,
          'messages': history.map((m) => m.toJson()).toList(),
        }),
      ),
    ),
  );

  /// Keyword answers built from the demo data. Understands questions in en / ru / tg,
  /// answers in [language].
  static String mockReply(String question, MockDatabase db, {String language = 'en'}) {
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);
    final o = db.overview();
    String tjs(double v) => '${formatAmount(v)} TJS';
    final ranked = List.of(db.stores)..sort((a, b) => b.monthlySales.compareTo(a.monthlySales));
    final top3 = ranked.take(3).toList();
    final topList = [
      for (var i = 0; i < top3.length; i++) '${i + 1}. ${top3[i].name} — ${tjs(top3[i].monthlySales)}',
    ].join('\n');
    String pick(String en, String ru, String tg) => switch (language) {
      'ru' => ru,
      'tg' => tg,
      _ => en,
    };

    if (has(['report', 'hisobot', 'ҳисобот', 'отчет', 'отчёт', 'analy', 'анализ', 'таҳлил', 'tahlil'])) {
      return pick(
        'Report: this month ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)} vs last month), '
            'average ${tjs(o.averageDaily)} a day, gross margin ${o.grossMargin}%. Best store: ${ranked.first.name}. '
            'Unpaid salaries: ${tjs(o.unpaidSalaries)} (${o.pendingPayrolls} people). Trend: steady growth.',
        'Отчёт: за месяц ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)} к прошлому месяцу), '
            'в среднем ${tjs(o.averageDaily)} в день, валовая маржа ${o.grossMargin}%. Лучший магазин: ${ranked.first.name}. '
            'Невыплаченные зарплаты: ${tjs(o.unpaidSalaries)} (${o.pendingPayrolls} чел.). Тренд: стабильный рост.',
        'Ҳисобот: дар ин моҳ ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)} нисбат ба моҳи гузашта), '
            'миёна ${tjs(o.averageDaily)} дар як рӯз, фоидаи умумӣ ${o.grossMargin}%. Беҳтарин мағоза: ${ranked.first.name}. '
            'Музди пардохтнашуда: ${tjs(o.unpaidSalaries)} (${o.pendingPayrolls} нафар). Тамоюл: афзоиши устувор.',
      );
    }
    if (has(['salar', 'payroll', 'maosh', 'моаш', 'музд', 'muzd', 'зарплат', 'unpaid'])) {
      return pick(
        'Unpaid salaries: ${tjs(o.unpaidSalaries)} for ${o.pendingPayrolls} employees (${o.payrollCycle} cycle). '
            'Open the Salaries page to pay them.',
        'Невыплаченные зарплаты: ${tjs(o.unpaidSalaries)} для ${o.pendingPayrolls} сотрудников (цикл: ${o.payrollCycle}). '
            'Откройте страницу «Зарплаты», чтобы выплатить.',
        'Музди пардохтнашуда: ${tjs(o.unpaidSalaries)} барои ${o.pendingPayrolls} корманд (давраи ${o.payrollCycle}). '
            'Барои пардохт саҳифаи «Музди меҳнат»-ро кушоед.',
      );
    }
    if (has(['sale', 'revenue', 'savdo', 'фурӯш', 'furush', 'продаж', 'выручк'])) {
      return pick(
        "Today's sales are ${tjs(o.todaySales)}. This week ${tjs(o.weeklySales)} — target ${tjs(o.weeklyTarget)}. "
            'This month ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)}).',
        'Продажи сегодня: ${tjs(o.todaySales)}. За неделю ${tjs(o.weeklySales)} — цель ${tjs(o.weeklyTarget)}. '
            'За месяц ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)}).',
        'Фурӯши имрӯза: ${tjs(o.todaySales)}. Дар ҳафта ${tjs(o.weeklySales)} — ҳадаф ${tjs(o.weeklyTarget)}. '
            'Дар моҳ ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)}).',
      );
    }
    if (has([
      'expense',
      'cost',
      'xaroj',
      'хароҷ',
      'расход',
      'cut',
      'profit',
      'foida',
      'фоида',
      'прибыл',
      'margin',
      'марж',
    ])) {
      return pick(
        'Gross margin is ${o.grossMargin}%. Payroll is the biggest cost, then rent and delivery. '
            '${ranked.last.name} brings the least — check whether its rent pays off.',
        'Валовая маржа ${o.grossMargin}%. Самая большая статья расходов — зарплаты, затем аренда и доставка. '
            '${ranked.last.name} приносит меньше всех — проверьте, окупается ли аренда.',
        'Фоидаи умумӣ ${o.grossMargin}% аст. Хароҷоти калонтарин — музди меҳнат, баъд иҷора ва расонидан. '
            '${ranked.last.name} камтар аз ҳама даромад медиҳад — санҷед, ки иҷораи он худро сафед мекунад ё не.',
      );
    }
    if (has(['store', 'magoza', 'мағоза', 'магазин', 'branch', 'лучш', 'беҳтарин'])) {
      return pick(
        'Top stores this month:\n$topList',
        'Лучшие магазины за месяц:\n$topList',
        'Беҳтарин мағозаҳои моҳ:\n$topList',
      );
    }
    if (has(['staff', 'employee', 'kormand', 'корманд', 'сотрудник', 'персонал', 'shift'])) {
      return pick(
        'You have ${o.totalStaff} staff, ${o.staffOnShift} on shift today.',
        'У вас ${o.totalStaff} сотрудников, сегодня на смене ${o.staffOnShift}.',
        'Шумо ${o.totalStaff} корманд доред, имрӯз ${o.staffOnShift} нафар дар баст ҳастанд.',
      );
    }
    if (has([
      'marketing',
      'маркетинг',
      'reklama',
      'реклам',
      'idea',
      'ғоя',
      'иде',
      'grow',
      'customer',
      'mijoz',
      'клиент',
      'мизоҷ',
    ])) {
      return pick(
        'Three ideas for next month:\n1. Move a promo stand from ${ranked.first.name} to ${ranked[3].name} for a week.\n'
            '2. ${o.onlineShare}% already pay by card/QR — give 3% cashback on QR payments.\n'
            '3. A holiday bundle of your top 3 products in all stores.',
        'Три идеи на следующий месяц:\n1. Перенесите промостойку из ${ranked.first.name} в ${ranked[3].name} на неделю.\n'
            '2. ${o.onlineShare}% уже платят картой/QR — дайте 3% кэшбэк за оплату по QR.\n'
            '3. Праздничный набор из 3 самых продаваемых товаров во всех магазинах.',
        'Се ғоя барои моҳи оянда:\n1. Стенди рекламаро аз ${ranked.first.name} ба ${ranked[3].name} барои як ҳафта баред.\n'
            '2. ${o.onlineShare}% аллакай бо корт/QR пардохт мекунанд — барои QR 3% кэшбэк диҳед.\n'
            '3. Маҷмӯаи идонаи 3 моли серхаридор дар ҳамаи мағозаҳо.',
      );
    }
    if (has(['salom', 'hello', 'hi', 'привет', 'салом', 'здравств'])) {
      return pick(
        'Hello! I am your business assistant. Ask me about sales, stores, staff, salaries or reports.',
        'Здравствуйте! Я ваш бизнес-ассистент. Спрашивайте о продажах, магазинах, персонале, зарплатах или отчётах.',
        'Салом! Ман ёрдамчии тиҷоратии шумо ҳастам. Дар бораи фурӯш, мағозаҳо, кормандон, музд ё ҳисобот пурсед.',
      );
    }
    return pick(
      'I can help with sales, stores, staff, salaries, reports and marketing ideas. Try: "Sales today" or "Top stores".',
      'Я помогу с продажами, магазинами, персоналом, зарплатами, отчётами и маркетингом. Например: «Продажи сегодня».',
      'Ман дар фурӯш, мағозаҳо, кормандон, музд, ҳисобот ва маркетинг кӯмак мекунам. Масалан: «Фурӯши имрӯза».',
    );
  }
}
