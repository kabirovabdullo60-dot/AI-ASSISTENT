import 'dart:typed_data';

import '../core/network/api_client.dart';
import '../models/password_change_model.dart';
import '../models/profile_model.dart';
import '../models/profile_update_model.dart';

/// `Profile` (API.md).
class ProfileService {
  ProfileService(this._api);

  final ApiClient _api;

  Future<ProfileModel> get() async => ProfileModel.fromJson(
    await _api.get('/api/profile') as Map<String, dynamic>,
  );

  Future<ProfileModel> update(
    ProfileUpdateModel update, {
    Set<String> clear = const {},
  }) async => ProfileModel.fromJson(
    await _api.put('/api/profile', body: update.toJson(clear: clear))
        as Map<String, dynamic>,
  );

  /// Multipart, field `file`: JPEG, PNG or WebP, at most 5 MB.
  Future<ProfileModel> uploadAvatar(Uint8List bytes, String filename) async =>
      ProfileModel.fromJson(
        await _api.uploadFile(
              '/api/profile/avatar',
              field: 'file',
              bytes: bytes,
              filename: filename,
            )
            as Map<String, dynamic>,
      );

  Future<void> changePassword(PasswordChangeModel change) =>
      _api.patch('/api/profile/password', body: change.toJson());
}
