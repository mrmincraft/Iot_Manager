import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/plugins/core/plugin_metadata.dart';

void main() {
  group('PluginMetadata Tests', () {
    test('Create metadata with required fields', () {
      final metadata = PluginMetadata(
        id: 'test-plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        author: 'Test Author',
        description: 'A test plugin',
      );

      expect(metadata.id, 'test-plugin');
      expect(metadata.name, 'Test Plugin');
      expect(metadata.version, '1.0.0');
      expect(metadata.author, 'Test Author');
      expect(metadata.description, 'A test plugin');
    });

    test('Create metadata with optional fields', () {
      final configSchema = {'host': 'string', 'port': 'int'};
      final tags = {'category': 'protocol', 'stability': 'stable'};

      final metadata = PluginMetadata(
        id: 'mqtt-plugin',
        name: 'MQTT Plugin',
        version: '2.1.0',
        author: 'MQTT Foundation',
        description: 'MQTT protocol support',
        dependencies: ['core', 'networking'],
        configSchema: configSchema,
        tags: tags,
      );

      expect(metadata.dependencies.length, 2);
      expect(metadata.dependencies.contains('core'), true);
      expect(metadata.configSchema, configSchema);
      expect(metadata.tags, tags);
    });

    test('Check version compatibility - same major version', () {
      final metadata = PluginMetadata(
        id: 'plugin',
        name: 'Plugin',
        version: '2.5.3',
        author: 'Author',
        description: 'Description',
      );

      expect(metadata.isVersionCompatible('2.0.0'), true);
      expect(metadata.isVersionCompatible('2.1.0'), true);
      expect(metadata.isVersionCompatible('2.10.5'), true);
    });

    test('Check version compatibility - different major version', () {
      final metadata = PluginMetadata(
        id: 'plugin',
        name: 'Plugin',
        version: '2.5.3',
        author: 'Author',
        description: 'Description',
      );

      expect(metadata.isVersionCompatible('1.0.0'), false);
      expect(metadata.isVersionCompatible('3.0.0'), false);
    });

    test('Check version compatibility - exact match', () {
      final metadata = PluginMetadata(
        id: 'plugin',
        name: 'Plugin',
        version: '1.2.3',
        author: 'Author',
        description: 'Description',
      );

      expect(metadata.isVersionCompatible('1.2.3'), true);
    });

    test('Convert metadata to map', () {
      final metadata = PluginMetadata(
        id: 'test-plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        author: 'Test Author',
        description: 'A test plugin',
        dependencies: ['dep1', 'dep2'],
        tags: {'tag': 'value'},
      );

      final map = metadata.toMap();

      expect(map['id'], 'test-plugin');
      expect(map['name'], 'Test Plugin');
      expect(map['version'], '1.0.0');
      expect(map['author'], 'Test Author');
      expect(map['dependencies'], ['dep1', 'dep2']);
      expect(map['tags']['tag'], 'value');
    });

    test('Create metadata from map', () {
      final inputMap = {
        'id': 'plugin-from-map',
        'name': 'Plugin From Map',
        'version': '1.5.0',
        'author': 'Map Author',
        'description': 'Created from map',
        'dependencies': ['dep1'],
        'configSchema': {'key': 'value'},
        'tags': {'env': 'prod'},
      };

      final metadata = PluginMetadata.fromMap(inputMap);

      expect(metadata.id, 'plugin-from-map');
      expect(metadata.name, 'Plugin From Map');
      expect(metadata.version, '1.5.0');
      expect(metadata.author, 'Map Author');
      expect(metadata.dependencies.length, 1);
      expect(metadata.configSchema['key'], 'value');
      expect(metadata.tags['env'], 'prod');
    });

    test('Roundtrip serialization - toMap then fromMap', () {
      final original = PluginMetadata(
        id: 'roundtrip-plugin',
        name: 'Roundtrip Plugin',
        version: '2.3.1',
        author: 'Test Author',
        description: 'Test roundtrip serialization',
        dependencies: ['core', 'utils'],
        configSchema: {'host': 'string', 'port': 'int', 'ssl': 'bool'},
        tags: {'type': 'protocol', 'status': 'stable'},
      );

      final map = original.toMap();
      final restored = PluginMetadata.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.version, original.version);
      expect(restored.author, original.author);
      expect(restored.description, original.description);
      expect(restored.dependencies, original.dependencies);
      expect(restored.configSchema, original.configSchema);
      expect(restored.tags, original.tags);
    });

    test('Metadata toString format', () {
      final metadata = PluginMetadata(
        id: 'test',
        name: 'Test',
        version: '1.0.0',
        author: 'Author',
        description: 'Test',
      );

      final str = metadata.toString();

      expect(str, contains('test'));
      expect(str, contains('1.0.0'));
      expect(str, contains('Author'));
    });

    test('Default values for optional fields', () {
      final metadata = PluginMetadata(
        id: 'minimal',
        name: 'Minimal',
        version: '0.1.0',
        author: 'Me',
        description: 'Minimal metadata',
      );

      expect(metadata.dependencies, isEmpty);
      expect(metadata.configSchema, isEmpty);
      expect(metadata.tags, isEmpty);
    });

    test('Metadata with empty optional collections', () {
      final metadata = PluginMetadata(
        id: 'empty-collections',
        name: 'Empty Collections',
        version: '1.0.0',
        author: 'Author',
        description: 'Empty collections',
        dependencies: [],
        configSchema: {},
        tags: {},
      );

      expect(metadata.dependencies.isEmpty, true);
      expect(metadata.configSchema.isEmpty, true);
      expect(metadata.tags.isEmpty, true);
    });

    test('Multiple plugins metadata comparison', () {
      final mqtt = PluginMetadata(
        id: 'mqtt',
        name: 'MQTT Plugin',
        version: '3.0.0',
        author: 'Eclipse',
        description: 'MQTT support',
      );

      final http = PluginMetadata(
        id: 'http',
        name: 'HTTP Plugin',
        version: '2.0.0',
        author: 'HTTP Org',
        description: 'HTTP support',
      );

      expect(mqtt.id, isNot(http.id));
      expect(mqtt.author, isNot(http.author));
      expect(mqtt.isVersionCompatible('3.1.0'), true);
      expect(http.isVersionCompatible('3.0.0'), false);
    });

    test('Version compatibility with malformed version', () {
      final metadata = PluginMetadata(
        id: 'test',
        name: 'Test',
        version: 'invalid.version',
        author: 'Author',
        description: 'Test',
      );

      // Should handle gracefully
      expect(metadata.isVersionCompatible('1.0'), false);
    });

    test('Metadata with complex configSchema', () {
      final complexSchema = {
        'connection': {
          'host': 'string',
          'port': 'int',
          'timeout': 'int',
          'ssl': {
            'enabled': 'bool',
            'certificatePath': 'string',
          },
        },
        'advanced': {
          'compression': 'bool',
          'maxConnections': 'int',
        },
      };

      final metadata = PluginMetadata(
        id: 'complex',
        name: 'Complex Plugin',
        version: '1.0.0',
        author: 'Author',
        description: 'Complex configuration',
        configSchema: complexSchema,
      );

      final map = metadata.toMap();
      final restored = PluginMetadata.fromMap(map);

      expect(restored.configSchema['connection']['ssl']['certificatePath'], 'string');
      expect(restored.configSchema['advanced']['maxConnections'], 'int');
    });

    test('Metadata immutability check', () {
      final metadata = PluginMetadata(
        id: 'immutable',
        name: 'Immutable',
        version: '1.0.0',
        author: 'Author',
        description: 'Test immutability',
        dependencies: ['dep1'],
      );

      final map = metadata.toMap();

      // Verify values didn't change
      expect(metadata.id, 'immutable');
      expect(metadata.version, '1.0.0');
      expect(metadata.dependencies[0], 'dep1');
    });
  });
}
