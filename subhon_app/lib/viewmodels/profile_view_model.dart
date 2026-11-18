import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/utils/phone.dart';
import '../models/profile_model.dart';
import '../models/profile_update_model.dart';
import '../services/profile_service.dart';

/// The signed-in user's profile: load, edit, avatar.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._profiles);

  final ProfileService _profiles;

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _error;
  Object? _saveError;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasData => _profile != null;

  /// Loading failed.
  Object? get error => _error;

  /// The last edit / avatar upload failed.
  Object? get saveError => _saveError;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _profiles.get();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProfileModel?> update({
    required String fullName,
    required String email,
    required String phone,
    required String businessName,
  }) => _save(
    () => _profiles.update(
      ProfileUpdateModel(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim().isEmpty ? null : normalizePhone(phone),
        businessName: businessName.trim(),
      ),
      clear: ProfileUpdateModel.clearable,
    ),
  );

  /// JPEG, PNG or WebP, at most 5 MB.
  Future<ProfileModel?> uploadAvatar(Uint8List bytes, String filename) =>
      _save(() => _profiles.uploadAvatar(bytes, filename));

  Future<ProfileModel?> _save(Future<ProfileModel> Function() action) async {
    if (_isSaving) return null;
    _isSaving = true;
    _saveError = null;
    notifyListeners();
    try {
      return _profile = await action();
    } on ApiException catch (e) {
      _saveError = e;
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
