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
  String get introTitle => 'AI accountant';

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
  String get authRegisterTab => 'Sign up';

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

  @override
  String get navExpenses => 'Expenses';

  @override
  String get moreExpensesHint => 'Rent, utilities, delivery and more';

  @override
  String get actionNewExpense => 'Expense';

  @override
  String get fieldCategory => 'Category';

  @override
  String get expenseCategoryRent => 'Rent';

  @override
  String get expenseCategoryUtilities => 'Utilities';

  @override
  String get expenseCategoryDelivery => 'Delivery';

  @override
  String get expenseCategorySupplies => 'Supplies';

  @override
  String get expenseCategoryMarketing => 'Marketing';

  @override
  String get expenseCategoryTaxes => 'Taxes';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get expensesAllCategories => 'All categories';

  @override
  String get expenseWholeBusiness => 'Whole business';

  @override
  String get expensesTotal => 'Total expenses';

  @override
  String expensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '$count expense',
      zero: 'No expenses',
    );
    return '$_temp0';
  }

  @override
  String get expensesNothingFound => 'No expenses for this filter.';

  @override
  String get expensesEmptyTitle => 'No expenses yet';

  @override
  String get expensesEmptyMessage =>
      'Record rent, utilities and other costs to see your real profit.';

  @override
  String get expenseNewTitle => 'New expense';

  @override
  String get expenseEditTitle => 'Expense';

  @override
  String get expenseSaved => 'Expense added';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get expenseDeleteTitle => 'Delete the expense?';

  @override
  String get expenseDeleteMessage =>
      'It will no longer count in expenses and profit.';

  @override
  String get errExpenseNotFound => 'This expense no longer exists.';

  @override
  String get errExpenseDateFuture =>
      'The expense date can\'t be in the future.';

  @override
  String get reportProfit => 'Profit';

  @override
  String get profitSales => 'Sales';

  @override
  String get profitExpenses => 'Expenses';

  @override
  String get profitSalaryDue => 'Salaries due';

  @override
  String profitMargin(String percent) {
    return 'Margin $percent';
  }

  @override
  String get profitNoSales => 'No sales in this period';

  @override
  String get profitByCategory => 'Expenses by category';

  @override
  String get profitByStore => 'Profit by store';

  @override
  String get profitNoExpenses => 'No expenses in this period.';

  @override
  String profitStoreLine(String sales, String expenses, String salary) {
    return 'Sales $sales · expenses $expenses · salaries $salary';
  }

  @override
  String get homeTargetsProfit => 'Targets & profit';

  @override
  String get homeMonthProfit => 'Profit this month';

  @override
  String homeProfitCaption(String expenses, String margin) {
    return 'Expenses $expenses · $margin';
  }

  @override
  String get targetWeek => 'Weekly target';

  @override
  String get targetMonth => 'Monthly target';

  @override
  String get targetNotSet => 'Set a target';

  @override
  String targetDone(String percent) {
    return '$percent reached';
  }

  @override
  String get targetSheetTitleWeek => 'Sales target for a week';

  @override
  String get targetSheetTitleMonth => 'Sales target for a month';

  @override
  String get targetSheetHint =>
      'For the whole business. You can change it any time.';

  @override
  String get targetSaved => 'Target saved';

  @override
  String get activityTitle => 'Recent activity';

  @override
  String get activityLogTitle => 'Operations log';

  @override
  String get activityEmpty => 'No changes yet.';

  @override
  String activityStoreCreated(String name) {
    return 'Store “$name” added';
  }

  @override
  String activityStoreUpdated(String name) {
    return 'Store “$name” edited';
  }

  @override
  String activityStoreDeleted(String name) {
    return 'Store “$name” deleted';
  }

  @override
  String activityStoreStatus(String name, String status) {
    return 'Store “$name”: $status';
  }

  @override
  String activitySaleCreated(String name) {
    return 'Sale in “$name”';
  }

  @override
  String activitySaleUpdated(String name) {
    return 'Sale in “$name” edited';
  }

  @override
  String activitySaleDeleted(String name) {
    return 'Sale in “$name” deleted';
  }

  @override
  String activityEmployeeCreated(String name) {
    return 'Employee $name added';
  }

  @override
  String activityEmployeeUpdated(String name) {
    return 'Employee $name edited';
  }

  @override
  String activityEmployeeDeleted(String name) {
    return 'Employee $name deleted';
  }

  @override
  String activityEmployeeStatus(String name, String status) {
    return '$name: $status';
  }

  @override
  String activityPayrollPaid(String name) {
    return 'Salary paid: $name';
  }

  @override
  String activityPayrollCancelled(String name) {
    return 'Salary payment cancelled: $name';
  }

  @override
  String get activityProfileUpdated => 'Profile updated';

  @override
  String activityOther(String name) {
    return '$name: changed';
  }

  @override
  String activityBy(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get notificationsEmpty => 'All good: nothing needs attention.';

  @override
  String get notificationsNew => 'New';

  @override
  String get notifSalaryOverdueTitle => 'Overdue salaries';

  @override
  String notifSalaryOverdueBody(int count, String amount) {
    return '$count unpaid employee-months from earlier months · $amount';
  }

  @override
  String get notifUnpaidTitle => 'Salaries to pay this month';

  @override
  String notifUnpaidBody(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count employees still to pay',
      one: '1 employee still to pay',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get notifNoSalesTitle => 'No sales today';

  @override
  String notifNoSalesBody(String store) {
    return '“$store” has no sales recorded today.';
  }

  @override
  String get notifOther => 'Something needs attention';

  @override
  String get assistantTitle => 'AI assistant';

  @override
  String get moreAssistantHint => 'Ask about your sales, stores and salaries';

  @override
  String get assistantIntro =>
      'Ask me about your money or your business — I answer from your real figures.';

  @override
  String get assistantHint => 'Your question…';

  @override
  String get assistantSend => 'Send';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get assistantSuggestToday => 'How are my sales today?';

  @override
  String get assistantSuggestBestStore => 'Which store sells best?';

  @override
  String get assistantSuggestSalary => 'How much salary is still unpaid?';

  @override
  String get errAssistantUnavailable =>
      'The assistant is not available right now. Try again later.';

  @override
  String errAssistantRateLimited(int seconds) {
    return 'Too many questions. Wait $seconds s and try again.';
  }

  @override
  String get fieldPaymentMethod => 'Payment method';

  @override
  String get paymentNotSet => 'Not specified';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentCard => 'Card';

  @override
  String get paymentQr => 'QR';

  @override
  String get paymentMixed => 'Cash + card';

  @override
  String get fieldCashAmount => 'Of it in cash';

  @override
  String get fieldCardAmount => 'Of it by card';

  @override
  String get fieldReceiptNumber => 'Receipt number';

  @override
  String get validationSplit => 'Cash and card must add up to the amount';

  @override
  String get errSaleSplit => 'Cash and card must add up to the amount.';

  @override
  String get homeByPayment => 'By payment method';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldRegion => 'Region';

  @override
  String get fieldRegionHint => 'Dushanbe, Sughd, Khatlon, GBAO, RRS';

  @override
  String get fieldStoreType => 'Format';

  @override
  String get fieldStoreTypeHint => 'Supermarket, kiosk…';

  @override
  String get fieldCounters => 'Checkout counters';

  @override
  String get fieldOpeningHours => 'Opening hours';

  @override
  String get fieldOpeningHoursHint => '09:00–21:00';

  @override
  String get fieldStatusNote => 'Status reason';

  @override
  String get fieldStatusNoteHint => 'E.g. renovation';

  @override
  String get validationCounters => 'A whole number from 0 to 999';

  @override
  String get storeMoreDetails => 'More details';

  @override
  String get fieldSalaryMethod => 'Paid by';

  @override
  String get salaryMethodBank => 'Bank transfer';

  @override
  String get salaryMethodCash => 'Cash';

  @override
  String get payrollAllTimeRemaining => 'Unpaid salaries, all months';

  @override
  String payrollAllTimeCaption(String due, String paid) {
    return 'Due $due · paid $paid';
  }

  @override
  String get reportByRegion => 'By region';

  @override
  String get reportNoRegion => 'No region';

  @override
  String reportRegionStores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stores',
      one: '1 store',
    );
    return '$_temp0';
  }

  @override
  String get homeTodaySales => 'Sales today';

  @override
  String get homeMonth => 'This month';

  @override
  String get storeTargets => 'Store targets';

  @override
  String get targetSheetHintStore =>
      'For this store only. You can change it any time.';

  @override
  String get activityHistory => 'History';

  @override
  String get voiceTitle => 'Voice chat';

  @override
  String get voiceOpen => 'Talk by voice';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceSpeaking => 'Answering…';

  @override
  String get voiceTapToTalk => 'Tap the microphone and speak';

  @override
  String get voiceHint =>
      'Ask anything: “employees”, “sales today”, “how much salary is left?”';

  @override
  String get voiceMic => 'Speak';

  @override
  String get voiceEnd => 'End';

  @override
  String get voiceUnavailable =>
      'Speech recognition is not available. Allow the microphone and speech recognition in Settings.';

  @override
  String get voiceMicFailed =>
      'The microphone didn\'t start. Try again; if it keeps happening, check the microphone permission in Settings.';

  @override
  String get chatHistory => 'Chat history';

  @override
  String get chatNew => 'New chat';

  @override
  String get chatHistoryEmpty =>
      'Your conversations with the assistant will be kept here.';

  @override
  String get chatDeleteAll => 'Delete all';

  @override
  String get chatDeleteAllTitle => 'Delete all chats?';

  @override
  String get chatDeleteAllMessage =>
      'The history is kept only on this phone; it can\'t be restored.';

  @override
  String get chatDeleted => 'Chat deleted';

  @override
  String get chatCurrent => 'Open now';

  @override
  String homeStores(int count) {
    return 'Stores · $count';
  }

  @override
  String get homeStoreMonth => 'This month';

  @override
  String get homeAddStore => 'Add a store';

  @override
  String get homeProfit => 'Profit';

  @override
  String get homeShowAllStores => 'All';

  @override
  String historyExpensesFor(String month) {
    return 'Expenses in $month';
  }

  @override
  String historyOfSales(String percent) {
    return '$percent of sales';
  }

  @override
  String get historyStatement => 'Statement';

  @override
  String get historyShowAmount => 'Show the amount';

  @override
  String get historyHideAmount => 'Hide the amount';

  @override
  String get historySearch => 'Search';

  @override
  String get historySearchHint => 'Store, employee or note';

  @override
  String get historyAll => 'All';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyWeek => 'Week';

  @override
  String get historyNothing => 'No operations for this period.';

  @override
  String get opSale => 'Sale';

  @override
  String get opSaleEdited => 'Sale edited';

  @override
  String get opSaleDeleted => 'Sale deleted';

  @override
  String get opSalary => 'Salary paid';

  @override
  String get opSalaryCancelled => 'Payment cancelled';

  @override
  String get opStoreNew => 'New store';

  @override
  String get opStoreEdited => 'Store edited';

  @override
  String get opStoreDeleted => 'Store deleted';

  @override
  String get opEmployeeNew => 'New employee';

  @override
  String get opEmployeeEdited => 'Employee edited';

  @override
  String get opEmployeeDeleted => 'Employee deleted';

  @override
  String opStatus(String status) {
    return 'Status: $status';
  }

  @override
  String get opProfile => 'Profile updated';

  @override
  String get opOther => 'Change';

  @override
  String get stmtTitle => 'Statements and certificates';

  @override
  String get stmtAvailable => 'Available';

  @override
  String get stmtMine => 'My statements';

  @override
  String get stmtCertificates => 'Certificates';

  @override
  String get stmtStatements => 'Statements';

  @override
  String get stmtForPeriod => 'All operations for a period';

  @override
  String get stmtSales => 'Sales';

  @override
  String get stmtStore => 'By store';

  @override
  String get stmtStoreHint => 'Sales of one store for a period';

  @override
  String get stmtCash => 'Cash';

  @override
  String get stmtCashHint => 'Only cash, mixed payments split';

  @override
  String get stmtCard => 'Card and QR';

  @override
  String get stmtCardHint => 'Only non-cash payments';

  @override
  String get stmtExpenses => 'Expenses';

  @override
  String get stmtSalaries => 'Salary payments';

  @override
  String get stmtOperations => 'All operations';

  @override
  String get stmtOperationsHint => 'Every change in the business';

  @override
  String get stmtSalaryDebt => 'Unpaid salaries';

  @override
  String get stmtSalaryDebtHint => 'Employees not fully paid, as of today';

  @override
  String get stmtProfit => 'Profit';

  @override
  String get stmtProfitHint => 'Sales − expenses − salaries for a period';

  @override
  String get stmtStores => 'Stores summary';

  @override
  String get stmtStoresHint => 'Stores ranked by sales';

  @override
  String get stmtMineEmpty => 'Statements you open are kept here.';

  @override
  String get stmtPeriodLastMonth => 'Last month';

  @override
  String get stmtPeriodCustom => 'Choose dates';

  @override
  String get stmtChooseStore => 'Choose a store';

  @override
  String stmtAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get stmtEmpty => 'Nothing for this period.';

  @override
  String get stmtTruncated =>
      'Too many lines: only the newest are shown. Choose a shorter period.';

  @override
  String get stmtExcel => 'Download Excel';

  @override
  String get stmtShared => 'Excel file is ready';

  @override
  String get stmtTotal => 'Total';

  @override
  String get stmtCount => 'Operations';

  @override
  String get stmtCashTotal => 'Cash';

  @override
  String get stmtCardTotal => 'Card';

  @override
  String get stmtQrTotal => 'QR';

  @override
  String get stmtNoMethod => 'Method not set';

  @override
  String get stmtSalesTotal => 'Sales';

  @override
  String get stmtExpensesTotal => 'Expenses';

  @override
  String get stmtSalariesTotal => 'Salaries';

  @override
  String get stmtProfitTotal => 'Profit';

  @override
  String get stmtDue => 'Due';

  @override
  String get stmtPaid => 'Paid';

  @override
  String get stmtRemaining => 'Owed';

  @override
  String get colDate => 'Date';

  @override
  String get colStore => 'Store';

  @override
  String get colMethod => 'Payment method';

  @override
  String get colCash => 'Cash';

  @override
  String get colCard => 'Card / QR';

  @override
  String get colAmount => 'Amount, TJS';

  @override
  String get colReceipt => 'Receipt';

  @override
  String get colDescription => 'Description';

  @override
  String get colCategory => 'Category';

  @override
  String get colEmployee => 'Employee';

  @override
  String get colForMonth => 'For month';

  @override
  String get colNote => 'Note';

  @override
  String get colWhat => 'What';

  @override
  String get colWho => 'Store / employee';

  @override
  String get colUser => 'By';

  @override
  String get colUnpaidMonths => 'Unpaid months';

  @override
  String get colItem => 'Item';

  @override
  String get colPlace => 'Place';

  @override
  String get colShare => 'Share, %';

  @override
  String get colSalesCount => 'Sales';

  @override
  String get moreStatementsHint =>
      'Excel statements: sales, cash, card, expenses…';

  @override
  String get securityTitle => 'Security';

  @override
  String get lockFaceId => 'Sign in with Face ID';

  @override
  String get lockFingerprint => 'Sign in with fingerprint';

  @override
  String get lockBiometric => 'Sign in with biometrics';

  @override
  String get lockHint => 'Ask for it when the app opens';

  @override
  String get lockUnavailable =>
      'No Face ID or fingerprint set up on this phone';

  @override
  String get lockReasonEnable => 'Confirm to turn on the lock';

  @override
  String get lockReasonOpen => 'Open OFAR';

  @override
  String get lockTitle => 'OFAR is locked';

  @override
  String get lockMessage => 'Confirm it is you to see your business.';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockOn => 'Biometric sign-in is on';

  @override
  String get lockOff => 'Biometric sign-in is off';

  @override
  String get lockNotConfirmed => 'Not confirmed — the lock stays off';

  @override
  String get navCurrencies => 'Currencies';

  @override
  String get currenciesSoon => 'Coming soon.';

  @override
  String fxUpdated(String time) {
    return 'Updated: $time';
  }

  @override
  String get fxRefresh => 'Refresh';

  @override
  String get fxConverter => 'Converter';

  @override
  String get fxAmount => 'AMOUNT';

  @override
  String get fxSwap => 'Swap';

  @override
  String get fxFrom => 'From';

  @override
  String get fxTo => 'To';

  @override
  String get fxCrypto => 'Crypto';

  @override
  String get fxCryptoNote =>
      'Rates only — you can\'t buy, sell or exchange here';

  @override
  String get fxAll => 'All';

  @override
  String get fxAllCrypto => 'Cryptocurrencies';

  @override
  String get fxSearchCoin => 'Coin name or ticker';

  @override
  String get fxSources =>
      'Rates: open.er-api.com (daily), crypto: CoinGecko (live).';

  @override
  String get fxCryptoUnavailable => 'Crypto prices are unavailable right now.';

  @override
  String fxLive(String time) {
    return 'Live · $time';
  }

  @override
  String get navDebts => 'Debts';

  @override
  String get debtsTitle => 'Debts and credits';

  @override
  String get debtsOverview => 'Overview';

  @override
  String get debtsOwedToMe => 'Owed to me';

  @override
  String get debtsIOwe => 'I owe';

  @override
  String get debtsToPeople => 'Debts to people';

  @override
  String get debtsLoans => 'Credits and installments';

  @override
  String debtsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String debtsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count debts',
      one: '1 debt',
    );
    return '$_temp0';
  }

  @override
  String get debtsEmptyOwedTitle => 'People owe you money';

  @override
  String get debtsEmptyOwedMessage => 'Add someone who owes you';

  @override
  String get debtsEmptyIOweTitle => 'You owe money';

  @override
  String get debtsEmptyIOweMessage => 'Add someone you owe';

  @override
  String get debtsAdd => 'Add a debt';

  @override
  String get debtsActiveLoans => 'Active credits';

  @override
  String get debtsAddLoan => 'Add a credit';

  @override
  String get debtsNoLoans => 'No active credits or installments';

  @override
  String get debtsClosed => 'Repaid';

  @override
  String get debtsLocalNote =>
      'Kept only on this phone: the server has no debts yet.';

  @override
  String debtLeft(String amount) {
    return '$amount left';
  }

  @override
  String debtDue(String date) {
    return 'Due $date';
  }

  @override
  String debtOverdue(String date) {
    return 'Overdue since $date';
  }

  @override
  String get debtNewOwed => 'Owed to me';

  @override
  String get debtNewIOwe => 'I owe';

  @override
  String get debtNewLoan => 'New credit';

  @override
  String get debtEditTitle => 'Edit';

  @override
  String get debtWho => 'Who';

  @override
  String get debtWhoHint => 'Name';

  @override
  String get debtBank => 'Bank or shop';

  @override
  String get debtLoanType => 'Type';

  @override
  String get debtCredit => 'Credit';

  @override
  String get debtInstallment => 'Installment';

  @override
  String get debtAmountTotal => 'Total to repay';

  @override
  String get debtMonthly => 'Monthly payment';

  @override
  String get debtDueDate => 'Repay by';

  @override
  String get debtNoDueDate => 'No date';

  @override
  String get debtSaved => 'Saved';

  @override
  String get debtRepay => 'Record a repayment';

  @override
  String get debtRepayAll => 'Repaid in full';

  @override
  String get debtRepaid => 'Repayment recorded';

  @override
  String get debtPayments => 'Repayments';

  @override
  String get debtNoPayments => 'No repayments yet.';

  @override
  String debtPaidOf(String paid, String total) {
    return 'Repaid $paid of $total';
  }

  @override
  String get debtDeleteTitle => 'Delete it?';

  @override
  String get debtDeleteMessage =>
      'It and its repayments will be removed from this phone.';

  @override
  String get debtDeleted => 'Deleted';

  @override
  String get debtClosedBadge => 'Repaid';

  @override
  String get actionSalesList => 'Sales';

  @override
  String get pfExpense => 'Expense';

  @override
  String get pfIncome => 'Income';

  @override
  String get pfTransfer => 'Transfer';

  @override
  String get pfNewExpense => 'New expense';

  @override
  String get pfNewIncome => 'New income';

  @override
  String get pfNewTransfer => 'Transfer between accounts';

  @override
  String get pfEditOperation => 'Operation';

  @override
  String get pfAccount => 'Account';

  @override
  String get pfFromAccount => 'From account';

  @override
  String get pfToAccount => 'To account';

  @override
  String get pfSameAccount => 'Choose another account';

  @override
  String get pfSaved => 'Saved';

  @override
  String get pfDeleted => 'Deleted';

  @override
  String get pfDeleteTitle => 'Delete the operation?';

  @override
  String get pfDeleteMessage => 'The account balance changes back.';

  @override
  String get pfOperations => 'Operations';

  @override
  String get pfNoOperations =>
      'No operations yet. Tap “+” to write down an expense or income.';

  @override
  String get pfAccounts => 'Accounts';

  @override
  String get pfAccountsHint => 'Cash, cards and their balances';

  @override
  String get pfNewAccount => 'New account';

  @override
  String get pfAccountName => 'Name';

  @override
  String get pfAccountNameHint => 'Alif card, cash…';

  @override
  String get pfAccountKind => 'Type';

  @override
  String get pfOpeningBalance => 'Balance now';

  @override
  String get pfAccountUsed => 'The account has operations: delete them first.';

  @override
  String get pfAccountDeleteTitle => 'Delete the account?';

  @override
  String get pfKindCash => 'Cash';

  @override
  String get pfKindCard => 'Card';

  @override
  String get pfKindBank => 'Bank account';

  @override
  String get pfKindSavings => 'Savings';

  @override
  String get pfKindOther => 'Other';

  @override
  String get pfTotalBalance => 'My money';

  @override
  String get pfRecurring => 'Regular payments';

  @override
  String get pfRecurringHint => 'Rent, internet, subscriptions';

  @override
  String get pfNewRecurring => 'New regular payment';

  @override
  String get pfRecurringName => 'What for';

  @override
  String get pfRecurringNameHint => 'Internet, rent…';

  @override
  String get pfNextDate => 'Next payment';

  @override
  String get pfEvery => 'How often';

  @override
  String get pfEveryMonth => 'Every month';

  @override
  String get pfEveryQuarter => 'Every 3 months';

  @override
  String get pfEveryYear => 'Every year';

  @override
  String get pfAnyAccount => 'Choose when paying';

  @override
  String get pfPay => 'Paid';

  @override
  String get pfPaid => 'Paid: written as an expense';

  @override
  String get pfNoRecurring => 'No regular payments yet.';

  @override
  String pfDue(String date) {
    return '$date';
  }

  @override
  String get pfDueToday => 'Today';

  @override
  String pfOverdue(String date) {
    return 'Overdue · $date';
  }

  @override
  String get pfUpcoming => 'Coming payments';

  @override
  String get pfMonthIncome => 'Income';

  @override
  String get pfMonthExpense => 'Expenses';

  @override
  String get pfByCategory => 'Expenses by category';

  @override
  String get pfNoExpensesMonth => 'No expenses this month.';

  @override
  String get pfRecent => 'Latest operations';

  @override
  String get pfMyFinances => 'My finances';

  @override
  String get pfLocalNote => 'Personal finances are kept only on this phone.';

  @override
  String get pfCatFood => 'Groceries';

  @override
  String get pfCatCafe => 'Cafés';

  @override
  String get pfCatTransport => 'Transport';

  @override
  String get pfCatHome => 'Home and rent';

  @override
  String get pfCatUtilities => 'Utilities';

  @override
  String get pfCatPhone => 'Phone and internet';

  @override
  String get pfCatHealth => 'Health';

  @override
  String get pfCatClothes => 'Clothes';

  @override
  String get pfCatEducation => 'Education';

  @override
  String get pfCatFun => 'Fun';

  @override
  String get pfCatGifts => 'Gifts';

  @override
  String get pfCatFamily => 'Family';

  @override
  String get pfCatOtherExpense => 'Other';

  @override
  String get pfCatSalary => 'Salary';

  @override
  String get pfCatBusiness => 'Business';

  @override
  String get pfCatSideJob => 'Side job';

  @override
  String get pfCatGiftIn => 'Gift';

  @override
  String get pfCatRefund => 'Refund';

  @override
  String get pfCatOtherIncome => 'Other income';

  @override
  String get phMonthIncome => 'Income this month';

  @override
  String get phMonthExpense => 'Expenses this month';

  @override
  String get phMyBusiness => 'My business';

  @override
  String phBusinessToday(String amount, String profit) {
    return 'Sales today $amount · profit this month $profit';
  }

  @override
  String get phStartBusinessTitle => 'Have a shop?';

  @override
  String get phStartBusinessMessage =>
      'Add it: sales, employees, salaries and its expenses will appear.';

  @override
  String get phAddStore => 'Add a store';

  @override
  String get phAddAccount => 'Add an account';

  @override
  String get phOpen => 'Open';

  @override
  String get actionStoreExpense => 'Store expense';

  @override
  String get quickPersonal => 'Personal';

  @override
  String get quickBusiness => 'Business';

  @override
  String get morePersonal => 'My money';

  @override
  String get moreOperationsHint => 'Every income, expense and transfer';

  @override
  String get assistantSuggestSpending => 'What do I spend the most on?';

  @override
  String get assistantSuggestMonth => 'How much did I spend this month?';

  @override
  String get moreReportsAllHint =>
      'Profit, statements in Excel, history of changes';

  @override
  String get moreCurrenciesHint => 'Rates, converter, crypto';

  @override
  String get reportsProfitHint => 'Stores compared, salaries for the year';

  @override
  String get reportsHistoryHint => 'Every change: sales, expenses, salaries';

  @override
  String get navOperations => 'Operations';

  @override
  String get qeTitle => 'Quick entry';

  @override
  String get qeHint => 'Taxi 50, lunch 35 by card…';

  @override
  String get qeHelp =>
      'Say or type what and how much: “taxi 50”, “got salary 3000 on card”.';

  @override
  String get qeSpeak => 'Speak';

  @override
  String get qeListening => 'Listening…';

  @override
  String get qeNoAmount => 'No amount heard: add a number, e.g. “taxi 50”.';

  @override
  String get qeWrite => 'Write it down';

  @override
  String get qeEdit => 'Change';

  @override
  String get qeNoCategory => 'Category: choose in “Change”';

  @override
  String get qeMicFailed => 'The microphone did not start: type instead.';

  @override
  String get qeButton => 'Say or type: “taxi 50”';

  @override
  String get remTitle => 'AI accountant';

  @override
  String remPaymentTomorrow(String name, String amount) {
    return 'Tomorrow: $name, $amount';
  }

  @override
  String remPaymentToday(String name, String amount) {
    return 'Today: $name, $amount. Tap “Paid” in the app.';
  }

  @override
  String remDebtTomorrow(String name, String amount) {
    return 'Tomorrow the debt is due: $name, $amount';
  }

  @override
  String remDebtToday(String name, String amount) {
    return 'Today the debt is due: $name, $amount';
  }

  @override
  String get pfCurrency => 'Currency';

  @override
  String get pfCurrencyLocked =>
      'The account has operations: its currency stays.';

  @override
  String get pfReceived => 'Arrived on the account';

  @override
  String get pfInTjsNote =>
      'Other currencies are counted in somoni at today\'s rate.';

  @override
  String get pfRatesMissing =>
      'No exchange rates yet: other currencies are counted as is.';

  @override
  String get goalTitle => 'Savings goals';

  @override
  String get goalHint => 'A car, a flat, a trip…';

  @override
  String get goalNew => 'New goal';

  @override
  String get goalName => 'What for';

  @override
  String get goalNameHint => 'A car';

  @override
  String get goalTarget => 'How much is needed';

  @override
  String get goalDeadline => 'By when';

  @override
  String get goalNoDeadline => 'No date';

  @override
  String get goalTopUp => 'Top up';

  @override
  String goalSaved(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get goalReached => 'Reached!';

  @override
  String goalLeft(String amount, String date) {
    return '$amount left · by $date';
  }

  @override
  String goalLeftNoDate(String amount) {
    return '$amount left';
  }

  @override
  String goalPerMonth(String amount) {
    return '≈ $amount a month';
  }

  @override
  String get goalEmpty =>
      'No goals yet. Each goal keeps its money on its own savings account.';

  @override
  String get goalDeleteTitle => 'Delete the goal?';

  @override
  String get goalDeleteMessage => 'Its account and the money on it stay.';

  @override
  String get opsSearch => 'Search: note, category, account';

  @override
  String get opsClear => 'Clear';

  @override
  String get opsAll => 'All';

  @override
  String get opsExpenses => 'Expenses';

  @override
  String get opsIncome => 'Income';

  @override
  String get opsTransfers => 'Transfers';

  @override
  String get opsAllAccounts => 'All accounts';

  @override
  String get opsAllCategories => 'All categories';

  @override
  String get opsReset => 'Reset filters';

  @override
  String opsFound(int count, String income, String expense) {
    return 'Found: $count · income $income · expenses $expense';
  }

  @override
  String get opsNothing => 'Nothing found.';

  @override
  String get opsExcel => 'Excel';

  @override
  String get opsExcelTitle => 'My operations';

  @override
  String get opsColType => 'Type';

  @override
  String get opsColTo => 'To account';

  @override
  String get opsTotalIncome => 'Income, TJS';

  @override
  String get opsTotalExpense => 'Expenses, TJS';

  @override
  String get bkTitle => 'Backup';

  @override
  String get bkHint => 'Save to a file and restore';

  @override
  String get bkAbout =>
      'Personal finances and debts are kept only on this phone. Save a backup file now and then (to Files, iCloud or Telegram “Saved”) so they are not lost with the phone.';

  @override
  String get bkSave => 'Save a backup file';

  @override
  String get bkRestore => 'Restore from a file';

  @override
  String get bkBadFile => 'This file is not a backup of this app.';

  @override
  String get bkConfirmTitle => 'Restore the backup?';

  @override
  String bkConfirmMessage(
    String date,
    int accounts,
    int operations,
    int debts,
  ) {
    return 'From $date: $accounts accounts, $operations operations, $debts debts. What is on the phone now is replaced.';
  }

  @override
  String get bkRestoreAction => 'Restore';

  @override
  String get bkRestored => 'Restored';

  @override
  String get actionFromStore => 'Took from the shop';

  @override
  String get fromStoreNote => 'From the shop';

  @override
  String get pfCatDebtOut => 'Lent';

  @override
  String get pfCatDebtPay => 'Debt repayment';

  @override
  String get pfCatDebtIn => 'Borrowed';

  @override
  String get pfCatDebtBack => 'Debt returned';

  @override
  String get debtAccount => 'Write to account';

  @override
  String get debtNoAccount => 'Don\'t write';
}
