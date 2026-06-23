// Local DataSource Interface: UserSettingsLocalDataSource
// Interface pour les opérations de base de données sur les paramètres utilisateur

import 'package:iot_manager/data/models/user_settings_model.dart';

abstract class UserSettingsLocalDataSource {
  Future<UserSettingsModel?> getUserSettings(String userId);
  Future<void> createUserSettings(UserSettingsModel settings);
  Future<void> updateUserSettings(UserSettingsModel settings);
  Future<void> deleteUserSettings(String userId);
}
