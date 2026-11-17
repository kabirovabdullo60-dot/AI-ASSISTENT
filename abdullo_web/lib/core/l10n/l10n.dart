import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';
import '../../models/activity_model.dart';
import '../../models/payroll_model.dart';
import '../../models/sale_model.dart';
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

/// Translated names for enums used on screen.
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

  String split(BalanceSplit s) => switch (s) {
    BalanceSplit.balanced => splitBalanced,
    BalanceSplit.posHeavy => splitPos,
    BalanceSplit.cashHeavy => splitCash,
  };

  String payStatus(PayStatus s) => switch (s) {
    PayStatus.paid => statusPaid,
    PayStatus.partial => statusPartial,
    PayStatus.unpaid => statusUnpaid,
  };

  String activityType(ActivityType t) => switch (t) {
    ActivityType.sale => activitySales,
    ActivityType.payroll => activityPayroll,
    ActivityType.audit => activityAudits,
    ActivityType.staff => activityStaff,
  };

  /// Payment method names come from the backend in English.
  String paymentMethod(String method) => switch (method) {
    'Bank Transfer' => methodBank,
    'Cash Disbursement' => methodCash,
    _ => method,
  };
}

extension ViewModelLabels on AppLocalizations {
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

  String storeStatus(StoreModel s) =>
      s.isActive ? active : (s.statusNote.isEmpty ? inactive : inactiveWithReason(s.statusNote));
}
