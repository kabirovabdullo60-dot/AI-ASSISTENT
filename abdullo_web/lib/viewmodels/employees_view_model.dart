import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'base_view_model.dart';

class EmployeesViewModel extends BaseViewModel {
  EmployeesViewModel(this._service);

  final EmployeeService _service;
  List<EmployeeModel> _employees = const [];
  bool _loaded = false;

  List<EmployeeModel> get employees => _employees;
  bool get hasData => _loaded;
  int get onShiftCount => _employees.where((e) => e.isOnShift).length;
  double get monthlyPayroll => _employees.fold(0, (sum, e) => sum + e.monthlySalary);

  List<EmployeeModel> filtered(String query) => query.isEmpty
      ? _employees
      : _employees.where((e) => '${e.name} ${e.role} ${e.storeName} ${e.shift}'.toLowerCase().contains(query)).toList();

  Future<void> load() => runTask(() async {
    _employees = await _service.fetchEmployees();
    _loaded = true;
  }, errorMessage: 'Could not load employees.');
}
