import '../../core/utils/format.dart';
import '../../models/activity_model.dart';
import '../../models/chart_point_model.dart';
import '../../models/employee_model.dart';
import '../../models/overview_model.dart';
import '../../models/payroll_model.dart';
import '../../models/sale_model.dart';
import '../../models/store_model.dart';
import '../../models/user_profile_model.dart';

/// In-memory demo backend. Used only while `ApiConstants.useMock` is true.
/// Delete this folder once Mehroj's API is connected.
class MockDatabase {
  MockDatabase._() {
    reset();
  }

  static final MockDatabase instance = MockDatabase._();

  static const _dailyRevenue = <double>[
    31200, 33800, 35100, 28400, 36900, 39800, 34200, 33500, 37200, 41800, 36600, 35900, //
    38800, 40200, 43900, 39400, 44800, 52100, 41200, 37900, 36200, 42600, 45300, 38450,
  ];
  static const _dailyCashflow = <double>[
    9800, 11200, 12400, 12900, 13600, 14800, 14100, 13200, 12500, 12100, 12800, 14200, //
    15900, 17800, 19600, 21800, 24900, 27800, 24600, 19400, 16100, 19800, 26900, 28600,
  ];

  late List<StoreModel> stores;
  late List<SaleModel> sales;
  late List<EmployeeModel> employees;
  late List<PayrollModel> payroll;
  late List<ActivityModel> activity;
  late UserProfileModel profile;
  final Map<String, double> _recordedToday = {};
  int _recordedCount = 0;
  int _nextId = 1000;

