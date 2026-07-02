import 'package:get_it/get_it.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/plugins/core/plugin_registry.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';

final getIt = GetIt.instance;

/// Context provided to plugins for accessing framework services
/// Allows plugins to communicate with other plugins and access DI services
class PluginContext {
  final String pluginId;
  final PluginRegistry _registry = PluginRegistry.instance;
  final EventBus _eventBus;

  PluginContext({
    required this.pluginId,
  }) : _eventBus = getIt<EventBus>();

  /// Get another plugin by ID
  ProtocolPlugin? getPlugin(String id) {
    final result = _registry.getPlugin(id);
    return result.isSuccess ? result.value : null;
  }

  /// Emit an event for other plugins to listen to
  void emitEvent(String eventType, Map<String, dynamic> data) {
    _eventBus.publish(
      PluginEvent(
        pluginId: pluginId,
        type: PluginEventType.values[0], // Custom event
        message: eventType,
        data: data,
      ),
    );
  }

  /// Listen to events
  void onEvent(String eventType, Function(PluginEvent) callback) {
    _eventBus.listen<PluginEvent>((event) {
      if (event.message == eventType) {
        callback(event);
      }
    });
  }

  /// Get a service from the service locator
  T? getService<T>() {
    try {
      return getIt<T>();
    } catch (e) {
      return null;
    }
  }

  /// Register a service in the service locator (if allowed)
  bool registerService<T>(T instance) {
    try {
      getIt.registerSingleton<T>(instance);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get registry for querying plugins
  PluginRegistry get registry => _registry;

  /// Get event bus for publishing
  EventBus get eventBus => _eventBus;

  /// Get service locator for dependency access
  ServiceLocator get serviceLocator => _serviceLocator;

  @override
  String toString() => 'PluginContext($pluginId)';
}
