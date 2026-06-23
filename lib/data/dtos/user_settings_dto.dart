// DTO: UserSettingsDTO
// Data Transfer Object pour UserSettings

class UserSettingsDTO {
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
  final Map<String, dynamic> uiPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsDTO({
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

  factory UserSettingsDTO.fromJson(Map<String, dynamic> json) {
    return UserSettingsDTO(
      id: json['id'] as String,
      userId: json['userId'] as String,
      themeMode: json['themeMode'] as String,
      language: json['language'] as String,
      enableNotifications: json['enableNotifications'] as bool,
      enableAutoStart: json['enableAutoStart'] as bool,
      enableErrorReporting: json['enableErrorReporting'] as bool,
      logLevel: json['logLevel'] as String,
      logRetentionDays: json['logRetentionDays'] as int,
      enableLocalEncryption: json['enableLocalEncryption'] as bool,
      encryptionKey: json['encryptionKey'] as String?,
      messageHistoryLimit: json['messageHistoryLimit'] as int,
      enableMessageFiltering: json['enableMessageFiltering'] as bool,
      uiPreferences: Map<String, dynamic>.from(json['uiPreferences'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'themeMode': themeMode,
      'language': language,
      'enableNotifications': enableNotifications,
      'enableAutoStart': enableAutoStart,
      'enableErrorReporting': enableErrorReporting,
      'logLevel': logLevel,
      'logRetentionDays': logRetentionDays,
      'enableLocalEncryption': enableLocalEncryption,
      'encryptionKey': encryptionKey,
      'messageHistoryLimit': messageHistoryLimit,
      'enableMessageFiltering': enableMessageFiltering,
      'uiPreferences': uiPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserSettingsDTO(id: $id, userId: $userId)';
}