  /// Back to the starting demo data (used by tests).
  void reset() {
    final now = DateTime.now();
    final cycle = '${formatMonth(now)} ${now.year}';
    _recordedToday.clear();
    _recordedCount = 0;
    _nextId = 1000;

    profile = const UserProfileModel(
      name: 'Alisher Rahimov',
      role: 'Owner & Admin',
      email: 'owner@apexsuite.tj',
      phone: '+992 90 000 00 00',
    );

    stores = const [
      StoreModel(
        id: 's1',
        name: 'Central Plaza Store',
        type: 'Flagship',
        area: 'City Center',
        counters: 8,
        monthlySales: 114200,
        manager: 'Jamshed Ismoilov',
        staffCount: 9,
      ),
      StoreModel(
        id: 's2',
        name: 'Somoni Avenue Branch',
        type: 'Downtown',
        area: 'Somoni Ave',
        counters: 6,
        monthlySales: 89450,
        manager: 'Rustam Aliev',
        staffCount: 7,
      ),
      StoreModel(
        id: 's3',
        name: 'Rudaki Mall Kiosk',
        type: 'Mall Express',
        area: 'Rudaki Mall',
        counters: 3,
        monthlySales: 72100,
        manager: 'Farrukh Nazarov',
        staffCount: 5,
      ),
      StoreModel(
        id: 's4',
        name: 'Sino District Supermarket',
        type: 'Suburban',
        area: 'Sino District',
        counters: 5,
        monthlySales: 54200,
        manager: 'Bekhruz Odinaev',
        staffCount: 6,
      ),
      StoreModel(
        id: 's5',
        name: 'Firdavsi Market Stall',
        type: 'Market',
        area: 'Firdavsi',
        counters: 4,
        monthlySales: 21300,
        manager: 'Parvina Sharipova',
        staffCount: 5,
      ),
      StoreModel(
        id: 's6',
        name: 'Vahdat Road Shop',
        type: 'Roadside',
        area: 'Vahdat Road',
        counters: 2,
        monthlySales: 11000,
        manager: 'Manizha Davlatova',
        staffCount: 4,
      ),
      StoreModel(
        id: 's7',
        name: 'Shohmansur Outlet',
        type: 'Outlet',
        area: 'Shohmansur',
        counters: 2,
        monthlySales: 4800,
        manager: 'Sorbon Kurbonov',
        staffCount: 3,
      ),
      StoreModel(
        id: 's8',
        name: 'Airport Mini Mart',
        type: 'Express',
        area: 'Airport',
        counters: 1,
        monthlySales: 3700,
        manager: 'Firuz Hakimov',
        staffCount: 3,
      ),
    ];

    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));
    sales = [
      SaleModel(
        id: 'x1',
        receipt: 'POS-88219',
        storeId: 's2',
        storeName: 'Somoni Avenue Branch',
        amount: 4850,
        method: PaymentMethod.card,
        register: 'Register 02',
        time: ago(12),
      ),
      SaleModel(
        id: 'x2',
        receipt: 'POS-88218',
        storeId: 's1',
        storeName: 'Central Plaza Store',
        amount: 2310,
        method: PaymentMethod.qr,
        register: 'Register 05',
        time: ago(26),
      ),
      SaleModel(
        id: 'x3',
        receipt: 'POS-88217',
        storeId: 's3',
        storeName: 'Rudaki Mall Kiosk',
        amount: 960,
        method: PaymentMethod.cash,
        register: 'Register 01',
        time: ago(41),
      ),
      SaleModel(
        id: 'x4',
        receipt: 'POS-88216',
        storeId: 's1',
        storeName: 'Central Plaza Store',
        amount: 5420,
        method: PaymentMethod.card,
        register: 'Register 03',
        time: ago(58),
      ),
      SaleModel(
        id: 'x5',
        receipt: 'POS-88215',
        storeId: 's4',
        storeName: 'Sino District Supermarket',
        amount: 1780,
        method: PaymentMethod.cash,
        register: 'Register 02',
        time: ago(75),
      ),
      SaleModel(
        id: 'x6',
        receipt: 'POS-88214',
        storeId: 's5',
        storeName: 'Firdavsi Market Stall',
        amount: 640,
        method: PaymentMethod.qr,
        register: 'Register 01',
        time: ago(96),
      ),
      SaleModel(
        id: 'x7',
        receipt: 'POS-88213',
        storeId: 's2',
        storeName: 'Somoni Avenue Branch',
        amount: 3150,
        method: PaymentMethod.card,
        register: 'Register 04',
        time: ago(130),
      ),
      SaleModel(
        id: 'x8',
        receipt: 'POS-88212',
        storeId: 's6',
        storeName: 'Vahdat Road Shop',
        amount: 1220,
        method: PaymentMethod.cash,
        register: 'Register 01',
        time: ago(170),
      ),
    ];

    employees = const [
      EmployeeModel(
        id: 'e1',
        name: 'Jamshed Ismoilov',
        role: 'Store Manager',
        storeName: 'Central Plaza Store',
        shift: 'Day',
        isOnShift: true,
        monthlySalary: 7500,
      ),
      EmployeeModel(
        id: 'e2',
        name: 'Zarina Karimova',
        role: 'Store Supervisor',
        storeName: 'Central Plaza Store',
        shift: 'Morning',
        isOnShift: true,
        monthlySalary: 6500,
      ),
      EmployeeModel(
        id: 'e3',
        name: 'Madina Rahimova',
        role: 'Cashier',
        storeName: 'Central Plaza Store',
        shift: 'Evening',
        isOnShift: false,
        monthlySalary: 3800,
      ),
      EmployeeModel(
        id: 'e4',
        name: 'Rustam Aliev',
        role: 'Store Manager',
        storeName: 'Somoni Avenue Branch',
        shift: 'Morning',
        isOnShift: true,
        monthlySalary: 7200,
      ),
      EmployeeModel(
        id: 'e5',
        name: 'Dilnoza Saidova',
        role: 'Cashier',
        storeName: 'Somoni Avenue Branch',
        shift: 'Morning',
        isOnShift: true,
        monthlySalary: 3600,
      ),
      EmployeeModel(
        id: 'e6',
        name: 'Farrukh Nazarov',
        role: 'Senior Cashier',
        storeName: 'Rudaki Mall Kiosk',
        shift: 'Evening',
        isOnShift: true,
        monthlySalary: 4200,
      ),
      EmployeeModel(
        id: 'e7',
        name: 'Firuz Hakimov',
        role: 'Security',
        storeName: 'Rudaki Mall Kiosk',
        shift: 'Night',
        isOnShift: false,
        monthlySalary: 3000,
      ),
      EmployeeModel(
        id: 'e8',
        name: 'Bekhruz Odinaev',
        role: 'Stock Keeper',
        storeName: 'Sino District Supermarket',
        shift: 'Morning',
        isOnShift: true,
        monthlySalary: 3400,
      ),
      EmployeeModel(
        id: 'e9',
        name: 'Sorbon Kurbonov',
        role: 'Cashier',
        storeName: 'Sino District Supermarket',
        shift: 'Evening',
        isOnShift: false,
        monthlySalary: 3400,
      ),
      EmployeeModel(
        id: 'e10',
        name: 'Parvina Sharipova',
        role: 'Sales Assistant',
        storeName: 'Firdavsi Market Stall',
        shift: 'Morning',
        isOnShift: true,
        monthlySalary: 3200,
      ),
      EmployeeModel(
        id: 'e11',
        name: 'Manizha Davlatova',
        role: 'Cashier',
        storeName: 'Vahdat Road Shop',
        shift: 'Evening',
        isOnShift: false,
        monthlySalary: 3400,
      ),
      EmployeeModel(
        id: 'e12',
        name: 'Nigina Yusufova',
        role: 'Accountant',
        storeName: 'Head Office',
        shift: 'Day',
        isOnShift: true,
        monthlySalary: 5800,
      ),
    ];

    payroll = [
      PayrollModel(
        id: 'p1',
        employeeName: 'Madina Rahimova',
        role: 'Cashier',
        storeName: 'Central Plaza Store',
        amount: 3800,
        period: cycle,
        isPaid: false,
      ),
      PayrollModel(
        id: 'p2',
        employeeName: 'Dilnoza Saidova',
        role: 'Cashier',
        storeName: 'Somoni Avenue Branch',
        amount: 3600,
        period: cycle,
        isPaid: false,
      ),
      PayrollModel(
        id: 'p3',
        employeeName: 'Bekhruz Odinaev',
        role: 'Stock Keeper',
        storeName: 'Sino District Supermarket',
        amount: 3400,
        period: cycle,
        isPaid: false,
      ),
      PayrollModel(
        id: 'p4',
        employeeName: 'Sorbon Kurbonov',
        role: 'Cashier',
        storeName: 'Sino District Supermarket',
        amount: 3400,
        period: cycle,
        isPaid: false,
      ),
      PayrollModel(
        id: 'p5',
        employeeName: 'Jamshed Ismoilov',
        role: 'Store Manager',
        storeName: 'Central Plaza Store',
        amount: 7500,
        period: cycle,
        isPaid: true,
      ),
      PayrollModel(
        id: 'p6',
        employeeName: 'Zarina Karimova',
        role: 'Store Supervisor',
        storeName: 'Central Plaza Store',
        amount: 6500,
        period: cycle,
        isPaid: true,
      ),
      PayrollModel(
        id: 'p7',
        employeeName: 'Rustam Aliev',
        role: 'Store Manager',
        storeName: 'Somoni Avenue Branch',
        amount: 7200,
        period: cycle,
        isPaid: true,
      ),
      PayrollModel(
        id: 'p8',
        employeeName: 'Farrukh Nazarov',
        role: 'Senior Cashier',
        storeName: 'Rudaki Mall Kiosk',
        amount: 4200,
        period: cycle,
        isPaid: true,
      ),
      PayrollModel(
        id: 'p9',
        employeeName: 'Nigina Yusufova',
        role: 'Accountant',
        storeName: 'Head Office',
        amount: 5800,
        period: cycle,
        isPaid: true,
      ),
    ];

    final mon = formatMonth(now).toUpperCase();
    activity = [
      ActivityModel(
        id: 'a1',
        type: ActivityType.sale,
        text: 'New daily sale recorded by Store Manager',
        highlight: 'Somoni Ave',
        amount: 4850,
        reference: 'Receipt #POS-88219',
        tag: 'Register 02',
        time: ago(12),
      ),
      ActivityModel(
        id: 'a2',
        type: ActivityType.payroll,
        text: 'Payroll disbursement processed for',
        highlight: 'Sino District Supermarket',
        amount: -18200,
        reference: 'Batch #PAY-$mon-4',
        tag: 'Direct Bank Wire',
        time: ago(60),
      ),
      ActivityModel(
        id: 'a3',
        type: ActivityType.audit,
        text: 'Inventory & sales audit closed for',
        highlight: 'Central Plaza Store',
        reference: 'Supervisor: Z. Karimova',
        tag: 'Zero Discrepancy',
        time: ago(180),
      ),
      ActivityModel(
        id: 'a4',
        type: ActivityType.staff,
        text: 'Employee onboarding completed:',
        highlight: 'Farrukh N.',
        detail: ' assigned as Senior Cashier to Rudaki Mall',
        reference: 'Staff ID #EMP-918',
        tag: 'Shift B (Evening)',
        time: ago(300),
      ),
    ];
  }

  StoreModel? _store(String? id) {
    for (final s in stores) {
      if (s.id == id) return s;
    }
    return null;
  }

  OverviewModel overview({String? storeId}) {
    final store = _store(storeId);
    final total = stores.fold<double>(0, (sum, s) => sum + s.monthlySales);
    final f = store == null ? 1.0 : store.monthlySales / total;
    final extra = store == null
        ? _recordedToday.values.fold<double>(0, (a, b) => a + b)
        : (_recordedToday[store.id] ?? 0);
    final pending = payroll.where((p) => !p.isPaid && (store == null || p.storeName == store.name));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final n = _dailyRevenue.length;
    final daily = [
      for (var i = 0; i < n; i++)
        ChartPointModel(
          date: today.subtract(Duration(days: n - 1 - i)),
          revenue: _dailyRevenue[i] * f + (i == n - 1 ? extra : 0),
          cashflow: _dailyCashflow[i] * f,
        ),
    ];

    return OverviewModel(
      totalStores: store == null ? stores.length : 1,
      activeStores: store == null ? stores.where((s) => s.isActive).length : (store.isActive ? 1 : 0),
      newStoresThisQuarter: store == null ? 1 : 0,
      totalStaff: store == null ? 42 : store.staffCount,
      staffOnShift: store == null ? 38 : (store.staffCount * 0.9).round(),
      todaySales: daily.last.revenue,
      todayChange: 12.4,
      weeklySales: 264800 * f + extra,
      weeklyChange: 8.2,
      weeklyTarget: 250000 * f,
      monthlySales: 1142500 * f + extra,
      monthlyChange: 15.8,
      unpaidSalaries: pending.fold<double>(0, (sum, p) => sum + p.amount),
      pendingPayrolls: pending.length,
      payrollCycle: formatMonth(now),
      grossMargin: 34.8,
      onlineShare: 61.2,
      cashInVaults: 148320 * f,
      averageDaily: daily.fold<double>(0, (sum, p) => sum + p.revenue) / n,
      totalTransactions: (8410 * f).round() + _recordedCount,
      reconciliationRate: 99.4,
      dailyRevenue: daily,
    );
  }

  SaleModel recordSale({required String storeId, required double amount, required PaymentMethod method}) {
    final store = _store(storeId) ?? stores.first;
    final id = ++_nextId;
    final sale = SaleModel(
      id: 'x$id',
      receipt: 'POS-${88220 + id - 1001}',
      storeId: store.id,
      storeName: store.name,
      amount: amount,
      method: method,
      register: 'Register 01',
      time: DateTime.now(),
    );
    sales.insert(0, sale);
    _recordedToday[store.id] = (_recordedToday[store.id] ?? 0) + amount;
    _recordedCount++;
    activity.insert(
      0,
      ActivityModel(
        id: 'a$id',
        type: ActivityType.sale,
        text: 'New sale recorded at',
        highlight: store.name,
        amount: amount,
        reference: 'Receipt #${sale.receipt}',
        tag: method.label,
        time: sale.time,
      ),
    );
    return sale;
  }

  PayrollModel markPaid(String id) {
    final i = payroll.indexWhere((p) => p.id == id);
    if (i < 0) throw StateError('Payroll $id not found');
    final paid = payroll[i].copyWith(isPaid: true);
    payroll[i] = paid;
    activity.insert(
      0,
      ActivityModel(
        id: 'a${++_nextId}',
        type: ActivityType.payroll,
        text: 'Salary paid to',
        highlight: paid.employeeName,
        detail: ' (${paid.storeName})',
        amount: -paid.amount,
        reference: 'Payroll #${paid.id.toUpperCase()}',
        tag: paid.period,
        time: DateTime.now(),
      ),
    );
    return paid;
  }
}
