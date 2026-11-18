import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_exception.dart';
import 'package:subhon_app/l10n/error_text.dart';
import 'package:subhon_app/l10n/generated/app_localizations.dart';

void main() {
  final languages = [
    for (final code in ['en', 'ru', 'tg']) lookupAppLocalizations(Locale(code)),
  ];

  test('the required codes have their own text in English, Russian and '
      'Tajik', () {
    const required = {
      'AUTH_INVALID_CREDENTIALS': (
        'Wrong e-mail',
        'Неверный e-mail',
        'нодуруст',
      ),
      'EMAIL_ALREADY_REGISTERED': ('already exists', 'уже есть', 'аллакай'),
      'STORE_HAS_ACTIVE_EMPLOYEES': (
        'working employees',
        'работающие',
        'фаъол',
      ),
      'PAYROLL_AMOUNT_EXCEEDS_REMAINING': ('more than', 'больше', 'зиёд'),
      'VALIDATION_ERROR': ('wrongly', 'неверно', 'нодуруст'),
      'NETWORK_ERROR': ('connection', 'связи', 'алоқа'),
    };
    for (final MapEntry(key: code, value: (en, ru, tg)) in required.entries) {
      final error = ApiException(400, code, message: 'SERVER TEXT');
      final texts = [for (final l10n in languages) errorText(l10n, error)];
      expect(texts[0], contains(en), reason: '$code en');
      expect(texts[1], contains(ru), reason: '$code ru');
      expect(texts[2], contains(tg), reason: '$code tg');
      for (final t in texts) {
        expect(t, isNot(contains('SERVER TEXT')), reason: code);
      }
    }
  });

  test('every documented error code gets a translated text, never the '
      'generic one', () {
    const codes = [
      'AUTH_ACCOUNT_DISABLED',
      'AUTH_ACCOUNT_LOCKED',
      'AUTH_REQUIRED',
      'AUTH_SESSION_REVOKED',
      'AUTH_TOKEN_EXPIRED',
      'AUTH_TOKEN_INVALID',
      'AVATAR_INVALID_TYPE',
      'AVATAR_TOO_LARGE',
      'CONFLICT',
      'CURRENT_PASSWORD_INCORRECT',
      'EMPLOYEE_NOT_EMPLOYED_IN_PERIOD',
      'EMPLOYEE_NOT_FOUND',
      'INTERNAL_ERROR',
      'INVALID_DATE_RANGE',
      'INVALID_EMPLOYMENT_DATES',
      'NOT_FOUND',
      'PASSWORD_TOO_WEAK',
      'PAYLOAD_TOO_LARGE',
      'PAYMENT_DATE_IN_FUTURE',
      'PAYROLL_ALREADY_PAID',
      'PAYROLL_NOT_FOUND',
      'PAYROLL_PERIOD_IN_FUTURE',
      'PERMISSION_DENIED',
      'RATE_LIMITED',
      'SALE_DATE_IN_FUTURE',
      'SALE_NOT_FOUND',
      'STORE_NAME_TAKEN',
      'STORE_NOT_FOUND',
      'UNSUPPORTED_MEDIA_TYPE',
    ];
    for (final l10n in languages) {
      for (final code in codes) {
        final text = errorText(l10n, ApiException(400, code));
        expect(
          text,
          isNot(l10n.errUnknown),
          reason: '$code ${l10n.localeName}',
        );
        expect(text, isNotEmpty);
      }
    }
  });

  test('unknown codes and 5xx fall back to calm texts', () {
    final ru = languages[1];
    expect(
      errorText(ru, const ApiException(400, 'SOMETHING_NEW')),
      ru.errUnknown,
    );
    expect(
      errorText(ru, const ApiException(503, 'SOMETHING_NEW')),
      ru.errServer,
    );
    expect(errorText(ru, StateError('bug')), ru.errUnknown);
  });
}
