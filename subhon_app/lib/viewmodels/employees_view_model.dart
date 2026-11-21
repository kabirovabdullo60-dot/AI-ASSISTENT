import 'dart:async';

import '../core/network/api_client.dart';
import '../models/employee_model.dart';
import '../models/employees_report_model.dart';
import '../models/page_model.dart';
import '../services/employee_service.dart';
import '../services/reports_service.dart';
import 'paged_list_view_model.dart';

/// Employees page by page, with search and the employees report summary.
class EmployeesViewModel extends PagedListViewModel<EmployeeModel> {
  EmployeesViewModel(this._employees, this._reports);

  final EmployeeService _employees;
  final ReportsService _reports;

  String _search = '';
  Timer? _typing;

  /// How long to wait after the last key before searching.
  static const searchDelay = Duration(milliseconds: 400);
  EmployeesReportModel? _report;

  String get search => _search;

  /// `GET /api/reports/employees` (totals above the list).
  EmployeesReportModel? get report => _report;

  Future<void> setSearch(String value) {
    _typing?.cancel();
    _search = value.trim();
    return load();
  }

  /// Searches as the name, position or phone is typed: once typing pauses
  /// for [searchDelay] (at once when cleared), and only when the text
  /// really changed.
  void searchAsTyped(String value) {
    _typing?.cancel();
    if (value.trim() == _search) return;
    // Cleared: the whole list comes back at once.
    if (value.trim().isEmpty) {
      setSearch('');
      return;
    }
    _typing = Timer(searchDelay, () => setSearch(value));
  }

  @override
  void dispose() {
    _typing?.cancel();
    super.dispose();
  }

  @override
  Future<PageModel<EmployeeModel>> fetch(int page) async {
    if (page == 1) {
      try {
        _report = await _reports.employees();
      } on ApiException {
        // The list matters more; the summary is shown when available.
      }
    }
    return _employees.list(
      search: _search.isEmpty ? null : _search,
      page: page,
    );
  }

  Future<void> delete(String id) async {
    await _employees.delete(id);
    removeWhere((e) => e.id == id);
  }
}
