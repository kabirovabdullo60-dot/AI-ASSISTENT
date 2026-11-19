import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/employee_create_model.dart';
import '../models/employee_model.dart';
import '../models/employee_status.dart';
import '../models/employee_update_model.dart';
import '../models/page_model.dart';

/// `Employees` (API.md).
class EmployeeService {
  EmployeeService(this._api);

  final ApiClient _api;

  Future<PageModel<EmployeeModel>> list({
    String? storeId,
    EmployeeStatus? status,
    String? search,
    int page = 1,
    int limit = ApiConstants.pageSize,
  }) async => PageModel.fromJson(
    await _api.get(
          storeId == null ? '/api/employees' : '/api/employees/store/$storeId',
          query: {
            'status': status?.json,
            'search': search,
            'page': page,
            'limit': limit,
          },
        )
        as Map<String, dynamic>,
    EmployeeModel.fromJson,
  );

  Future<EmployeeModel> get(String id) async => EmployeeModel.fromJson(
    await _api.get('/api/employees/$id') as Map<String, dynamic>,
  );

  Future<EmployeeModel> create(EmployeeCreateModel employee) async =>
      EmployeeModel.fromJson(
        await _api.post('/api/employees', body: employee.toJson())
            as Map<String, dynamic>,
      );

  Future<EmployeeModel> update(
    String id,
    EmployeeUpdateModel update, {
    Set<String> clear = const {},
  }) async => EmployeeModel.fromJson(
    await _api.put('/api/employees/$id', body: update.toJson(clear: clear))
        as Map<String, dynamic>,
  );

  Future<void> delete(String id) => _api.delete('/api/employees/$id');
}
