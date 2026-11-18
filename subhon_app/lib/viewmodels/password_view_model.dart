import '../models/password_change_model.dart';
import '../services/profile_service.dart';
import 'form_view_model.dart';

/// Changes the password (other devices are signed out).
class PasswordViewModel extends FormViewModel {
  PasswordViewModel(this._profiles);

  final ProfileService _profiles;

  Future<bool> change({required String current, required String next}) =>
      submit(
        () => _profiles.changePassword(
          PasswordChangeModel(currentPassword: current, newPassword: next),
        ),
      );
}
