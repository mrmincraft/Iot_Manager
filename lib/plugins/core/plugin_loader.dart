import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/plugins/core/plugin_metadata.dart';

/// Dynamically loads protocol plugins from various sources
/// Handles plugin validation, integrity checking, and initialization
class PluginLoader {
  /// Cache for loaded plugins
  final Map<String, ProtocolPlugin> _pluginCache = {};

  /// Security salt for plugin validation
  final String _securitySalt = 'iot_manager_plugin_security_2026';

  /// Load plugin from memory (for core plugins)
  Result<ProtocolPlugin, Exception> loadPluginFromMemory(
    ProtocolPlugin plugin,
  ) {
    try {
      // Validate plugin
      final validationResult = _validatePlugin(plugin);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error);
      }

      // Cache plugin
      _pluginCache[plugin.id] = plugin;

      return Result.success(plugin);
    } catch (e) {
      return Result.failure(
        PluginException(
          'Failed to load plugin from memory: ${plugin.id}',
          originalError: e,
        ),
      );
    }
  }

  /// Load plugin by ID from cache
  Result<ProtocolPlugin, Exception> getPluginFromCache(String pluginId) {
    if (_pluginCache.containsKey(pluginId)) {
      return Result.success(_pluginCache[pluginId]!);
    }

    return Result.failure(
      PluginException('Plugin "$pluginId" not found in cache'),
    );
  }

  /// Validate plugin integrity and compatibility
  Result<void, Exception> _validatePlugin(ProtocolPlugin plugin) {
    // Check required properties
    if (plugin.id.isEmpty) {
      return Result.failure(
        PluginException('Plugin ID cannot be empty'),
      );
    }

    if (plugin.name.isEmpty) {
      return Result.failure(
        PluginException('Plugin name cannot be empty', pluginId: plugin.id),
      );
    }

    if (plugin.version.isEmpty) {
      return Result.failure(
        PluginException(
          'Plugin version cannot be empty',
          pluginId: plugin.id,
        ),
      );
    }

    if (plugin.supportedProtocols.isEmpty) {
      return Result.failure(
        PluginException(
          'Plugin must support at least one protocol',
          pluginId: plugin.id,
        ),
      );
    }

    // Validate version format (semantic versioning)
    if (!_isValidSemanticVersion(plugin.version)) {
      return Result.failure(
        PluginException(
          'Invalid version format: ${plugin.version}. Expected semantic versioning (e.g., 1.0.0)',
          pluginId: plugin.id,
        ),
      );
    }

    return Result.success(null);
  }

  /// Check if version follows semantic versioning
  bool _isValidSemanticVersion(String version) {
    final parts = version.split('.');
    if (parts.length < 3) return false;

    for (final part in parts) {
      if (int.tryParse(part) == null) return false;
    }

    return true;
  }

  /// Check if plugin version is compatible with requirements
  bool isPluginCompatible(String pluginVersion, String requiredVersion) {
    final pluginParts = pluginVersion.split('.');
    final requiredParts = requiredVersion.split('.');

    if (pluginParts.isEmpty || requiredParts.isEmpty) {
      return pluginVersion == requiredVersion;
    }

    // Major version must match
    final pluginMajor = int.tryParse(pluginParts[0]) ?? 0;
    final requiredMajor = int.tryParse(requiredParts[0]) ?? 0;

    return pluginMajor == requiredMajor;
  }

  /// Calculate integrity hash for plugin (placeholder)
  String _calculatePluginHash(ProtocolPlugin plugin) {
    final input = '${plugin.id}:${plugin.version}:${plugin.author}:$_securitySalt';
    // In production, use actual cryptographic hashing
    return input.hashCode.toString();
  }

  /// Verify plugin integrity
  bool verifyPluginIntegrity(ProtocolPlugin plugin, String expectedHash) {
    final calculatedHash = _calculatePluginHash(plugin);
    return calculatedHash == expectedHash;
  }

  /// Get all cached plugins
  List<ProtocolPlugin> getCachedPlugins() =>
      List.unmodifiable(_pluginCache.values);

  /// Clear plugin cache
  void clearCache() => _pluginCache.clear();

  /// Clear specific plugin from cache
  bool removeFromCache(String pluginId) =>
      _pluginCache.remove(pluginId) != null;

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedPlugins': _pluginCache.length,
      'pluginIds': _pluginCache.keys.toList(),
      'totalMemoryEstimate': _estimateMemoryUsage(),
    };
  }

  int _estimateMemoryUsage() {
    // Rough estimate: each plugin ~500KB
    return _pluginCache.length * 500;
  }
}
