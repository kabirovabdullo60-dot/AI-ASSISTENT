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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OFAR'**
  String get appTitle;

  /// No description provided for @introTitle.
  ///
  /// In en, this message translates to:
  /// **'AI accountant'**
  String get introTitle;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmptyTitle;

  /// No description provided for @commonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get commonErrorTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get commonShowMore;

  /// No description provided for @commonNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get commonNothingFound;

  /// No description provided for @fieldShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get fieldShowPassword;

  /// No description provided for @fieldHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get fieldHidePassword;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navPayroll.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get navPayroll;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get navStores;

  /// No description provided for @navEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get navEmployees;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile and settings'**
  String get navProfile;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickActionsTitle;

  /// No description provided for @actionNewSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get actionNewSale;

  /// No description provided for @actionPaySalary.
  ///
  /// In en, this message translates to:
  /// **'Pay salary'**
  String get actionPaySalary;

  /// No description provided for @actionNewStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get actionNewStore;

  /// No description provided for @actionNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get actionNewEmployee;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep working with your business finances'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterTab.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterTab;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI accountant for tracking income and expenses'**
  String get authRegisterSubtitle;

  /// No description provided for @fieldWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Work e-mail'**
  String get fieldWorkEmail;

  /// No description provided for @authPasswordMinHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordMinHint;

  /// No description provided for @validationPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get validationPasswordMin;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get authPasswordRepeat;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get authSignOutConfirmTitle;

  /// No description provided for @authSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need your e-mail and password to sign in again.'**
  String get authSignOutConfirmMessage;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.tj'**
  String get fieldEmailHint;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get fieldBusinessName;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+992 90 123 45 67'**
  String get fieldPhoneHint;

  /// No description provided for @fieldOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// No description provided for @fieldStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get fieldStore;

  /// No description provided for @fieldChooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose a store'**
  String get fieldChooseStore;

  /// No description provided for @fieldStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get fieldStoreName;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get fieldPeriod;

  /// No description provided for @fieldPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get fieldPosition;

  /// No description provided for @fieldMonthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary'**
  String get fieldMonthlySalary;

  /// No description provided for @fieldHiredAt.
  ///
  /// In en, this message translates to:
  /// **'Hired on'**
  String get fieldHiredAt;

  /// No description provided for @fieldTerminatedAt.
  ///
  /// In en, this message translates to:
  /// **'Left on'**
  String get fieldTerminatedAt;

  /// No description provided for @fieldPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get fieldPaymentDate;

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Fill in this field'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid e-mail'**
  String get validationEmail;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'7–15 digits, may start with +'**
  String get validationPhone;

  /// No description provided for @validationAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0 (up to 2 decimals)'**
  String get validationAmount;

  /// No description provided for @validationPasswordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get validationPasswordsDiffer;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @homeMonthSales.
  ///
  /// In en, this message translates to:
  /// **'Sales this month'**
  String get homeMonthSales;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeWeek;

  /// No description provided for @homeRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue today'**
  String get homeRevenueToday;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get periodPrevious;

  /// No description provided for @periodNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get periodNext;

  /// No description provided for @homePeriodSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get homePeriodSales;

  /// No description provided for @homeAverageSale.
  ///
  /// In en, this message translates to:
  /// **'Average sale'**
  String get homeAverageSale;

  /// No description provided for @homeNoComparison.
  ///
  /// In en, this message translates to:
  /// **'Nothing to compare yet'**
  String get homeNoComparison;

  /// No description provided for @homeChange.
  ///
  /// In en, this message translates to:
  /// **'{change} {compare}'**
  String homeChange(String change, String compare);

  /// No description provided for @compareToday.
  ///
  /// In en, this message translates to:
  /// **'vs yesterday'**
  String get compareToday;

  /// No description provided for @compareWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get compareWeek;

  /// No description provided for @compareMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get compareMonth;

  /// No description provided for @homeSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries this month'**
  String get homeSalaries;

  /// No description provided for @homeRemainingTotal.
  ///
  /// In en, this message translates to:
  /// **'Unpaid for all months: {amount}'**
  String homeRemainingTotal(String amount);

  /// No description provided for @homeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Stores and employees'**
  String get homeBusiness;

  /// No description provided for @homeOfTotal.
  ///
  /// In en, this message translates to:
  /// **'active of {total}'**
  String homeOfTotal(int total);

  /// No description provided for @homeTopStores.
  ///
  /// In en, this message translates to:
  /// **'Top stores this month'**
  String get homeTopStores;

  /// No description provided for @homeShowAll.
  ///
  /// In en, this message translates to:
  /// **'All sales'**
  String get homeShowAll;

  /// No description provided for @homeNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales yet.'**
  String get homeNoSales;

  /// No description provided for @salesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sales} one{{count} sale} other{{count} sales}}'**
  String salesCount(int count);

  /// No description provided for @salesTotal.
  ///
  /// In en, this message translates to:
  /// **'Sales total'**
  String get salesTotal;

  /// No description provided for @salesAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get salesAllStores;

  /// No description provided for @salesAllDates.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get salesAllDates;

  /// No description provided for @salesClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset filter'**
  String get salesClearFilter;

  /// No description provided for @salesNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No sales for this filter.'**
  String get salesNothingFound;

  /// No description provided for @salesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get salesEmptyTitle;

  /// No description provided for @salesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Record the first sale of a store.'**
  String get salesEmptyMessage;

  /// No description provided for @saleNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get saleNewTitle;

  /// No description provided for @saleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get saleEditTitle;

  /// No description provided for @saleNoStores.
  ///
  /// In en, this message translates to:
  /// **'Add a store first'**
  String get saleNoStores;

  /// No description provided for @saleSaved.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded'**
  String get saleSaved;

  /// No description provided for @saleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sale updated'**
  String get saleUpdated;

  /// No description provided for @saleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sale deleted'**
  String get saleDeleted;

  /// No description provided for @saleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the sale?'**
  String get saleDeleteTitle;

  /// No description provided for @saleDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'It will no longer count in sales and reports.'**
  String get saleDeleteMessage;

  /// No description provided for @storesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or address'**
  String get storesSearch;

  /// No description provided for @storesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stores yet'**
  String get storesEmptyTitle;

  /// No description provided for @storesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first store to record its sales.'**
  String get storesEmptyMessage;

  /// No description provided for @storeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New store'**
  String get storeNewTitle;

  /// No description provided for @storeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit store'**
  String get storeEditTitle;

  /// No description provided for @storeSaved.
  ///
  /// In en, this message translates to:
  /// **'Store saved'**
  String get storeSaved;

  /// No description provided for @storeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Store deleted. Its sales stay in reports.'**
  String get storeDeleted;

  /// No description provided for @storeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the store?'**
  String get storeDeleteTitle;

  /// No description provided for @storeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Its sales history is kept. A store with working employees cannot be deleted.'**
  String get storeDeleteMessage;

  /// No description provided for @storeLatestSales.
  ///
  /// In en, this message translates to:
  /// **'Latest sales'**
  String get storeLatestSales;

  /// No description provided for @storeNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees in this store.'**
  String get storeNoEmployees;

  /// No description provided for @employeesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get employeesSearch;

  /// No description provided for @employeesActive.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get employeesActive;

  /// No description provided for @employeesSalaryFund.
  ///
  /// In en, this message translates to:
  /// **'Salaries per month'**
  String get employeesSalaryFund;

  /// No description provided for @employeesAverage.
  ///
  /// In en, this message translates to:
  /// **'Average {amount}'**
  String employeesAverage(String amount);

  /// No description provided for @employeesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get employeesEmptyTitle;

  /// No description provided for @employeesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add employees to keep track of their salaries.'**
  String get employeesEmptyMessage;

  /// No description provided for @employeeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get employeeNewTitle;

  /// No description provided for @employeeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employeeEditTitle;

  /// No description provided for @employeeSaved.
  ///
  /// In en, this message translates to:
  /// **'Employee saved'**
  String get employeeSaved;

  /// No description provided for @employeeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Employee deleted. Their salary history stays.'**
  String get employeeDeleted;

  /// No description provided for @employeeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the employee?'**
  String get employeeDeleteTitle;

  /// No description provided for @employeeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The salary history is kept.'**
  String get employeeDeleteMessage;

  /// No description provided for @payrollPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payrollPaid;

  /// No description provided for @payrollPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get payrollPartial;

  /// No description provided for @payrollUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get payrollUnpaid;

  /// No description provided for @payrollDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get payrollDue;

  /// No description provided for @payrollDueTotal.
  ///
  /// In en, this message translates to:
  /// **'Due in total'**
  String get payrollDueTotal;

  /// No description provided for @payrollPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payrollPaidAmount;

  /// No description provided for @payrollRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get payrollRemaining;

  /// No description provided for @payrollCounts.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} · partly {partial} · not paid {unpaid}'**
  String payrollCounts(int paid, int partial, int unpaid);

  /// No description provided for @payrollLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String payrollLeft(String amount);

  /// No description provided for @payrollEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No salaries this month'**
  String get payrollEmptyTitle;

  /// No description provided for @payrollEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Employees who worked this month appear here.'**
  String get payrollEmptyMessage;

  /// No description provided for @payrollHistory.
  ///
  /// In en, this message translates to:
  /// **'Salary history'**
  String get payrollHistory;

  /// No description provided for @payrollMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get payrollMonths;

  /// No description provided for @payrollPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payrollPayments;

  /// No description provided for @payrollNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get payrollNoPayments;

  /// No description provided for @payrollPaidOf.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {due}'**
  String payrollPaidOf(String paid, String due);

  /// No description provided for @payrollPaidSoFar.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String payrollPaidSoFar(String amount);

  /// No description provided for @payrollMonthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary {amount} per month'**
  String payrollMonthlySalary(String amount);

  /// No description provided for @payrollWorkedDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day worked} other{{count} days worked}}'**
  String payrollWorkedDays(int count);

  /// No description provided for @payrollMonthsWorked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month} other{{count} months}}'**
  String payrollMonthsWorked(int count);

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary payment'**
  String get paymentTitle;

  /// No description provided for @paymentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentSubmit;

  /// No description provided for @paymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentSaved;

  /// No description provided for @paymentAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'This month is already paid in full.'**
  String get paymentAlreadyPaid;

  /// No description provided for @paymentFor.
  ///
  /// In en, this message translates to:
  /// **'for {period}'**
  String paymentFor(String period);

  /// No description provided for @paymentCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get paymentCancel;

  /// No description provided for @paymentCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the payment?'**
  String get paymentCancelTitle;

  /// No description provided for @paymentCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} will count as not paid again.'**
  String paymentCancelMessage(String amount);

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// No description provided for @reportStores.
  ///
  /// In en, this message translates to:
  /// **'Stores this month'**
  String get reportStores;

  /// No description provided for @reportStoresPeriod.
  ///
  /// In en, this message translates to:
  /// **'Sales {start} – {end}'**
  String reportStoresPeriod(String start, String end);

  /// No description provided for @reportPayroll.
  ///
  /// In en, this message translates to:
  /// **'Salaries by year'**
  String get reportPayroll;

  /// No description provided for @reportEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees by store and position'**
  String get reportEmployees;

  /// No description provided for @reportEmployeesCount.
  ///
  /// In en, this message translates to:
  /// **'{active} working of {total}'**
  String reportEmployeesCount(int active, int total);

  /// No description provided for @moreBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get moreBusiness;

  /// No description provided for @moreAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccount;

  /// No description provided for @moreStoresHint.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, see sales and staff'**
  String get moreStoresHint;

  /// No description provided for @moreEmployeesHint.
  ///
  /// In en, this message translates to:
  /// **'Staff, positions and salaries'**
  String get moreEmployeesHint;

  /// No description provided for @moreReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Stores compared, salaries by year'**
  String get moreReportsHint;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileAvatarSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get profileAvatarSaved;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Business and contacts'**
  String get profileDetails;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get profileCurrency;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'As on the phone'**
  String get profileLanguageSystem;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordTitle;

  /// No description provided for @passwordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @passwordNote.
  ///
  /// In en, this message translates to:
  /// **'Other devices will be signed out. This one stays signed in.'**
  String get passwordNote;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check the internet and try again.'**
  String get errNetwork;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong e-mail or password.'**
  String get errInvalidCredentials;

  /// No description provided for @errAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in 15 minutes.'**
  String get errAccountLocked;

  /// No description provided for @errAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled.'**
  String get errAccountDisabled;

  /// No description provided for @errSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'The session has ended. Please sign in again.'**
  String get errSessionEnded;

  /// No description provided for @errEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this e-mail already exists.'**
  String get errEmailTaken;

  /// No description provided for @errPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak. Use a longer one with letters and digits.'**
  String get errPasswordWeak;

  /// No description provided for @errCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is wrong.'**
  String get errCurrentPassword;

  /// No description provided for @errAvatarTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo is too large (at most 5 MB).'**
  String get errAvatarTooLarge;

  /// No description provided for @errAvatarType.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPEG, PNG or WebP photo.'**
  String get errAvatarType;

  /// No description provided for @errStoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'The store was not found. It may have been deleted.'**
  String get errStoreNotFound;

  /// No description provided for @errStoreNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A store with this name already exists.'**
  String get errStoreNameTaken;

  /// No description provided for @errStoreHasEmployees.
  ///
  /// In en, this message translates to:
  /// **'This store has working employees. Move them to another store or mark them inactive first.'**
  String get errStoreHasEmployees;

  /// No description provided for @errSaleNotFound.
  ///
  /// In en, this message translates to:
  /// **'The sale was not found. It may have been deleted.'**
  String get errSaleNotFound;

  /// No description provided for @errSaleDateFuture.
  ///
  /// In en, this message translates to:
  /// **'A sale cannot be dated in the future.'**
  String get errSaleDateFuture;

  /// No description provided for @errEmployeeNotFound.
  ///
  /// In en, this message translates to:
  /// **'The employee was not found. They may have been deleted.'**
  String get errEmployeeNotFound;

  /// No description provided for @errEmploymentDates.
  ///
  /// In en, this message translates to:
  /// **'The leaving date must be after the hiring date.'**
  String get errEmploymentDates;

  /// No description provided for @errNotEmployedInPeriod.
  ///
  /// In en, this message translates to:
  /// **'The employee did not work in this month.'**
  String get errNotEmployedInPeriod;

  /// No description provided for @errPaymentNotFound.
  ///
  /// In en, this message translates to:
  /// **'The payment was not found. It may have been cancelled.'**
  String get errPaymentNotFound;

  /// No description provided for @errPayrollExceeds.
  ///
  /// In en, this message translates to:
  /// **'The amount is more than is left to pay for this month.'**
  String get errPayrollExceeds;

  /// No description provided for @errPayrollAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'This month is already paid in full.'**
  String get errPayrollAlreadyPaid;

  /// No description provided for @errPayrollFuture.
  ///
  /// In en, this message translates to:
  /// **'A future month cannot be paid yet.'**
  String get errPayrollFuture;

  /// No description provided for @errPaymentDateFuture.
  ///
  /// In en, this message translates to:
  /// **'The payment date cannot be in the future.'**
  String get errPaymentDateFuture;

  /// No description provided for @errDateRange.
  ///
  /// In en, this message translates to:
  /// **'The start date must not be after the end date.'**
  String get errDateRange;

  /// No description provided for @errValidation.
  ///
  /// In en, this message translates to:
  /// **'Some fields are filled in wrongly. Check them and try again.'**
  String get errValidation;

  /// No description provided for @errPermission.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this.'**
  String get errPermission;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. It may have been deleted.'**
  String get errNotFound;

  /// No description provided for @errConflict.
  ///
  /// In en, this message translates to:
  /// **'This conflicts with the current data. Refresh and try again.'**
  String get errConflict;

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a little and try again.'**
  String get errRateLimited;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding properly. Try again later.'**
  String get errServer;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errUnknown;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @moreExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Rent, utilities, delivery and more'**
  String get moreExpensesHint;

  /// No description provided for @actionNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get actionNewExpense;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @expenseCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCategoryRent;

  /// No description provided for @expenseCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get expenseCategoryUtilities;

  /// No description provided for @expenseCategoryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get expenseCategoryDelivery;

  /// No description provided for @expenseCategorySupplies.
  ///
  /// In en, this message translates to:
  /// **'Supplies'**
  String get expenseCategorySupplies;

  /// No description provided for @expenseCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get expenseCategoryMarketing;

  /// No description provided for @expenseCategoryTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get expenseCategoryTaxes;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @expensesAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expensesAllCategories;

  /// No description provided for @expenseWholeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Whole business'**
  String get expenseWholeBusiness;

  /// No description provided for @expensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get expensesTotal;

  /// No description provided for @expensesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No expenses} one{{count} expense} other{{count} expenses}}'**
  String expensesCount(int count);

  /// No description provided for @expensesNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this filter.'**
  String get expensesNothingFound;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Record rent, utilities and other costs to see your real profit.'**
  String get expensesEmptyMessage;

  /// No description provided for @expenseNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseNewTitle;

  /// No description provided for @expenseEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseEditTitle;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense added'**
  String get expenseSaved;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @expenseDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the expense?'**
  String get expenseDeleteTitle;

  /// No description provided for @expenseDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'It will no longer count in expenses and profit.'**
  String get expenseDeleteMessage;

  /// No description provided for @errExpenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'This expense no longer exists.'**
  String get errExpenseNotFound;

  /// No description provided for @errExpenseDateFuture.
  ///
  /// In en, this message translates to:
  /// **'The expense date can\'t be in the future.'**
  String get errExpenseDateFuture;

  /// No description provided for @reportProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reportProfit;

  /// No description provided for @profitSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get profitSales;

  /// No description provided for @profitExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get profitExpenses;

  /// No description provided for @profitSalaryDue.
  ///
  /// In en, this message translates to:
  /// **'Salaries due'**
  String get profitSalaryDue;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin {percent}'**
  String profitMargin(String percent);

  /// No description provided for @profitNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period'**
  String get profitNoSales;

  /// No description provided for @profitByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get profitByCategory;

  /// No description provided for @profitByStore.
  ///
  /// In en, this message translates to:
  /// **'Profit by store'**
  String get profitByStore;

  /// No description provided for @profitNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period.'**
  String get profitNoExpenses;

  /// No description provided for @profitStoreLine.
  ///
  /// In en, this message translates to:
  /// **'Sales {sales} · expenses {expenses} · salaries {salary}'**
  String profitStoreLine(String sales, String expenses, String salary);

  /// No description provided for @homeTargetsProfit.
  ///
  /// In en, this message translates to:
  /// **'Targets & profit'**
  String get homeTargetsProfit;

  /// No description provided for @homeMonthProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit this month'**
  String get homeMonthProfit;

  /// No description provided for @homeProfitCaption.
  ///
  /// In en, this message translates to:
  /// **'Expenses {expenses} · {margin}'**
  String homeProfitCaption(String expenses, String margin);

  /// No description provided for @targetWeek.
  ///
  /// In en, this message translates to:
  /// **'Weekly target'**
  String get targetWeek;

  /// No description provided for @targetMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly target'**
  String get targetMonth;

  /// No description provided for @targetNotSet.
  ///
  /// In en, this message translates to:
  /// **'Set a target'**
  String get targetNotSet;

  /// No description provided for @targetDone.
  ///
  /// In en, this message translates to:
  /// **'{percent} reached'**
  String targetDone(String percent);

  /// No description provided for @targetSheetTitleWeek.
  ///
  /// In en, this message translates to:
  /// **'Sales target for a week'**
  String get targetSheetTitleWeek;

  /// No description provided for @targetSheetTitleMonth.
  ///
  /// In en, this message translates to:
  /// **'Sales target for a month'**
  String get targetSheetTitleMonth;

  /// No description provided for @targetSheetHint.
  ///
  /// In en, this message translates to:
  /// **'For the whole business. You can change it any time.'**
  String get targetSheetHint;

  /// No description provided for @targetSaved.
  ///
  /// In en, this message translates to:
  /// **'Target saved'**
  String get targetSaved;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get activityTitle;

  /// No description provided for @activityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations log'**
  String get activityLogTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No changes yet.'**
  String get activityEmpty;

  /// No description provided for @activityStoreCreated.
  ///
  /// In en, this message translates to:
  /// **'Store “{name}” added'**
  String activityStoreCreated(String name);

  /// No description provided for @activityStoreUpdated.
  ///
  /// In en, this message translates to:
  /// **'Store “{name}” edited'**
  String activityStoreUpdated(String name);

  /// No description provided for @activityStoreDeleted.
  ///
  /// In en, this message translates to:
  /// **'Store “{name}” deleted'**
  String activityStoreDeleted(String name);

  /// No description provided for @activityStoreStatus.
  ///
  /// In en, this message translates to:
  /// **'Store “{name}”: {status}'**
  String activityStoreStatus(String name, String status);

  /// No description provided for @activitySaleCreated.
  ///
  /// In en, this message translates to:
  /// **'Sale in “{name}”'**
  String activitySaleCreated(String name);

  /// No description provided for @activitySaleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sale in “{name}” edited'**
  String activitySaleUpdated(String name);

  /// No description provided for @activitySaleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sale in “{name}” deleted'**
  String activitySaleDeleted(String name);

  /// No description provided for @activityEmployeeCreated.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} added'**
  String activityEmployeeCreated(String name);

  /// No description provided for @activityEmployeeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} edited'**
  String activityEmployeeUpdated(String name);

  /// No description provided for @activityEmployeeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} deleted'**
  String activityEmployeeDeleted(String name);

  /// No description provided for @activityEmployeeStatus.
  ///
  /// In en, this message translates to:
  /// **'{name}: {status}'**
  String activityEmployeeStatus(String name, String status);

  /// No description provided for @activityPayrollPaid.
  ///
  /// In en, this message translates to:
  /// **'Salary paid: {name}'**
  String activityPayrollPaid(String name);

  /// No description provided for @activityPayrollCancelled.
  ///
  /// In en, this message translates to:
  /// **'Salary payment cancelled: {name}'**
  String activityPayrollCancelled(String name);

  /// No description provided for @activityProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get activityProfileUpdated;

  /// No description provided for @activityOther.
  ///
  /// In en, this message translates to:
  /// **'{name}: changed'**
  String activityOther(String name);

  /// No description provided for @activityBy.
  ///
  /// In en, this message translates to:
  /// **'{actor} · {time}'**
  String activityBy(String actor, String time);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'All good: nothing needs attention.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNew;

  /// No description provided for @notifSalaryOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue salaries'**
  String get notifSalaryOverdueTitle;

  /// No description provided for @notifSalaryOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'{count} unpaid employee-months from earlier months · {amount}'**
  String notifSalaryOverdueBody(int count, String amount);

  /// No description provided for @notifUnpaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Salaries to pay this month'**
  String get notifUnpaidTitle;

  /// No description provided for @notifUnpaidBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 employee still to pay} other{{count} employees still to pay}} · {amount}'**
  String notifUnpaidBody(int count, String amount);

  /// No description provided for @notifNoSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales today'**
  String get notifNoSalesTitle;

  /// No description provided for @notifNoSalesBody.
  ///
  /// In en, this message translates to:
  /// **'“{store}” has no sales recorded today.'**
  String notifNoSalesBody(String store);

  /// No description provided for @notifOther.
  ///
  /// In en, this message translates to:
  /// **'Something needs attention'**
  String get notifOther;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get assistantTitle;

  /// No description provided for @moreAssistantHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your sales, stores and salaries'**
  String get moreAssistantHint;

  /// No description provided for @assistantIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask me about your money or your business — I answer from your real figures.'**
  String get assistantIntro;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'Your question…'**
  String get assistantHint;

  /// No description provided for @assistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get assistantSend;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get assistantThinking;

  /// No description provided for @assistantSuggestToday.
  ///
  /// In en, this message translates to:
  /// **'How are my sales today?'**
  String get assistantSuggestToday;

  /// No description provided for @assistantSuggestBestStore.
  ///
  /// In en, this message translates to:
  /// **'Which store sells best?'**
  String get assistantSuggestBestStore;

  /// No description provided for @assistantSuggestSalary.
  ///
  /// In en, this message translates to:
  /// **'How much salary is still unpaid?'**
  String get assistantSuggestSalary;

  /// No description provided for @errAssistantUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The assistant is not available right now. Try again later.'**
  String get errAssistantUnavailable;

  /// No description provided for @errAssistantRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many questions. Wait {seconds} s and try again.'**
  String errAssistantRateLimited(int seconds);

  /// No description provided for @fieldPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get fieldPaymentMethod;

  /// No description provided for @paymentNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get paymentNotSet;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @paymentQr.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get paymentQr;

  /// No description provided for @paymentMixed.
  ///
  /// In en, this message translates to:
  /// **'Cash + card'**
  String get paymentMixed;

  /// No description provided for @fieldCashAmount.
  ///
  /// In en, this message translates to:
  /// **'Of it in cash'**
  String get fieldCashAmount;

  /// No description provided for @fieldCardAmount.
  ///
  /// In en, this message translates to:
  /// **'Of it by card'**
  String get fieldCardAmount;

  /// No description provided for @fieldReceiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt number'**
  String get fieldReceiptNumber;

  /// No description provided for @validationSplit.
  ///
  /// In en, this message translates to:
  /// **'Cash and card must add up to the amount'**
  String get validationSplit;

  /// No description provided for @errSaleSplit.
  ///
  /// In en, this message translates to:
  /// **'Cash and card must add up to the amount.'**
  String get errSaleSplit;

  /// No description provided for @homeByPayment.
  ///
  /// In en, this message translates to:
  /// **'By payment method'**
  String get homeByPayment;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get fieldRegion;

  /// No description provided for @fieldRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Dushanbe, Sughd, Khatlon, GBAO, RRS'**
  String get fieldRegionHint;

  /// No description provided for @fieldStoreType.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get fieldStoreType;

  /// No description provided for @fieldStoreTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Supermarket, kiosk…'**
  String get fieldStoreTypeHint;

  /// No description provided for @fieldCounters.
  ///
  /// In en, this message translates to:
  /// **'Checkout counters'**
  String get fieldCounters;

  /// No description provided for @fieldOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get fieldOpeningHours;

  /// No description provided for @fieldOpeningHoursHint.
  ///
  /// In en, this message translates to:
  /// **'09:00–21:00'**
  String get fieldOpeningHoursHint;

  /// No description provided for @fieldStatusNote.
  ///
  /// In en, this message translates to:
  /// **'Status reason'**
  String get fieldStatusNote;

  /// No description provided for @fieldStatusNoteHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. renovation'**
  String get fieldStatusNoteHint;

  /// No description provided for @validationCounters.
  ///
  /// In en, this message translates to:
  /// **'A whole number from 0 to 999'**
  String get validationCounters;

  /// No description provided for @storeMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get storeMoreDetails;

  /// No description provided for @fieldSalaryMethod.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get fieldSalaryMethod;

  /// No description provided for @salaryMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get salaryMethodBank;

  /// No description provided for @salaryMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get salaryMethodCash;

  /// No description provided for @payrollAllTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Unpaid salaries, all months'**
  String get payrollAllTimeRemaining;

  /// No description provided for @payrollAllTimeCaption.
  ///
  /// In en, this message translates to:
  /// **'Due {due} · paid {paid}'**
  String payrollAllTimeCaption(String due, String paid);

  /// No description provided for @reportByRegion.
  ///
  /// In en, this message translates to:
  /// **'By region'**
  String get reportByRegion;

  /// No description provided for @reportNoRegion.
  ///
  /// In en, this message translates to:
  /// **'No region'**
  String get reportNoRegion;

  /// No description provided for @reportRegionStores.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 store} other{{count} stores}}'**
  String reportRegionStores(int count);

  /// No description provided for @homeTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get homeTodaySales;

  /// No description provided for @homeMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeMonth;

  /// No description provided for @storeTargets.
  ///
  /// In en, this message translates to:
  /// **'Store targets'**
  String get storeTargets;

  /// No description provided for @targetSheetHintStore.
  ///
  /// In en, this message translates to:
  /// **'For this store only. You can change it any time.'**
  String get targetSheetHintStore;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get activityHistory;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice chat'**
  String get voiceTitle;

  /// No description provided for @voiceOpen.
  ///
  /// In en, this message translates to:
  /// **'Talk by voice'**
  String get voiceOpen;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Answering…'**
  String get voiceSpeaking;

  /// No description provided for @voiceTapToTalk.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and speak'**
  String get voiceTapToTalk;

  /// No description provided for @voiceHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything: “employees”, “sales today”, “how much salary is left?”'**
  String get voiceHint;

  /// No description provided for @voiceMic.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get voiceMic;

  /// No description provided for @voiceEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get voiceEnd;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available. Allow the microphone and speech recognition in Settings.'**
  String get voiceUnavailable;

  /// No description provided for @voiceMicFailed.
  ///
  /// In en, this message translates to:
  /// **'The microphone didn\'t start. Try again; if it keeps happening, check the microphone permission in Settings.'**
  String get voiceMicFailed;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @chatNew.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNew;

  /// No description provided for @chatHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with the assistant will be kept here.'**
  String get chatHistoryEmpty;

  /// No description provided for @chatDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get chatDeleteAll;

  /// No description provided for @chatDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all chats?'**
  String get chatDeleteAllTitle;

  /// No description provided for @chatDeleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'The history is kept only on this phone; it can\'t be restored.'**
  String get chatDeleteAllMessage;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chatDeleted;

  /// No description provided for @chatCurrent.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get chatCurrent;

  /// No description provided for @homeStores.
  ///
  /// In en, this message translates to:
  /// **'Stores · {count}'**
  String homeStores(int count);

  /// No description provided for @homeStoreMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeStoreMonth;

  /// No description provided for @homeAddStore.
  ///
  /// In en, this message translates to:
  /// **'Add a store'**
  String get homeAddStore;

  /// No description provided for @homeProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get homeProfit;

  /// No description provided for @homeShowAllStores.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeShowAllStores;

  /// No description provided for @historyExpensesFor.
  ///
  /// In en, this message translates to:
  /// **'Expenses in {month}'**
  String historyExpensesFor(String month);

  /// No description provided for @historyOfSales.
  ///
  /// In en, this message translates to:
  /// **'{percent} of sales'**
  String historyOfSales(String percent);

  /// No description provided for @historyStatement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get historyStatement;

  /// No description provided for @historyShowAmount.
  ///
  /// In en, this message translates to:
  /// **'Show the amount'**
  String get historyShowAmount;

  /// No description provided for @historyHideAmount.
  ///
  /// In en, this message translates to:
  /// **'Hide the amount'**
  String get historyHideAmount;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get historySearch;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Store, employee or note'**
  String get historySearchHint;

  /// No description provided for @historyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyAll;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get historyWeek;

  /// No description provided for @historyNothing.
  ///
  /// In en, this message translates to:
  /// **'No operations for this period.'**
  String get historyNothing;

  /// No description provided for @opSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get opSale;

  /// No description provided for @opSaleEdited.
  ///
  /// In en, this message translates to:
  /// **'Sale edited'**
  String get opSaleEdited;

  /// No description provided for @opSaleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sale deleted'**
  String get opSaleDeleted;

  /// No description provided for @opSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary paid'**
  String get opSalary;

  /// No description provided for @opSalaryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get opSalaryCancelled;

  /// No description provided for @opStoreNew.
  ///
  /// In en, this message translates to:
  /// **'New store'**
  String get opStoreNew;

  /// No description provided for @opStoreEdited.
  ///
  /// In en, this message translates to:
  /// **'Store edited'**
  String get opStoreEdited;

  /// No description provided for @opStoreDeleted.
  ///
  /// In en, this message translates to:
  /// **'Store deleted'**
  String get opStoreDeleted;

  /// No description provided for @opEmployeeNew.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get opEmployeeNew;

  /// No description provided for @opEmployeeEdited.
  ///
  /// In en, this message translates to:
  /// **'Employee edited'**
  String get opEmployeeEdited;

  /// No description provided for @opEmployeeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Employee deleted'**
  String get opEmployeeDeleted;

  /// No description provided for @opStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String opStatus(String status);

  /// No description provided for @opProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get opProfile;

  /// No description provided for @opOther.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get opOther;

  /// No description provided for @stmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Statements and certificates'**
  String get stmtTitle;

  /// No description provided for @stmtAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get stmtAvailable;

  /// No description provided for @stmtMine.
  ///
  /// In en, this message translates to:
  /// **'My statements'**
  String get stmtMine;

  /// No description provided for @stmtCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get stmtCertificates;

  /// No description provided for @stmtStatements.
  ///
  /// In en, this message translates to:
  /// **'Statements'**
  String get stmtStatements;

  /// No description provided for @stmtForPeriod.
  ///
  /// In en, this message translates to:
  /// **'All operations for a period'**
  String get stmtForPeriod;

  /// No description provided for @stmtSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get stmtSales;

  /// No description provided for @stmtStore.
  ///
  /// In en, this message translates to:
  /// **'By store'**
  String get stmtStore;

  /// No description provided for @stmtStoreHint.
  ///
  /// In en, this message translates to:
  /// **'Sales of one store for a period'**
  String get stmtStoreHint;

  /// No description provided for @stmtCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get stmtCash;

  /// No description provided for @stmtCashHint.
  ///
  /// In en, this message translates to:
  /// **'Only cash, mixed payments split'**
  String get stmtCashHint;

  /// No description provided for @stmtCard.
  ///
  /// In en, this message translates to:
  /// **'Card and QR'**
  String get stmtCard;

  /// No description provided for @stmtCardHint.
  ///
  /// In en, this message translates to:
  /// **'Only non-cash payments'**
  String get stmtCardHint;

  /// No description provided for @stmtExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get stmtExpenses;

  /// No description provided for @stmtSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salary payments'**
  String get stmtSalaries;

  /// No description provided for @stmtOperations.
  ///
  /// In en, this message translates to:
  /// **'All operations'**
  String get stmtOperations;

  /// No description provided for @stmtOperationsHint.
  ///
  /// In en, this message translates to:
  /// **'Every change in the business'**
  String get stmtOperationsHint;

  /// No description provided for @stmtSalaryDebt.
  ///
  /// In en, this message translates to:
  /// **'Unpaid salaries'**
  String get stmtSalaryDebt;

  /// No description provided for @stmtSalaryDebtHint.
  ///
  /// In en, this message translates to:
  /// **'Employees not fully paid, as of today'**
  String get stmtSalaryDebtHint;

  /// No description provided for @stmtProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get stmtProfit;

  /// No description provided for @stmtProfitHint.
  ///
  /// In en, this message translates to:
  /// **'Sales − expenses − salaries for a period'**
  String get stmtProfitHint;

  /// No description provided for @stmtStores.
  ///
  /// In en, this message translates to:
  /// **'Stores summary'**
  String get stmtStores;

  /// No description provided for @stmtStoresHint.
  ///
  /// In en, this message translates to:
  /// **'Stores ranked by sales'**
  String get stmtStoresHint;

  /// No description provided for @stmtMineEmpty.
  ///
  /// In en, this message translates to:
  /// **'Statements you open are kept here.'**
  String get stmtMineEmpty;

  /// No description provided for @stmtPeriodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get stmtPeriodLastMonth;

  /// No description provided for @stmtPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get stmtPeriodCustom;

  /// No description provided for @stmtChooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose a store'**
  String get stmtChooseStore;

  /// No description provided for @stmtAsOf.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String stmtAsOf(String date);

  /// No description provided for @stmtEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing for this period.'**
  String get stmtEmpty;

  /// No description provided for @stmtTruncated.
  ///
  /// In en, this message translates to:
  /// **'Too many lines: only the newest are shown. Choose a shorter period.'**
  String get stmtTruncated;

  /// No description provided for @stmtExcel.
  ///
  /// In en, this message translates to:
  /// **'Download Excel'**
  String get stmtExcel;

  /// No description provided for @stmtShared.
  ///
  /// In en, this message translates to:
  /// **'Excel file is ready'**
  String get stmtShared;

  /// No description provided for @stmtTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get stmtTotal;

  /// No description provided for @stmtCount.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get stmtCount;

  /// No description provided for @stmtCashTotal.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get stmtCashTotal;

  /// No description provided for @stmtCardTotal.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get stmtCardTotal;

  /// No description provided for @stmtQrTotal.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get stmtQrTotal;

  /// No description provided for @stmtNoMethod.
  ///
  /// In en, this message translates to:
  /// **'Method not set'**
  String get stmtNoMethod;

  /// No description provided for @stmtSalesTotal.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get stmtSalesTotal;

  /// No description provided for @stmtExpensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get stmtExpensesTotal;

  /// No description provided for @stmtSalariesTotal.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get stmtSalariesTotal;

  /// No description provided for @stmtProfitTotal.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get stmtProfitTotal;

  /// No description provided for @stmtDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get stmtDue;

  /// No description provided for @stmtPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get stmtPaid;

  /// No description provided for @stmtRemaining.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get stmtRemaining;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get colStore;

  /// No description provided for @colMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get colMethod;

  /// No description provided for @colCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get colCash;

  /// No description provided for @colCard.
  ///
  /// In en, this message translates to:
  /// **'Card / QR'**
  String get colCard;

  /// No description provided for @colAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount, TJS'**
  String get colAmount;

  /// No description provided for @colReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get colReceipt;

  /// No description provided for @colDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get colDescription;

  /// No description provided for @colCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get colCategory;

  /// No description provided for @colEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get colEmployee;

  /// No description provided for @colForMonth.
  ///
  /// In en, this message translates to:
  /// **'For month'**
  String get colForMonth;

  /// No description provided for @colNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get colNote;

  /// No description provided for @colWhat.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get colWhat;

  /// No description provided for @colWho.
  ///
  /// In en, this message translates to:
  /// **'Store / employee'**
  String get colWho;

  /// No description provided for @colUser.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get colUser;

  /// No description provided for @colUnpaidMonths.
  ///
  /// In en, this message translates to:
  /// **'Unpaid months'**
  String get colUnpaidMonths;

  /// No description provided for @colItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get colItem;

  /// No description provided for @colPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get colPlace;

  /// No description provided for @colShare.
  ///
  /// In en, this message translates to:
  /// **'Share, %'**
  String get colShare;

  /// No description provided for @colSalesCount.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get colSalesCount;

  /// No description provided for @moreStatementsHint.
  ///
  /// In en, this message translates to:
  /// **'Excel statements: sales, cash, card, expenses…'**
  String get moreStatementsHint;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @lockFaceId.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Face ID'**
  String get lockFaceId;

  /// No description provided for @lockFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with fingerprint'**
  String get lockFingerprint;

  /// No description provided for @lockBiometric.
  ///
  /// In en, this message translates to:
  /// **'Sign in with biometrics'**
  String get lockBiometric;

  /// No description provided for @lockHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for it when the app opens'**
  String get lockHint;

  /// No description provided for @lockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No Face ID or fingerprint set up on this phone'**
  String get lockUnavailable;

  /// No description provided for @lockReasonEnable.
  ///
  /// In en, this message translates to:
  /// **'Confirm to turn on the lock'**
  String get lockReasonEnable;

  /// No description provided for @lockReasonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open OFAR'**
  String get lockReasonOpen;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'OFAR is locked'**
  String get lockTitle;

  /// No description provided for @lockMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you to see your business.'**
  String get lockMessage;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockOn.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in is on'**
  String get lockOn;

  /// No description provided for @lockOff.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in is off'**
  String get lockOff;

  /// No description provided for @lockNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed — the lock stays off'**
  String get lockNotConfirmed;

  /// No description provided for @navCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get navCurrencies;

  /// No description provided for @currenciesSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get currenciesSoon;

  /// No description provided for @fxUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {time}'**
  String fxUpdated(String time);

  /// No description provided for @fxRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get fxRefresh;

  /// No description provided for @fxConverter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get fxConverter;

  /// No description provided for @fxAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get fxAmount;

  /// No description provided for @fxSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get fxSwap;

  /// No description provided for @fxFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fxFrom;

  /// No description provided for @fxTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get fxTo;

  /// No description provided for @fxCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get fxCrypto;

  /// No description provided for @fxCryptoNote.
  ///
  /// In en, this message translates to:
  /// **'Rates only — you can\'t buy, sell or exchange here'**
  String get fxCryptoNote;

  /// No description provided for @fxAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get fxAll;

  /// No description provided for @fxAllCrypto.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrencies'**
  String get fxAllCrypto;

  /// No description provided for @fxSearchCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin name or ticker'**
  String get fxSearchCoin;

  /// No description provided for @fxSources.
  ///
  /// In en, this message translates to:
  /// **'Rates: open.er-api.com (daily), crypto: CoinGecko (live).'**
  String get fxSources;

  /// No description provided for @fxCryptoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Crypto prices are unavailable right now.'**
  String get fxCryptoUnavailable;

  /// No description provided for @fxLive.
  ///
  /// In en, this message translates to:
  /// **'Live · {time}'**
  String fxLive(String time);

  /// No description provided for @navDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navDebts;

  /// No description provided for @debtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Debts and credits'**
  String get debtsTitle;

  /// No description provided for @debtsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get debtsOverview;

  /// No description provided for @debtsOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get debtsOwedToMe;

  /// No description provided for @debtsIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get debtsIOwe;

  /// No description provided for @debtsToPeople.
  ///
  /// In en, this message translates to:
  /// **'Debts to people'**
  String get debtsToPeople;

  /// No description provided for @debtsLoans.
  ///
  /// In en, this message translates to:
  /// **'Credits and installments'**
  String get debtsLoans;

  /// No description provided for @debtsPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 person} other{{count} people}}'**
  String debtsPeople(int count);

  /// No description provided for @debtsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 debt} other{{count} debts}}'**
  String debtsCount(int count);

  /// No description provided for @debtsEmptyOwedTitle.
  ///
  /// In en, this message translates to:
  /// **'People owe you money'**
  String get debtsEmptyOwedTitle;

  /// No description provided for @debtsEmptyOwedMessage.
  ///
  /// In en, this message translates to:
  /// **'Add someone who owes you'**
  String get debtsEmptyOwedMessage;

  /// No description provided for @debtsEmptyIOweTitle.
  ///
  /// In en, this message translates to:
  /// **'You owe money'**
  String get debtsEmptyIOweTitle;

  /// No description provided for @debtsEmptyIOweMessage.
  ///
  /// In en, this message translates to:
  /// **'Add someone you owe'**
  String get debtsEmptyIOweMessage;

  /// No description provided for @debtsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a debt'**
  String get debtsAdd;

  /// No description provided for @debtsActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'Active credits'**
  String get debtsActiveLoans;

  /// No description provided for @debtsAddLoan.
  ///
  /// In en, this message translates to:
  /// **'Add a credit'**
  String get debtsAddLoan;

  /// No description provided for @debtsNoLoans.
  ///
  /// In en, this message translates to:
  /// **'No active credits or installments'**
  String get debtsNoLoans;

  /// No description provided for @debtsClosed.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get debtsClosed;

  /// No description provided for @debtsLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Kept only on this phone: the server has no debts yet.'**
  String get debtsLocalNote;

  /// No description provided for @debtLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String debtLeft(String amount);

  /// No description provided for @debtDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String debtDue(String date);

  /// No description provided for @debtOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue since {date}'**
  String debtOverdue(String date);

  /// No description provided for @debtNewOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get debtNewOwed;

  /// No description provided for @debtNewIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get debtNewIOwe;

  /// No description provided for @debtNewLoan.
  ///
  /// In en, this message translates to:
  /// **'New credit'**
  String get debtNewLoan;

  /// No description provided for @debtEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get debtEditTitle;

  /// No description provided for @debtWho.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get debtWho;

  /// No description provided for @debtWhoHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get debtWhoHint;

  /// No description provided for @debtBank.
  ///
  /// In en, this message translates to:
  /// **'Bank or shop'**
  String get debtBank;

  /// No description provided for @debtLoanType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get debtLoanType;

  /// No description provided for @debtCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get debtCredit;

  /// No description provided for @debtInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get debtInstallment;

  /// No description provided for @debtAmountTotal.
  ///
  /// In en, this message translates to:
  /// **'Total to repay'**
  String get debtAmountTotal;

  /// No description provided for @debtMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get debtMonthly;

  /// No description provided for @debtDueDate.
  ///
  /// In en, this message translates to:
  /// **'Repay by'**
  String get debtDueDate;

  /// No description provided for @debtNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get debtNoDueDate;

  /// No description provided for @debtSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get debtSaved;

  /// No description provided for @debtRepay.
  ///
  /// In en, this message translates to:
  /// **'Record a repayment'**
  String get debtRepay;

  /// No description provided for @debtRepayAll.
  ///
  /// In en, this message translates to:
  /// **'Repaid in full'**
  String get debtRepayAll;

  /// No description provided for @debtRepaid.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded'**
  String get debtRepaid;

  /// No description provided for @debtPayments.
  ///
  /// In en, this message translates to:
  /// **'Repayments'**
  String get debtPayments;

  /// No description provided for @debtNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No repayments yet.'**
  String get debtNoPayments;

  /// No description provided for @debtPaidOf.
  ///
  /// In en, this message translates to:
  /// **'Repaid {paid} of {total}'**
  String debtPaidOf(String paid, String total);

  /// No description provided for @debtDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete it?'**
  String get debtDeleteTitle;

  /// No description provided for @debtDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'It and its repayments will be removed from this phone.'**
  String get debtDeleteMessage;

  /// No description provided for @debtDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get debtDeleted;

  /// No description provided for @debtClosedBadge.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get debtClosedBadge;

  /// No description provided for @actionSalesList.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get actionSalesList;

  /// No description provided for @pfExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get pfExpense;

  /// No description provided for @pfIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get pfIncome;

  /// No description provided for @pfTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get pfTransfer;

  /// No description provided for @pfNewExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get pfNewExpense;

  /// No description provided for @pfNewIncome.
  ///
  /// In en, this message translates to:
  /// **'New income'**
  String get pfNewIncome;

  /// No description provided for @pfNewTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer between accounts'**
  String get pfNewTransfer;

  /// No description provided for @pfEditOperation.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get pfEditOperation;

  /// No description provided for @pfAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get pfAccount;

  /// No description provided for @pfFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get pfFromAccount;

  /// No description provided for @pfToAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get pfToAccount;

  /// No description provided for @pfSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose another account'**
  String get pfSameAccount;

  /// No description provided for @pfSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get pfSaved;

  /// No description provided for @pfDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get pfDeleted;

  /// No description provided for @pfDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the operation?'**
  String get pfDeleteTitle;

  /// No description provided for @pfDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The account balance changes back.'**
  String get pfDeleteMessage;

  /// No description provided for @pfOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get pfOperations;

  /// No description provided for @pfNoOperations.
  ///
  /// In en, this message translates to:
  /// **'No operations yet. Tap “+” to write down an expense or income.'**
  String get pfNoOperations;

  /// No description provided for @pfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get pfAccounts;

  /// No description provided for @pfAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Cash, cards and their balances'**
  String get pfAccountsHint;

  /// No description provided for @pfNewAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get pfNewAccount;

  /// No description provided for @pfAccountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pfAccountName;

  /// No description provided for @pfAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alif card, cash…'**
  String get pfAccountNameHint;

  /// No description provided for @pfAccountKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pfAccountKind;

  /// No description provided for @pfOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance now'**
  String get pfOpeningBalance;

  /// No description provided for @pfAccountUsed.
  ///
  /// In en, this message translates to:
  /// **'The account has operations: delete them first.'**
  String get pfAccountUsed;

  /// No description provided for @pfAccountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the account?'**
  String get pfAccountDeleteTitle;

  /// No description provided for @pfKindCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get pfKindCash;

  /// No description provided for @pfKindCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get pfKindCard;

  /// No description provided for @pfKindBank.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get pfKindBank;

  /// No description provided for @pfKindSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get pfKindSavings;

  /// No description provided for @pfKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pfKindOther;

  /// No description provided for @pfTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'My money'**
  String get pfTotalBalance;

  /// No description provided for @pfRecurring.
  ///
  /// In en, this message translates to:
  /// **'Regular payments'**
  String get pfRecurring;

  /// No description provided for @pfRecurringHint.
  ///
  /// In en, this message translates to:
  /// **'Rent, internet, subscriptions'**
  String get pfRecurringHint;

  /// No description provided for @pfNewRecurring.
  ///
  /// In en, this message translates to:
  /// **'New regular payment'**
  String get pfNewRecurring;

  /// No description provided for @pfRecurringName.
  ///
  /// In en, this message translates to:
  /// **'What for'**
  String get pfRecurringName;

  /// No description provided for @pfRecurringNameHint.
  ///
  /// In en, this message translates to:
  /// **'Internet, rent…'**
  String get pfRecurringNameHint;

  /// No description provided for @pfNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next payment'**
  String get pfNextDate;

  /// No description provided for @pfEvery.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get pfEvery;

  /// No description provided for @pfEveryMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get pfEveryMonth;

  /// No description provided for @pfEveryQuarter.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get pfEveryQuarter;

  /// No description provided for @pfEveryYear.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get pfEveryYear;

  /// No description provided for @pfAnyAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose when paying'**
  String get pfAnyAccount;

  /// No description provided for @pfPay.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get pfPay;

  /// No description provided for @pfPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid: written as an expense'**
  String get pfPaid;

  /// No description provided for @pfNoRecurring.
  ///
  /// In en, this message translates to:
  /// **'No regular payments yet.'**
  String get pfNoRecurring;

  /// No description provided for @pfDue.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String pfDue(String date);

  /// No description provided for @pfDueToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pfDueToday;

  /// No description provided for @pfOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {date}'**
  String pfOverdue(String date);

  /// No description provided for @pfUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming payments'**
  String get pfUpcoming;

  /// No description provided for @pfMonthIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get pfMonthIncome;

  /// No description provided for @pfMonthExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get pfMonthExpense;

  /// No description provided for @pfByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get pfByCategory;

  /// No description provided for @pfNoExpensesMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get pfNoExpensesMonth;

  /// No description provided for @pfRecent.
  ///
  /// In en, this message translates to:
  /// **'Latest operations'**
  String get pfRecent;

  /// No description provided for @pfMyFinances.
  ///
  /// In en, this message translates to:
  /// **'My finances'**
  String get pfMyFinances;

  /// No description provided for @pfLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Personal finances are kept only on this phone.'**
  String get pfLocalNote;

  /// No description provided for @pfCatFood.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get pfCatFood;

  /// No description provided for @pfCatCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafés'**
  String get pfCatCafe;

  /// No description provided for @pfCatTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get pfCatTransport;

  /// No description provided for @pfCatHome.
  ///
  /// In en, this message translates to:
  /// **'Home and rent'**
  String get pfCatHome;

  /// No description provided for @pfCatUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get pfCatUtilities;

  /// No description provided for @pfCatPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone and internet'**
  String get pfCatPhone;

  /// No description provided for @pfCatHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pfCatHealth;

  /// No description provided for @pfCatClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get pfCatClothes;

  /// No description provided for @pfCatEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get pfCatEducation;

  /// No description provided for @pfCatFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get pfCatFun;

  /// No description provided for @pfCatGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get pfCatGifts;

  /// No description provided for @pfCatFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get pfCatFamily;

  /// No description provided for @pfCatOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pfCatOtherExpense;

  /// No description provided for @pfCatSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get pfCatSalary;

  /// No description provided for @pfCatBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get pfCatBusiness;

  /// No description provided for @pfCatSideJob.
  ///
  /// In en, this message translates to:
  /// **'Side job'**
  String get pfCatSideJob;

  /// No description provided for @pfCatGiftIn.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get pfCatGiftIn;

  /// No description provided for @pfCatRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get pfCatRefund;

  /// No description provided for @pfCatOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get pfCatOtherIncome;

  /// No description provided for @phMonthIncome.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get phMonthIncome;

  /// No description provided for @phMonthExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month'**
  String get phMonthExpense;

  /// No description provided for @phMyBusiness.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get phMyBusiness;

  /// No description provided for @phBusinessToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today {amount} · profit this month {profit}'**
  String phBusinessToday(String amount, String profit);

  /// No description provided for @phStartBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a shop?'**
  String get phStartBusinessTitle;

  /// No description provided for @phStartBusinessMessage.
  ///
  /// In en, this message translates to:
  /// **'Add it: sales, employees, salaries and its expenses will appear.'**
  String get phStartBusinessMessage;

  /// No description provided for @phAddStore.
  ///
  /// In en, this message translates to:
  /// **'Add a store'**
  String get phAddStore;

  /// No description provided for @phAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add an account'**
  String get phAddAccount;

  /// No description provided for @phOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get phOpen;

  /// No description provided for @actionStoreExpense.
  ///
  /// In en, this message translates to:
  /// **'Store expense'**
  String get actionStoreExpense;

  /// No description provided for @quickPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get quickPersonal;

  /// No description provided for @quickBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get quickBusiness;

  /// No description provided for @morePersonal.
  ///
  /// In en, this message translates to:
  /// **'My money'**
  String get morePersonal;

  /// No description provided for @moreOperationsHint.
  ///
  /// In en, this message translates to:
  /// **'Every income, expense and transfer'**
  String get moreOperationsHint;

  /// No description provided for @assistantSuggestSpending.
  ///
  /// In en, this message translates to:
  /// **'What do I spend the most on?'**
  String get assistantSuggestSpending;

  /// No description provided for @assistantSuggestMonth.
  ///
  /// In en, this message translates to:
  /// **'How much did I spend this month?'**
  String get assistantSuggestMonth;

  /// No description provided for @moreReportsAllHint.
  ///
  /// In en, this message translates to:
  /// **'Profit, statements in Excel, history of changes'**
  String get moreReportsAllHint;

  /// No description provided for @moreCurrenciesHint.
  ///
  /// In en, this message translates to:
  /// **'Rates, converter, crypto'**
  String get moreCurrenciesHint;

  /// No description provided for @reportsProfitHint.
  ///
  /// In en, this message translates to:
  /// **'Stores compared, salaries for the year'**
  String get reportsProfitHint;

  /// No description provided for @reportsHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Every change: sales, expenses, salaries'**
  String get reportsHistoryHint;

  /// No description provided for @navOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get navOperations;
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
