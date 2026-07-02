import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/plugins/core/plugin_registry.dart';
import 'package:iot_manager/plugins/core/protocol_plugin.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/core/utils/result.dart';

// Mock plugin implementation
class TestProtocolPlugin extends ProtocolPlugin {
  final String _id;
  final String _name;
  final List<ProtocolType> _types;
  final String _author;

  TestProtocolPlugin({
    required String id,
    required String name,
    required List<ProtocolType> types,
    String author = 'Test Author',
  })  : _id = id,
        _name = name,
        _types = types,
        _author = author;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get version => '1.0.0';

  @override
  String get author => _author;

  @override
  List<ProtocolType> get supportedProtocols => _types;

  @override
  String get description => 'Test plugin for $name';

  @override
  bool get isEnabled => true;

  @override
  Map<String, dynamic> get metadata => {};

  @override
  Future<Result<void, Exception>> initialize(Map<String, dynamic> config) async =>
      Result.success(null);

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
  Future<Result<void, Exception>> shutdown() async => Result.success(null);

  @override
  Future<Result<Map<String, dynamic>, Exception>> getHealthStatus() async =>
      Result.success({'healthy': true});
}

void main() {
  group('PluginRegistry Tests', () {
    late PluginRegistry registry;

    setUp(() {
      registry = PluginRegistry.instance;
      registry.clear();
    });

    test('Registry is singleton', () {
      final registry1 = PluginRegistry.instance;
      final registry2 = PluginRegistry.instance;

      expect(identical(registry1, registry2), true);
    });

    test('Register plugin successfully', () {
      final plugin = TestProtocolPlugin(
        id: 'test-plugin-1',
        name: 'Test Plugin 1',
        types: [ProtocolType.mqtt],
      );

      final result = registry.register(plugin);

      expect(result.isSuccess, true);
      expect(registry.pluginCount, 1);
    });

    test('Cannot register duplicate plugin ID', () {
      final plugin1 = TestProtocolPlugin(
        id: 'test-plugin',
        name: 'Plugin 1',
        types: [ProtocolType.mqtt],
      );

      final plugin2 = TestProtocolPlugin(
        id: 'test-plugin',
        name: 'Plugin 2',
        types: [ProtocolType.http],
      );

      registry.register(plugin1);
      final result = registry.register(plugin2);

      expect(result.isFailure, true);
      expect(registry.pluginCount, 1);
    });

    test('Get plugin by ID', () {
      final plugin = TestProtocolPlugin(
        id: 'plugin-123',
        name: 'Test Plugin',
        types: [ProtocolType.mqtt],
      );

      registry.register(plugin);
      final result = registry.getPlugin('plugin-123');

      expect(result.isSuccess, true);
      expect(result.value!.name, 'Test Plugin');
    });

    test('Get nonexistent plugin returns failure', () {
      final result = registry.getPlugin('nonexistent');

      expect(result.isFailure, true);
    });

    test('Unregister plugin successfully', () {
      final plugin = TestProtocolPlugin(
        id: 'plugin-to-remove',
        name: 'Removable Plugin',
        types: [ProtocolType.mqtt],
      );

      registry.register(plugin);
      expect(registry.pluginCount, 1);

      final result = registry.unregister('plugin-to-remove');

      expect(result.isSuccess, true);
      expect(registry.pluginCount, 0);
    });

    test('Get all plugins', () {
      final plugin1 = TestProtocolPlugin(
        id: 'plugin-1',
        name: 'Plugin 1',
        types: [ProtocolType.mqtt],
      );

      final plugin2 = TestProtocolPlugin(
        id: 'plugin-2',
        name: 'Plugin 2',
        types: [ProtocolType.http],
      );

      registry.register(plugin1);
      registry.register(plugin2);

      final plugins = registry.getAllPlugins();

      expect(plugins.length, 2);
      expect(plugins.any((p) => p.id == 'plugin-1'), true);
      expect(plugins.any((p) => p.id == 'plugin-2'), true);
    });

    test('Get plugins by protocol type', () {
      final mqttPlugin = TestProtocolPlugin(
        id: 'mqtt-plugin',
        name: 'MQTT Plugin',
        types: [ProtocolType.mqtt],
      );

      final httpPlugin = TestProtocolPlugin(
        id: 'http-plugin',
        name: 'HTTP Plugin',
        types: [ProtocolType.http],
      );

      registry.register(mqttPlugin);
      registry.register(httpPlugin);

      final mqttPlugins = registry.getPluginsByType(ProtocolType.mqtt);

      expect(mqttPlugins.length, 1);
      expect(mqttPlugins[0].id, 'mqtt-plugin');
    });

    test('Get plugins by author', () {
      final plugin1 = TestProtocolPlugin(
        id: 'plugin-1',
        name: 'Plugin 1',
        types: [ProtocolType.mqtt],
        author: 'AuthorA',
      );

      final plugin2 = TestProtocolPlugin(
        id: 'plugin-2',
        name: 'Plugin 2',
        types: [ProtocolType.mqtt],
        author: 'AuthorB',
      );

      registry.register(plugin1);
      registry.register(plugin2);

      final authorAPlugins = registry.getPluginsByAuthor('AuthorA');

      expect(authorAPlugins.length, 1);
      expect(authorAPlugins[0].id, 'plugin-1');
    });

    test('Check if plugin exists', () {
      final plugin = TestProtocolPlugin(
        id: 'existing-plugin',
        name: 'Existing',
        types: [ProtocolType.mqtt],
      );

      registry.register(plugin);

      expect(registry.hasPlugin('existing-plugin'), true);
      expect(registry.hasPlugin('nonexistent'), false);
    });

    test('Get supported protocol types', () {
      final mqttPlugin = TestProtocolPlugin(
        id: 'mqtt',
        name: 'MQTT',
        types: [ProtocolType.mqtt],
      );

      final httpPlugin = TestProtocolPlugin(
        id: 'http',
        name: 'HTTP',
        types: [ProtocolType.http, ProtocolType.coap],
      );

      registry.register(mqttPlugin);
      registry.register(httpPlugin);

      final types = registry.getSupportedProtocolTypes();

      expect(types.contains(ProtocolType.mqtt), true);
      expect(types.contains(ProtocolType.http), true);
      expect(types.contains(ProtocolType.coap), true);
    });

    test('Get registry statistics', () {
      final plugin1 = TestProtocolPlugin(
        id: 'plugin-1',
        name: 'Plugin 1',
        types: [ProtocolType.mqtt],
        author: 'AuthorA',
      );

      final plugin2 = TestProtocolPlugin(
        id: 'plugin-2',
        name: 'Plugin 2',
        types: [ProtocolType.http],
        author: 'AuthorA',
      );

      registry.register(plugin1);
      registry.register(plugin2);

      final stats = registry.getStatistics();

      expect(stats['totalPlugins'], 2);
      expect(stats['enabledPlugins'], 2);
      expect(stats['authors'], 1);
    });

    test('Get plugins sorted by name', () {
      final pluginZ = TestProtocolPlugin(
        id: 'z-plugin',
        name: 'Z Plugin',
        types: [ProtocolType.mqtt],
      );

      final pluginA = TestProtocolPlugin(
        id: 'a-plugin',
        name: 'A Plugin',
        types: [ProtocolType.mqtt],
      );

      registry.register(pluginZ);
      registry.register(pluginA);

      final sorted = registry.getPluginsSorted();

      expect(sorted[0].name, 'A Plugin');
      expect(sorted[1].name, 'Z Plugin');
    });

    test('Clear registry', () {
      final plugin = TestProtocolPlugin(
        id: 'plugin-1',
        name: 'Plugin 1',
        types: [ProtocolType.mqtt],
      );

      registry.register(plugin);
      expect(registry.pluginCount, 1);

      registry.clear();

      expect(registry.pluginCount, 0);
    });

    test('Multiple protocol types in single plugin', () {
      final multiPlugin = TestProtocolPlugin(
        id: 'multi-plugin',
        name: 'Multi Protocol Plugin',
        types: [ProtocolType.mqtt, ProtocolType.http, ProtocolType.coap],
      );

      registry.register(multiPlugin);

      final mqttPlugins = registry.getPluginsByType(ProtocolType.mqtt);
      final httpPlugins = registry.getPluginsByType(ProtocolType.http);
      final coapPlugins = registry.getPluginsByType(ProtocolType.coap);

      expect(mqttPlugins.length, 1);
      expect(httpPlugins.length, 1);
      expect(coapPlugins.length, 1);
    });
  });
}
