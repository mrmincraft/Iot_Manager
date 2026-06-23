// Repository Implementation: UserSettingsRepositoryImpl
// Implémentation de la gestion des paramètres utilisateur

import 'dart:convert';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/user_settings_local_datasource.dart';
import 'package:iot_manager/data/models/user_settings_model.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';
import 'package:iot_manager/domain/repositories/user_settings_repository.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final UserSettingsLocalDataSource _localDataSource;

  UserSettingsRepositoryImpl(this._localDataSource);

  @override
  Future<Result<UserSettings, Exception>> getUserSettings(String userId) async {
    try {
      final model = await _localDataSource.getUserSettings(userId);
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<UserSettings, Exception>> createUserSettings(UserSettings settings) async {
    try {
      final model = _mapEntityToModel(settings);
      await _localDataSource.createUserSettings(model);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<UserSettings, Exception>> updateUserSettings(UserSettings settings) async {
    try {
      final model = _mapEntityToModel(settings);
      await _localDataSource.updateUserSettings(model);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteUserSettings(String userId) async {
    try {
      await _localDataSource.deleteUserSettings(userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<UserSettings, Exception>> getOrCreateDefaults(String userId) async {
    try {
      UserSettingsModel? model = await _localDataSource.getUserSettings(userId);
      if (model == null) {
        model = _createDefaultSettings(userId);
        await _localDataSource.createUserSettings(model);
      }
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<UserSettings, Exception>> resetToDefaults(String userId) async {
    try {
      final defaultSettings = _createDefaultSettings(userId);
      await _localDataSource.updateUserSettings(defaultSettings);
      return Result.success(_mapModelToEntity(defaultSettings));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  UserSettings _mapModelToEntity(UserSettingsModel model) {
    return UserSettings(
      id: model.id,
      userId: model.userId,
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == model.themeMode,
        orElse: () => ThemeMode.system,
      ),
      language: model.language,
      enableNotifications: model.enableNotifications,
      enableAutoStart: model.enableAutoStart,
      enableErrorReporting: model.enableErrorReporting,
      logLevel: LogLevel.values.firstWhere(
        (e) => e.toString().split('.').last == model.logLevel,
        orElse: () => LogLevel.info,
      ),
      logRetentionDays: model.logRetentionDays,
      enableLocalEncryption: model.enableLocalEncryption,
      encryptionKey: model.encryptionKey,
      messageHistoryLimit: model.messageHistoryLimit,
      enableMessageFiltering: model.enableMessageFiltering,
      uiPreferences: Map<String, dynamic>.from(jsonDecode(model.uiPreferences) as Map),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  UserSettingsModel _mapEntityToModel(UserSettings entity) {
    return UserSettingsModel(
      id: entity.id,
      userId: entity.userId,
      themeMode: entity.themeMode.toString().split('.').last,
      language: entity.language,
      enableNotifications: entity.enableNotifications,
      enableAutoStart: entity.enableAutoStart,
      enableErrorReporting: entity.enableErrorReporting,
      logLevel: entity.logLevel.toString().split('.').last,
      logRetentionDays: entity.logRetentionDays,
      enableLocalEncryption: entity.enableLocalEncryption,
      encryptionKey: entity.encryptionKey,
      messageHistoryLimit: entity.messageHistoryLimit,
      enableMessageFiltering: entity.enableMessageFiltering,
      uiPreferences: jsonEncode(entity.uiPreferences),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserSettingsModel _createDefaultSettings(String userId) {
    final now = DateTime.now();
    return UserSettingsModel(
      id: 'settings_$userId',
      userId: userId,
      themeMode: 'system',
      language: 'en',
      enableNotifications: true,
      enableAutoStart: true,
      enableErrorReporting: true,
      logLevel: 'info',
      logRetentionDays: 30,
      enableLocalEncryption: false,
      encryptionKey: null,
      messageHistoryLimit: 1000,
      enableMessageFiltering: true,
      uiPreferences: jsonEncode({}),
      createdAt: now,
      updatedAt: now,
    );
  }
}
