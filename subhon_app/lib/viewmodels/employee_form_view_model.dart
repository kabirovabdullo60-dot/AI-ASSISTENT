import '../core/network/api_client.dart';
import '../core/utils/phone.dart';
import '../models/employee_create_model.dart';
import '../models/employee_model.dart';
import '../models/employee_status.dart';
import '../models/employee_update_model.dart';
import '../models/store_model.dart';
import '../services/employee_service.dart';
import '../services/store_service.dart';
import 'form_view_model.dart';

/// Adds an employee, or edits [initial]. Loads the stores to choose from.
class EmployeeFormViewModel extends FormViewModel {
  EmployeeFormViewModel(this._employees, this._storesService, {this.initial});

  final EmployeeService _employees;
  final StoreService _storesService;
  final EmployeeModel? initial;

  List<StoreModel> _stores = const [];
  bool _storesLoading = false;
  Object? _storesError;

  List<StoreModel> get stores => _stores;
  bool get storesLoading => _storesLoading;
  Object? get storesError => _storesError;
  bool get isEdit => initial != null;

  Future<void> loadStores() async {
    _storesLoading = true;
    _storesError = null;
    notifyListeners();
    try {
      _stores = (await _storesService.list(limit: 100)).items;
    } on ApiException catch (e) {
      _storesError = e;
    } finally {
      _storesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String fullName,
    required String phone,
    required String position,
    required String storeId,
    required double monthlySalary,
    required DateTime hiredAt,
    required DateTime? terminatedAt,
    required EmployeeStatus status,
  }) => submit(() async {
    final phoneValue = phone.trim().isEmpty ? null : normalizePhone(phone);
    final current = initial;
    if (current == null) {
      await _employees.create(
        EmployeeCreateModel(
          fullName: fullName.trim(),
          phone: phoneValue,
          position: position.trim(),
          storeId: storeId,
          monthlySalary: monthlySalary,
          hiredAt: hiredAt,
          terminatedAt: terminatedAt,
          status: status,
        ),
      );
    } else {
      await _employees.update(
        current.id,
        EmployeeUpdateModel(
          fullName: fullName.trim(),
          phone: phoneValue,
          position: position.trim(),
          storeId: storeId,
          monthlySalary: monthlySalary,
          hiredAt: hiredAt,
          terminatedAt: terminatedAt,
          status: status,
        ),
        clear: EmployeeUpdateModel.clearable,
      );
    }
  });

  /// Deletes the edited employee (soft delete; payroll history stays).
  Future<bool> delete() => submit(() => _employees.delete(initial!.id));
}
