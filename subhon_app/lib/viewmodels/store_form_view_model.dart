import '../core/utils/phone.dart';
import '../models/store_create_model.dart';
import '../models/store_model.dart';
import '../models/store_status.dart';
import '../models/store_update_model.dart';
import '../services/store_service.dart';
import 'form_view_model.dart';

/// Adds a store, or edits [initial].
class StoreFormViewModel extends FormViewModel {
  StoreFormViewModel(this._stores, {this.initial});

  final StoreService _stores;
  final StoreModel? initial;

  StoreModel? _saved;

  /// The store as the server returned it after a successful save.
  StoreModel? get saved => _saved;

  bool get isEdit => initial != null;

  Future<bool> save({
    required String name,
    required String address,
    required String phone,
    required String description,
    required StoreStatus status,
  }) => submit(() async {
    String? opt(String v) => v.trim().isEmpty ? null : v.trim();
    final phoneValue = opt(phone) == null ? null : normalizePhone(phone);
    final current = initial;
    if (current == null) {
      _saved = await _stores.create(
        StoreCreateModel(
          name: name.trim(),
          address: opt(address),
          phone: phoneValue,
          description: opt(description),
          status: status,
        ),
      );
    } else {
      _saved = await _stores.update(
        current.id,
        StoreUpdateModel(
          name: name.trim(),
          address: opt(address),
          phone: phoneValue,
          description: opt(description),
          status: status,
        ),
        // Emptied optional fields are cleared.
        clear: StoreUpdateModel.clearable,
      );
    }
  });
}
