import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/employee_model.dart';
import '../models/page_model.dart';

class EmployeeService {
  EmployeeService(this._api);

  final ApiClient _api;

  /// All employees (every page).
  Future<List<EmployeeModel>> fetchAll({String? storeId}) async {
    final all = <EmployeeModel>[];
    for (var page = 1; ; page++) {
      final query = {'page': page, 'limit': 100, 'sort': 'fullName'};
      final json = storeId == null
          ? await _api.get(ApiConstants.employees, query: query)
          : await _api.get(ApiConstants.employeesOfStore(storeId), query: query);
      final p = PageModel.fromJson(json, EmployeeModel.fromJson);
      all.addAll(p.items);
      if (page >= p.pages || p.items.isEmpty) return all;
    }
  }

  Future<EmployeeModel> create(EmployeeModel e) async =>
      EmployeeModel.fromJson(asJsonMap(await _api.post(ApiConstants.employees, e.toJson())));

  Future<EmployeeModel> update(EmployeeModel e) async =>
      EmployeeModel.fromJson(asJsonMap(await _api.put(ApiConstants.employee(e.id), e.toJson())));

  Future<void> delete(String id) => _api.delete(ApiConstants.employee(id));
}
