/// The three languages of the web.
enum AppLanguage {
  en('English', 'EN'),
  ru('Русский', 'RU'),
  tg('Тоҷикӣ', 'TJ');

  const AppLanguage(this.nativeName, this.short);

  final String nativeName;
  final String short;

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.name == code, orElse: () => AppLanguage.en);
}
