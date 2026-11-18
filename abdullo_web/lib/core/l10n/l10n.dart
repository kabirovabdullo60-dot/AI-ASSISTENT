import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';
import '../../models/activity_model.dart';
import '../../models/payroll_model.dart';
import '../../models/store_model.dart';
import '../../viewmodels/payroll_view_model.dart';
import '../../viewmodels/sales_view_model.dart';
import '../../viewmodels/stores_view_model.dart';
import '../navigation/app_section.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Translated texts: `context.l10n.navDashboard`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// All delegates for MaterialApp. Flutter has no built-in Tajik texts for date pickers,
/// "OK/Cancel" etc., so for `tg` those come from Russian (same Cyrillic alphabet).
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  _TgFallback<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
  _TgFallback<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
  _TgFallback<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
];

class _TgFallback<T> extends LocalizationsDelegate<T> {
  const _TgFallback(this.inner);

  final LocalizationsDelegate<T> inner;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<T> load(Locale locale) => inner.load(const Locale('ru'));

  @override
  bool shouldReload(_TgFallback<T> old) => false;
}

extension EnumLabels on AppLocalizations {
  String section(AppSection s) => switch (s) {
    AppSection.dashboard => navDashboard,
    AppSection.stores => navStores,
    AppSection.sales => navSales,
    AppSection.employees => navEmployees,
    AppSection.salaries => navSalaries,
    AppSection.reports => navReports,
    AppSection.assistant => navAssistant,
    AppSection.profile => navProfile,
    AppSection.settings => navSettings,
  };

  String payStatus(PayStatus s) => switch (s) {
    PayStatus.paid => statusPaid,
    PayStatus.partial => statusPartial,
    PayStatus.unpaid => statusUnpaid,
  };

  String activityType(ActivityType t) => switch (t) {
    ActivityType.sale => activitySales,
    ActivityType.payroll => activityPayroll,
    ActivityType.store => activityStores,
    ActivityType.employee => activityStaff,
    ActivityType.profile => activityProfile,
  };

  String activityAction(ActivityAction a) => switch (a) {
    ActivityAction.created => actCreated,
    ActivityAction.updated => actUpdated,
    ActivityAction.deleted => actDeleted,
    ActivityAction.statusChanged => actStatusChanged,
    ActivityAction.paid => actPaid,
    ActivityAction.cancelled => actCancelled,
  };

  String salesRange(SalesRange r) => switch (r) {
    SalesRange.today => rangeToday,
    SalesRange.week => rangeWeek,
    SalesRange.month => rangeMonth,
    SalesRange.custom => rangeCustom,
  };

  String storeSort(StoreSort s) => switch (s) {
    StoreSort.revenue => sortRevenue,
    StoreSort.today => kpiTodaySales,
    StoreSort.name => sortName,
  };

  String payrollTab(PayrollTab t) => switch (t) {
    PayrollTab.all => tabAll,
    PayrollTab.paid => tabPaid,
    PayrollTab.partial => tabPartial,
    PayrollTab.unpaid => tabUnpaid,
  };

  String storeStatus(StoreModel s) => s.isActive ? active : inactive;

  /// Translated text for a backend error code (see the error table in Swagger).
  String error(String code) => switch (code) {
    'AUTH_INVALID_CREDENTIALS' => errInvalidCredentials,
    'EMAIL_ALREADY_REGISTERED' => errEmailTaken,
    'AUTH_ACCOUNT_DISABLED' => errAccountDisabled,
    'AUTH_ACCOUNT_LOCKED' => errAccountLocked,
    'AUTH_REQUIRED' || 'AUTH_SESSION_REVOKED' || 'AUTH_TOKEN_EXPIRED' || 'AUTH_TOKEN_INVALID' => errSessionEnded,
    'PERMISSION_DENIED' => errPermission,
    'NOT_FOUND' || 'STORE_NOT_FOUND' || 'SALE_NOT_FOUND' || 'EMPLOYEE_NOT_FOUND' || 'PAYROLL_NOT_FOUND' => errNotFound,
    'CONFLICT' => errConflict,
    'STORE_NAME_TAKEN' => errStoreNameTaken,
    'STORE_HAS_ACTIVE_EMPLOYEES' => errStoreHasEmployees,
    'PAYROLL_ALREADY_PAID' => errAlreadyPaid,
    'PAYROLL_AMOUNT_EXCEEDS_REMAINING' => errExceedsRemaining,
    'EMPLOYEE_NOT_EMPLOYED_IN_PERIOD' => errNotEmployed,
    'SALE_DATE_IN_FUTURE' || 'PAYMENT_DATE_IN_FUTURE' => errFutureDate,
    'PAYROLL_PERIOD_IN_FUTURE' => errFuturePeriod,
    'INVALID_EMPLOYMENT_DATES' => errEmploymentDates,
    'INVALID_DATE_RANGE' => errDateRange,
    'PASSWORD_TOO_WEAK' => errPasswordWeak,
    'CURRENT_PASSWORD_INCORRECT' => errCurrentPassword,
    'AVATAR_INVALID_TYPE' || 'UNSUPPORTED_MEDIA_TYPE' => errAvatarType,
    'AVATAR_TOO_LARGE' || 'PAYLOAD_TOO_LARGE' => errAvatarSize,
    'VALIDATION_ERROR' => errValidationShort,
    'NETWORK_ERROR' => errNetwork,
    'RATE_LIMITED' => errRateLimited,
    'INTERNAL_ERROR' => errServer,
    _ => errUnknown(code),
  };
}

/// Shows a translated error (or success) message at the bottom of the screen.
void showResult(BuildContext context, String? errorCode, {required String success}) {
  final tr = context.l10n;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(errorCode == null ? success : tr.error(errorCode)),
        backgroundColor: errorCode == null ? null : const Color(0xFFB91C1C),
      ),
    );
}
