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
