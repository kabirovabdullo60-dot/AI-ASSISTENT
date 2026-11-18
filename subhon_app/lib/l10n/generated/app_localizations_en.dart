// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OFAR';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmptyTitle => 'Nothing here yet';

  @override
  String get commonErrorTitle => 'Could not load';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonNothingFound => 'Nothing found.';

  @override
  String get fieldShowPassword => 'Show password';

  @override
  String get fieldHidePassword => 'Hide password';

  @override
  String get navHome => 'Home';

  @override
  String get navSales => 'Sales';

  @override
  String get navPayroll => 'Salaries';

  @override
  String get navMore => 'More';

  @override
  String get navAdd => 'Add';

  @override
  String get navStores => 'Stores';

  @override
  String get navEmployees => 'Employees';

  @override
  String get navReports => 'Reports';

  @override
  String get navProfile => 'Profile and settings';

  @override
  String get quickActionsTitle => 'Add';

  @override
  String get actionNewSale => 'Sale';

  @override
  String get actionPaySalary => 'Pay salary';

  @override
  String get actionNewStore => 'Store';

  @override
  String get actionNewEmployee => 'Employee';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle =>
      'Sign in to keep working with your business finances';

  @override
  String get authRegisterTitle => 'Create an account';

  @override
  String get authRegisterSubtitle =>
      'AI accountant for tracking income and expenses';

  @override
  String get fieldWorkEmail => 'Work e-mail';

  @override
  String get authPasswordMinHint => 'At least 8 characters';

  @override
  String get validationPasswordMin => 'At least 8 characters';

  @override
  String get authNoAccount => 'No account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authPasswordRepeat => 'Repeat the password';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignOutConfirmTitle => 'Sign out?';

  @override
  String get authSignOutConfirmMessage =>
      'You will need your e-mail and password to sign in again.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldEmailHint => 'name@company.tj';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldBusinessName => 'Business name';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldPhoneHint => '+992 90 123 45 67';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get fieldStore => 'Store';

  @override
  String get fieldChooseStore => 'Choose a store';

  @override
  String get fieldStoreName => 'Store name';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldPeriod => 'Period';

  @override
  String get fieldPosition => 'Position';

  @override
  String get fieldMonthlySalary => 'Monthly salary';

  @override
  String get fieldHiredAt => 'Hired on';

  @override
  String get fieldTerminatedAt => 'Left on';

  @override
  String get fieldPaymentDate => 'Payment date';

  @override
  String get fieldNote => 'Note';

  @override
  String get validationRequired => 'Fill in this field';

  @override
  String get validationEmail => 'Enter a valid e-mail';

  @override
  String get validationPhone => '7–15 digits, may start with +';

  @override
  String get validationAmount =>
      'Enter an amount greater than 0 (up to 2 decimals)';

  @override
  String get validationPasswordsDiffer => 'The passwords do not match';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get homeMonthSales => 'Sales this month';

  @override
  String get homeToday => 'Today';

  @override
  String get homeWeek => 'This week';

  @override
  String get homeRevenueToday => 'Revenue today';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodPrevious => 'Previous';

  @override
  String get periodNext => 'Next';

  @override
  String get homePeriodSales => 'Sales';

  @override
  String get homeAverageSale => 'Average sale';

  @override
  String get homeNoComparison => 'Nothing to compare yet';

  @override
  String homeChange(String change, String compare) {
    return '$change $compare';
  }

  @override
  String get compareToday => 'vs yesterday';

  @override
  String get compareWeek => 'vs last week';

  @override
  String get compareMonth => 'vs last month';

  @override
  String get homeSalaries => 'Salaries this month';

  @override
  String homeRemainingTotal(String amount) {
    return 'Unpaid for all months: $amount';
  }

  @override
  String get homeBusiness => 'Stores and employees';

  @override
  String homeOfTotal(int total) {
    return 'active of $total';
  }

  @override
  String get homeTopStores => 'Top stores this month';

  @override
  String get homeShowAll => 'All sales';

  @override
  String get homeNoSales => 'No sales yet.';

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '$count sale',
      zero: 'No sales',
    );
    return '$_temp0';
  }

  @override
  String get salesTotal => 'Sales total';

  @override
  String get salesAllStores => 'All stores';

  @override
  String get salesAllDates => 'All time';

  @override
  String get salesClearFilter => 'Reset filter';

  @override
  String get salesNothingFound => 'No sales for this filter.';

  @override
  String get salesEmptyTitle => 'No sales yet';

  @override
  String get salesEmptyMessage => 'Record the first sale of a store.';

  @override
  String get saleNewTitle => 'New sale';

  @override
  String get saleEditTitle => 'Sale';

  @override
  String get saleNoStores => 'Add a store first';

  @override
  String get saleSaved => 'Sale recorded';

  @override
  String get saleUpdated => 'Sale updated';

  @override
  String get saleDeleted => 'Sale deleted';

  @override
  String get saleDeleteTitle => 'Delete the sale?';

  @override
  String get saleDeleteMessage =>
      'It will no longer count in sales and reports.';

  @override
  String get storesSearch => 'Search by name or address';

  @override
  String get storesEmptyTitle => 'No stores yet';

  @override
  String get storesEmptyMessage => 'Add your first store to record its sales.';

  @override
  String get storeNewTitle => 'New store';

  @override
  String get storeEditTitle => 'Edit store';

  @override
  String get storeSaved => 'Store saved';

  @override
  String get storeDeleted => 'Store deleted. Its sales stay in reports.';

  @override
  String get storeDeleteTitle => 'Delete the store?';

  @override
  String get storeDeleteMessage =>
      'Its sales history is kept. A store with working employees cannot be deleted.';

  @override
  String get storeLatestSales => 'Latest sales';

  @override
  String get storeNoEmployees => 'No employees in this store.';

  @override
  String get employeesSearch => 'Search by name or phone';

  @override
  String get employeesActive => 'Working';

  @override
  String get employeesSalaryFund => 'Salaries per month';

  @override
  String employeesAverage(String amount) {
    return 'Average $amount';
  }

  @override
  String get employeesEmptyTitle => 'No employees yet';

  @override
  String get employeesEmptyMessage =>
      'Add employees to keep track of their salaries.';

  @override
  String get employeeNewTitle => 'New employee';

  @override
  String get employeeEditTitle => 'Employee';

  @override
  String get employeeSaved => 'Employee saved';

  @override
  String get employeeDeleted => 'Employee deleted. Their salary history stays.';

  @override
  String get employeeDeleteTitle => 'Delete the employee?';

  @override
  String get employeeDeleteMessage => 'The salary history is kept.';

  @override
  String get payrollPaid => 'Paid';

  @override
  String get payrollPartial => 'Partly paid';

  @override
  String get payrollUnpaid => 'Not paid';

  @override
  String get payrollDue => 'Due';

  @override
  String get payrollDueTotal => 'Due in total';

  @override
  String get payrollPaidAmount => 'Paid';

  @override
  String get payrollRemaining => 'Remaining';

  @override
  String payrollCounts(int paid, int partial, int unpaid) {
    return 'Paid $paid · partly $partial · not paid $unpaid';
  }

  @override
  String payrollLeft(String amount) {
    return '$amount left';
  }

  @override
  String get payrollEmptyTitle => 'No salaries this month';

  @override
  String get payrollEmptyMessage =>
      'Employees who worked this month appear here.';

  @override
  String get payrollHistory => 'Salary history';

  @override
  String get payrollMonths => 'Months';

  @override
  String get payrollPayments => 'Payments';

  @override
  String get payrollNoPayments => 'No payments yet.';

  @override
  String payrollPaidOf(String paid, String due) {
    return '$paid of $due';
  }

  @override
  String payrollPaidSoFar(String amount) {
    return 'Paid $amount';
  }

  @override
  String payrollMonthlySalary(String amount) {
    return 'Salary $amount per month';
  }

  @override
  String payrollWorkedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days worked',
      one: '$count day worked',
    );
    return '$_temp0';
  }

  @override
  String payrollMonthsWorked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String get paymentTitle => 'Salary payment';

  @override
  String get paymentSubmit => 'Pay';

  @override
  String get paymentSaved => 'Payment recorded';

  @override
  String get paymentAlreadyPaid => 'This month is already paid in full.';

  @override
  String paymentFor(String period) {
    return 'for $period';
  }

  @override
  String get paymentCancel => 'Cancel payment';

  @override
  String get paymentCancelTitle => 'Cancel the payment?';

  @override
  String paymentCancelMessage(String amount) {
    return '$amount will count as not paid again.';
  }

  @override
  String get paymentCancelled => 'Payment cancelled';

  @override
  String get reportStores => 'Stores this month';

  @override
  String reportStoresPeriod(String start, String end) {
    return 'Sales $start – $end';
  }

  @override
  String get reportPayroll => 'Salaries by year';

  @override
  String get reportEmployees => 'Employees by store and position';

  @override
  String reportEmployeesCount(int active, int total) {
    return '$active working of $total';
  }

  @override
  String get moreBusiness => 'Business';

  @override
  String get moreAccount => 'Account';

  @override
  String get moreStoresHint => 'Add, edit, see sales and staff';

  @override
  String get moreEmployeesHint => 'Staff, positions and salaries';

  @override
  String get moreReportsHint => 'Stores compared, salaries by year';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileAvatarSaved => 'Photo updated';

  @override
  String get profileDetails => 'Business and contacts';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileCurrency => 'Currency';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageSystem => 'As on the phone';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get passwordTitle => 'Change password';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordNote =>
      'Other devices will be signed out. This one stays signed in.';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get errNetwork =>
      'No connection to the server. Check the internet and try again.';

  @override
  String get errInvalidCredentials => 'Wrong e-mail or password.';

  @override
  String get errAccountLocked => 'Too many attempts. Try again in 15 minutes.';

  @override
  String get errAccountDisabled => 'This account is disabled.';

  @override
  String get errSessionEnded => 'The session has ended. Please sign in again.';

  @override
  String get errEmailTaken => 'An account with this e-mail already exists.';

  @override
  String get errPasswordWeak =>
      'The password is too weak. Use a longer one with letters and digits.';

  @override
  String get errCurrentPassword => 'The current password is wrong.';

  @override
  String get errAvatarTooLarge => 'The photo is too large (at most 5 MB).';

  @override
  String get errAvatarType => 'Choose a JPEG, PNG or WebP photo.';

  @override
  String get errStoreNotFound =>
      'The store was not found. It may have been deleted.';

  @override
  String get errStoreNameTaken => 'A store with this name already exists.';

  @override
  String get errStoreHasEmployees =>
      'This store has working employees. Move them to another store or mark them inactive first.';

  @override
  String get errSaleNotFound =>
      'The sale was not found. It may have been deleted.';

  @override
  String get errSaleDateFuture => 'A sale cannot be dated in the future.';

  @override
  String get errEmployeeNotFound =>
      'The employee was not found. They may have been deleted.';

  @override
  String get errEmploymentDates =>
      'The leaving date must be after the hiring date.';

  @override
  String get errNotEmployedInPeriod =>
      'The employee did not work in this month.';

  @override
  String get errPaymentNotFound =>
      'The payment was not found. It may have been cancelled.';

  @override
  String get errPayrollExceeds =>
      'The amount is more than is left to pay for this month.';

  @override
  String get errPayrollAlreadyPaid => 'This month is already paid in full.';

  @override
  String get errPayrollFuture => 'A future month cannot be paid yet.';

  @override
  String get errPaymentDateFuture =>
      'The payment date cannot be in the future.';

  @override
  String get errDateRange => 'The start date must not be after the end date.';

  @override
  String get errValidation =>
      'Some fields are filled in wrongly. Check them and try again.';

  @override
  String get errPermission => 'You are not allowed to do this.';

  @override
  String get errNotFound => 'Not found. It may have been deleted.';

  @override
  String get errConflict =>
      'This conflicts with the current data. Refresh and try again.';

  @override
  String get errRateLimited =>
      'Too many requests. Wait a little and try again.';

  @override
  String get errServer =>
      'The server is not responding properly. Try again later.';

  @override
  String get errUnknown => 'Something went wrong. Try again.';
}
