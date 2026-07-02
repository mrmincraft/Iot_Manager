import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

void main() {
  group('Protocol Entity Tests', () {
    group('Protocol Creation', () {
      test('creates protocol with all parameters', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT Broker',
          type: ProtocolType.mqtt,
          port: 1883,
          description: 'MQTT protocol implementation',
          metadata: {'version': '5.0'},
        );

        expect(protocol.id, 'mqtt-001');
        expect(protocol.name, 'MQTT Broker');
        expect(protocol.type, ProtocolType.mqtt);
        expect(protocol.port, 1883);
        expect(protocol.description, 'MQTT protocol implementation');
        expect(protocol.metadata, {'version': '5.0'});
      });

      test('creates protocol with minimal parameters', () {
        final protocol = Protocol(
          id: 'http-001',
          name: 'HTTP API',
          type: ProtocolType.http,
          port: 80,
        );

        expect(protocol.id, 'http-001');
        expect(protocol.name, 'HTTP API');
        expect(protocol.type, ProtocolType.http);
        expect(protocol.port, 80);
        expect(protocol.description, isNull);
        expect(protocol.metadata, {});
      });

      test('validates protocol ID is not empty', () {
        expect(
          () => Protocol(
            id: '',
            name: 'Test',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates protocol name is not empty', () {
        expect(
          () => Protocol(
            id: 'test',
            name: '',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates port is within valid range', () {
        expect(
          () => Protocol(
            id: 'test',
            name: 'Test',
            type: ProtocolType.mqtt,
            port: 0,
          ),
          throwsA(isA<AssertionError>()),
        );

        expect(
          () => Protocol(
            id: 'test',
            name: 'Test',
            type: ProtocolType.mqtt,
            port: 65536,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('allows valid port range 1-65535', () {
        final protocol1 = Protocol(
          id: 'test1',
          name: 'Test',
          type: ProtocolType.mqtt,
          port: 1,
        );
        expect(protocol1.port, 1);

        final protocol2 = Protocol(
          id: 'test2',
          name: 'Test',
          type: ProtocolType.mqtt,
          port: 65535,
        );
        expect(protocol2.port, 65535);
      });
    });

    group('ProtocolType Enum', () {
      test('mqtt protocol type', () {
        expect(ProtocolType.mqtt, ProtocolType.mqtt);
      });

      test('http protocol type', () {
        expect(ProtocolType.http, ProtocolType.http);
      });

      test('coap protocol type', () {
        expect(ProtocolType.coap, ProtocolType.coap);
      });

      test('modbus protocol type', () {
        expect(ProtocolType.modbus, ProtocolType.modbus);
      });

      test('all protocol types are distinct', () {
        final types = {
          ProtocolType.mqtt,
          ProtocolType.http,
          ProtocolType.coap,
          ProtocolType.modbus,
        };
        expect(types.length, 4);
      });
    });

    group('Protocol copyWith', () {
      test('creates copy with changed values', () {
        final original = Protocol(
          id: 'mqtt-001',
          name: 'Original Name',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          port: 8883,
        );

        expect(updated.id, 'mqtt-001'); // Unchanged
        expect(updated.name, 'Updated Name');
        expect(updated.port, 8883);
        expect(updated.type, ProtocolType.mqtt); // Unchanged
      });

      test('copyWith preserves original object', () {
        final original = Protocol(
          id: 'mqtt-001',
          name: 'Original',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        original.copyWith(name: 'Updated');

        expect(original.name, 'Original'); // Unchanged
      });

      test('copyWith can change all fields', () {
        final original = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final updated = original.copyWith(
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
          description: 'New description',
          metadata: {'new': 'metadata'},
        );

        expect(updated.name, 'HTTP');
        expect(updated.type, ProtocolType.http);
        expect(updated.port, 80);
        expect(updated.description, 'New description');
        expect(updated.metadata, {'new': 'metadata'});
      });
    });

    group('Protocol Equality', () {
      test('protocols with same values are equal', () {
        final protocol1 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT Broker',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final protocol2 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT Broker',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol1, protocol2);
      });

      test('protocols with different values are not equal', () {
        final protocol1 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final protocol2 = Protocol(
          id: 'mqtt-002',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol1, isNot(protocol2));
      });

      test('hash codes are equal for equal protocols', () {
        final protocol1 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final protocol2 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol1.hashCode, protocol2.hashCode);
      });

      test('equal protocols can be added to Set', () {
        final protocol1 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final protocol2 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final set = {protocol1, protocol2};
        expect(set.length, 1); // Duplicates removed
      });
    });

    group('Protocol String Representation', () {
      test('toString returns meaningful representation', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT Broker',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final str = protocol.toString();
        expect(str, contains('mqtt-001'));
        expect(str, contains('MQTT Broker'));
        expect(str, contains('1883'));
      });

      test('toString different for different protocols', () {
        final protocol1 = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final protocol2 = Protocol(
          id: 'http-001',
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
        );

        expect(protocol1.toString(), isNot(protocol2.toString()));
      });
    });

    group('Protocol Metadata', () {
      test('metadata is mutable', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          metadata: {'key1': 'value1'},
        );

        expect(protocol.metadata['key1'], 'value1');
      });

      test('metadata can contain complex values', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          metadata: {
            'version': '5.0',
            'features': ['auth', 'tls', 'qos'],
            'config': {
              'timeout': 30,
              'retries': 3,
            }
          },
        );

        expect(protocol.metadata['version'], '5.0');
        expect(protocol.metadata['features'], ['auth', 'tls', 'qos']);
        expect(protocol.metadata['config']['timeout'], 30);
      });

      test('empty metadata by default', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol.metadata, isEmpty);
      });
    });

    group('Protocol Description', () {
      test('description is optional', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol.description, isNull);
      });

      test('description can be provided', () {
        final description = 'MQTT protocol implementation with TLS support';
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          description: description,
        );

        expect(protocol.description, description);
      });

      test('description can be long', () {
        final description = 'A' * 500;
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          description: description,
        );

        expect(protocol.description!.length, 500);
      });
    });

    group('Protocol Validation', () {
      test('valid protocols pass validation', () {
        final validProtocols = [
          Protocol(
            id: 'mqtt-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'http-001',
            name: 'HTTP API',
            type: ProtocolType.http,
            port: 80,
          ),
          Protocol(
            id: 'coap-001',
            name: 'CoAP',
            type: ProtocolType.coap,
            port: 5683,
          ),
        ];

        for (final protocol in validProtocols) {
          expect(protocol.id.isNotEmpty, true);
          expect(protocol.name.isNotEmpty, true);
          expect(protocol.port > 0 && protocol.port <= 65535, true);
        }
      });

      test('protocol with special characters in name', () {
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT@5.0-Broker_Test',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol.name, 'MQTT@5.0-Broker_Test');
      });

      test('protocol port can be well-known ports', () {
        final wellKnownPorts = [
          Protocol(
            id: 'http',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
          Protocol(
            id: 'https',
            name: 'HTTPS',
            type: ProtocolType.http,
            port: 443,
          ),
          Protocol(
            id: 'mqtt',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'mqtt-tls',
            name: 'MQTT over TLS',
            type: ProtocolType.mqtt,
            port: 8883,
          ),
        ];

        expect(wellKnownPorts[0].port, 80);
        expect(wellKnownPorts[1].port, 443);
        expect(wellKnownPorts[2].port, 1883);
        expect(wellKnownPorts[3].port, 8883);
      });
    });
  });
}
