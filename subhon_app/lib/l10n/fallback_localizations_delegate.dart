import 'package:flutter/widgets.dart';

/// Flutter has no Material / Cupertino texts for Tajik: for `tg` the
/// Russian ones are used (the app's own texts are Tajik).
class FallbackLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  const FallbackLocalizationsDelegate(this._delegate, {this.fallback = 'ru'});

  final LocalizationsDelegate<T> _delegate;
  final String fallback;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<T> load(Locale locale) => _delegate.load(Locale(fallback));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;

  @override
  Type get type => T;

  @override
  String toString() => 'FallbackLocalizationsDelegate<$T>(tg → $fallback)';
}
