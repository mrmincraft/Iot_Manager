import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/plugins/core/plugin_registry.dart';
import 'package:iot_manager/plugins/core/plugin_manager.dart';
import 'package:iot_manager/plugins/core/plugin_metadata.dart';
import 'package:iot_manager/plugins/core/plugin_context.dart';
import 'package:iot_manager/plugins/core/plugin_loader.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/core/utils/result.dart';

// Full protocol plugin implementation for testing
class FullTestPlugin extends ProtocolPlugin {
  final String _id;
  final String _name;
  final List<ProtocolType> _types;
  bool _initialized = false;
  bool _connected = false;
  final Map<String, dynamic> _state = {};

  FullTestPlugin({
    required String id,
    required String name,
    required List<ProtocolType> types,
  })  : _id = id,
        _name = name,
        _types = types;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get version => '1.0.0';

  @override
  String get author => 'Integration Test';

  @override
  List<ProtocolType> get supportedProtocols => _types;

  @override
  String get description => 'Full test plugin for integration testing';

  @override
  bool get isEnabled => true;

  @override
  Map<String, dynamic> get metadata => {'test': true, 'initialized': _initialized};

  @override
  Future<Result<void, Exception>> initialize(Map<String, dynamic> config) async {
    _initialized = true;
    _state.addAll(config);
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> connect({
    required String host,
    required int port,
    required ProtocolType protocolType,
    Map<String, dynamic>? options,
  }) async {
    _connected = true;
    _state['host'] = host;
    _state['port'] = port;
    return Result.success('conn-${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<Result<void, Exception>> disconnect(String connectionId) async {
    _connected = false;
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> subscribe({
    required String connectionId,
    required String topic,
    Map<String, dynamic>? options,
  }) async {
    return Result.success('sub-${DateTime.now().millisecondsSinceEpoch}');
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
    if (host.isEmpty || port <= 0 || port > 65535) {
      return Result.failure(Exception('Invalid configuration'));
    }
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> shutdown() async {
    _initialized = false;
    _connected = false;
    return Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> getHealthStatus() async {
    return Result.success({
      'healthy': _initialized,
      'connected': _connected,
      'state': _state,
    });
  }
}

void main() {
  group('Plugin System Integration Tests', () {
    late PluginRegistry registry;
    late PluginManager manager;
    late PluginLoader loader;

    setUp(() {
      registry = PluginRegistry.instance;
      manager = PluginManager.instance;
      loader = PluginLoader();
      registry.clear();
    });

    group('Full Plugin Lifecycle', () {
      test('Complete lifecycle: load, use, unload', () async {
        final plugin = FullTestPlugin(
          id: 'lifecycle-test',
          name: 'Lifecycle Test Plugin',
          types: [ProtocolType.mqtt],
        );

        // Load
        var result = await manager.loadPlugin(plugin, {'debug': true});
        expect(result.isSuccess, true);
        expect(plugin.metadata['initialized'], true);

        // Use
        final connResult = await plugin.connect(
          host: 'broker.example.com',
          port: 1883,
          protocolType: ProtocolType.mqtt,
        );
        expect(connResult.isSuccess, true);

        // Unload
        result = await manager.unloadPlugin('lifecycle-test');
        expect(result.isSuccess, true);
        expect(registry.hasPlugin('lifecycle-test'), false);
      });

      test('Plugin state management through lifecycle', () async {
        final plugin = FullTestPlugin(
          id: 'state-test',
          name: 'State Test Plugin',
          types: [ProtocolType.mqtt],
        );

        await manager.loadPlugin(plugin, {'version': '1.0'});

        var health = await plugin.getHealthStatus();
        expect(health.isSuccess, true);

        await manager.disablePlugin('state-test');
        health = await plugin.getHealthStatus();
        expect(health.isSuccess, true);

        await manager.unloadPlugin('state-test');
      });
    });

    group('Multi-Plugin Orchestration', () {
      test('Load and manage multiple plugins', () async {
        final mqttPlugin = FullTestPlugin(
          id: 'mqtt-plugin',
          name: 'MQTT Plugin',
          types: [ProtocolType.mqtt],
        );

        final httpPlugin = FullTestPlugin(
          id: 'http-plugin',
          name: 'HTTP Plugin',
          types: [ProtocolType.http],
        );

        final coapPlugin = FullTestPlugin(
          id: 'coap-plugin',
          name: 'CoAP Plugin',
          types: [ProtocolType.coap],
        );

        await manager.loadPlugin(mqttPlugin, {});
        await manager.loadPlugin(httpPlugin, {});
        await manager.loadPlugin(coapPlugin, {});

        expect(registry.pluginCount, 3);

        var mqttPlugins = registry.getPluginsByType(ProtocolType.mqtt);
        var httpPlugins = registry.getPluginsByType(ProtocolType.http);
        var coapPlugins = registry.getPluginsByType(ProtocolType.coap);

        expect(mqttPlugins.length, 1);
        expect(httpPlugins.length, 1);
        expect(coapPlugins.length, 1);
      });

      test('Plugin enable/disable patterns', () async {
        final plugin1 = FullTestPlugin(
          id: 'plugin-1',
          name: 'Plugin 1',
          types: [ProtocolType.mqtt],
        );

        final plugin2 = FullTestPlugin(
          id: 'plugin-2',
          name: 'Plugin 2',
          types: [ProtocolType.mqtt],
        );

        await manager.loadPlugin(plugin1, {});
        await manager.loadPlugin(plugin2, {});

        expect(manager.getEnabledPlugins().length, 2);

        await manager.disablePlugin('plugin-1');
        expect(manager.getEnabledPlugins().length, 1);

        await manager.enablePlugin('plugin-1');
        expect(manager.getEnabledPlugins().length, 2);
      });
    });

    group('Plugin Context Communication', () {
      test('Plugin context provides registry access', () {
        final plugin = FullTestPlugin(
          id: 'context-test',
          name: 'Context Test',
          types: [ProtocolType.mqtt],
        );

        final context = PluginContext(pluginId: plugin.id);

        expect(context.pluginId, plugin.id);
        expect(context.registry, isNotNull);
      });

      test('Plugin context can access other plugins', () async {
        final plugin1 = FullTestPlugin(
          id: 'plugin-a',
          name: 'Plugin A',
          types: [ProtocolType.mqtt],
        );

        final plugin2 = FullTestPlugin(
          id: 'plugin-b',
          name: 'Plugin B',
          types: [ProtocolType.http],
        );

        await manager.loadPlugin(plugin1, {});
        await manager.loadPlugin(plugin2, {});

        final context = PluginContext(pluginId: plugin1.id);
        final otherPlugin = context.getPlugin('plugin-b');

        expect(otherPlugin, isNotNull);
        expect(otherPlugin!.id, 'plugin-b');
      });
    });

    group('Plugin Metadata Management', () {
      test('Plugin metadata versioning', () {
        final metadata1 = PluginMetadata(
          id: 'mqtt-v1',
          name: 'MQTT Plugin V1',
          version: '1.0.0',
          author: 'MQTT Team',
          description: 'MQTT v1',
        );

        final metadata2 = PluginMetadata(
          id: 'mqtt-v2',
          name: 'MQTT Plugin V2',
          version: '2.0.0',
          author: 'MQTT Team',
          description: 'MQTT v2',
        );

        expect(metadata1.isVersionCompatible('1.5.0'), true);
        expect(metadata1.isVersionCompatible('2.0.0'), false);
        expect(metadata2.isVersionCompatible('2.1.0'), true);
      });

      test('Plugin metadata serialization', () {
        final original = PluginMetadata(
          id: 'serialize-test',
          name: 'Serialize Test',
          version: '1.2.3',
          author: 'Test',
          description: 'Test serialization',
          dependencies: ['core', 'utils'],
          tags: {'category': 'protocol'},
        );

        final map = original.toMap();
        final restored = PluginMetadata.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.version, original.version);
        expect(restored.dependencies, original.dependencies);
        expect(restored.tags, original.tags);
      });
    });

    group('Plugin Loader Integration', () {
      test('Load plugin from memory', () {
        final plugin = FullTestPlugin(
          id: 'memory-plugin',
          name: 'Memory Plugin',
          types: [ProtocolType.mqtt],
        );

        final result = loader.loadPluginFromMemory(plugin);

        expect(result.isSuccess, true);
        expect(loader.getPluginFromCache('memory-plugin').isSuccess, true);
      });

      test('Verify plugin integrity', () {
        final plugin = FullTestPlugin(
          id: 'integrity-test',
          name: 'Integrity Test',
          types: [ProtocolType.mqtt],
        );

        loader.loadPluginFromMemory(plugin);

        // Calculate expected hash
        final expectedHash = 'integrity-test:1.0.0:Integration Test:iot_manager_plugin_security_2026'.hashCode.toString();
        final verified = loader.verifyPluginIntegrity(plugin, expectedHash);

        expect(verified, true);
      });

      test('Cache statistics', () {
        final plugin1 = FullTestPlugin(
          id: 'cache-1',
          name: 'Cache 1',
          types: [ProtocolType.mqtt],
        );

        final plugin2 = FullTestPlugin(
          id: 'cache-2',
          name: 'Cache 2',
          types: [ProtocolType.http],
        );

        loader.loadPluginFromMemory(plugin1);
        loader.loadPluginFromMemory(plugin2);

        final stats = loader.getCacheStats();

        expect(stats['cachedPlugins'], 2);
        expect((stats['pluginIds'] as List).contains('cache-1'), true);
        expect((stats['pluginIds'] as List).contains('cache-2'), true);
      });

      test('Version compatibility checking', () {
        expect(loader.isPluginCompatible('1.5.3', '1.0.0'), true);
        expect(loader.isPluginCompatible('2.0.0', '1.0.0'), false);
        expect(loader.isPluginCompatible('1.0.0', '1.0.0'), true);
      });
    });

    group('Error Handling', () {
      test('Handle invalid plugin configuration', () async {
        final plugin = FullTestPlugin(
          id: 'error-test',
          name: 'Error Test',
          types: [ProtocolType.mqtt],
        );

        final invalidConfig = {'invalid': null};

        var result = await manager.loadPlugin(plugin, invalidConfig);
        expect(result.isSuccess, true); // Still loads but config stored

        // Test validation
        final validationResult = plugin.validate(
          host: '',
          port: 0,
        );
        expect(validationResult.isFailure, true);
      });

      test('Handle plugin not found errors', () {
        final getResult = registry.getPlugin('nonexistent');
        expect(getResult.isFailure, true);

        final unregisterResult = registry.unregister('nonexistent');
        expect(unregisterResult.isFailure, true);
      });

      test('Plugin exception with context', () {
        final exception = PluginException(
          'Test error',
          pluginId: 'test-plugin',
          originalError: Exception('Root cause'),
        );

        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('test-plugin'));
        expect(exception.pluginId, 'test-plugin');
      });
    });

    group('Performance Integration Tests', () {
      test('Load many plugins efficiently', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 50; i++) {
          final plugin = FullTestPlugin(
            id: 'perf-plugin-$i',
            name: 'Perf Plugin $i',
            types: [ProtocolType.mqtt],
          );

          await manager.loadPlugin(plugin, {'index': i});
        }

        stopwatch.stop();

        expect(registry.pluginCount, 50);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Query plugins from large registry', () async {
        for (int i = 0; i < 100; i++) {
          final plugin = FullTestPlugin(
            id: 'query-plugin-$i',
            name: 'Query Plugin $i',
            types: [
              if (i % 3 == 0) ProtocolType.mqtt,
              if (i % 3 == 1) ProtocolType.http,
              if (i % 3 == 2) ProtocolType.coap,
            ],
          );

          await manager.loadPlugin(plugin, {});
        }

        final stopwatch = Stopwatch()..start();

        final mqttPlugins = registry.getPluginsByType(ProtocolType.mqtt);

        stopwatch.stop();

        expect(mqttPlugins.length, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Plugin Statistics', () {
      test('Registry provides comprehensive statistics', () async {
        final plugin1 = FullTestPlugin(
          id: 'stat-1',
          name: 'Stat 1',
          types: [ProtocolType.mqtt],
        );

        final plugin2 = FullTestPlugin(
          id: 'stat-2',
          name: 'Stat 2',
          types: [ProtocolType.http, ProtocolType.coap],
        );

        await manager.loadPlugin(plugin1, {});
        await manager.loadPlugin(plugin2, {});

        final stats = registry.getStatistics();

        expect(stats['totalPlugins'], 2);
        expect(stats['enabledPlugins'], 2);
        expect(stats['protocolSupport'], isNotNull);
      });

      test('Manager provides health statistics', () async {
        final plugin = FullTestPlugin(
          id: 'health-stat',
          name: 'Health Stat',
          types: [ProtocolType.mqtt],
        );

        await manager.loadPlugin(plugin, {});

        final stats = manager.getStatistics();

        expect(stats.containsKey('totalPlugins'), true);
        expect(stats.containsKey('enabledPlugins'), true);
        expect(stats.containsKey('averageUptimeSeconds'), true);
      });
    });
  });
}
