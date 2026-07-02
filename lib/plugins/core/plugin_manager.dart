import 'package:get_it/get_it.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/plugins/core/plugin_registry.dart';
import 'package:iot_manager/plugins/core/plugin_metadata.dart';

final getIt = GetIt.instance;

/// Manages the lifecycle of plugins (load, unload, enable, disable)
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final PluginRegistry _registry = PluginRegistry.instance;
  final EventBus _eventBus;
  final Map<String, bool> _enabledState = {};
  final Map<String, DateTime> _loadTimes = {};

  PluginManager._internal() : _eventBus = getIt<EventBus>();

  /// Get singleton instance
  static PluginManager get instance => _instance;

  /// Load and register a plugin
  /// Configuration is passed to plugin's initialize() method
  Future<Result<void, Exception>> loadPlugin(
    ProtocolPlugin plugin,
    Map<String, dynamic> config,
  ) async {
    try {
      // Initialize plugin with config
      final initResult = await plugin.initialize(config);

      if (initResult.isFailure) {
        return Result.failure(
          PluginException(
            'Failed to initialize plugin: ${plugin.id}',
            pluginId: plugin.id,
            originalError: initResult.error,
          ),
        );
      }

      // Register plugin
      final registerResult = _registry.register(plugin);
      if (registerResult.isFailure) {
        return registerResult;
      }

      // Track plugin state
      _enabledState[plugin.id] = true;
      _loadTimes[plugin.id] = DateTime.now();

      // Emit event
      _eventBus.publish(
        PluginEvent(
          pluginId: plugin.id,
          type: PluginEventType.loaded,
          message: 'Plugin loaded successfully: ${plugin.name}',
          data: plugin,
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Error loading plugin: ${plugin.id}',
          pluginId: plugin.id,
          originalError: e,
        ),
      );
    }
  }

  /// Unload a plugin
  Future<Result<void, Exception>> unloadPlugin(String pluginId) async {
    try {
      final getResult = _registry.getPlugin(pluginId);
      if (getResult.isFailure) {
        return getResult;
      }

      final plugin = getResult.value!;

      // Shutdown plugin
      final shutdownResult = await plugin.shutdown();
      if (shutdownResult.isFailure) {
        return shutdownResult;
      }

      // Unregister from registry
      final unregisterResult = _registry.unregister(pluginId);
      if (unregisterResult.isFailure) {
        return unregisterResult;
      }

      // Clean up state
      _enabledState.remove(pluginId);
      _loadTimes.remove(pluginId);

      // Emit event
      _eventBus.publish(
        PluginEvent(
          pluginId: pluginId,
          type: PluginEventType.unloaded,
          message: 'Plugin unloaded: $pluginId',
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Error unloading plugin: $pluginId',
          pluginId: pluginId,
          originalError: e,
        ),
      );
    }
  }

  /// Enable a plugin
  Future<Result<void, Exception>> enablePlugin(String pluginId) async {
    try {
      final getResult = _registry.getPlugin(pluginId);
      if (getResult.isFailure) {
        return getResult;
      }

      _enabledState[pluginId] = true;

      _eventBus.publish(
        PluginEvent(
          pluginId: pluginId,
          type: PluginEventType.enabled,
          message: 'Plugin enabled: $pluginId',
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Error enabling plugin: $pluginId',
          originalError: e,
        ),
      );
    }
  }

  /// Disable a plugin
  Future<Result<void, Exception>> disablePlugin(String pluginId) async {
    try {
      final getResult = _registry.getPlugin(pluginId);
      if (getResult.isFailure) {
        return getResult;
      }

      _enabledState[pluginId] = false;

      _eventBus.publish(
        PluginEvent(
          pluginId: pluginId,
          type: PluginEventType.disabled,
          message: 'Plugin disabled: $pluginId',
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Error disabling plugin: $pluginId',
          originalError: e,
        ),
      );
    }
  }

  /// Check if a plugin is enabled
  bool isPluginEnabled(String pluginId) => _enabledState[pluginId] ?? false;

  /// Get all enabled plugins
  List<ProtocolPlugin> getEnabledPlugins() {
    return _registry
        .getAllPlugins()
        .where((plugin) => isPluginEnabled(plugin.id))
        .toList();
  }

  /// Get plugin load time
  DateTime? getPluginLoadTime(String pluginId) => _loadTimes[pluginId];

  /// Get plugin uptime in seconds
  int? getPluginUptime(String pluginId) {
    final loadTime = _loadTimes[pluginId];
    if (loadTime == null) return null;
    return DateTime.now().difference(loadTime).inSeconds;
  }

  /// Get health status of all plugins
  Future<Result<Map<String, Map<String, dynamic>>, Exception>>
      getHealthStatus() async {
    final status = <String, Map<String, dynamic>>{};

    for (final plugin in _registry.getAllPlugins()) {
      try {
        final result = await plugin.getHealthStatus();
        status[plugin.id] = {
          'healthy': result.isSuccess,
          'status': result.value,
          'enabled': isPluginEnabled(plugin.id),
          'uptime': getPluginUptime(plugin.id),
        };
      } catch (e) {
        status[plugin.id] = {
          'healthy': false,
          'error': e.toString(),
          'enabled': isPluginEnabled(plugin.id),
        };
      }
    }

    return Result.success(status);
  }

  /// Get manager statistics
  Map<String, dynamic> getStatistics() {
    return {
      ...?_registry.getStatistics(),
      'enabledNow': _enabledState.values.where((v) => v).length,
      'averageUptimeSeconds': _calculateAverageUptime(),
    };
  }

  int _calculateAverageUptime() {
    if (_loadTimes.isEmpty) return 0;
    final uptimes = _loadTimes.values
        .map((t) => DateTime.now().difference(t).inSeconds)
        .toList();
    return (uptimes.reduce((a, b) => a + b) / uptimes.length).toInt();
  }

  @override
  String toString() => 'PluginManager(loaded: ${_registry.pluginCount})';
}
