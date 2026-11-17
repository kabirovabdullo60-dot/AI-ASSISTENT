import '../models/employee_model.dart';
import '../models/employees_report_model.dart';
import '../services/employee_service.dart';
import '../services/reports_service.dart';
import 'base_view_model.dart';

class EmployeesViewModel extends BaseViewModel {
  EmployeesViewModel(this._service, this._reports);

  final EmployeeService _service;
  final ReportsService _reports;
  List<EmployeeModel> _employees = const [];
  EmployeesReportModel? _report;
  bool _loaded = false;
  bool _isSaving = false;

  List<EmployeeModel> get employees => _employees;
  EmployeesReportModel? get report => _report;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;
  int get activeCount => _employees.where((e) => e.isActive).length;
  double get monthlyPayroll => _employees.where((e) => e.isActive).fold(0, (s, e) => s + e.monthlySalary);

  List<EmployeeModel> filtered(String query) => query.isEmpty
      ? _employees
      : _employees
            .where((e) => '${e.fullName} ${e.position} ${e.storeName} ${e.phone ?? ''}'.toLowerCase().contains(query))
            .toList();

  Future<void> load() => runTask(() async {
    final (list, report) = await (_service.fetchAll(), _reports.employees()).wait;
    _employees = list;
    _report = report;
    _loaded = true;
  });

  Future<String?> save(EmployeeModel e, {required bool isNew}) async {
    _isSaving = true;
    notifySafe();
    final error = await runAction(() async {
      final saved = isNew ? await _service.create(e) : await _service.update(e);
      _employees = isNew ? [..._employees, saved] : [for (final x in _employees) x.id == saved.id ? saved : x];
      _report = await _reports.employees();
    });
    _isSaving = false;
    notifySafe();
    return error;
  }

  Future<String?> delete(String id) => runAction(() async {
    await _service.delete(id);
    _employees = _employees.where((e) => e.id != id).toList();
    _report = await _reports.employees();
  });
}
