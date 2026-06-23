// Domain Repository Interface: UserSettingsRepository
// Interface pour la gestion des paramètres utilisateur

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';

abstract class UserSettingsRepository {
  /// Récupère les paramètres pour un utilisateur
  Future<Result<UserSettings, Exception>> getUserSettings(String userId);

  /// Crée les paramètres utilisateur
  Future<Result<UserSettings, Exception>> createUserSettings(UserSettings settings);

  /// Met à jour les paramètres utilisateur
  Future<Result<UserSettings, Exception>> updateUserSettings(UserSettings settings);

  /// Supprime les paramètres utilisateur
  Future<Result<void, Exception>> deleteUserSettings(String userId);

  /// Récupère ou crée les paramètres par défaut
  Future<Result<UserSettings, Exception>> getOrCreateDefaults(String userId);

  /// Réinitialise les paramètres aux valeurs par défaut
  Future<Result<UserSettings, Exception>> resetToDefaults(String userId);
}
