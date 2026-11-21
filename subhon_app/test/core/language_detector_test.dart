import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/utils/language_detector.dart';

void main() {
  test('the examples from the task', () {
    expect(
      detectLanguage('yak magazini nav bo nomi Ali ilova kun', 'ru'),
      'tg',
    );
    expect(detectLanguage('Сколько я продал сегодня?', 'tg'), 'ru');
    expect(detectLanguage('Фурӯши имрӯза чанд аст?', 'ru'), 'tg');
    expect(detectLanguage('How much did I sell today?', 'ru'), 'en');
  });

  test('Tajik words in Cyrillic without Tajik letters', () {
    expect(detectLanguage('Фуруши имруз чанд аст', 'ru'), 'tg');
    expect(detectLanguage('Кормандон чанд нафаранд?', 'en'), 'tg');
  });

  test('plain Russian and English stay as they are', () {
    expect(detectLanguage('Какой магазин продаёт лучше всех?', 'tg'), 'ru');
    expect(detectLanguage('Which store sells best this month?', 'tg'), 'en');
    expect(detectLanguage('Add a store Central Plaza', 'ru'), 'en');
    expect(detectLanguage('Сколько он продал вчера?', 'tg'), 'ru');
  });

  test('too short to tell: the app language', () {
    expect(detectLanguage('ok', 'tg'), 'tg');
    expect(detectLanguage('100', 'ru'), 'ru');
    expect(detectLanguage('да', 'en'), 'en');
    expect(detectLanguage('  ', 'ru'), 'ru');
  });
}
