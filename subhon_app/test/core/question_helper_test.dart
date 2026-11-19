import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/utils/question_helper.dart';

void main() {
  test('a single word becomes a clear question about that topic', () {
    final q = expandQuestion('сотрудники', 'ru');
    expect(q, contains('«сотрудники»'));
    expect(q, contains('сколько всего сотрудников'));
  });

  test('a short request without "?" is expanded too', () {
    expect(
      expandQuestion('сколько сотрудников', 'ru'),
      contains('фонд зарплаты'),
    );
    expect(expandQuestion('зарплата сотрудников', 'ru'), contains('выплачено'));
    expect(expandQuestion('продажи магазина', 'ru'), contains('за неделю'));
    expect(expandQuestion('employees', 'en'), contains('how many employees'));
    expect(expandQuestion('кормандон', 'tg'), contains('чанд корманд'));
  });

  test('an unknown word still gets a clear frame', () {
    expect(
      expandQuestion('погода', 'ru'),
      'Коротко ответь про «погода» в моём бизнесе: дай главные цифры.',
    );
  });

  test('full questions are sent as they are', () {
    const question = 'Какой магазин продаёт лучше всех в этом месяце?';
    expect(expandQuestion(question, 'ru'), question);
    expect(
      expandQuestion(
        'покажи сколько у меня сейчас всего сотрудников работает',
        'ru',
      ),
      'покажи сколько у меня сейчас всего сотрудников работает',
    );
  });
}
