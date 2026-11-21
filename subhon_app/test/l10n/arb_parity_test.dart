import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

/// `{name}` placeholders a text uses (plural/select names included).
Set<String> _placeholders(String text) =>
    {for (final m in RegExp(r'\{(\w+)[,}]').allMatches(text)) m.group(1)!}
      ..removeAll(const {'one', 'few', 'many', 'other', 'zero', 'two'});

void main() {
  final arbs = {
    for (final l in ['en', 'ru', 'tg']) l: _arb(l),
  };
  Set<String> keys(String l) => {
    for (final k in arbs[l]!.keys)
      if (!k.startsWith('@')) k,
  };

  test('every text exists in en, ru and tg', () {
    final all = {...keys('en'), ...keys('ru'), ...keys('tg')};
    for (final l in ['en', 'ru', 'tg']) {
      expect(all.difference(keys(l)), isEmpty, reason: 'missing in $l');
    }
  });

  test('the same placeholders in every language, and none left empty', () {
    for (final key in keys('en')) {
      final en = _placeholders(arbs['en']![key] as String);
      for (final l in ['ru', 'tg']) {
        final text = arbs[l]![key] as String;
        expect(text.trim(), isNotEmpty, reason: '$key ($l)');
        expect(_placeholders(text), en, reason: '$key ($l)');
      }
    }
  });
}
