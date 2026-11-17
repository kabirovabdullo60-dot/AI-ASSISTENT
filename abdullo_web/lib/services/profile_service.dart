import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/user_profile_model.dart';
import 'base_service.dart';

class ProfileService extends BaseService {
  ProfileService({super.client, super.useMock});

  Future<UserProfileModel> fetchMe() => mockOr(
    mock: (db) => db.profile,
    api: () async => UserProfileModel.fromJson(asJsonMap(await client.get(ApiConstants.me))),
  );
}
