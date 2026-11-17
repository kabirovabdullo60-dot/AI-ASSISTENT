import '../../core/utils/format.dart';
import '../../models/activity_model.dart';
import '../../models/chart_point_model.dart';
import '../../models/disbursement_model.dart';
import '../../models/employee_model.dart';
import '../../models/overview_model.dart';
import '../../models/payroll_model.dart';
import '../../models/sale_model.dart';
import '../../models/store_analytics_model.dart';
import '../../models/store_model.dart';
import '../../models/user_profile_model.dart';

/// In-memory demo backend. Used only while `ApiConstants.useMock` is true.
/// Delete this folder once Mehroj's API is connected.
class MockDatabase {
  MockDatabase._() {
    reset();
  }

  static final MockDatabase instance = MockDatabase._();

  /// How many days of sales history the demo has.
  static const historyDays = 30;

  late List<StoreModel> stores;
  late List<SaleModel> sales;
  late List<EmployeeModel> employees;
  late List<PayrollModel> payroll;
  late List<DisbursementModel> disbursements;
  late List<ActivityModel> activity;
  late List<ActivityModel> storeLog;
  late UserProfileModel profile;
  int _nextId = 1000;

  String get currentPeriod => periodKey(DateTime.now());

  /// Back to the starting demo data (used by tests).
  void reset() {
    final now = DateTime.now();
    final today = dateOnly(now);
    _nextId = 1000;

    profile = const UserProfileModel(
      name: 'Alisher Rahimov',
      role: 'Owner & Admin',
      email: 'owner@apexsuite.tj',
      phone: '+992 90 000 00 00',
    );

    final reopen = DateTime(now.year, now.month + 1, 15);
    stores = [
      const StoreModel(
        id: 's1',
        name: 'Central Plaza Flagship',
        type: 'Flagship',
        address: '45 Rudaki Ave',
        city: 'Dushanbe',
        region: 'Dushanbe',
        phone: '+992 90 123 4567',
        counters: 8,
        staffCount: 9,
        todaySales: 12400,
        todayChange: 12,
        weeklySales: 84200,
        monthlySales: 342000,
        monthlyChange: 15.4,
        note: 'Top Earner (#1)',
      ),
      const StoreModel(
        id: 's2',
        name: 'Somoni Avenue Branch',
        type: 'Downtown',
        address: '112 Ismoili Somoni St',
        city: 'Dushanbe',
        region: 'Dushanbe',
        phone: '+992 93 456 7890',
        counters: 6,
        staffCount: 6,
        todaySales: 8950,
        todayChange: 5.6,
        weeklySales: 62500,
        monthlySales: 268000,
        monthlyChange: 11.2,
        note: '94% Target met',
      ),
      const StoreModel(
        id: 's3',
        name: 'Rudaki Mall Kiosk',
        type: 'Mall Express',
        address: 'Rudaki Mall 2nd Floor',
        city: 'Dushanbe',
        region: 'Dushanbe',
        phone: '+992 98 765 4321',
        counters: 3,
        staffCount: 4,
        todaySales: 6100,
        todayChange: 3.1,
        weeklySales: 45600,
        monthlySales: 195500,
        monthlyChange: 9.8,
        note: 'High footfall',
      ),
      const StoreModel(
        id: 's4',
        name: 'Sino District Supermarket',
        type: 'Suburban',
        address: '78 Sino Blvd',
        city: 'Dushanbe',
        region: 'Dushanbe',
        phone: '+992 91 888 2345',
        counters: 5,
        staffCount: 7,
        todaySales: 5200,
        todayChange: 1.4,
        weeklySales: 40100,
        monthlySales: 172000,
        monthlyChange: 6.1,
        note: 'Residential hub',
      ),
      const StoreModel(
        id: 's5',
        name: 'Khujand Central Market',
        type: 'Market',
        address: '14 Lenin St',
        city: 'Khujand',
        region: 'Sughd',
        phone: '+992 92 333 9012',
        counters: 4,
        staffCount: 5,
        todaySales: 4100,
        todayChange: 0.9,
        weeklySales: 26300,
        monthlySales: 112000,
        monthlyChange: 4.2,
        note: 'Northern hub',
      ),
      StoreModel(
        id: 's6',
        name: 'Bokhtar Express Branch',
        type: 'Express',
        address: '22 Vakhsh Ave',
        city: 'Bokhtar',
        region: 'Khatlon',
        phone: '+992 90 777 6543',
        counters: 2,
        note: 'Reopening ${formatDay(reopen)}',
        isActive: false,
        statusNote: 'Renovation',
      ),
    ];

    const clerks = {'s1': 'D. Aliev', 's2': 'M. Zohidov', 's3': 'S. Karimova', 's4': 'B. Nazarov', 's5': 'N. Umarov'};
    const notes = [
      'POS + Cash',
      'Daily regular',
      'Card payments',
      'Cash reconciliation',
      'Weekend market',
      'Evening peak',
    ];
    const todayTimes = [(18, 30), (17, 45), (16, 15), (15, 0), (14, 10)];
    final active = stores.where((s) => s.isActive).toList();

    sales = [];
    for (var i = 0; i < active.length; i++) {
      final s = active[i];
      sales.add(
        SaleModel(
          id: 'x${s.id}0',
          reference: 'ENT-${10500 + i}',
          storeId: s.id,
          storeName: s.name,
          amount: s.todaySales,
          date: today.add(Duration(hours: todayTimes[i].$1, minutes: todayTimes[i].$2)),
          registeredBy: clerks[s.id]!,
          split: BalanceSplit.values[i % 3],
          notes: notes[i],
        ),
      );
    }
    var ref = 10499;
    for (var d = 1; d < historyDays; d++) {
      for (var i = 0; i < active.length; i++) {
        final s = active[i];
        final vary = 0.8 + ((d * 37 + i * 11) % 41) / 100;
        final amount = ((s.monthlySales / historyDays * vary) / 50).round() * 50.0;
        sales.add(
          SaleModel(
            id: 'x${s.id}$d',
            reference: 'ENT-${ref--}',
            storeId: s.id,
            storeName: s.name,
            amount: amount,
            date: today.subtract(Duration(days: d)).add(Duration(hours: 21, minutes: 15 - i * 3)),
            registeredBy: clerks[s.id]!,
            split: BalanceSplit.values[(d + i) % 3],
            notes: notes[(d + i) % notes.length],
          ),
        );
      }
    }
    sales.sort((a, b) => b.date.compareTo(a.date));

    // name, role, store, tenure, salary, disbursed, shift, on shift
    const staff = [
      ('Davron Aliev', 'Store Manager', 'Central Plaza Flagship', 18, 4500.0, 4500.0, 'Day', true),
      ('Malika Karimova', 'Senior Cashier', 'Somoni Avenue Branch', 12, 3200.0, 3200.0, 'Morning', true),
      ('Farrukh Nazarov', 'Sales Associate', 'Rudaki Mall Kiosk', 8, 2800.0, 1800.0, 'Evening', true),
      ('Nigora Umarova', 'Store Supervisor', 'Khujand Central Market', 24, 3800.0, 3800.0, 'Day', true),
      ('Jamshed Saidov', 'Inventory Specialist', 'Sino District Supermarket', 4, 2600.0, 1300.0, 'Morning', true),
      ('Tahmina Rustamova', 'Sales Associate', 'Central Plaza Flagship', 1, 2400.0, 0.0, 'Evening', false),
      ('Zarina Karimova', 'Store Supervisor', 'Central Plaza Flagship', 30, 4200.0, 4200.0, 'Morning', true),
      ('Rustam Aliev', 'Store Manager', 'Somoni Avenue Branch', 22, 4400.0, 4400.0, 'Day', true),
      ('Dilnoza Saidova', 'Cashier', 'Somoni Avenue Branch', 10, 2600.0, 2600.0, 'Evening', false),
      ('Bekhruz Odinaev', 'Stock Keeper', 'Sino District Supermarket', 14, 2500.0, 0.0, 'Night', false),
      ('Sorbon Kurbonov', 'Cashier', 'Sino District Supermarket', 6, 2400.0, 2400.0, 'Evening', true),
      ('Parvina Sharipova', 'Cashier', 'Khujand Central Market', 9, 2500.0, 2500.0, 'Morning', true),
      ('Manizha Davlatova', 'Security', 'Rudaki Mall Kiosk', 16, 2300.0, 2300.0, 'Night', false),
      ('Firuz Hakimov', 'Store Manager', 'Khujand Central Market', 20, 4100.0, 4100.0, 'Day', true),
    ];
    employees = [
      for (var i = 0; i < staff.length; i++)
        EmployeeModel(
          id: 'e${i + 1}',
          name: staff[i].$1,
          role: staff[i].$2,
          storeName: staff[i].$3,
          shift: staff[i].$7,
          isOnShift: staff[i].$8,
          monthlySalary: staff[i].$5,
        ),
    ];
    payroll = [
      for (var i = 0; i < staff.length; i++)
        PayrollModel(
          id: 'p${i + 1}',
          employeeId: 'e${i + 1}',
          employeeName: staff[i].$1,
          role: staff[i].$2,
          storeName: staff[i].$3,
          tenureMonths: staff[i].$4,
          salary: staff[i].$5,
          disbursed: staff[i].$6,
          period: currentPeriod,
        ),
    ];
    disbursements = [
      DisbursementModel(
        id: 'd4',
        payrollId: 'p1',
        employeeName: 'Davron Aliev',
        amount: 4500,
        method: 'Bank Transfer',
        reference: '#PAY-9921',
        time: today.add(const Duration(hours: 9, minutes: 15)),
      ),
      DisbursementModel(
        id: 'd3',
        payrollId: 'p2',
        employeeName: 'Malika Karimova',
        amount: 3200,
        method: 'Cash Disbursement',
        reference: '#PAY-9918',
        time: today.subtract(const Duration(hours: 6, minutes: 20)),
      ),
      DisbursementModel(
        id: 'd2',
        payrollId: 'p3',
        employeeName: 'Farrukh Nazarov',
        amount: 1800,
        method: 'Bank Transfer',
        reference: '#PAY-9905',
        part: 'Part 1 of 2',
        time: today.subtract(const Duration(days: 2, hours: 9, minutes: 40)),
      ),
      DisbursementModel(
        id: 'd1',
        payrollId: 'p5',
        employeeName: 'Jamshed Saidov',
        amount: 1300,
        method: 'Cash Disbursement',
        reference: '#PAY-9892',
        part: 'Part 1 of 2',
        time: today.subtract(const Duration(days: 3, hours: 12, minutes: 55)),
      ),
    ];

    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));
    final mon = formatMonth(now).toUpperCase();
    activity = [
      ActivityModel(
        id: 'a1',
        type: ActivityType.sale,
        text: 'New daily sale recorded by Store Manager',
        highlight: 'Somoni Ave',
        amount: 8950,
        reference: 'Entry #ENT-10501',
        tag: 'Register 02',
        time: ago(12),
      ),
      ActivityModel(
        id: 'a2',
        type: ActivityType.payroll,
        text: 'Payroll disbursement processed for',
        highlight: 'Davron Aliev',
        amount: -4500,
        reference: 'Batch #PAY-$mon-4',
        tag: 'Direct Bank Wire',
        time: ago(60),
      ),
      ActivityModel(
        id: 'a3',
        type: ActivityType.audit,
        text: 'Inventory & sales audit closed for',
        highlight: 'Central Plaza Flagship',
        reference: 'Supervisor: Z. Karimova',
        tag: 'Zero Discrepancy',
        time: ago(180),
      ),
      ActivityModel(
        id: 'a4',
        type: ActivityType.staff,
        text: 'Employee onboarding completed:',
        highlight: 'Farrukh N.',
        detail: ' assigned as Sales Associate to Rudaki Mall',
        reference: 'Staff ID #EMP-918',
        tag: 'Shift B (Evening)',
        time: ago(300),
      ),
    ];
    storeLog = [
      ActivityModel(
        id: 'l1',
        type: ActivityType.audit,
        text: '',
        highlight: 'Central Plaza Terminal #2 Opened',
        reference: 'Cashier: S. Karimova • 08:30 AM',
        time: ago(200),
      ),
      ActivityModel(
        id: 'l2',
        type: ActivityType.sale,
        text: '',
        highlight: 'Stock Rebalanced to Rudaki Mall',
        reference: '42 SKUs from Warehouse • 10:15 AM',
        time: ago(120),
      ),
      ActivityModel(
        id: 'l3',
        type: ActivityType.staff,
        text: '',
        highlight: 'Bokhtar Branch Renovation Phase II',
        reference: 'Contractor on-site • Yesterday',
        time: ago(1500),
      ),
    ];
  }

  // ---------------- stores ----------------

  StoreModel? store(String? id) {
    for (final s in stores) {
      if (s.id == id) return s;
    }
    return null;
  }

  StoreModel addStore(StoreModel draft) {
    final created = StoreModel(
      id: 's${++_nextId}',
      name: draft.name,
      type: draft.type,
      address: draft.address,
      city: draft.city,
      region: draft.region,
      phone: draft.phone,
      openingHours: draft.openingHours,
      isActive: draft.isActive,
      note: 'New branch',
    );
    stores.add(created);
    storeLog.insert(0, _log('${created.name} added', 'New branch • ${created.city}'));
    return created;
  }

  StoreModel updateStore(StoreModel store) {
    final i = stores.indexWhere((s) => s.id == store.id);
    if (i < 0) throw StateError('Store ${store.id} not found');
    stores[i] = store;
    storeLog.insert(0, _log('${store.name} updated', 'Store details changed'));
    return store;
  }

  void deleteStore(String id) {
    final s = store(id);
    stores.removeWhere((e) => e.id == id);
    if (s != null) storeLog.insert(0, _log('${s.name} removed', 'Store closed in directory'));
  }

  ActivityModel _log(String title, String detail) => ActivityModel(
    id: 'l${++_nextId}',
    type: ActivityType.audit,
    text: '',
    highlight: title,
    reference: detail,
    time: DateTime.now(),
  );

  StoreAnalyticsModel analytics(String storeId) {
    final today = dateOnly(DateTime.now());
    final mine = sales.where((s) => s.storeId == storeId).toList();
    return StoreAnalyticsModel(
      storeId: storeId,
      last7Days: [
        for (var d = 6; d >= 0; d--)
          ChartPointModel(
            date: today.subtract(Duration(days: d)),
            revenue: mine
                .where((s) => isSameDay(s.date, today.subtract(Duration(days: d))))
                .fold<double>(0, (sum, s) => sum + s.amount),
            cashflow: 0,
          ),
      ],
      recent: mine.take(5).toList(),
    );
  }

  // ---------------- sales ----------------

  SaleModel recordSale({
    required String storeId,
    required double amount,
    required DateTime date,
    required BalanceSplit split,
    String notes = '',
  }) {
    final s = store(storeId) ?? stores.first;
    final id = ++_nextId;
    final now = DateTime.now();
    final when = isSameDay(date, now) ? now : DateTime(date.year, date.month, date.day, 21);
    final sale = SaleModel(
      id: 'x$id',
      reference: 'ENT-${11000 + id - 1000}',
      storeId: s.id,
      storeName: s.name,
      amount: amount,
      date: when,
      registeredBy: 'A. Rahimov',
      split: split,
      notes: notes,
    );
    sales.insert(0, sale);
    sales.sort((a, b) => b.date.compareTo(a.date));

    final daysAgo = dateOnly(now).difference(dateOnly(when)).inDays;
    stores[stores.indexOf(s)] = s.copyWith(
      todaySales: daysAgo == 0 ? s.todaySales + amount : null,
      weeklySales: daysAgo < 7 ? s.weeklySales + amount : null,
      monthlySales: daysAgo < 30 ? s.monthlySales + amount : null,
    );
    activity.insert(
      0,
      ActivityModel(
        id: 'a$id',
        type: ActivityType.sale,
        text: 'Daily sales recorded for',
        highlight: s.name,
        amount: amount,
        reference: 'Entry #${sale.reference}',
        tag: split.label,
        time: now,
      ),
    );
    return sale;
  }

  // ---------------- payroll ----------------

  /// Current month = live data; past months = fully paid; future = empty.
  List<PayrollModel> payrollFor(String period) {
    if (period == currentPeriod) return List.of(payroll);
    if (period.compareTo(currentPeriod) > 0) return [];
    return [
      for (final p in payroll)
        if (p.tenureMonths > _monthsBetween(period, currentPeriod))
          PayrollModel(
            id: '${p.id}-$period',
            employeeId: p.employeeId,
            employeeName: p.employeeName,
            role: p.role,
            storeName: p.storeName,
            tenureMonths: p.tenureMonths - _monthsBetween(period, currentPeriod),
            salary: p.salary,
            disbursed: p.salary,
            period: period,
          ),
    ];
  }

  List<DisbursementModel> disbursementsFor(String period) => period == currentPeriod ? List.of(disbursements) : [];

  static int _monthsBetween(String from, String to) {
    int months(String p) => int.parse(p.substring(0, 4)) * 12 + int.parse(p.substring(5, 7));
    return months(to) - months(from);
  }

  DisbursementModel recordPayment({required String payrollId, required double amount, required String method}) {
    final i = payroll.indexWhere((p) => p.id == payrollId);
    if (i < 0) throw StateError('Payroll $payrollId not found');
    final p = payroll[i];
    final pay = amount.clamp(0, p.remaining).toDouble();
    if (pay <= 0) throw StateError('Nothing left to pay');
    final updated = p.copyWith(disbursed: p.disbursed + pay);
    payroll[i] = updated;

    final parts = disbursements.where((d) => d.payrollId == payrollId).length + 1;
    final id = ++_nextId;
    final d = DisbursementModel(
      id: 'd$id',
      payrollId: payrollId,
      employeeName: p.employeeName,
      amount: pay,
      method: method,
      reference: '#PAY-${9900 + id - 1000 + 30}',
      part: parts == 1 && updated.remaining <= 0 ? '' : 'Part $parts${updated.remaining <= 0 ? ' of $parts' : ''}',
      time: DateTime.now(),
    );
    disbursements.insert(0, d);
    activity.insert(
      0,
      ActivityModel(
        id: 'a$id',
        type: ActivityType.payroll,
        text: 'Salary paid to',
        highlight: p.employeeName,
        detail: ' (${p.storeName})',
        amount: -pay,
        reference: 'Payroll ${d.reference}',
        tag: method,
        time: d.time,
      ),
    );
    return d;
  }

  // ---------------- dashboard ----------------

  OverviewModel overview({String? storeId}) {
    final one = store(storeId);
    final scope = one == null ? stores : [one];
    final ids = scope.map((s) => s.id).toSet();
    final names = scope.map((s) => s.name).toSet();
    final mine = sales.where((s) => ids.contains(s.storeId)).toList();
    final pending = payroll.where((p) => p.remaining > 0 && (one == null || names.contains(p.storeName)));
    final staff = employees.where((e) => one == null || names.contains(e.storeName));

    final today = dateOnly(DateTime.now());
    const days = 24;
    final daily = [
      for (var i = 0; i < days; i++)
        () {
          final day = today.subtract(Duration(days: days - 1 - i));
          final revenue = mine.where((s) => isSameDay(s.date, day)).fold<double>(0, (sum, s) => sum + s.amount);
          return ChartPointModel(date: day, revenue: revenue, cashflow: revenue * (0.25 + ((i * 13) % 20) / 100));
        }(),
    ];
    double sum(double Function(StoreModel s) f) => scope.fold(0, (a, s) => a + f(s));
    final yesterday = daily.length > 1 ? daily[daily.length - 2].revenue : 0.0;
    final f = one == null ? 1.0 : (sum((s) => s.monthlySales) / stores.fold<double>(1, (a, s) => a + s.monthlySales));

    return OverviewModel(
      totalStores: scope.length,
      activeStores: scope.where((s) => s.isActive).length,
      newStoresThisQuarter: one == null ? 1 : 0,
      totalStaff: staff.length,
      staffOnShift: staff.where((e) => e.isOnShift).length,
      todaySales: sum((s) => s.todaySales),
      todayChange: percentChange(sum((s) => s.todaySales), yesterday),
      weeklySales: sum((s) => s.weeklySales),
      weeklyChange: 8.2,
      weeklyTarget: 250000 * f,
      monthlySales: sum((s) => s.monthlySales),
      monthlyChange: 14.2,
      unpaidSalaries: pending.fold<double>(0, (a, p) => a + p.remaining),
      pendingPayrolls: pending.length,
      payrollCycle: formatMonth(DateTime.now()),
      grossMargin: 34.8,
      onlineShare: 61.2,
      cashInVaults: 148320 * f,
      averageDaily: daily.fold<double>(0, (a, p) => a + p.revenue) / days,
      totalTransactions: mine.length * 56,
      reconciliationRate: 99.4,
      dailyRevenue: daily,
    );
  }
}
