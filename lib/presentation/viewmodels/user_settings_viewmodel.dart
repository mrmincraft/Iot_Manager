import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';
import 'package:iot_manager/domain/events/user_settings_events.dart';
import 'package:iot_manager/domain/repositories/user_settings_repository.dart';
import 'package:iot_manager/domain/usecases/user_settings_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for User Settings management
class UserSettingsViewModel extends BaseViewModel {
  final UserSettingsRepository _userSettingsRepository;
  final EventBus _eventBus;
  final GetUserSettingsUseCase _getUserSettingsUseCase;
  final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  final ResetUserSettingsUseCase _resetUserSettingsUseCase;

  /// Observable state
  final ValueNotifier<UserSettings?> settings = ValueNotifier(null);
  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);
  final ValueNotifier<String> language = ValueNotifier('en');
  final ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<int> autoRefreshInterval = ValueNotifier(30);

  UserSettingsViewModel({
    required UserSettingsRepository userSettingsRepository,
    required EventBus eventBus,
    required GetUserSettingsUseCase getUserSettingsUseCase,
    required UpdateUserSettingsUseCase updateUserSettingsUseCase,
    required ResetUserSettingsUseCase resetUserSettingsUseCase,
  })  : _userSettingsRepository = userSettingsRepository,
        _eventBus = eventBus,
        _getUserSettingsUseCase = getUserSettingsUseCase,
        _updateUserSettingsUseCase = updateUserSettingsUseCase,
        _resetUserSettingsUseCase = resetUserSettingsUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<UserSettingsRetrievedEvent>(_onSettingsRetrieved);
    _eventBus.listen<UserSettingsUpdatedEvent>(_onSettingsUpdated);
    _eventBus.listen<UserPreferencesChangedEvent>(_onPreferencesChanged);
    _eventBus.listen<SettingKeyChangedEvent>(_onSettingKeyChanged);
  }

  Future<void> loadSettings(String userId) async {
    isLoading.value = true;
    clearError();

    final result = await _userSettingsRepository.getUserSettings(userId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    isLoading.value = true;
    clearError();

    final result = await _userSettingsRepository.updateUserSettings(newSettings);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Settings updated');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    isDarkMode.value = enabled;
    
    if (settings.value != null) {
      final updated = settings.value!.copyWith(
        metadata: {...settings.value!.metadata, 'darkMode': enabled.toString()},
      );
      await updateSettings(updated);
    }
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    
    if (settings.value != null) {
      final updated = settings.value!.copyWith(
        metadata: {...settings.value!.metadata, 'language': lang},
      );
      await updateSettings(updated);
    }
  }

  Future<void> setAutoRefreshInterval(int seconds) async {
    autoRefreshInterval.value = seconds;
    
    if (settings.value != null) {
      final updated = settings.value!.copyWith(
        metadata: {...settings.value!.metadata, 'autoRefreshInterval': seconds.toString()},
      );
      await updateSettings(updated);
    }
  }

  Future<void> resetToDefaults(String userId) async {
    isLoading.value = true;
    clearError();

    final result = await _userSettingsRepository.getUserSettings(userId);

    if (result.isSuccess) {
      isDarkMode.value = false;
      language.value = 'en';
      notificationsEnabled.value = true;
      autoRefreshInterval.value = 30;
      setSuccess('Settings reset to defaults');
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void _onSettingsRetrieved(UserSettingsRetrievedEvent event) {
    settings.value = event.settings;
    _loadPreferencesFromSettings(event.settings);
    notifyListeners();
  }

  void _onSettingsUpdated(UserSettingsUpdatedEvent event) {
    settings.value = event.settings;
    _loadPreferencesFromSettings(event.settings);
    notifyListeners();
  }

  void _onPreferencesChanged(UserPreferencesChangedEvent event) {
    final prefs = event.preferences;
    if (prefs.containsKey('darkMode')) {
      isDarkMode.value = prefs['darkMode'] as bool;
    }
    if (prefs.containsKey('language')) {
      language.value = prefs['language'] as String;
    }
    if (prefs.containsKey('notificationsEnabled')) {
      notificationsEnabled.value = prefs['notificationsEnabled'] as bool;
    }
    notifyListeners();
  }

  void _onSettingKeyChanged(SettingKeyChangedEvent event) {
    if (event.key == 'darkMode') {
      isDarkMode.value = event.newValue as bool;
    } else if (event.key == 'language') {
      language.value = event.newValue as String;
    } else if (event.key == 'autoRefreshInterval') {
      autoRefreshInterval.value = int.tryParse(event.newValue.toString()) ?? 30;
    }
    notifyListeners();
  }

  void _loadPreferencesFromSettings(UserSettings settings) {
    final meta = settings.metadata;
    isDarkMode.value = meta['darkMode']?.toString().toLowerCase() == 'true' ?? false;
    language.value = meta['language']?.toString() ?? 'en';
    notificationsEnabled.value = meta['notificationsEnabled']?.toString().toLowerCase() == 'true' ?? true;
    autoRefreshInterval.value = int.tryParse(meta['autoRefreshInterval']?.toString() ?? '30') ?? 30;
  }

  @override
  void initialize() {
    // Settings will be loaded by the app on initialization
  }

  @override
  void dispose() {
    settings.dispose();
    isDarkMode.dispose();
    language.dispose();
    notificationsEnabled.dispose();
    autoRefreshInterval.dispose();
    super.dispose();
  }
}
