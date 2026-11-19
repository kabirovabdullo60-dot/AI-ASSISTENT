import '../core/network/api_exception.dart';
import 'generated/app_localizations.dart';

/// A user-facing, translated text for an API failure. The backend's own
/// `message` is never shown.
String errorText(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.errUnknown;
  return switch (error.code) {
    ApiException.networkError => l10n.errNetwork,
    'AUTH_INVALID_CREDENTIALS' => l10n.errInvalidCredentials,
    'AUTH_ACCOUNT_LOCKED' => l10n.errAccountLocked,
    'AUTH_ACCOUNT_DISABLED' => l10n.errAccountDisabled,
    'AUTH_REQUIRED' ||
    'AUTH_TOKEN_EXPIRED' ||
    'AUTH_TOKEN_INVALID' ||
    'AUTH_SESSION_REVOKED' => l10n.errSessionEnded,
    'EMAIL_ALREADY_REGISTERED' => l10n.errEmailTaken,
    'PASSWORD_TOO_WEAK' => l10n.errPasswordWeak,
    'CURRENT_PASSWORD_INCORRECT' => l10n.errCurrentPassword,
    'AVATAR_TOO_LARGE' || 'PAYLOAD_TOO_LARGE' => l10n.errAvatarTooLarge,
    'AVATAR_INVALID_TYPE' || 'UNSUPPORTED_MEDIA_TYPE' => l10n.errAvatarType,
    'STORE_NOT_FOUND' => l10n.errStoreNotFound,
    'STORE_NAME_TAKEN' => l10n.errStoreNameTaken,
    'STORE_HAS_ACTIVE_EMPLOYEES' => l10n.errStoreHasEmployees,
    'SALE_NOT_FOUND' => l10n.errSaleNotFound,
    'SALE_DATE_IN_FUTURE' => l10n.errSaleDateFuture,
    'EMPLOYEE_NOT_FOUND' => l10n.errEmployeeNotFound,
    'INVALID_EMPLOYMENT_DATES' => l10n.errEmploymentDates,
    'EMPLOYEE_NOT_EMPLOYED_IN_PERIOD' => l10n.errNotEmployedInPeriod,
    'PAYROLL_NOT_FOUND' => l10n.errPaymentNotFound,
    'PAYROLL_AMOUNT_EXCEEDS_REMAINING' => l10n.errPayrollExceeds,
    'PAYROLL_ALREADY_PAID' => l10n.errPayrollAlreadyPaid,
    'PAYROLL_PERIOD_IN_FUTURE' => l10n.errPayrollFuture,
    'PAYMENT_DATE_IN_FUTURE' => l10n.errPaymentDateFuture,
    'EXPENSE_NOT_FOUND' => l10n.errExpenseNotFound,
    'EXPENSE_DATE_IN_FUTURE' => l10n.errExpenseDateFuture,
    'INVALID_DATE_RANGE' => l10n.errDateRange,
    'VALIDATION_ERROR' => l10n.errValidation,
    'PERMISSION_DENIED' => l10n.errPermission,
    'NOT_FOUND' => l10n.errNotFound,
    'CONFLICT' => l10n.errConflict,
    'RATE_LIMITED' => l10n.errRateLimited,
    'INTERNAL_ERROR' => l10n.errServer,
    _ when error.statusCode >= 500 => l10n.errServer,
    _ => l10n.errUnknown,
  };
}
