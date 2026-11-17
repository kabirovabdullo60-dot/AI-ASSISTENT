import '../core/constants/api_constants.dart';
import '../core/utils/format.dart';
import '../core/utils/json.dart';
import '../models/chat_message_model.dart';
import 'base_service.dart';
import 'mock/mock_database.dart';

class AssistantService extends BaseService {
  AssistantService({super.client, super.useMock});

  /// Sends the whole conversation, returns the assistant's reply.
  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history) => mockOr(
    mock: (db) {
      final last = history.lastWhere((m) => m.isUser, orElse: () => history.last);
      return ChatMessageModel(role: ChatRole.assistant, text: mockReply(last.text, db), time: DateTime.now());
    },
    api: () async => ChatMessageModel.fromJson(
      asJsonMap(await client.post(ApiConstants.assistantChat, {'messages': history.map((m) => m.toJson()).toList()})),
    ),
  );

  /// Keyword answers (en / tj / ru) built from the demo data.
  static String mockReply(String question, MockDatabase db) {
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);
    final o = db.overview();
    String tjs(double v) => '${formatAmount(v)} TJS';
    final ranked = List.of(db.stores)..sort((a, b) => b.monthlySales.compareTo(a.monthlySales));

    if (has(['report', 'hisobot', 'ҳисобот', 'отчет', 'отчёт', 'analy', 'tahlil'])) {
      return 'Report: this month ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)} vs last month), '
          'average ${tjs(o.averageDaily)} a day, gross margin ${o.grossMargin}%. '
          'Best store: ${ranked.first.name}. Unpaid salaries: ${tjs(o.unpaidSalaries)} '
          '(${o.pendingPayrolls} people). Trend: steady growth.';
    }
    if (has(['salar', 'payroll', 'maosh', 'моаш', 'зарплат', 'unpaid'])) {
      return 'Unpaid salaries: ${tjs(o.unpaidSalaries)} for ${o.pendingPayrolls} employees '
          '(${o.payrollCycle} cycle). Open the Salaries page to pay them.';
    }
    if (has(['sale', 'revenue', 'savdo', 'фурӯш', 'furush', 'продаж', 'выручк'])) {
      return "Today's sales are ${tjs(o.todaySales)} (${formatPercent(o.todayChange)} vs yesterday). "
          'This week ${tjs(o.weeklySales)} — target ${tjs(o.weeklyTarget)}. '
          'This month ${tjs(o.monthlySales)} (${formatPercent(o.monthlyChange)}).';
    }
    if (has(['expense', 'cost', 'xaroj', 'хароҷ', 'расход', 'cut', 'profit', 'foida', 'фоида', 'прибыл', 'margin'])) {
      return 'Gross margin is ${o.grossMargin}%. Payroll is the biggest cost line, then rent and delivery. '
          'The two smallest stores (${ranked[ranked.length - 2].name}, ${ranked.last.name}) bring under 2% of sales — '
          'check whether their rent pays off.';
    }
    if (has(['store', 'magoza', 'мағоза', 'магазин', 'branch'])) {
      final top = ranked.take(3).toList();
      return 'Top stores this month:\n'
          '${[for (var i = 0; i < top.length; i++) '${i + 1}. ${top[i].name} — ${tjs(top[i].monthlySales)}'].join('\n')}';
    }
    if (has(['staff', 'employee', 'kormand', 'корманд', 'сотрудник', 'shift'])) {
      return 'You have ${o.totalStaff} staff, ${o.staffOnShift} on shift today.';
    }
    if (has(['marketing', 'reklama', 'реклам', 'idea', 'ғоя', 'идея', 'grow', 'customer', 'mijoz', 'клиент'])) {
      return 'Three ideas for next month:\n'
          '1. Move a promo stand from ${ranked.first.name} to ${ranked[3].name} for a week.\n'
          '2. ${o.onlineShare}% already pay by card/QR — give 3% cashback on QR payments.\n'
          '3. A holiday bundle of your top 3 products in all stores.';
    }
    if (has(['salom', 'hello', 'hi', 'привет', 'салом'])) {
      return 'Salom! I am your business assistant. Ask me about sales, stores, staff, salaries or reports.';
    }
    return 'I can help with sales, stores, staff, salaries, reports and marketing ideas. '
        'Try: "Sales today" or "Top stores".';
  }
}
