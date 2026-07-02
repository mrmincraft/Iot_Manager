import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

/// Abstract base class that all protocol plugins must implement
/// Defines the contract for protocol implementations (MQTT, HTTP, CoAP, Modbus, etc.)
abstract class ProtocolPlugin {
  /// Unique identifier for this plugin
  String get id;

  /// Human-readable name of the protocol
  String get name;

  /// Version of the plugin (semantic versioning)
  String get version;

  /// Author/organization that maintains this plugin
  String get author;

  /// Protocol types this plugin supports
  List<ProtocolType> get supportedProtocols;

  /// Plugin description
  String get description;

  /// Whether this plugin is enabled
  bool get isEnabled;

  /// Additional metadata about the plugin
  Map<String, dynamic> get metadata;

  /// Initialize the plugin with configuration
  /// Called once during plugin loading
  Future<Result<void, Exception>> initialize(Map<String, dynamic> config);

  /// Connect to a protocol endpoint
  /// Returns connection ID on success
  Future<Result<String, Exception>> connect({
    required String host,
    required int port,
    required ProtocolType protocolType,
    Map<String, dynamic>? options,
  });

  /// Disconnect from an endpoint
  Future<Result<void, Exception>> disconnect(String connectionId);

  /// Subscribe to a topic/channel
  /// Returns subscription ID on success
  Future<Result<String, Exception>> subscribe({
    required String connectionId,
    required String topic,
    Map<String, dynamic>? options,
  });

  /// Unsubscribe from a topic/channel
  Future<Result<void, Exception>> unsubscribe({
    required String connectionId,
    required String subscriptionId,
  });

  /// Publish a message
  Future<Result<void, Exception>> publish({
    required String connectionId,
    required String topic,
    required List<int> payload,
    Map<String, dynamic>? options,
  });

  /// Validate connection configuration
  /// Used before actual connection attempt
  Result<void, Exception> validate({
    required String host,
    required int port,
    Map<String, dynamic>? options,
  });

  /// Get plugin capabilities as comma-separated string
  String getCapabilities() {
    return supportedProtocols.map((p) => p.toString()).join(', ');
  }

  /// Shutdown the plugin gracefully
  Future<Result<void, Exception>> shutdown();

  /// Get health status of the plugin
  Future<Result<Map<String, dynamic>, Exception>> getHealthStatus();
}

/// Plugin event types for EventBus
enum PluginEventType {
  loaded,
  unloaded,
  enabled,
  disabled,
  error,
  connected,
  disconnected,
}

/// Plugin event emitted via EventBus
class PluginEvent {
  final String pluginId;
  final PluginEventType type;
  final String message;
  final dynamic data;
  final DateTime timestamp;

  PluginEvent({
    required this.pluginId,
    required this.type,
    required this.message,
    this.data,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'PluginEvent($pluginId, $type, $message)';
}

/// Exception for plugin-related errors
class PluginException implements Exception {
  final String message;
  final String? pluginId;
  final dynamic originalError;

  PluginException(
    this.message, {
    this.pluginId,
    this.originalError,
  });

  @override
  String toString() => 'PluginException: $message${pluginId != null ? ' (Plugin: $pluginId)' : ''}';
}
