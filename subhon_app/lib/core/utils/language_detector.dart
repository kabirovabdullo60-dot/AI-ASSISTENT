/// The language a question is WRITTEN in, so the assistant answers in it
/// (API.md "AI assistant — rules for the apps"):
/// * Tajik letters (ӣ ӯ ҳ ҷ қ ғ) or Tajik words in Cyrillic → `tg`;
/// * other Cyrillic → `ru`;
/// * Latin letters with Tajik words (yak, magazin, ilova, kun, imruz,
///   furush…) → `tg`; other Latin → `en`;
/// * too short to tell ("ok", "100") → [appLanguage].
String detectLanguage(String text, String appLanguage) {
  final lower = text.toLowerCase();
  final letters = RegExp(r'\p{L}', unicode: true).allMatches(lower).length;
  if (letters < 3) return appLanguage;

  if (RegExp('[ӣӯҳҷқғ]').hasMatch(lower)) return 'tg';
  final words = RegExp(
    r'\p{L}+',
    unicode: true,
  ).allMatches(lower).map((m) => m.group(0)!).toList();
  final cyrillic = RegExp('[а-яё]').allMatches(lower).length;
  final latin = RegExp('[a-z]').allMatches(lower).length;
  if (cyrillic >= latin && cyrillic > 0) {
    return words.any(_tajikCyrillic.contains) ? 'tg' : 'ru';
  }
  if (latin > 0) {
    final tajik = words.where(_tajikLatin.contains).length;
    // One Tajik word in a longer sentence is enough ("yak magazin…"), but a
    // two-letter English word like "kun" alone is not.
    if (tajik >= 2 || (tajik == 1 && words.length <= 3)) return 'tg';
    return words.length < 2 && letters < 5 ? appLanguage : 'en';
  }
  return appLanguage;
}

/// Common Tajik words written without the Tajik letters.
const _tajikCyrillic = {
  'чанд',
  'ман',
  'мо',
  'шумо',
  'ин',
  'чи',
  'чӣ',
  'кадом',
  'имруз',
  'имрӯз',
  'дирӯз',
  'дируз',
  'фурӯш',
  'фуруш',
  'фурӯши',
  'фуруши',
  'мағоза',
  'магоза',
  'магозаи',
  'кормандон',
  'корманд',
  'маош',
  'моҳ',
  'мох',
  'ҳафта',
  'хафта',
  'кун',
  'кунед',
  'илова',
  'нав',
  'бо',
  'номи',
  'аст',
  'буд',
  'нест',
  'ҳаст',
  'хаст',
  'пул',
  'харҷ',
  'харч',
  'хароҷот',
  'харочот',
  'даромад',
  'фоида',
  'рӯз',
  'руз',
  'бисёр',
  'бисер',
  'камтар',
  'зиёд',
  'зиед',
  'барои',
  'чаро',
  'куҷо',
  'кучо',
  'кай',
  'як',
  'ду',
  'се',
  'бигӯ',
  'бигу',
  'нишон',
  'деҳ',
  'дех',
  'лутфан',
  'раҳмат',
  'рахмат',
  'салом',
};

const _tajikLatin = {
  'yak',
  'du',
  'se',
  'magazin',
  'magozin',
  'magoza',
  'magazini',
  'magozai',
  'ilova',
  'kun',
  'kunad',
  'kuned',
  'imruz',
  'imroz',
  'diruz',
  'furush',
  'furushi',
  'chand',
  'man',
  'mo',
  'shumo',
  'nav',
  'bo',
  'nomi',
  'ast',
  'nest',
  'hast',
  'kormand',
  'kormandon',
  'maosh',
  'moh',
  'hafta',
  'pul',
  'kharj',
  'daromad',
  'foida',
  'ruz',
  'baroi',
  'chi',
  'kadom',
  'chiqadar',
  'chikadar',
  'biguy',
  'nishon',
  'deh',
  'lutfan',
  'rahmat',
  'salom',
};
