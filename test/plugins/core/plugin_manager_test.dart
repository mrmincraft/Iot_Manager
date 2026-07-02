import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/plugins/core/plugin_manager.dart';
import 'package:iot_manager/plugins/core/plugin_registry.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/core/utils/result.dart';

// Test implementation
class TestPlugin extends ProtocolPlugin {
  final String _id;
  bool _initialized = false;
  bool _shutdown = false;

  TestPlugin({required String id}) : _id = id;

  @override
  String get id => _id;

  @override
  String get name => 'Test Plugin $_id';

  @override
  String get version => '1.0.0';

  @override
  String get author => 'Test';

  @override
  List<ProtocolType> get supportedProtocols => [ProtocolType.mqtt];

  @override
  String get description => 'Test plugin';

  @override
  bool get isEnabled => true;

  @override
  Map<String, dynamic> get metadata => {};

  @override
  Future<Result<void, Exception>> initialize(Map<String, dynamic> config) async {
    _initialized = true;
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> connect({
    required String host,
    required int port,
    required ProtocolType protocolType,
    Map<String, dynamic>? options,
  }) async =>
      Result.success('conn-id');

  @override
  Future<Result<void, Exception>> disconnect(String connectionId) async =>
      Result.success(null);

  @override
  Future<Result<String, Exception>> subscribe({
    required String connectionId,
    required String topic,
    Map<String, dynamic>? options,
  }) async =>
      Result.success('sub-id');

  @override
  Future<Result<void, Exception>> unsubscribe({
    required String connectionId,
    required String subscriptionId,
  }) async =>
      Result.success(null);

  @override
  Future<Result<void, Exception>> publish({
    required String connectionId,
    required String topic,
    required List<int> payload,
    Map<String, dynamic>? options,
  }) async =>
      Result.success(null);

  @override
  Result<void, Exception> validate({
    required String host,
    required int port,
    Map<String, dynamic>? options,
  }) =>
      Result.success(null);

  @override
  Future<Result<void, Exception>> shutdown() async {
    _shutdown = true;
    return Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> getHealthStatus() async =>
      Result.success({'healthy': true});

  bool get initialized => _initialized;
  bool get shutdownCalled => _shutdown;
}

void main() {
  group('PluginManager Tests', () {
    late PluginManager manager;
    late PluginRegistry registry;

    setUp(() {
      manager = PluginManager.instance;
      registry = PluginRegistry.instance;
      registry.clear();
    });

    test('PluginManager is singleton', () {
      final manager1 = PluginManager.instance;
      final manager2 = PluginManager.instance;

      expect(identical(manager1, manager2), true);
    });

    test('Load plugin successfully', () async {
      final plugin = TestPlugin(id: 'test-load-1');

      final result = await manager.loadPlugin(plugin, {});

      expect(result.isSuccess, true);
      expect(registry.hasPlugin('test-load-1'), true);
      expect(plugin.initialized, true);
    });

    test('Load plugin with configuration', () async {
      final plugin = TestPlugin(id: 'test-load-config');
      final config = {'key': 'value', 'debug': true};

      final result = await manager.loadPlugin(plugin, config);

      expect(result.isSuccess, true);
      expect(plugin.initialized, true);
    });

    test('Cannot load plugin twice', () async {
      final plugin = TestPlugin(id: 'test-duplicate');

      await manager.loadPlugin(plugin, {});
      final result = await manager.loadPlugin(plugin, {});

      expect(result.isFailure, true);
    });

    test('Unload plugin successfully', () async {
      final plugin = TestPlugin(id: 'test-unload');

      await manager.loadPlugin(plugin, {});
      expect(registry.hasPlugin('test-unload'), true);

      final result = await manager.unloadPlugin('test-unload');

      expect(result.isSuccess, true);
      expect(registry.hasPlugin('test-unload'), false);
      expect(plugin.shutdownCalled, true);
    });

    test('Cannot unload nonexistent plugin', () async {
      final result = await manager.unloadPlugin('nonexistent');

      expect(result.isFailure, true);
    });

    test('Enable plugin', () async {
      final plugin = TestPlugin(id: 'test-enable');

      await manager.loadPlugin(plugin, {});
      final result = await manager.enablePlugin('test-enable');

      expect(result.isSuccess, true);
      expect(manager.isPluginEnabled('test-enable'), true);
    });

    test('Disable plugin', () async {
      final plugin = TestPlugin(id: 'test-disable');

      await manager.loadPlugin(plugin, {});
      expect(manager.isPluginEnabled('test-disable'), true);

      final result = await manager.disablePlugin('test-disable');

      expect(result.isSuccess, true);
      expect(manager.isPluginEnabled('test-disable'), false);
    });

    test('Get enabled plugins', () async {
      final plugin1 = TestPlugin(id: 'enabled-1');
      final plugin2 = TestPlugin(id: 'enabled-2');

      await manager.loadPlugin(plugin1, {});
      await manager.loadPlugin(plugin2, {});

      final enabled = manager.getEnabledPlugins();

      expect(enabled.length, 2);
      expect(enabled.any((p) => p.id == 'enabled-1'), true);
      expect(enabled.any((p) => p.id == 'enabled-2'), true);
    });

    test('Get plugin load time', () async {
      final plugin = TestPlugin(id: 'test-loadtime');

      await manager.loadPlugin(plugin, {});
      final loadTime = manager.getPluginLoadTime('test-loadtime');

      expect(loadTime, isNotNull);
      expect(
        loadTime!.isBefore(DateTime.now()),
        true,
      );
    });

    test('Get plugin uptime', () async {
      final plugin = TestPlugin(id: 'test-uptime');

      await manager.loadPlugin(plugin, {});
      await Future.delayed(Duration(milliseconds: 100));

      final uptime = manager.getPluginUptime('test-uptime');

      expect(uptime, isNotNull);
      expect(uptime!, greaterThan(0));
    });

    test('Get health status of all plugins', () async {
      final plugin1 = TestPlugin(id: 'health-1');
      final plugin2 = TestPlugin(id: 'health-2');

      await manager.loadPlugin(plugin1, {});
      await manager.loadPlugin(plugin2, {});

      final result = await manager.getHealthStatus();

      expect(result.isSuccess, true);
      expect(result.value!.containsKey('health-1'), true);
      expect(result.value!.containsKey('health-2'), true);
    });

    test('Get manager statistics', () async {
      final plugin1 = TestPlugin(id: 'stats-1');
      final plugin2 = TestPlugin(id: 'stats-2');

      await manager.loadPlugin(plugin1, {});
      await manager.loadPlugin(plugin2, {});

      final stats = manager.getStatistics();

      expect(stats.containsKey('totalPlugins'), true);
      expect(stats['totalPlugins'], 2);
    });

    test('Toggle plugin enable/disable', () async {
      final plugin = TestPlugin(id: 'toggle-plugin');

      await manager.loadPlugin(plugin, {});

      // Initially enabled
      expect(manager.isPluginEnabled('toggle-plugin'), true);

      // Disable
      await manager.disablePlugin('toggle-plugin');
      expect(manager.isPluginEnabled('toggle-plugin'), false);

      // Re-enable
      await manager.enablePlugin('toggle-plugin');
      expect(manager.isPluginEnabled('toggle-plugin'), true);
    });

    test('Multiple plugin lifecycle', () async {
      final plugins = [
        TestPlugin(id: 'lifecycle-1'),
        TestPlugin(id: 'lifecycle-2'),
        TestPlugin(id: 'lifecycle-3'),
      ];

      for (final plugin in plugins) {
        await manager.loadPlugin(plugin, {});
      }

      expect(manager.getEnabledPlugins().length, 3);

      await manager.disablePlugin('lifecycle-2');
      expect(manager.getEnabledPlugins().length, 2);

      await manager.unloadPlugin('lifecycle-1');
      expect(registry.getAllPlugins().length, 2);
    });
  });

  group('Plugin Events', () {
    test('Plugin event has timestamp', () {
      final event = PluginEvent(
        pluginId: 'test-plugin',
        type: PluginEventType.loaded,
        message: 'Test message',
      );

      expect(event.timestamp, isNotNull);
      expect(event.timestamp.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('Plugin event includes data', () {
      final data = {'key': 'value'};
      final event = PluginEvent(
        pluginId: 'test-plugin',
        type: PluginEventType.connected,
        message: 'Connected',
        data: data,
      );

      expect(event.data, data);
      expect(event.data!['key'], 'value');
    });

    test('Plugin exception has context', () {
      final exception = PluginException(
        'Test error message',
        pluginId: 'failing-plugin',
        originalError: Exception('Original'),
      );

      expect(exception.message, 'Test error message');
      expect(exception.pluginId, 'failing-plugin');
      expect(exception.originalError, isNotNull);
    });
  });
}
