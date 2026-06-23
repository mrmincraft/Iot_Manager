// SQLite Model: UserSettingsModel
// Modèle de données pour la table user_settings en SQLite

class UserSettingsModel {
  final String id;
  final String userId;
  final String themeMode;
  final String language;
  final bool enableNotifications;
  final bool enableAutoStart;
  final bool enableErrorReporting;
  final String logLevel;
  final int logRetentionDays;
  final bool enableLocalEncryption;
  final String? encryptionKey;
  final int messageHistoryLimit;
  final bool enableMessageFiltering;
  final String uiPreferences; // JSON string
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.id,
    required this.userId,
    required this.themeMode,
    required this.language,
    required this.enableNotifications,
    required this.enableAutoStart,
    required this.enableErrorReporting,
    required this.logLevel,
    required this.logRetentionDays,
    required this.enableLocalEncryption,
    this.encryptionKey,
    required this.messageHistoryLimit,
    required this.enableMessageFiltering,
    required this.uiPreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      themeMode: map['themeMode'] as String,
      language: map['language'] as String,
      enableNotifications: (map['enableNotifications'] as int) == 1,
      enableAutoStart: (map['enableAutoStart'] as int) == 1,
      enableErrorReporting: (map['enableErrorReporting'] as int) == 1,
      logLevel: map['logLevel'] as String,
      logRetentionDays: map['logRetentionDays'] as int,
      enableLocalEncryption: (map['enableLocalEncryption'] as int) == 1,
      encryptionKey: map['encryptionKey'] as String?,
      messageHistoryLimit: map['messageHistoryLimit'] as int,
      enableMessageFiltering: (map['enableMessageFiltering'] as int) == 1,
      uiPreferences: map['uiPreferences'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'themeMode': themeMode,
      'language': language,
      'enableNotifications': enableNotifications ? 1 : 0,
      'enableAutoStart': enableAutoStart ? 1 : 0,
      'enableErrorReporting': enableErrorReporting ? 1 : 0,
      'logLevel': logLevel,
      'logRetentionDays': logRetentionDays,
      'enableLocalEncryption': enableLocalEncryption ? 1 : 0,
      'encryptionKey': encryptionKey,
      'messageHistoryLimit': messageHistoryLimit,
      'enableMessageFiltering': enableMessageFiltering ? 1 : 0,
      'uiPreferences': uiPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserSettingsModel(id: $id, userId: $userId)';
}
