import '../core/utils/phone.dart';
import 'generated/app_localizations.dart';

/// Form checks before a request (the server validates again).
abstract final class Validators {
  static String? required(String? value, AppLocalizations l10n) =>
      (value ?? '').trim().isEmpty ? l10n.validationRequired : null;

  static String? email(String? value, AppLocalizations l10n) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return l10n.validationRequired;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
        ? null
        : l10n.validationEmail;
  }

  /// Optional phone: empty, or `^\+?[0-9]{7,15}$` after removing spaces.
  static String? phone(String? value, AppLocalizations l10n) =>
      (value ?? '').trim().isEmpty || isValidPhone(value!)
      ? null
      : l10n.validationPhone;

  /// A positive amount with at most two decimals (`1250,50` or `1250.50`).
  static String? amount(String? value, AppLocalizations l10n) {
    final parsed = parseAmount(value);
    if ((value ?? '').trim().isEmpty) return l10n.validationRequired;
    return parsed == null || parsed <= 0 ? l10n.validationAmount : null;
  }

  /// `"1 250,5"` → 1250.5; `null` when it is not a number with at most two
  /// decimals.
  static double? parseAmount(String? value) {
    final v = (value ?? '')
        .replaceAll(RegExp(r'[\s ]'), '')
        .replaceAll(',', '.');
    if (!RegExp(r'^\d{1,12}(\.\d{1,2})?$').hasMatch(v)) return null;
    return double.parse(v);
  }
}
