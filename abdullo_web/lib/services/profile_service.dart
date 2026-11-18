import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/profile_model.dart';

class ProfileService {
  ProfileService(this._api);

  final ApiClient _api;

  Future<ProfileModel> fetch() async => ProfileModel.fromJson(asJsonMap(await _api.get(ApiConstants.profile)));

  /// Only the fields that are not null are sent (PUT updates only what you send).
  Future<ProfileModel> update({String? fullName, String? email, String? phone, String? businessName}) async =>
      ProfileModel.fromJson(
        asJsonMap(
          await _api.put(ApiConstants.profile, {
            'fullName': ?fullName,
            'email': ?email,
            'phone': ?phone,
            'businessName': ?businessName,
          }),
        ),
      );

  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      _api.patch(ApiConstants.profilePassword, {'currentPassword': currentPassword, 'newPassword': newPassword});

  Future<ProfileModel> uploadAvatar(List<int> bytes, String filename) async => ProfileModel.fromJson(
    asJsonMap(await _api.upload(ApiConstants.profileAvatar, field: 'file', bytes: bytes, filename: filename)),
  );
}
