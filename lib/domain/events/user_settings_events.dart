import '../../core/events/app_event.dart';
import '../entities/user_settings.dart';

/// Event fired when user settings are updated
class UserSettingsUpdatedEvent extends AppEvent {
  final UserSettings settings;
  final UserSettings? previousSettings;

  UserSettingsUpdatedEvent({
    required this.settings,
    this.previousSettings,
  });
}

/// Event fired when user settings are retrieved
class UserSettingsRetrievedEvent extends AppEvent {
  final UserSettings settings;

  UserSettingsRetrievedEvent(this.settings);
}

/// Event fired when a specific setting key is changed
class SettingKeyChangedEvent extends AppEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;

  SettingKeyChangedEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
  });
}

/// Event fired when user preferences (theme, language, etc) are changed
class UserPreferencesChangedEvent extends AppEvent {
  final Map<String, dynamic> preferences;

  UserPreferencesChangedEvent(this.preferences);
}
