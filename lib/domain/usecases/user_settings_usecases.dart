import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';
import 'package:iot_manager/domain/repositories/user_settings_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET USER SETTINGS
// ============================================================

/// Get User Settings Use Case
class GetUserSettingsUseCase extends UseCase<UserSettings, NoParams> {
  final UserSettingsRepository _userSettingsRepository;

  GetUserSettingsUseCase(this._userSettingsRepository);

  @override
  Future<Result<UserSettings>> call(NoParams params) async {
    return _userSettingsRepository.getUserSettings();
  }
}

// ============================================================
// GET USER SETTINGS BY ID
// ============================================================

class GetUserSettingsByIdParams {
  final String id;
  GetUserSettingsByIdParams({required this.id});
}

/// Get User Settings By ID Use Case
class GetUserSettingsByIdUseCase extends UseCase<UserSettings, GetUserSettingsByIdParams> {
  final UserSettingsRepository _userSettingsRepository;

  GetUserSettingsByIdUseCase(this._userSettingsRepository);

  @override
  Future<Result<UserSettings>> call(GetUserSettingsByIdParams params) async {
    return _userSettingsRepository.getUserSettingsById(params.id);
  }
}

// ============================================================
// UPDATE USER SETTINGS
// ============================================================

class UpdateUserSettingsParams {
  final UserSettings userSettings;
  UpdateUserSettingsParams({required this.userSettings});
}

/// Update User Settings Use Case
class UpdateUserSettingsUseCase extends UseCase<UserSettings, UpdateUserSettingsParams> {
  final UserSettingsRepository _userSettingsRepository;

  UpdateUserSettingsUseCase(this._userSettingsRepository);

  @override
  Future<Result<UserSettings>> call(UpdateUserSettingsParams params) async {
    return _userSettingsRepository.updateUserSettings(params.userSettings);
  }
}
