import 'package:sqflite/sqflite.dart';
import '../../models/user_settings_model.dart';

/// LocalDataSource pour les User Settings
class UserSettingsLocalDataSourceImpl implements UserSettingsLocalDataSource {
  final Database _database;
  
  UserSettingsLocalDataSourceImpl(this._database);
  
  @override
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    try {
      final maps = await _database.query(
        'user_settings',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      if (maps.isEmpty) return null;
      return UserSettingsModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching user settings: $e');
    }
  }
  
  @override
  Future<void> createUserSettings(UserSettingsModel settings) async {
    try {
      await _database.insert(
        'user_settings',
        settings.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating user settings: $e');
    }
  }
  
  @override
  Future<void> updateUserSettings(UserSettingsModel settings) async {
    try {
      final rowsAffected = await _database.update(
        'user_settings',
        settings.toMap(),
        where: 'userId = ?',
        whereArgs: [settings.userId],
      );
      
      if (rowsAffected == 0) {
        throw Exception('User settings not found for user ${settings.userId}');
      }
    } catch (e) {
      throw Exception('Error updating user settings: $e');
    }
  }
  
  @override
  Future<void> deleteUserSettings(String userId) async {
    try {
      await _database.delete(
        'user_settings',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Error deleting user settings: $e');
    }
  }
  
  @override
  Future<bool> exists(String userId) async {
    try {
      final result = await _database.rawQuery(
        'SELECT 1 FROM user_settings WHERE userId = ? LIMIT 1',
        [userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking if user settings exists: $e');
    }
  }
}
