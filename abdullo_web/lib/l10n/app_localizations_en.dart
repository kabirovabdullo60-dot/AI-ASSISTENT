// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navStores => 'Stores';

  @override
  String get navSales => 'Sales';

  @override
  String get navEmployees => 'Employees';

  @override
  String get navSalaries => 'Salaries';

  @override
  String get navReports => 'Reports';

  @override
  String get navAssistant => 'AI Assistant';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loadError =>
      'Could not load data. Check the connection and try again.';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get today => 'Today';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String inactiveWithReason(String reason) {
    return 'Inactive ($reason)';
  }

  @override
  String get store => 'Store';

  @override
  String get city => 'City';

  @override
  String get status => 'Status';

  @override
  String get phone => 'Phone';

  @override
  String get staff => 'Staff';

  @override
  String get name => 'Name';

  @override
  String get role => 'Role';

  @override
  String get shift => 'Shift';

  @override
  String get type => 'Type';

  @override
  String get share => 'Share';

  @override
  String get export => 'Export';

  @override
  String get allStores => 'All Stores';

  @override
  String get amountTjs => 'Amount (TJS)';

  @override
  String get enterAmount => 'Enter an amount above 0';

  @override
  String get required => 'Required';

  @override
  String rowsCopied(int count) {
    return '$count rows copied as CSV — paste them into Excel';
  }

  @override
  String get pagerPrev => '‹ Prev';

  @override
  String get pagerNext => 'Next ›';

  @override
  String showingRange(int from, int to, int total) {
    return 'Showing $from–$to of $total';
  }

  @override
  String get language => 'Language';

  @override
  String allStoresActive(int count) {
    return 'All Stores ($count Active)';
  }

  @override
  String get chooseStore => 'Choose store';

  @override
  String get searchHint => 'Search transactions, stores, staff…';

  @override
  String get demoBadge => 'Demo data · API not connected';

  @override
  String get notifications => 'Notifications';

  @override
  String salariesWaiting(int count) {
    return '$count salaries waiting to be paid';
  }

  @override
  String get noNotifications => 'No notifications';

  @override
  String get businessOverview => 'Business Overview';

  @override
  String get liveAudit => 'Live audit';

  @override
  String get overviewSubtitle =>
      'Real-time consolidated performance across all retail branches and capital flows';

  @override
  String get recordSale => 'Record Sale';

  @override
  String todayDate(String date) {
    return 'Today: $date';
  }

  @override
  String get kpiTotalStores => 'Total Stores';

  @override
  String nActive(int count) {
    return '$count Active';
  }

  @override
  String quarterNew(int count, int quarter) {
    return '+$count Q$quarter';
  }

  @override
  String ofRegistered(int count) {
    return 'of $count registered';
  }

  @override
  String get kpiTotalStaff => 'Total Staff';

  @override
  String nStaff(int count) {
    return '$count Staff';
  }

  @override
  String get onShiftToday => 'on shift today';

  @override
  String get kpiTodaySales => 'Today\'s Sales';

  @override
  String get vsYesterday => 'vs yesterday';

  @override
  String get kpiWeeklySales => 'Weekly Sales';

  @override
  String target(String value) {
    return 'Target $value';
  }

  @override
  String get kpiMonthlySales => 'Monthly Sales';

  @override
  String get mom => 'MoM';

  @override
  String get kpiUnpaidSalaries => 'Unpaid Salaries';

  @override
  String nPending(int count) {
    return '$count Pending';
  }

  @override
  String cycle(String month) {
    return '$month cycle';
  }

  @override
  String get revenueTitle => 'Revenue & Cashflow Analytics';

  @override
  String get revenueSubtitle =>
      'Daily gross revenue trajectory across the current operational month';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String peakLabel(String day, String amount) {
    return 'Peak: $day ($amount)';
  }

  @override
  String get peakShort => 'Peak';

  @override
  String get averageDaily => 'Average Daily: ';

  @override
  String get totalVolume => 'Total Volume: ';

  @override
  String txns(String count) {
    return '$count txns';
  }

  @override
  String autoReconciliation(String pct) {
    return '$pct% Automated Reconciliation';
  }

  @override
  String get grossMargin => 'Gross Profit Margin';

  @override
  String get onlineSplit => 'Online / QR Split';

  @override
  String cardShare(String pct) {
    return '$pct% Card';
  }

  @override
  String get cashVaults => 'Cash in Safe Vaults';

  @override
  String get topStores => 'Top Stores';

  @override
  String get ranked => 'Ranked';

  @override
  String get rankedSubtitle => 'Ranked by monthly sales volume';

  @override
  String countersType(String type, int count) {
    return '$type • $count Counters';
  }

  @override
  String shareValue(String pct) {
    return '$pct% Share';
  }

  @override
  String viewAllStores(int count) {
    return 'View All $count Stores Directory';
  }

  @override
  String get recentActivity => 'Recent Business Activity';

  @override
  String get liveFeed => 'Live feed';

  @override
  String get activitySubtitle =>
      'Real-time financial audits, POS register closures, and staff deployments';

  @override
  String get demoFeed => 'Demo feed';

  @override
  String get syncActive => 'Real-time Sync Active';

  @override
  String get filter => 'Filter';

  @override
  String get allActivity => 'All activity';

  @override
  String get activitySales => 'Sales';

  @override
  String get activityPayroll => 'Payroll';

  @override
  String get activityAudits => 'Audits';

  @override
  String get activityStaff => 'Staff';

  @override
  String get noActivity => 'No activity found';

  @override
  String get activityStores => 'Stores';

  @override
  String get activityProfile => 'Profile';

  @override
  String get actCreated => 'created';

  @override
  String get actUpdated => 'updated';

  @override
  String get actDeleted => 'deleted';

  @override
  String get actStatusChanged => 'status changed';

  @override
  String get actPaid => 'paid';

  @override
  String get actCancelled => 'cancelled';

  @override
  String get assistantBusy =>
      'Too many questions. Wait a minute and ask again.';

  @override
  String connectedTo(String endpoints) {
    return 'Connected to $endpoints';
  }

  @override
  String get demoBackend => 'Demo data — backend not connected yet';

  @override
  String get salesEyebrow => 'Financial operations · tajikistan zone';

  @override
  String get salesTitle => 'Sales & Daily Entries';

  @override
  String get salesSubtitle =>
      'Log daily store turnover in Tajikistani Somoni (TJS) and monitor real-time transaction logs.';

  @override
  String get totalToday => 'Total today';

  @override
  String get totalThisMonth => 'Total this month';

  @override
  String get successPrefix => 'Success: ';

  @override
  String saleSavedMessage(String amount, String store) {
    return 'Daily sales of $amount recorded for $store.';
  }

  @override
  String get sessionClerk => 'Active Session Clerk';

  @override
  String get authorized => 'Authorized';

  @override
  String get storeLabel => 'Store:';

  @override
  String get searchReceipt => 'Search receipt # or notes…';

  @override
  String get updatedJustNow => 'Updated just now';

  @override
  String updatedMinutesAgo(int count) {
    return 'Updated $count minutes ago';
  }

  @override
  String get activeFilterVolume => 'Active filter volume';

  @override
  String get filteredTotal => 'Filtered Total: ';

  @override
  String acrossEntries(int count) {
    return '  across $count entries';
  }

  @override
  String vsPrevPeriod(String pct) {
    return '$pct vs prev. period';
  }

  @override
  String get colDateTime => 'Date & time';

  @override
  String get colStoreName => 'Store name';

  @override
  String get colSalesAmount => 'Sales amount';

  @override
  String get colRegisteredBy => 'Registered by';

  @override
  String get colNotesMethod => 'Notes / method';

  @override
  String get noEntries => 'No entries for this filter';

  @override
  String get hourlyVelocity => 'Hourly Velocity (Today)';

  @override
  String get reconciliation => 'Reconciliation Compliance';

  @override
  String storesSynced(int synced, int total) {
    return '$synced of $total stores synced today';
  }

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeWeek => 'This Week';

  @override
  String get rangeMonth => 'This Month';

  @override
  String get rangeCustom => 'Custom Range';

  @override
  String get newDailySale => 'New Daily Sales Record';

  @override
  String get posTerminal => 'POS Terminal';

  @override
  String get selectStore => 'Select Store';

  @override
  String activeBranches(int count) {
    return '$count active branches';
  }

  @override
  String get dailySalesAmount => 'Daily Sales Amount';

  @override
  String get amountHint => 'e.g. 5,450.00';

  @override
  String get amountHelper => 'Gross daily register total inclusive of VAT';

  @override
  String get accountingDate => 'Transaction Accounting Date';

  @override
  String get balanceSplit => 'Primary Balance Split';

  @override
  String get splitBalanced => 'Balanced';

  @override
  String get splitPos => 'POS > 80%';

  @override
  String get splitCash => 'Cash Heavy';

  @override
  String get notesLabel => 'Description / Notes ';

  @override
  String get optional => '(optional)';

  @override
  String get notesHint =>
      'e.g. End of day cash & POS terminal reconciliation, promo event';

  @override
  String get saveSaleRecord => 'Save Sale Record';

  @override
  String get syncsTo => '  Data syncs instantly to REST endpoint ';

  @override
  String get saleFailed => 'Could not save the sale. Try again.';

  @override
  String saleRecorded(String date) {
    return 'Sale recorded · $date';
  }

  @override
  String get storesEyebrow1 => 'Enterprise fleet';

  @override
  String get storesEyebrow2 => 'Store directory';

  @override
  String get storesTitle => 'Store Management';

  @override
  String get storesSubtitle =>
      'Manage multi-branch retail locations, track revenue and branch health across regional networks.';

  @override
  String get exportDirectory => 'Export Directory';

  @override
  String get addNewStore => 'Add New Store';

  @override
  String get networkScope => 'Network Scope';

  @override
  String nLocations(int count) {
    return '$count Locations';
  }

  @override
  String opRatio(int pct) {
    return '$pct% Op. Ratio';
  }

  @override
  String activeInactive(int active, int inactive) {
    return '$active active · $inactive inactive';
  }

  @override
  String get fleetVelocity => 'Today\'s Fleet Velocity';

  @override
  String get allBranchesToday => 'all branches today';

  @override
  String get totalMonthlyRevenue => 'Total Monthly Revenue';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get allocatedWorkforce => 'Allocated Workforce';

  @override
  String acrossBranches(int count) {
    return 'Across $count branches';
  }

  @override
  String get noStoresMatch => 'No stores match the filters';

  @override
  String get monthlyVolume => 'Monthly Volume';

  @override
  String allStatusCounts(int active, int inactive) {
    return 'All Status ($active Active, $inactive Inactive)';
  }

  @override
  String activeOnly(int count) {
    return 'Active only ($count)';
  }

  @override
  String inactiveOnly(int count) {
    return 'Inactive only ($count)';
  }

  @override
  String get allStatus => 'All Status';

  @override
  String get searchStores => 'Search stores by name, city, phone…';

  @override
  String sortBy(String label) {
    return 'Sort by: $label';
  }

  @override
  String get sortRevenue => 'Highest Revenue';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get grid => 'Grid';

  @override
  String get list => 'List';

  @override
  String get deleteStoreTitle => 'Delete store?';

  @override
  String deleteStoreBody(String name) {
    return '\"$name\" will be removed from the directory. Its past sales stay in reports.';
  }

  @override
  String storeDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get deleteFailed => 'Could not delete the store';

  @override
  String get viewAnalytics => 'View Analytics →';

  @override
  String vsYest(String pct) {
    return '$pct vs yest.';
  }

  @override
  String get offline => 'Offline';

  @override
  String get topEarner => 'Top Earner (#1)';

  @override
  String get staffHeadcount => 'Staff Headcount';

  @override
  String get reassigned => '0 (reassigned)';

  @override
  String nEmployees(int count) {
    return '$count employees';
  }

  @override
  String get regionalTitle => 'Regional Sales Distribution';

  @override
  String regionalSubtitle(String regions) {
    return 'Live breakdown across $regions';
  }

  @override
  String get endpoint => 'Endpoint';

  @override
  String branchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Branches',
      one: '1 Branch',
    );
    return '$_temp0';
  }

  @override
  String nInactive(int count) {
    return '$count inactive';
  }

  @override
  String get capitalOutlets => 'Capital outlets';

  @override
  String get regionalTerritory => 'Regional territory';

  @override
  String registersSynced(int count) {
    return '✓ All $count active registers synced';
  }

  @override
  String get opsLog => 'Store Operations Log';

  @override
  String get noOperations => 'No operations yet';

  @override
  String get viewAuditTrail => 'View Full Audit Trail →';

  @override
  String get editStore => 'Edit Store';

  @override
  String get storeName => 'Store name';

  @override
  String get storeType => 'Type (Flagship, Mall Express…)';

  @override
  String get address => 'Address';

  @override
  String get region => 'Region';

  @override
  String get enterPhone => 'Enter a phone number';

  @override
  String get operatingHours => 'Operating hours';

  @override
  String get storeOpen => 'Store is open (active)';

  @override
  String get addStore => 'Add Store';

  @override
  String storeAdded(String name) {
    return '$name added';
  }

  @override
  String storeSaved(String name) {
    return '$name saved';
  }

  @override
  String get storeSaveFailed => 'Could not save the store. Try again.';

  @override
  String get storeNotFound => 'Store not found';

  @override
  String get dailySales => 'Daily Sales';

  @override
  String get monthlyTotal => 'Monthly Total';

  @override
  String get velocity7 => '7-Day Sales Velocity';

  @override
  String avgPerDay(String amount) {
    return 'Avg: $amount/day';
  }

  @override
  String get sixDaysAgo => '6 Days Ago';

  @override
  String get todayCurrent => 'Today (Current)';

  @override
  String get storeParams => 'Store Parameters & Configuration';

  @override
  String get phoneLine => 'Phone Line:';

  @override
  String get staffAllocation => 'Branch Staff Allocation:';

  @override
  String activeCrew(int count) {
    return '$count Active Crew';
  }

  @override
  String get apiSync => 'REST API Synchronizer:';

  @override
  String get operatingHoursLabel => 'Operating Hours:';

  @override
  String get statusLabel => 'Status:';

  @override
  String get recentPos => 'Recent POS Activity';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get payrollEyebrow => 'Enterprise portal';

  @override
  String fiscalYear(String year) {
    return 'FISCAL YEAR $year';
  }

  @override
  String ledger(String path) {
    return 'LEDGER $path';
  }

  @override
  String get payrollTitle => 'Salaries & Payroll Management';

  @override
  String get payrollSubtitle =>
      'Manage monthly employee remuneration, record disbursements and track outstanding balances across all regional hubs.';

  @override
  String get exportLedger => 'Export Ledger';

  @override
  String get recordSalaryPayment => 'Record Salary Payment';

  @override
  String get totalMonthlyPayroll => 'Total Monthly Payroll';

  @override
  String get allocatedBudget => 'Allocated monthly budget';

  @override
  String get totalDisbursed => 'Total Disbursed';

  @override
  String pctDisbursed(String pct) {
    return '$pct% disbursed';
  }

  @override
  String get settled => 'Settled';

  @override
  String get totalOutstanding => 'Total Outstanding';

  @override
  String pctBalance(String pct) {
    return '$pct% balance';
  }

  @override
  String get pendingClearance => 'Pending clearance';

  @override
  String get staffDistribution => 'Staff Distribution';

  @override
  String nBranches(int count) {
    return '$count Branches';
  }

  @override
  String get activeContracts => '100% active contracts';

  @override
  String get colEmployee => 'Employee & position';

  @override
  String get colAssignedStore => 'Assigned store';

  @override
  String get colTenure => 'Tenure';

  @override
  String get colMonthlySalary => 'Monthly salary';

  @override
  String get colDisbursed => 'Disbursed';

  @override
  String get colRemaining => 'Remaining';

  @override
  String get colStatus => 'Status';

  @override
  String get colActions => 'Actions';

  @override
  String noPayrollFor(String month) {
    return 'No payroll for $month yet';
  }

  @override
  String get noEmployeesMatch => 'No employees match the filters';

  @override
  String filteredBatch(String month) {
    return 'Filtered Batch: $month';
  }

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get history => 'History';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String allStoresCount(int count) {
    return 'All Stores ($count)';
  }

  @override
  String get searchStaff => 'Search by staff name or position…';

  @override
  String get tabAll => 'All';

  @override
  String get tabPaid => 'Fully Paid';

  @override
  String get tabPartial => 'Partial';

  @override
  String get tabUnpaid => 'Unpaid';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String tabCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String tenure(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mos',
      one: '1 mo',
    );
    return '$_temp0';
  }

  @override
  String get budgetTitle => 'Store Budget Allocation';

  @override
  String get balanced => 'Balanced';

  @override
  String get openBalance => 'Open balance';

  @override
  String get noPayrollMonth => 'No payroll for this month';

  @override
  String storeStaff(String store, int count) {
    return '$store ($count staff)';
  }

  @override
  String get erpSynced => 'Synced with ERP General Ledger';

  @override
  String get recentDisbursements => 'Recent Payroll Disbursements';

  @override
  String get disbursementsSubtitle =>
      'Real-time payment audit log across retail branches';

  @override
  String get viewFullAudit => 'View Full Audit →';

  @override
  String get noPaymentsMonth => 'No payments recorded this month';

  @override
  String get bankNote =>
      'All bank settlements follow National Bank standard formats and are signed via TLS.';

  @override
  String ledgerCopied(String month) {
    return 'Ledger for $month copied as CSV';
  }

  @override
  String get methodBank => 'Bank Transfer';

  @override
  String get methodCash => 'Cash Disbursement';

  @override
  String paidTo(String amount, String name) {
    return 'Paid $amount to $name';
  }

  @override
  String get paymentFailed => 'Payment failed. Try again.';

  @override
  String get everyonePaid => 'Everyone is fully paid for this month.';

  @override
  String get employee => 'Employee';

  @override
  String owed(String name, String amount) {
    return '$name — owed $amount';
  }

  @override
  String salarySummary(String salary, String paid, String remaining) {
    return 'Salary $salary · paid $paid · remaining $remaining';
  }

  @override
  String maxAmount(String amount) {
    return 'Max $amount';
  }

  @override
  String paymentsOf(String name) {
    return '$name — payments';
  }

  @override
  String get paidBeforeRecords =>
      'Paid before the records in this app (no separate payments listed).';

  @override
  String get employeesSubtitle => 'Staff across all stores and shifts';

  @override
  String get onShiftNow => 'On shift now';

  @override
  String get monthlyPayroll => 'Monthly payroll';

  @override
  String get staffDirectory => 'Staff directory';

  @override
  String get noEmployees => 'No employees found';

  @override
  String get onShift => 'On shift';

  @override
  String get offShift => 'Off';

  @override
  String get analyzeMyReport => 'Analyze my sales report';

  @override
  String get reportsSubtitle => 'Monthly performance by store';

  @override
  String get analyzeWithAi => 'Analyze with AI';

  @override
  String monthlySalesChange(String pct) {
    return 'Monthly sales ($pct)';
  }

  @override
  String get grossMarginShort => 'Gross margin';

  @override
  String get averagePerDay => 'Average per day';

  @override
  String get salesByStore => 'Sales by store';

  @override
  String get monthlySalesCol => 'Monthly sales';

  @override
  String get email => 'Email';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutNote =>
      'Sign in / sign out will work once the backend login is ready.';

  @override
  String get business => 'Business';

  @override
  String get businessName => 'Business name';

  @override
  String get currency => 'Currency';

  @override
  String get backendConnection => 'Backend connection';

  @override
  String get demoData => 'Demo data';

  @override
  String get demoNote =>
      'The web shows demo data until the endpoints below are connected.';

  @override
  String get askAssistant => 'Ask your business assistant';

  @override
  String get assistantIntro =>
      'Ask about sales, stores, staff, salaries or marketing in Tajik, Russian or English.';

  @override
  String get newChat => 'New chat';

  @override
  String get askHint => 'Ask about your business…';

  @override
  String get send => 'Send';

  @override
  String get assistantError =>
      'The assistant did not answer. Please try again.';

  @override
  String get suggestSales => 'Sales today';

  @override
  String get suggestStores => 'Top stores';

  @override
  String get suggestSalaries => 'Unpaid salaries';

  @override
  String get suggestMarketing => 'Marketing ideas';

  @override
  String chartRevenue(String amount) {
    return 'Revenue: $amount';
  }

  @override
  String chartCashflow(String amount) {
    return 'Cashflow: $amount';
  }

  @override
  String get loading => 'Loading…';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to manage your stores, sales and payroll.';

  @override
  String get registerTitle => 'Create your business account';

  @override
  String get registerSubtitle =>
      'One account = one business. You can add stores and staff after signing up.';

  @override
  String get emailLabel => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get businessNameOptional => 'Business name (optional)';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get noAccount => 'Don\'t have an account? Create one';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPhone => 'Phone: 7–15 digits, e.g. +992901234567';

  @override
  String get errInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errEmailTaken => 'An account with this email already exists.';

  @override
  String get errAccountDisabled => 'This account has been disabled.';

  @override
  String get errAccountLocked => 'Too many failed attempts. Try again later.';

  @override
  String get errSessionEnded => 'Your session has ended. Please sign in again.';

  @override
  String get errPermission => 'You do not have permission to do this.';

  @override
  String get errNotFound => 'Not found — it may have been deleted.';

  @override
  String get errConflict => 'This conflicts with existing data.';

  @override
  String errValidation(String fields) {
    return 'Some fields are not valid: $fields';
  }

  @override
  String get errValidationShort => 'Please check the fields.';

  @override
  String get errNetwork =>
      'No connection to the server. Check the internet and try again.';

  @override
  String get errRateLimited =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errServer => 'Server error. Try again later.';

  @override
  String get errStoreNameTaken => 'A store with this name already exists.';

  @override
  String get errStoreHasEmployees =>
      'The store still has active employees. Move or deactivate them first.';

  @override
  String get errAlreadyPaid =>
      'The salary for this month is already fully paid.';

  @override
  String get errExceedsRemaining =>
      'The amount is larger than what remains for this month.';

  @override
  String get errNotEmployed => 'The employee did not work in this month.';

  @override
  String get errFutureDate => 'The date cannot be in the future.';

  @override
  String get errFuturePeriod => 'Salary can\'t be paid for a future month.';

  @override
  String get errEmploymentDates => 'The employment dates are invalid.';

  @override
  String get errDateRange => 'The date range is invalid.';

  @override
  String get errPasswordWeak => 'The password is too weak.';

  @override
  String get errCurrentPassword => 'The current password is incorrect.';

  @override
  String get errAvatarType => 'The photo must be JPEG, PNG or WebP.';

  @override
  String get errAvatarSize => 'The photo is too large.';

  @override
  String errUnknown(String code) {
    return 'Something went wrong ($code).';
  }

  @override
  String get description => 'Description';

  @override
  String get storeDescriptionHint => 'e.g. Flagship · 8 counters';

  @override
  String get editSale => 'Edit sale';

  @override
  String get deleteSaleTitle => 'Delete this sale?';

  @override
  String deleteSaleBody(String amount, String store, String date) {
    return '$amount for $store on $date will be removed from reports.';
  }

  @override
  String get saleUpdated => 'Sale updated';

  @override
  String get saleDeleted => 'Sale deleted';

  @override
  String get colActionsShort => '';

  @override
  String get addEmployee => 'Add employee';

  @override
  String get editEmployee => 'Edit employee';

  @override
  String get position => 'Position';

  @override
  String get monthlySalary => 'Monthly salary (TJS)';

  @override
  String get hiredAt => 'Hired on';

  @override
  String get terminatedAt => 'Left on (optional)';

  @override
  String get employeeActive => 'Employee is active';

  @override
  String get deleteEmployeeTitle => 'Delete employee?';

  @override
  String deleteEmployeeBody(String name) {
    return '\"$name\" will be hidden. Salary history stays.';
  }

  @override
  String employeeSaved(String name) {
    return '$name saved';
  }

  @override
  String employeeDeleted(String name) {
    return '$name deleted';
  }

  @override
  String hiredThisMonth(int count) {
    return '$count hired this month';
  }

  @override
  String get averageSalary => 'Average salary';

  @override
  String get byPosition => 'By position';

  @override
  String get selectStoreFirst => 'Add a store first';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get paymentCancelled => 'Payment cancelled';

  @override
  String get cancelPayment => 'Cancel payment';

  @override
  String get cancelPaymentTitle => 'Cancel this payment?';

  @override
  String workedDays(int count) {
    return '$count days';
  }

  @override
  String payFor(String month) {
    return 'Payment for $month';
  }

  @override
  String owedAllMonths(String amount) {
    return 'Owed for all months: $amount';
  }

  @override
  String get months => 'Months';

  @override
  String get payments => 'Payments';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String salesCount(int count) {
    return '$count sales';
  }

  @override
  String chartSales(int count) {
    return 'Sales: $count';
  }

  @override
  String get averageSale => 'Average sale';

  @override
  String get salesThisMonth => 'Sales this month';

  @override
  String get unpaidAllMonths => 'Unpaid (all months)';

  @override
  String ofTotal(int count) {
    return 'of $count total';
  }

  @override
  String ofDue(String amount) {
    return 'of $amount due';
  }

  @override
  String topStore(String name) {
    return 'Top store: $name';
  }

  @override
  String get noSalesThisMonth => 'No sales this month yet';

  @override
  String get recentlyUpdated => 'Recently updated stores';

  @override
  String get salesShare => 'Sales share this month';

  @override
  String updatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get storeComparisonTitle => 'Store comparison — this month';

  @override
  String payrollYearTitle(String year) {
    return 'Payroll $year';
  }

  @override
  String get colDue => 'Due';

  @override
  String get colPaid => 'Paid';

  @override
  String get colRemainingShort => 'Remaining';

  @override
  String get colChange => 'Change';

  @override
  String get colSales => 'Sales';

  @override
  String get colMonth => 'Month';

  @override
  String get colEmployees => 'Employees';

  @override
  String get prevYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get apiServer => 'Server';

  @override
  String get apiOnline => 'API connected';

  @override
  String get apiOffline => 'API offline';

  @override
  String get openDocs => 'API docs (Swagger)';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get salesLast7 => 'Sales — last 7 days';

  @override
  String get storesReported => 'Stores with sales today';

  @override
  String storesReportedValue(int count, int total) {
    return '$count of $total stores';
  }

  @override
  String get assistantNote =>
      'Answers come from your real numbers, worked out by the AI on the server.';

  @override
  String get staffInStore => 'Staff';

  @override
  String get createdLabel => 'Created:';

  @override
  String get addressLabel => 'Address:';

  @override
  String get searchEntries => 'Search store or description…';

  @override
  String get today2 => 'Today';

  @override
  String noticeUnpaid(int count, String amount) {
    return '$count employees still to be paid this month · $amount TJS';
  }

  @override
  String noticeOverdue(int count, String amount) {
    return 'Overdue salaries: $count unpaid months · $amount TJS';
  }

  @override
  String noticeNoSales(String store) {
    return '$store: no sales today';
  }

  @override
  String get navExpenses => 'Expenses';

  @override
  String get expensesSubtitle =>
      'Rent, utilities, delivery and other costs, and the profit that is left';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get expenseList => 'All expenses';

  @override
  String get expenseTotal => 'Total';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseCategoryLabel => 'Category';

  @override
  String get allCategories => 'All categories';

  @override
  String get wholeBusiness => 'Whole business';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String get deleteExpenseBody =>
      'It will no longer count in the profit report.';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get catRent => 'Rent';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catDelivery => 'Delivery';

  @override
  String get catSupplies => 'Supplies';

  @override
  String get catMarketing => 'Marketing';

  @override
  String get catTaxes => 'Taxes';

  @override
  String get catOther => 'Other';

  @override
  String get profitThisMonth => 'Profit this month';

  @override
  String get profitLabel => 'Profit';

  @override
  String get salaryDueLabel => 'Salary due';

  @override
  String get byCategory => 'By category';

  @override
  String get profitByStore => 'Profit by store';

  @override
  String get errExpenseNotFound => 'This expense no longer exists.';

  @override
  String get goalsTitle => 'Targets & profit';

  @override
  String get weeklyTarget => 'Weekly sales target';

  @override
  String get monthlyTarget => 'Monthly sales target';

  @override
  String get noTarget => 'No target set';

  @override
  String get setTargets => 'Set targets';

  @override
  String get targetsSaved => 'Targets saved';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get loginHeadline => 'Every store, sale and salary in one calm place.';

  @override
  String get loginHeroBody =>
      'Ask the assistant about your numbers. It answers in Tajik, Russian or English.';

  @override
  String get assistantLiveData => 'Uses your real numbers';

  @override
  String get askSales => 'How much did I sell today?';

  @override
  String get askStores => 'Which store sells best this month?';

  @override
  String get askSalaries => 'Who is still waiting for salary?';

  @override
  String get askMarketing => 'Ideas to bring in more customers';

  @override
  String get themeLabel => 'Theme';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get greetingNoName => 'Hello';

  @override
  String get errSplitMismatch =>
      'Cash and card must add up to the sale amount.';

  @override
  String get clearDate => 'Clear date';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get voiceSpeak => 'Speak';

  @override
  String get voiceStop => 'Stop listening';

  @override
  String get voiceListening => 'Listening…';

  @override
  String voiceOpened(String section) {
    return 'Opened: $section';
  }

  @override
  String get voiceRepliesOn => 'Read answers aloud: on';

  @override
  String get voiceRepliesOff => 'Read answers aloud: off';

  @override
  String get voiceStopSpeaking => 'Stop reading';

  @override
  String get voiceHint =>
      'Tap the mic and say: “Open sales”, “New chat” or any question.';

  @override
  String get voiceDenied =>
      'Microphone access is blocked. Allow it in the browser address bar.';

  @override
  String get voiceNoSpeech => 'I didn\'t hear anything. Try again.';

  @override
  String get voiceNoMic => 'No microphone found.';

  @override
  String get voiceUnsupported =>
      'This browser can\'t listen. Use Chrome or Edge.';

  @override
  String get voiceNetwork => 'Voice recognition needs the internet.';

  @override
  String get voiceError => 'Voice input failed. Try again.';

  @override
  String get chatHistory => 'History';

  @override
  String get chatHistoryEmpty =>
      'No saved chats yet. Ask a question — the chat is saved here.';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get deleteChatConfirm => 'Delete this chat? It cannot be restored.';

  @override
  String chatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }
}
