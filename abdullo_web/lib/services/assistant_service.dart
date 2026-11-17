import '../core/utils/format.dart';
import '../models/chat_message_model.dart';
import '../models/dashboard_model.dart';
import '../models/sales_report_model.dart';
import 'reports_service.dart';

/// The backend has no AI endpoint yet, so the assistant answers with rules built from the
/// real numbers of /api/reports/dashboard and /api/reports/store-comparison.
/// When Mehroj adds an AI endpoint, only [sendMessage] has to change.
class AssistantService {
  AssistantService(this._reports);

  final ReportsService _reports;

  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history, {String language = 'en'}) async {
    final last = history.lastWhere((m) => m.isUser, orElse: () => history.last);
    final now = DateTime.now();
    final (dashboard, stores) = await (
      _reports.dashboard(),
      _reports.storeComparison(startDate: DateTime(now.year, now.month), endDate: now),
    ).wait;
    return ChatMessageModel(
      role: ChatRole.assistant,
      text: reply(last.text, dashboard, stores, language: language),
      time: DateTime.now(),
    );
  }

  /// Keyword answers. Understands questions in en / ru / tg, answers in [language].
  static String reply(String question, DashboardModel o, SalesReportModel month, {String language = 'en'}) {
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);
    String tjs(double v) => '${formatAmount(v)} TJS';
    final ranked = List.of(month.stores)..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final top3 = ranked.take(3).toList();
    final topList = top3.isEmpty
        ? '—'
        : [
            for (var i = 0; i < top3.length; i++) '${i + 1}. ${top3[i].storeName} — ${tjs(top3[i].totalAmount)}',
          ].join('\n');
    final best = ranked.isEmpty ? '—' : ranked.first.storeName;
    final worst = ranked.isEmpty ? '—' : ranked.last.storeName;
    final second = ranked.length > 1 ? ranked[1].storeName : best;
    final change = month.changePercent == null ? '' : ' (${formatPercent(month.changePercent!)})';
    String pick(String en, String ru, String tg) => switch (language) {
      'ru' => ru,
      'tg' => tg,
      _ => en,
    };

    if (has(['report', 'hisobot', 'ҳисобот', 'отчет', 'отчёт', 'analy', 'анализ', 'таҳлил', 'tahlil'])) {
      return pick(
        'Report: this month ${tjs(o.monthSales)}$change, '
            '${o.monthSalesCount} sales. Best store: $best. '
            'Unpaid salaries this month: ${tjs(o.remainingSalaryThisMonth)}.',
        'Отчёт: за месяц ${tjs(o.monthSales)}$change, '
            '${o.monthSalesCount} продаж. Лучший магазин: $best. '
            'Невыплачено зарплат за месяц: ${tjs(o.remainingSalaryThisMonth)}.',
        'Ҳисобот: дар ин моҳ ${tjs(o.monthSales)}$change, '
            '${o.monthSalesCount} фурӯш. Беҳтарин мағоза: $best. '
            'Музди пардохтнашудаи моҳ: ${tjs(o.remainingSalaryThisMonth)}.',
      );
    }
    if (has(['salar', 'payroll', 'maosh', 'моаш', 'музд', 'muzd', 'зарплат', 'unpaid'])) {
      return pick(
        'Unpaid salaries this month: ${tjs(o.remainingSalaryThisMonth)} of ${tjs(o.salaryDueThisMonth)}. '
            'All months together: ${tjs(o.remainingSalaryTotal)}. Open the Salaries page to pay them.',
        'Невыплачено за месяц: ${tjs(o.remainingSalaryThisMonth)} из ${tjs(o.salaryDueThisMonth)}. '
            'За все месяцы: ${tjs(o.remainingSalaryTotal)}. Откройте страницу «Зарплаты», чтобы выплатить.',
        'Музди пардохтнашудаи ин моҳ: ${tjs(o.remainingSalaryThisMonth)} аз ${tjs(o.salaryDueThisMonth)}. '
            'Дар ҳамаи моҳҳо: ${tjs(o.remainingSalaryTotal)}. Барои пардохт саҳифаи «Музди меҳнат»-ро кушоед.',
      );
    }
    if (has(['sale', 'revenue', 'savdo', 'фурӯш', 'furush', 'продаж', 'выручк'])) {
      return pick(
        "Today's sales are ${tjs(o.todaySales)}. This week ${tjs(o.weekSales)}. "
            'This month ${tjs(o.monthSales)}$change.',
        'Продажи сегодня: ${tjs(o.todaySales)}. За неделю ${tjs(o.weekSales)}. '
            'За месяц ${tjs(o.monthSales)}$change.',
        'Фурӯши имрӯза: ${tjs(o.todaySales)}. Дар ҳафта ${tjs(o.weekSales)}. '
            'Дар моҳ ${tjs(o.monthSales)}$change.',
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
        'Salaries due this month: ${tjs(o.salaryDueThisMonth)} — ${o.monthSales == 0 ? 0 : (o.salaryDueThisMonth / o.monthSales * 100).round()}% of sales. '
            '$worst brings the least — check whether its rent pays off.',
        'Зарплаты за месяц: ${tjs(o.salaryDueThisMonth)} — ${o.monthSales == 0 ? 0 : (o.salaryDueThisMonth / o.monthSales * 100).round()}% от продаж. '
            '$worst приносит меньше всех — проверьте, окупается ли аренда.',
        'Музди ин моҳ: ${tjs(o.salaryDueThisMonth)} — ${o.monthSales == 0 ? 0 : (o.salaryDueThisMonth / o.monthSales * 100).round()}% аз фурӯш. '
            '$worst камтар аз ҳама даромад медиҳад — санҷед, ки иҷораи он худро сафед мекунад ё не.',
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
        'You have ${o.totalEmployees} employees, ${o.activeEmployees} active.',
        'У вас ${o.totalEmployees} сотрудников, активных: ${o.activeEmployees}.',
        'Шумо ${o.totalEmployees} корманд доред, ${o.activeEmployees} нафар фаъол.',
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
        'Three ideas for next month:\n1. Move a promo stand from $best to $second for a week.\n'
            '2. Give 3% cashback on card/QR payments for a month and compare sales.\n'
            '3. A holiday bundle of your top 3 products in all stores.',
        'Три идеи на следующий месяц:\n1. Перенесите промостойку из $best в $second на неделю.\n'
            '2. Дайте 3% кэшбэк за оплату картой/QR на месяц и сравните продажи.\n'
            '3. Праздничный набор из 3 самых продаваемых товаров во всех магазинах.',
        'Се ғоя барои моҳи оянда:\n1. Стенди рекламаро аз $best ба $second барои як ҳафта баред.\n'
            '2. Барои як моҳ ба пардохти корт/QR 3% кэшбэк диҳед ва фурӯшро муқоиса кунед.\n'
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
