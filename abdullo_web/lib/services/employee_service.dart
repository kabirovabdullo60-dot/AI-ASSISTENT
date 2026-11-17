import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/employee_model.dart';
import 'base_service.dart';

class EmployeeService extends BaseService {
  EmployeeService({super.client, super.useMock});

  Future<List<EmployeeModel>> fetchEmployees() => mockOr(
    mock: (db) => List.of(db.employees),
    api: () async =>
        asJsonList(await client.get(ApiConstants.employees)).map(EmployeeModel.fromJson).toList(),
  );
}
