import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tg'),
  ];

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get navStores;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get navEmployees;

  /// No description provided for @navSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get navSalaries;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get navAssistant;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Check the connection and try again.'**
  String get loadError;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @inactiveWithReason.
  ///
  /// In en, this message translates to:
  /// **'Inactive ({reason})'**
  String inactiveWithReason(String reason);

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @allStores.
  ///
  /// In en, this message translates to:
  /// **'All Stores'**
  String get allStores;

  /// No description provided for @amountTjs.
  ///
  /// In en, this message translates to:
  /// **'Amount (TJS)'**
  String get amountTjs;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0'**
  String get enterAmount;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @rowsCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} rows copied as CSV — paste them into Excel'**
  String rowsCopied(int count);

  /// No description provided for @pagerPrev.
  ///
  /// In en, this message translates to:
  /// **'‹ Prev'**
  String get pagerPrev;

  /// No description provided for @pagerNext.
  ///
  /// In en, this message translates to:
  /// **'Next ›'**
  String get pagerNext;

  /// No description provided for @showingRange.
  ///
  /// In en, this message translates to:
  /// **'Showing {from}–{to} of {total}'**
  String showingRange(int from, int to, int total);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @allStoresActive.
  ///
  /// In en, this message translates to:
  /// **'All Stores ({count} Active)'**
  String allStoresActive(int count);

  /// No description provided for @chooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose store'**
  String get chooseStore;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions, stores, staff…'**
  String get searchHint;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'Demo data · API not connected'**
  String get demoBadge;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @salariesWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} salaries waiting to be paid'**
  String salariesWaiting(int count);

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Business Overview'**
  String get businessOverview;

  /// No description provided for @liveAudit.
  ///
  /// In en, this message translates to:
  /// **'LIVE AUDIT'**
  String get liveAudit;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time consolidated performance across all retail branches and capital flows'**
  String get overviewSubtitle;

  /// No description provided for @recordSale.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSale;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today: {date}'**
  String todayDate(String date);

  /// No description provided for @kpiTotalStores.
  ///
  /// In en, this message translates to:
  /// **'Total Stores'**
  String get kpiTotalStores;

  /// No description provided for @nActive.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String nActive(int count);

  /// No description provided for @quarterNew.
  ///
  /// In en, this message translates to:
  /// **'+{count} Q{quarter}'**
  String quarterNew(int count, int quarter);

  /// No description provided for @ofRegistered.
  ///
  /// In en, this message translates to:
  /// **'of {count} registered'**
  String ofRegistered(int count);

  /// No description provided for @kpiTotalStaff.
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get kpiTotalStaff;

  /// No description provided for @nStaff.
  ///
  /// In en, this message translates to:
  /// **'{count} Staff'**
  String nStaff(int count);

  /// No description provided for @onShiftToday.
  ///
  /// In en, this message translates to:
  /// **'on shift today'**
  String get onShiftToday;

  /// No description provided for @kpiTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get kpiTodaySales;

  /// No description provided for @vsYesterday.
  ///
  /// In en, this message translates to:
  /// **'vs yesterday'**
  String get vsYesterday;

  /// No description provided for @kpiWeeklySales.
  ///
  /// In en, this message translates to:
  /// **'Weekly Sales'**
  String get kpiWeeklySales;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target {value}'**
  String target(String value);

  /// No description provided for @kpiMonthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get kpiMonthlySales;

  /// No description provided for @mom.
  ///
  /// In en, this message translates to:
  /// **'MoM'**
  String get mom;

  /// No description provided for @kpiUnpaidSalaries.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Salaries'**
  String get kpiUnpaidSalaries;

  /// No description provided for @nPending.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String nPending(int count);

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'{month} cycle'**
  String cycle(String month);

  /// No description provided for @revenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue & Cashflow Analytics'**
  String get revenueTitle;

  /// No description provided for @revenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily gross revenue trajectory across the current operational month'**
  String get revenueSubtitle;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @peakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak: {day} ({amount})'**
  String peakLabel(String day, String amount);

  /// No description provided for @peakShort.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peakShort;

  /// No description provided for @averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily: '**
  String get averageDaily;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume: '**
  String get totalVolume;

  /// No description provided for @txns.
  ///
  /// In en, this message translates to:
  /// **'{count} txns'**
  String txns(String count);

  /// No description provided for @autoReconciliation.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Automated Reconciliation'**
  String autoReconciliation(String pct);

  /// No description provided for @grossMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit Margin'**
  String get grossMargin;

  /// No description provided for @onlineSplit.
  ///
  /// In en, this message translates to:
  /// **'Online / QR Split'**
  String get onlineSplit;

  /// No description provided for @cardShare.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Card'**
  String cardShare(String pct);

  /// No description provided for @cashVaults.
  ///
  /// In en, this message translates to:
  /// **'Cash in Safe Vaults'**
  String get cashVaults;

  /// No description provided for @topStores.
  ///
  /// In en, this message translates to:
  /// **'Top Stores'**
  String get topStores;

  /// No description provided for @ranked.
  ///
  /// In en, this message translates to:
  /// **'Ranked'**
  String get ranked;

  /// No description provided for @rankedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ranked by monthly sales volume'**
  String get rankedSubtitle;

  /// No description provided for @countersType.
  ///
  /// In en, this message translates to:
  /// **'{type} • {count} Counters'**
  String countersType(String type, int count);

  /// No description provided for @shareValue.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Share'**
  String shareValue(String pct);

  /// No description provided for @viewAllStores.
  ///
  /// In en, this message translates to:
  /// **'View All {count} Stores Directory'**
  String viewAllStores(int count);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Business Activity'**
  String get recentActivity;

  /// No description provided for @liveFeed.
  ///
  /// In en, this message translates to:
  /// **'LIVE FEED'**
  String get liveFeed;

  /// No description provided for @activitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time financial audits, POS register closures, and staff deployments'**
  String get activitySubtitle;

  /// No description provided for @demoFeed.
  ///
  /// In en, this message translates to:
  /// **'Demo feed'**
  String get demoFeed;

  /// No description provided for @syncActive.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sync Active'**
  String get syncActive;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @allActivity.
  ///
  /// In en, this message translates to:
  /// **'All activity'**
  String get allActivity;

  /// No description provided for @activitySales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get activitySales;

  /// No description provided for @activityPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get activityPayroll;

  /// No description provided for @activityAudits.
  ///
  /// In en, this message translates to:
  /// **'Audits'**
  String get activityAudits;

  /// No description provided for @activityStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get activityStaff;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity found'**
  String get noActivity;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {endpoints}'**
  String connectedTo(String endpoints);

  /// No description provided for @demoBackend.
  ///
  /// In en, this message translates to:
  /// **'Demo data — backend not connected yet'**
  String get demoBackend;

  /// No description provided for @salesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FINANCIAL OPERATIONS · TAJIKISTAN ZONE'**
  String get salesEyebrow;

  /// No description provided for @salesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales & Daily Entries'**
  String get salesTitle;

  /// No description provided for @salesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log daily store turnover in Tajikistani Somoni (TJS) and monitor real-time transaction logs.'**
  String get salesSubtitle;

  /// No description provided for @totalToday.
  ///
  /// In en, this message translates to:
  /// **'TOTAL TODAY'**
  String get totalToday;

  /// No description provided for @totalThisMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL THIS MONTH'**
  String get totalThisMonth;

  /// No description provided for @successPrefix.
  ///
  /// In en, this message translates to:
  /// **'Success: '**
  String get successPrefix;

  /// No description provided for @saleSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Daily sales of {amount} recorded for {store}.'**
  String saleSavedMessage(String amount, String store);

  /// No description provided for @sessionClerk.
  ///
  /// In en, this message translates to:
  /// **'Active Session Clerk'**
  String get sessionClerk;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @storeLabel.
  ///
  /// In en, this message translates to:
  /// **'Store:'**
  String get storeLabel;

  /// No description provided for @searchReceipt.
  ///
  /// In en, this message translates to:
  /// **'Search receipt # or notes…'**
  String get searchReceipt;

  /// No description provided for @updatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get updatedJustNow;

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} minutes ago'**
  String updatedMinutesAgo(int count);

  /// No description provided for @activeFilterVolume.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE FILTER VOLUME'**
  String get activeFilterVolume;

  /// No description provided for @filteredTotal.
  ///
  /// In en, this message translates to:
  /// **'Filtered Total: '**
  String get filteredTotal;

  /// No description provided for @acrossEntries.
  ///
  /// In en, this message translates to:
  /// **'  across {count} entries'**
  String acrossEntries(int count);

  /// No description provided for @vsPrevPeriod.
  ///
  /// In en, this message translates to:
  /// **'{pct} vs prev. period'**
  String vsPrevPeriod(String pct);

  /// No description provided for @colDateTime.
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
  String get colDateTime;

  /// No description provided for @colStoreName.
  ///
  /// In en, this message translates to:
  /// **'STORE NAME'**
  String get colStoreName;

  /// No description provided for @colSalesAmount.
  ///
  /// In en, this message translates to:
  /// **'SALES AMOUNT'**
  String get colSalesAmount;

  /// No description provided for @colRegisteredBy.
  ///
  /// In en, this message translates to:
  /// **'REGISTERED BY'**
  String get colRegisteredBy;

  /// No description provided for @colNotesMethod.
  ///
  /// In en, this message translates to:
  /// **'NOTES / METHOD'**
  String get colNotesMethod;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries for this filter'**
  String get noEntries;

  /// No description provided for @hourlyVelocity.
  ///
  /// In en, this message translates to:
  /// **'Hourly Velocity (Today)'**
  String get hourlyVelocity;

  /// No description provided for @reconciliation.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation Compliance'**
  String get reconciliation;

  /// No description provided for @storesSynced.
  ///
  /// In en, this message translates to:
  /// **'{synced} of {total} stores synced today'**
  String storesSynced(int synced, int total);

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @rangeWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get rangeMonth;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get rangeCustom;

  /// No description provided for @newDailySale.
  ///
  /// In en, this message translates to:
  /// **'New Daily Sales Record'**
  String get newDailySale;

  /// No description provided for @posTerminal.
  ///
  /// In en, this message translates to:
  /// **'POS Terminal'**
  String get posTerminal;

  /// No description provided for @selectStore.
  ///
  /// In en, this message translates to:
  /// **'Select Store'**
  String get selectStore;

  /// No description provided for @activeBranches.
  ///
  /// In en, this message translates to:
  /// **'{count} active branches'**
  String activeBranches(int count);

  /// No description provided for @dailySalesAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales Amount'**
  String get dailySalesAmount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5,450.00'**
  String get amountHint;

  /// No description provided for @amountHelper.
  ///
  /// In en, this message translates to:
  /// **'Gross daily register total inclusive of VAT'**
  String get amountHelper;

  /// No description provided for @accountingDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Accounting Date'**
  String get accountingDate;

  /// No description provided for @balanceSplit.
  ///
  /// In en, this message translates to:
  /// **'Primary Balance Split'**
  String get balanceSplit;

  /// No description provided for @splitBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get splitBalanced;

  /// No description provided for @splitPos.
  ///
  /// In en, this message translates to:
  /// **'POS > 80%'**
  String get splitPos;

  /// No description provided for @splitCash.
  ///
  /// In en, this message translates to:
  /// **'Cash Heavy'**
  String get splitCash;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Description / Notes '**
  String get notesLabel;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. End of day cash & POS terminal reconciliation, promo event'**
  String get notesHint;

  /// No description provided for @saveSaleRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Sale Record'**
  String get saveSaleRecord;

  /// No description provided for @syncsTo.
  ///
  /// In en, this message translates to:
  /// **'  Data syncs instantly to REST endpoint '**
  String get syncsTo;

  /// No description provided for @saleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the sale. Try again.'**
  String get saleFailed;

  /// No description provided for @saleRecorded.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded · {date}'**
  String saleRecorded(String date);

  /// No description provided for @storesEyebrow1.
  ///
  /// In en, this message translates to:
  /// **'ENTERPRISE FLEET'**
  String get storesEyebrow1;

  /// No description provided for @storesEyebrow2.
  ///
  /// In en, this message translates to:
  /// **'STORE DIRECTORY'**
  String get storesEyebrow2;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Management'**
  String get storesTitle;

  /// No description provided for @storesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage multi-branch retail locations, track revenue and branch health across regional networks.'**
  String get storesSubtitle;

  /// No description provided for @exportDirectory.
  ///
  /// In en, this message translates to:
  /// **'Export Directory'**
  String get exportDirectory;

  /// No description provided for @addNewStore.
  ///
  /// In en, this message translates to:
  /// **'Add New Store'**
  String get addNewStore;

  /// No description provided for @networkScope.
  ///
  /// In en, this message translates to:
  /// **'Network Scope'**
  String get networkScope;

  /// No description provided for @nLocations.
  ///
  /// In en, this message translates to:
  /// **'{count} Locations'**
  String nLocations(int count);

  /// No description provided for @opRatio.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Op. Ratio'**
  String opRatio(int pct);

  /// No description provided for @activeInactive.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {inactive} inactive'**
  String activeInactive(int active, int inactive);

  /// No description provided for @fleetVelocity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Fleet Velocity'**
  String get fleetVelocity;

  /// No description provided for @allBranchesToday.
  ///
  /// In en, this message translates to:
  /// **'all branches today'**
  String get allBranchesToday;

  /// No description provided for @totalMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Revenue'**
  String get totalMonthlyRevenue;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @allocatedWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Allocated Workforce'**
  String get allocatedWorkforce;

  /// No description provided for @acrossBranches.
  ///
  /// In en, this message translates to:
  /// **'Across {count} branches'**
  String acrossBranches(int count);

  /// No description provided for @noStoresMatch.
  ///
  /// In en, this message translates to:
  /// **'No stores match the filters'**
  String get noStoresMatch;

  /// No description provided for @monthlyVolume.
  ///
  /// In en, this message translates to:
  /// **'Monthly Volume'**
  String get monthlyVolume;

  /// No description provided for @allStatusCounts.
  ///
  /// In en, this message translates to:
  /// **'All Status ({active} Active, {inactive} Inactive)'**
  String allStatusCounts(int active, int inactive);

  /// No description provided for @activeOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only ({count})'**
  String activeOnly(int count);

  /// No description provided for @inactiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Inactive only ({count})'**
  String inactiveOnly(int count);

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores by name, city, phone…'**
  String get searchStores;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by: {label}'**
  String sortBy(String label);

  /// No description provided for @sortRevenue.
  ///
  /// In en, this message translates to:
  /// **'Highest Revenue'**
  String get sortRevenue;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortName;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @deleteStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete store?'**
  String get deleteStoreTitle;

  /// No description provided for @deleteStoreBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed from the directory. Its past sales stay in reports.'**
  String deleteStoreBody(String name);

  /// No description provided for @storeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String storeDeleted(String name);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the store'**
  String get deleteFailed;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics →'**
  String get viewAnalytics;

  /// No description provided for @vsYest.
  ///
  /// In en, this message translates to:
  /// **'{pct} vs yest.'**
  String vsYest(String pct);

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @topEarner.
  ///
  /// In en, this message translates to:
  /// **'Top Earner (#1)'**
  String get topEarner;

  /// No description provided for @staffHeadcount.
  ///
  /// In en, this message translates to:
  /// **'Staff Headcount'**
  String get staffHeadcount;

  /// No description provided for @reassigned.
  ///
  /// In en, this message translates to:
  /// **'0 (reassigned)'**
  String get reassigned;

  /// No description provided for @nEmployees.
  ///
  /// In en, this message translates to:
  /// **'{count} employees'**
  String nEmployees(int count);

  /// No description provided for @regionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Regional Sales Distribution'**
  String get regionalTitle;

  /// No description provided for @regionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live breakdown across {regions}'**
  String regionalSubtitle(String regions);

  /// No description provided for @endpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get endpoint;

  /// No description provided for @branchesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Branch} other{{count} Branches}}'**
  String branchesCount(int count);

  /// No description provided for @nInactive.
  ///
  /// In en, this message translates to:
  /// **'{count} inactive'**
  String nInactive(int count);

  /// No description provided for @capitalOutlets.
  ///
  /// In en, this message translates to:
  /// **'Capital outlets'**
  String get capitalOutlets;

  /// No description provided for @regionalTerritory.
  ///
  /// In en, this message translates to:
  /// **'Regional territory'**
  String get regionalTerritory;

  /// No description provided for @registersSynced.
  ///
  /// In en, this message translates to:
  /// **'✓ All {count} active registers synced'**
  String registersSynced(int count);

  /// No description provided for @opsLog.
  ///
  /// In en, this message translates to:
  /// **'Store Operations Log'**
  String get opsLog;

  /// No description provided for @noOperations.
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get noOperations;

  /// No description provided for @viewAuditTrail.
  ///
  /// In en, this message translates to:
  /// **'View Full Audit Trail →'**
  String get viewAuditTrail;

  /// No description provided for @editStore.
  ///
  /// In en, this message translates to:
  /// **'Edit Store'**
  String get editStore;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Type (Flagship, Mall Express…)'**
  String get storeType;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number'**
  String get enterPhone;

  /// No description provided for @operatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating hours'**
  String get operatingHours;

  /// No description provided for @storeOpen.
  ///
  /// In en, this message translates to:
  /// **'Store is open (active)'**
  String get storeOpen;

  /// No description provided for @addStore.
  ///
  /// In en, this message translates to:
  /// **'Add Store'**
  String get addStore;

  /// No description provided for @storeAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String storeAdded(String name);

  /// No description provided for @storeSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String storeSaved(String name);

  /// No description provided for @storeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the store. Try again.'**
  String get storeSaveFailed;

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySales;

  /// No description provided for @monthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Total'**
  String get monthlyTotal;

  /// No description provided for @velocity7.
  ///
  /// In en, this message translates to:
  /// **'7-Day Sales Velocity'**
  String get velocity7;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg: {amount}/day'**
  String avgPerDay(String amount);

  /// No description provided for @sixDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'6 Days Ago'**
  String get sixDaysAgo;

  /// No description provided for @todayCurrent.
  ///
  /// In en, this message translates to:
  /// **'Today (Current)'**
  String get todayCurrent;

  /// No description provided for @storeParams.
  ///
  /// In en, this message translates to:
  /// **'Store Parameters & Configuration'**
  String get storeParams;

  /// No description provided for @phoneLine.
  ///
  /// In en, this message translates to:
  /// **'Phone Line:'**
  String get phoneLine;

  /// No description provided for @staffAllocation.
  ///
  /// In en, this message translates to:
  /// **'Branch Staff Allocation:'**
  String get staffAllocation;

  /// No description provided for @activeCrew.
  ///
  /// In en, this message translates to:
  /// **'{count} Active Crew'**
  String activeCrew(int count);

  /// No description provided for @apiSync.
  ///
  /// In en, this message translates to:
  /// **'REST API Synchronizer:'**
  String get apiSync;

  /// No description provided for @operatingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating Hours:'**
  String get operatingHoursLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get statusLabel;

  /// No description provided for @recentPos.
  ///
  /// In en, this message translates to:
  /// **'Recent POS Activity'**
  String get recentPos;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @payrollEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ENTERPRISE PORTAL'**
  String get payrollEyebrow;

  /// No description provided for @fiscalYear.
  ///
  /// In en, this message translates to:
  /// **'FISCAL YEAR {year}'**
  String fiscalYear(String year);

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'LEDGER {path}'**
  String ledger(String path);

  /// No description provided for @payrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Salaries & Payroll Management'**
  String get payrollTitle;

  /// No description provided for @payrollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage monthly employee remuneration, record disbursements and track outstanding balances across all regional hubs.'**
  String get payrollSubtitle;

  /// No description provided for @exportLedger.
  ///
  /// In en, this message translates to:
  /// **'Export Ledger'**
  String get exportLedger;

  /// No description provided for @recordSalaryPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Salary Payment'**
  String get recordSalaryPayment;

  /// No description provided for @totalMonthlyPayroll.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Payroll'**
  String get totalMonthlyPayroll;

  /// No description provided for @allocatedBudget.
  ///
  /// In en, this message translates to:
  /// **'Allocated monthly budget'**
  String get allocatedBudget;

  /// No description provided for @totalDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Total Disbursed'**
  String get totalDisbursed;

  /// No description provided for @pctDisbursed.
  ///
  /// In en, this message translates to:
  /// **'{pct}% disbursed'**
  String pctDisbursed(String pct);

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding'**
  String get totalOutstanding;

  /// No description provided for @pctBalance.
  ///
  /// In en, this message translates to:
  /// **'{pct}% balance'**
  String pctBalance(String pct);

  /// No description provided for @pendingClearance.
  ///
  /// In en, this message translates to:
  /// **'Pending clearance'**
  String get pendingClearance;

  /// No description provided for @staffDistribution.
  ///
  /// In en, this message translates to:
  /// **'Staff Distribution'**
  String get staffDistribution;

  /// No description provided for @nBranches.
  ///
  /// In en, this message translates to:
  /// **'{count} Branches'**
  String nBranches(int count);

  /// No description provided for @activeContracts.
  ///
  /// In en, this message translates to:
  /// **'100% active contracts'**
  String get activeContracts;

  /// No description provided for @colEmployee.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEE & POSITION'**
  String get colEmployee;

  /// No description provided for @colAssignedStore.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED STORE'**
  String get colAssignedStore;

  /// No description provided for @colTenure.
  ///
  /// In en, this message translates to:
  /// **'TENURE'**
  String get colTenure;

  /// No description provided for @colMonthlySalary.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY SALARY'**
  String get colMonthlySalary;

  /// No description provided for @colDisbursed.
  ///
  /// In en, this message translates to:
  /// **'DISBURSED'**
  String get colDisbursed;

  /// No description provided for @colRemaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get colRemaining;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get colStatus;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get colActions;

  /// No description provided for @noPayrollFor.
  ///
  /// In en, this message translates to:
  /// **'No payroll for {month} yet'**
  String noPayrollFor(String month);

  /// No description provided for @noEmployeesMatch.
  ///
  /// In en, this message translates to:
  /// **'No employees match the filters'**
  String get noEmployeesMatch;

  /// No description provided for @filteredBatch.
  ///
  /// In en, this message translates to:
  /// **'Filtered Batch: {month}'**
  String filteredBatch(String month);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @prevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @allStoresCount.
  ///
  /// In en, this message translates to:
  /// **'All Stores ({count})'**
  String allStoresCount(int count);

  /// No description provided for @searchStaff.
  ///
  /// In en, this message translates to:
  /// **'Search by staff name or position…'**
  String get searchStaff;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get tabPaid;

  /// No description provided for @tabPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get tabPartial;

  /// No description provided for @tabUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get tabUnpaid;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusPartial;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @tabCount.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String tabCount(String label, int count);

  /// No description provided for @tenure.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mo} other{{count} mos}}'**
  String tenure(int count);

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Budget Allocation'**
  String get budgetTitle;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @openBalance.
  ///
  /// In en, this message translates to:
  /// **'Open balance'**
  String get openBalance;

  /// No description provided for @noPayrollMonth.
  ///
  /// In en, this message translates to:
  /// **'No payroll for this month'**
  String get noPayrollMonth;

  /// No description provided for @storeStaff.
  ///
  /// In en, this message translates to:
  /// **'{store} ({count} staff)'**
  String storeStaff(String store, int count);

  /// No description provided for @erpSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced with ERP General Ledger'**
  String get erpSynced;

  /// No description provided for @recentDisbursements.
  ///
  /// In en, this message translates to:
  /// **'Recent Payroll Disbursements'**
  String get recentDisbursements;

  /// No description provided for @disbursementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time payment audit log across retail branches'**
  String get disbursementsSubtitle;

  /// No description provided for @viewFullAudit.
  ///
  /// In en, this message translates to:
  /// **'View Full Audit →'**
  String get viewFullAudit;

  /// No description provided for @noPaymentsMonth.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded this month'**
  String get noPaymentsMonth;

  /// No description provided for @bankNote.
  ///
  /// In en, this message translates to:
  /// **'All bank settlements follow National Bank standard formats and are signed via TLS.'**
  String get bankNote;

  /// No description provided for @ledgerCopied.
  ///
  /// In en, this message translates to:
  /// **'Ledger for {month} copied as CSV'**
  String ledgerCopied(String month);

  /// No description provided for @methodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get methodBank;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash Disbursement'**
  String get methodCash;

  /// No description provided for @paidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount} to {name}'**
  String paidTo(String amount, String name);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Try again.'**
  String get paymentFailed;

  /// No description provided for @everyonePaid.
  ///
  /// In en, this message translates to:
  /// **'Everyone is fully paid for this month.'**
  String get everyonePaid;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @owed.
  ///
  /// In en, this message translates to:
  /// **'{name} — owed {amount}'**
  String owed(String name, String amount);

  /// No description provided for @salarySummary.
  ///
  /// In en, this message translates to:
  /// **'Salary {salary} · paid {paid} · remaining {remaining}'**
  String salarySummary(String salary, String paid, String remaining);

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max {amount}'**
  String maxAmount(String amount);

  /// No description provided for @paymentsOf.
  ///
  /// In en, this message translates to:
  /// **'{name} — payments'**
  String paymentsOf(String name);

  /// No description provided for @paidBeforeRecords.
  ///
  /// In en, this message translates to:
  /// **'Paid before the records in this app (no separate payments listed).'**
  String get paidBeforeRecords;

  /// No description provided for @employeesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff across all stores and shifts'**
  String get employeesSubtitle;

  /// No description provided for @onShiftNow.
  ///
  /// In en, this message translates to:
  /// **'On shift now'**
  String get onShiftNow;

  /// No description provided for @monthlyPayroll.
  ///
  /// In en, this message translates to:
  /// **'Monthly payroll'**
  String get monthlyPayroll;

  /// No description provided for @staffDirectory.
  ///
  /// In en, this message translates to:
  /// **'Staff directory'**
  String get staffDirectory;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get noEmployees;

  /// No description provided for @onShift.
  ///
  /// In en, this message translates to:
  /// **'On shift'**
  String get onShift;

  /// No description provided for @offShift.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offShift;

  /// No description provided for @analyzeMyReport.
  ///
  /// In en, this message translates to:
  /// **'Analyze my sales report'**
  String get analyzeMyReport;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly performance by store'**
  String get reportsSubtitle;

  /// No description provided for @analyzeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAi;

  /// No description provided for @monthlySalesChange.
  ///
  /// In en, this message translates to:
  /// **'Monthly sales ({pct})'**
  String monthlySalesChange(String pct);

  /// No description provided for @grossMarginShort.
  ///
  /// In en, this message translates to:
  /// **'Gross margin'**
  String get grossMarginShort;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per day'**
  String get averagePerDay;

  /// No description provided for @salesByStore.
  ///
  /// In en, this message translates to:
  /// **'Sales by store'**
  String get salesByStore;

  /// No description provided for @monthlySalesCol.
  ///
  /// In en, this message translates to:
  /// **'Monthly sales'**
  String get monthlySalesCol;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutNote.
  ///
  /// In en, this message translates to:
  /// **'Sign in / sign out will work once the backend login is ready.'**
  String get signOutNote;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @backendConnection.
  ///
  /// In en, this message translates to:
  /// **'Backend connection'**
  String get backendConnection;

  /// No description provided for @demoData.
  ///
  /// In en, this message translates to:
  /// **'Demo data'**
  String get demoData;

  /// No description provided for @demoNote.
  ///
  /// In en, this message translates to:
  /// **'The web shows demo data until the endpoints below are connected.'**
  String get demoNote;

  /// No description provided for @askAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ask your business assistant'**
  String get askAssistant;

  /// No description provided for @assistantIntro.
  ///
  /// In en, this message translates to:
  /// **'Sales, stores, staff, salaries or marketing — ask in Tajik, Russian or English.'**
  String get assistantIntro;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your business…'**
  String get askHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @assistantError.
  ///
  /// In en, this message translates to:
  /// **'The assistant did not answer. Please try again.'**
  String get assistantError;

  /// No description provided for @suggestSales.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get suggestSales;

  /// No description provided for @suggestStores.
  ///
  /// In en, this message translates to:
  /// **'Top stores'**
  String get suggestStores;

  /// No description provided for @suggestSalaries.
  ///
  /// In en, this message translates to:
  /// **'Unpaid salaries'**
  String get suggestSalaries;

  /// No description provided for @suggestMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing ideas'**
  String get suggestMarketing;

  /// No description provided for @chartRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue: {amount}'**
  String chartRevenue(String amount);

  /// No description provided for @chartCashflow.
  ///
  /// In en, this message translates to:
  /// **'Cashflow: {amount}'**
  String chartCashflow(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tg':
      return AppLocalizationsTg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
