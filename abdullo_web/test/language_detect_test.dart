import 'package:abdullo_web/core/utils/language_detect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tajik in Cyrillic, with or without its own letters', () {
    expect(detectMessageLanguage('Фурӯши имрӯза чанд аст?'), 'tg');
    expect(detectMessageLanguage('Як магозаи нав илова кун'), 'tg');
    expect(detectMessageLanguage('маоши кормандон чанд аст'), 'tg');
  });

  test('Tajik typed in Latin letters', () {
    expect(detectMessageLanguage('yak magazini nav bo nomi Magazini ALi ilova kun'), 'tg');
    expect(detectMessageLanguage('imruz chand furush shud?'), 'tg');
    expect(detectMessageLanguage('hozir yak magozai nav ilova kun'), 'tg');
  });

  test('Russian', () {
    expect(detectMessageLanguage('Сколько я продал сегодня?'), 'ru');
    expect(detectMessageLanguage('Добавь магазин Сомон на Рудаки 5'), 'ru');
  });

  test('English', () {
    expect(detectMessageLanguage('How much did I sell today?'), 'en');
    expect(detectMessageLanguage('Add a store called Navruz Mall'), 'en');
  });

  test('too short to tell → null (the site language is used)', () {
    expect(detectMessageLanguage('100'), isNull);
    expect(detectMessageLanguage('ok'), isNull);
    expect(detectMessageLanguage('   '), isNull);
  });
}
