// Domain Entity: UserSettings
// Représente les paramètres utilisateur de l'application

enum ThemeMode { light, dark, system }
enum LogLevel { debug, info, warning, error, critical }

class UserSettings {
  final String id;
  final String userId;
  final ThemeMode themeMode;
  final String language;
  final bool enableNotifications;
  final bool enableAutoStart;
  final bool enableErrorReporting;
  final LogLevel logLevel;
  final int logRetentionDays;
  final bool enableLocalEncryption;
  final String? encryptionKey;
  final int messageHistoryLimit;
  final bool enableMessageFiltering;
  final Map<String, dynamic> uiPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
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

  /// Crée une copie avec propriétés modifiées
  UserSettings copyWith({
    String? id,
    String? userId,
    ThemeMode? themeMode,
    String? language,
    bool? enableNotifications,
    bool? enableAutoStart,
    bool? enableErrorReporting,
    LogLevel? logLevel,
    int? logRetentionDays,
    bool? enableLocalEncryption,
    String? encryptionKey,
    int? messageHistoryLimit,
    bool? enableMessageFiltering,
    Map<String, dynamic>? uiPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAutoStart: enableAutoStart ?? this.enableAutoStart,
      enableErrorReporting: enableErrorReporting ?? this.enableErrorReporting,
      logLevel: logLevel ?? this.logLevel,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      enableLocalEncryption: enableLocalEncryption ?? this.enableLocalEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      messageHistoryLimit: messageHistoryLimit ?? this.messageHistoryLimit,
      enableMessageFiltering: enableMessageFiltering ?? this.enableMessageFiltering,
      uiPreferences: uiPreferences ?? this.uiPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserSettings(id: $id, userId: $userId)';
}
