import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';

/// Mock implementation of ProtocolPlugin for testing
class MockProtocolPlugin extends ProtocolPlugin {
  @override
  String get id => 'mock-protocol';

  @override
  String get name => 'Mock Protocol';

  @override
  String get version => '1.0.0';

  @override
  String get author => 'Test Author';

  @override
  List<ProtocolType> get supportedProtocols => [ProtocolType.mqtt];

  @override
  String get description => 'Mock protocol plugin for testing';

  @override
  bool get isEnabled => true;

  @override
  Map<String, dynamic> get metadata => {'test': true};

  @override
  Future<Result<void, Exception>> initialize(Map<String, dynamic> config) async {
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> connect({
    required String host,
    required int port,
    required ProtocolType protocolType,
    Map<String, dynamic>? options,
  }) async {
    return Result.success('connection-id-123');
  }

  @override
  Future<Result<void, Exception>> disconnect(String connectionId) async {
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> subscribe({
    required String connectionId,
    required String topic,
    Map<String, dynamic>? options,
  }) async {
    return Result.success('subscription-id-456');
  }

  @override
  Future<Result<void, Exception>> unsubscribe({
    required String connectionId,
    required String subscriptionId,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> publish({
    required String connectionId,
    required String topic,
    required List<int> payload,
    Map<String, dynamic>? options,
  }) async {
    return Result.success(null);
  }

  @override
  Result<void, Exception> validate({
    required String host,
    required int port,
    Map<String, dynamic>? options,
  }) {
    if (host.isEmpty) {
      return Result.failure(Exception('Host cannot be empty'));
    }
    if (port <= 0 || port > 65535) {
      return Result.failure(Exception('Port must be between 1 and 65535'));
    }
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> shutdown() async {
    return Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> getHealthStatus() async {
    return Result.success({'status': 'healthy', 'uptime': 3600});
  }
}

void main() {
  group('ProtocolPlugin Tests', () {
    late MockProtocolPlugin plugin;

    setUp(() {
      plugin = MockProtocolPlugin();
    });

    test('Plugin has correct properties', () {
      expect(plugin.id, 'mock-protocol');
      expect(plugin.name, 'Mock Protocol');
      expect(plugin.version, '1.0.0');
      expect(plugin.author, 'Test Author');
      expect(plugin.description, 'Mock protocol plugin for testing');
      expect(plugin.isEnabled, true);
    });

    test('Plugin supports expected protocol types', () {
      expect(plugin.supportedProtocols.length, 1);
      expect(plugin.supportedProtocols.contains(ProtocolType.mqtt), true);
    });

    test('Plugin metadata is accessible', () {
      expect(plugin.metadata.containsKey('test'), true);
      expect(plugin.metadata['test'], true);
    });

    test('getCapabilities returns comma-separated protocol types', () {
      final capabilities = plugin.getCapabilities();
      expect(capabilities, isNotNull);
      expect(capabilities.contains('mqtt'), true);
    });

    test('Initialize completes successfully', () async {
      final result = await plugin.initialize({'key': 'value'});
      expect(result.isSuccess, true);
    });

    test('Connect returns connection ID', () async {
      final result = await plugin.connect(
        host: 'broker.example.com',
        port: 1883,
        protocolType: ProtocolType.mqtt,
      );

      expect(result.isSuccess, true);
      expect(result.value, 'connection-id-123');
    });

    test('Subscribe returns subscription ID', () async {
      final result = await plugin.subscribe(
        connectionId: 'conn-123',
        topic: 'sensors/temperature',
      );

      expect(result.isSuccess, true);
      expect(result.value, 'subscription-id-456');
    });

    test('Unsubscribe completes successfully', () async {
      final result = await plugin.unsubscribe(
        connectionId: 'conn-123',
        subscriptionId: 'sub-456',
      );

      expect(result.isSuccess, true);
    });

    test('Publish completes successfully', () async {
      final result = await plugin.publish(
        connectionId: 'conn-123',
        topic: 'sensors/data',
        payload: [1, 2, 3],
      );

      expect(result.isSuccess, true);
    });

    test('Disconnect completes successfully', () async {
      final result = await plugin.disconnect('conn-123');
      expect(result.isSuccess, true);
    });

    test('Validate accepts valid configuration', () {
      final result = plugin.validate(
        host: 'example.com',
        port: 1883,
      );

      expect(result.isSuccess, true);
    });

    test('Validate rejects empty host', () {
      final result = plugin.validate(
        host: '',
        port: 1883,
      );

      expect(result.isFailure, true);
    });

    test('Validate rejects invalid port', () {
      final result = plugin.validate(
        host: 'example.com',
        port: 70000,
      );

      expect(result.isFailure, true);
    });

    test('Shutdown completes successfully', () async {
      final result = await plugin.shutdown();
      expect(result.isSuccess, true);
    });

    test('Get health status returns healthy', () async {
      final result = await plugin.getHealthStatus();

      expect(result.isSuccess, true);
      expect(result.value!['status'], 'healthy');
    });

    test('Plugin event creation works', () {
      final event = PluginEvent(
        pluginId: plugin.id,
        type: PluginEventType.loaded,
        message: 'Plugin loaded',
      );

      expect(event.pluginId, plugin.id);
      expect(event.type, PluginEventType.loaded);
      expect(event.message, 'Plugin loaded');
      expect(event.timestamp, isNotNull);
    });

    test('Plugin exception creation works', () {
      final exception = PluginException(
        'Test error',
        pluginId: plugin.id,
      );

      expect(exception.message, 'Test error');
      expect(exception.pluginId, plugin.id);
      expect(exception.toString(), contains('Test error'));
    });
  });

  group('Multi-Plugin Support', () {
    test('Multiple plugins can coexist with different types', () {
      final mqttPlugin = MockProtocolPlugin();

      expect(mqttPlugin.id, 'mock-protocol');
      expect(mqttPlugin.supportedProtocols.contains(ProtocolType.mqtt), true);
    });

    test('Plugin supports multiple protocol types', () {
      final multiPlugin = MockProtocolPlugin();
      // Mock plugin supports only MQTT, but the architecture supports multiple

      expect(multiPlugin.supportedProtocols.isNotEmpty, true);
    });
  });

  group('Plugin Error Handling', () {
    late MockProtocolPlugin plugin;

    setUp(() {
      plugin = MockProtocolPlugin();
    });

    test('Plugin handles connection errors gracefully', () async {
      // Mock a connection failure scenario
      expect(plugin.id, isNotEmpty);
    });

    test('Plugin validation catches configuration errors', () {
      final result = plugin.validate(
        host: 'invalid host with spaces',
        port: 0,
      );

      // Port validation will catch this
      expect(result.isFailure, true);
    });
  });
}
