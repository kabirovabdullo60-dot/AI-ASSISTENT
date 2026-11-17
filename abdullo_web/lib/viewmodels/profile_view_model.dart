import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import 'base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  ProfileViewModel(this._service);

  final ProfileService _service;
  UserProfileModel? _profile;

  UserProfileModel? get profile => _profile;

  Future<void> load() => runTask(() async {
    _profile = await _service.fetchMe();
  }, errorMessage: 'Could not load your profile.');
}
