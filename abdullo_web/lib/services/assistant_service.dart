import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';

class AssistantService {
  AssistantService({
    ApiClient? client,
    this.useMock = ApiConstants.useMock,
    this.mockDelay = const Duration(milliseconds: 700),
  }) : _client = client ?? ApiClient();

  final ApiClient _client;
  final bool useMock;
  final Duration mockDelay;

  /// Sends the whole conversation, returns the assistant's reply.
  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history) async {
    if (useMock) {
      await Future<void>.delayed(mockDelay);
      final last = history.lastWhere((m) => m.isUser, orElse: () => history.last);
      return ChatMessageModel(role: ChatRole.assistant, text: mockReply(last.text), time: DateTime.now());
    }
    final json = await _client.post(ApiConstants.assistantChatPath, {
      'messages': history.map((m) => m.toJson()).toList(),
    });
    return ChatMessageModel.fromJson(json as Map<String, dynamic>);
  }

  /// Simple keyword answers (en / tj / ru) for demo mode.
  static String mockReply(String question) {
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);

    if (has(['report', 'hisobot', 'ҳисобот', 'отчет', 'отчёт', 'analy'])) {
      return 'Report for the last 6 months: total revenue 232,450 TJS, average 38,742 TJS a month, '
          'best month November (48,250 TJS). Trend: steady growth. '
          'Main risk: delivery costs rising faster than orders.';
    }
    if (has(['sale', 'revenue', 'savdo', 'furush', 'фурӯш', 'продаж', 'выручк'])) {
      return 'Revenue this month is 48,250 TJS, up 12.4% from October. '
          'Sales grew 3 months in a row (Sep 39,900 → Oct 43,000 → Nov 48,250). '
          'Keep your best-selling products in stock for December.';
    }
    if (has(['expense', 'cost', 'xaroj', 'харoҷ', 'хароҷ', 'расход', 'cut'])) {
      return 'Expenses are 31,780 TJS (+4.1%). The biggest items: rent 35%, salaries 30%, delivery 22%. '
          'Grouping deliveries by area could save about 1,500 TJS a month.';
    }
    if (has(['profit', 'foida', 'фоида', 'прибыл', 'margin'])) {
      return 'Profit is 16,470 TJS (+18.2%), a 34% margin. '
          'Profit grows faster than revenue, so your costs are under control.';
    }
    if (has(['customer', 'client', 'mijoz', 'мизоҷ', 'клиент'])) {
      return 'You have 312 active customers (+6.8%). 41 of them have not bought in 60 days. '
          'Send them a short message with a 10% discount to bring them back.';
    }
    if (has(['marketing', 'reklama', 'реклам', 'idea', 'ғоя', 'идея', 'grow'])) {
      return 'Three ideas for next month:\n'
          '1. Instagram/Telegram posts with real customer photos, 3 times a week.\n'
          '2. "Bring a friend" — both get 5% off.\n'
          '3. A December holiday bundle of your top 3 products.';
    }
    if (has(['salom', 'hello', 'hi', 'привет', 'салом'])) {
      return 'Salom! I am your business assistant. Ask me about sales, expenses, profit, '
          'customers or marketing ideas.';
    }
    return 'I can help with sales, expenses, profit, customers, reports and marketing ideas. '
        'Try: "How are my sales this month?"';
  }
}
