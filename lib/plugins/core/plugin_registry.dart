import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

/// Central registry for managing all loaded plugins
class PluginRegistry {
  static final PluginRegistry _instance = PluginRegistry._internal();
  final Map<String, ProtocolPlugin> _plugins = {};

  PluginRegistry._internal();

  /// Get singleton instance
  static PluginRegistry get instance => _instance;

  /// Register a plugin in the registry
  /// Returns success if registration succeeds, failure if plugin with same ID already exists
  Result<void, Exception> register(ProtocolPlugin plugin) {
    try {
      if (_plugins.containsKey(plugin.id)) {
        return Result.failure(
          PluginException(
            'Plugin with ID "${plugin.id}" is already registered',
            pluginId: plugin.id,
          ),
        );
      }

      _plugins[plugin.id] = plugin;
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Failed to register plugin: ${plugin.id}',
          originalError: e,
        ),
      );
    }
  }

  /// Unregister a plugin from the registry
  Result<void, Exception> unregister(String pluginId) {
    try {
      if (!_plugins.containsKey(pluginId)) {
        return Result.failure(
          PluginException('Plugin with ID "$pluginId" not found'),
        );
      }

      _plugins.remove(pluginId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Failed to unregister plugin: $pluginId',
          originalError: e,
        ),
      );
    }
  }

  /// Get a plugin by ID
  Result<ProtocolPlugin, Exception> getPlugin(String pluginId) {
    if (!_plugins.containsKey(pluginId)) {
      return Result.failure(
        PluginException('Plugin with ID "$pluginId" not found'),
      );
    }

    return Result.success(_plugins[pluginId]!);
  }

  /// Get all registered plugins
  List<ProtocolPlugin> getAllPlugins() => List.unmodifiable(_plugins.values);

  /// Get plugins that support a specific protocol type
  List<ProtocolPlugin> getPluginsByType(ProtocolType protocolType) {
    return _plugins.values
        .where((plugin) => plugin.supportedProtocols.contains(protocolType))
        .toList();
  }

  /// Get plugins by author
  List<ProtocolPlugin> getPluginsByAuthor(String author) {
    return _plugins.values
        .where((plugin) => plugin.author.toLowerCase() == author.toLowerCase())
        .toList();
  }

  /// Check if a plugin is registered
  bool hasPlugin(String pluginId) => _plugins.containsKey(pluginId);

  /// Get the count of registered plugins
  int get pluginCount => _plugins.length;

  /// Get all unique protocol types supported by registered plugins
  Set<ProtocolType> getSupportedProtocolTypes() {
    final types = <ProtocolType>{};
    for (final plugin in _plugins.values) {
      types.addAll(plugin.supportedProtocols);
    }
    return types;
  }

  /// Clear all plugins from registry (use with caution)
  void clear() => _plugins.clear();

  /// Get registry statistics
  Map<String, dynamic> getStatistics() {
    final protocols = <String, int>{};
    for (final plugin in _plugins.values) {
      for (final type in plugin.supportedProtocols) {
        final key = type.toString();
        protocols[key] = (protocols[key] ?? 0) + 1;
      }
    }

    return {
      'totalPlugins': _plugins.length,
      'enabledPlugins': _plugins.values.where((p) => p.isEnabled).length,
      'disabledPlugins': _plugins.values.where((p) => !p.isEnabled).length,
      'protocolSupport': protocols,
      'authors': _plugins.values.map((p) => p.author).toSet().length,
    };
  }

  /// Get all plugins sorted by name
  List<ProtocolPlugin> getPluginsSorted() {
    final plugins = List<ProtocolPlugin>.from(_plugins.values);
    plugins.sort((a, b) => a.name.compareTo(b.name));
    return plugins;
  }

  /// Get plugin dependency chain
  Result<List<String>, Exception> getDependencies(String pluginId) {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      return Result.failure(
        PluginException('Plugin with ID "$pluginId" not found'),
      );
    }

    // For now, plugins don't have built-in dependencies
    // This is a placeholder for future enhancement
    return Result.success([]);
  }

  @override
  String toString() => 'PluginRegistry(plugins: ${_plugins.length})';
}
