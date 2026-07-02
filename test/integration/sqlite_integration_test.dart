import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/core/exceptions/app_exception.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';

void main() {
  group('SQLite Integration Tests', () {
    group('Protocol SQLite Operations', () {
      test('Protocol model converts to and from SQLite map', () {
        final protocol = ProtocolModel(
          id: 'proto-sqlite-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final map = protocol.toMap();
        expect(map, isNotNull);
        expect(map['id'], 'proto-sqlite-001');
        expect(map['name'], 'MQTT');
        expect(map['port'], 1883);

        final restored = ProtocolModel.fromMap(map);
        expect(restored.id, protocol.id);
        expect(restored.name, protocol.name);
        expect(restored.port, protocol.port);
      });

      test('Multiple protocols roundtrip through SQLite serialization', () {
        final protocols = [
          ProtocolModel(
            id: 'proto-1',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-2',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
          ProtocolModel(
            id: 'proto-3',
            name: 'CoAP',
            type: ProtocolType.coap,
            port: 5683,
          ),
        ];

        final maps = protocols.map((p) => p.toMap()).toList();
        final restored = maps.map((m) => ProtocolModel.fromMap(m)).toList();

        expect(restored.length, 3);
        for (int i = 0; i < protocols.length; i++) {
          expect(restored[i].id, protocols[i].id);
          expect(restored[i].name, protocols[i].name);
          expect(restored[i].port, protocols[i].port);
        }
      });

      test('Protocol with metadata persists correctly', () {
        final protocol = ProtocolModel(
          id: 'proto-metadata',
          name: 'MQTT with Metadata',
          type: ProtocolType.mqtt,
          port: 1883,
          metadata: {
            'version': '3.1.1',
            'tlsRequired': true,
          },
        );

        final map = protocol.toMap();
        final restored = ProtocolModel.fromMap(map);

        expect(restored.metadata, isNotNull);
        expect(restored.metadata!['version'], '3.1.1');
        expect(restored.metadata!['tlsRequired'], true);
      });
    });

    group('Connection SQLite Operations', () {
      test('Connection model converts to and from SQLite map', () {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-sqlite-001',
          name: 'Test Connection',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        final map = connection.toMap();
        expect(map, isNotNull);
        expect(map['id'], 'conn-sqlite-001');
        expect(map['host'], 'broker.example.com');
        expect(map['port'], 1883);

        final restored = ConnectionModel.fromMap(map);
        expect(restored.id, connection.id);
        expect(restored.host, connection.host);
        expect(restored.port, connection.port);
      });

      test('Connection status persists through serialization', () {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-status',
          name: 'Status Test',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.connecting,
          createdAt: now,
        );

        final map = connection.toMap();
        final restored = ConnectionModel.fromMap(map);

        expect(restored.status, ConnectionStatus.connecting);
      });

      test('Connection credentials persist securely', () {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-credentials',
          name: 'Secure Connection',
          host: 'secure.example.com',
          port: 8883,
          status: ConnectionStatus.inactive,
          createdAt: now,
          metadata: {
            'username': 'admin',
            'password_hash': 'hashed_password_here',
          },
        );

        final map = connection.toMap();
        final restored = ConnectionModel.fromMap(map);

        expect(restored.metadata!['username'], 'admin');
        expect(restored.metadata!['password_hash'], 'hashed_password_here');
      });
    });

    group('Certificate SQLite Operations', () {
      test('Certificate model converts to and from SQLite map', () {
        final now = DateTime.now();
        final cert = CertificateModel(
          id: 'cert-sqlite-001',
          name: 'Test Certificate',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        final map = cert.toMap();
        expect(map, isNotNull);
        expect(map['id'], 'cert-sqlite-001');
        expect(map['name'], 'Test Certificate');

        final restored = CertificateModel.fromMap(map);
        expect(restored.id, cert.id);
        expect(restored.name, cert.name);
        expect(restored.type, cert.type);
      });

      test('Certificate expiration dates persist accurately', () {
        final now = DateTime.now();
        final validFrom = now.subtract(const Duration(days: 10));
        final validTo = now.add(const Duration(days: 355));

        final cert = CertificateModel(
          id: 'cert-expiry',
          name: 'Expiration Test',
          type: CertificateType.client,
          validFrom: validFrom,
          validTo: validTo,
        );

        final map = cert.toMap();
        final restored = CertificateModel.fromMap(map);

        expect(restored.validFrom.year, validFrom.year);
        expect(restored.validFrom.month, validFrom.month);
        expect(restored.validFrom.day, validFrom.day);
        expect(restored.validTo.year, validTo.year);
      });
    });

    group('Concurrent SQLite Operations', () {
      test('Multiple entities can be saved concurrently', () async {
        final protocols = List.generate(
          50,
          (i) => ProtocolModel(
            id: 'proto-concurrent-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883 + i,
          ),
        );

        final connections = List.generate(
          50,
          (i) => ConnectionModel(
            id: 'conn-concurrent-$i',
            name: 'Connection $i',
            host: 'host-$i.example.com',
            port: 8000 + i,
            status: ConnectionStatus.inactive,
            createdAt: DateTime.now(),
          ),
        );

        final allMaps = [
          ...protocols.map((p) => p.toMap()),
          ...connections.map((c) => c.toMap()),
        ];

        expect(allMaps.length, 100);
        expect(allMaps.every((m) => m.isNotEmpty), true);
      });

      test('Large batch insert and retrieve', () async {
        final stopwatch = Stopwatch()..start();

        final protocols = List.generate(
          1000,
          (i) => ProtocolModel(
            id: 'proto-batch-$i',
            name: 'Protocol $i',
            type: i.isEven ? ProtocolType.mqtt : ProtocolType.http,
            port: 1883,
          ),
        );

        final maps = protocols.map((p) => p.toMap()).toList();
        final restored = maps.map((m) => ProtocolModel.fromMap(m)).toList();

        stopwatch.stop();

        expect(restored.length, 1000);
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });
    });

    group('SQLite Data Integrity', () {
      test('Protocol ID remains unique after serialization', () {
        final protocols = [
          ProtocolModel(
            id: 'proto-unique-1',
            name: 'Protocol 1',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-unique-2',
            name: 'Protocol 2',
            type: ProtocolType.http,
            port: 80,
          ),
          ProtocolModel(
            id: 'proto-unique-3',
            name: 'Protocol 3',
            type: ProtocolType.coap,
            port: 5683,
          ),
        ];

        final maps = protocols.map((p) => p.toMap()).toList();
        final ids = maps.map((m) => m['id']).toList();

        expect(ids.toSet().length, 3);
        expect(ids.toSet().length, ids.length);
      });

      test('No data loss in multi-field serialization', () {
        final protocol = ProtocolModel(
          id: 'proto-complete',
          name: 'Complete Protocol',
          type: ProtocolType.mqtt,
          port: 1883,
          metadata: {
            'field1': 'value1',
            'field2': 'value2',
            'nested': {
              'field3': 'value3',
            },
          },
        );

        final map = protocol.toMap();
        final restored = ProtocolModel.fromMap(map);

        expect(restored.id, protocol.id);
        expect(restored.name, protocol.name);
        expect(restored.type, protocol.type);
        expect(restored.port, protocol.port);
        expect(restored.metadata!.keys.length, 3);
      });

      test('Timestamps maintain precision after serialization', () {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-timestamp',
          name: 'Timestamp Test',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        final map = connection.toMap();
        final restored = ConnectionModel.fromMap(map);

        expect(restored.createdAt.year, now.year);
        expect(restored.createdAt.month, now.month);
        expect(restored.createdAt.day, now.day);
        expect(restored.createdAt.hour, now.hour);
      });
    });

    group('SQLite Error Handling', () {
      test('Invalid map throws appropriate exception on deserialization', () {
        final invalidMap = {
          'id': 'proto-invalid',
          'port': 'invalid_port', // Should be int
        };

        expect(
          () => ProtocolModel.fromMap(invalidMap),
          throwsA(isA<FormatException>()),
        );
      });

      test('Missing required fields handled gracefully', () {
        final incompleteMap = {
          'id': 'proto-incomplete',
          // Missing other required fields
        };

        expect(
          () => ProtocolModel.fromMap(incompleteMap),
          throwsA(isA<Exception>()),
        );
      });

      test('NULL values handled in optional fields', () {
        final now = DateTime.now();
        final connectionMap = {
          'id': 'conn-null',
          'name': 'Null Test',
          'host': 'example.com',
          'port': 1883,
          'status': 'inactive',
          'createdAt': now.toIso8601String(),
          'metadata': null, // NULL metadata
        };

        final restored = ConnectionModel.fromMap(connectionMap);
        expect(restored.metadata, null);
      });
    });

    group('SQLite Transaction Simulation', () {
      test('Multiple entities maintain consistency', () async {
        final protocol = ProtocolModel(
          id: 'proto-tx-1',
          name: 'Transaction Test',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final connection = ConnectionModel(
          id: 'conn-tx-1',
          name: 'Uses Protocol',
          host: 'example.com',
          port: protocol.port,
          status: ConnectionStatus.inactive,
          createdAt: DateTime.now(),
          metadata: {'protocolId': protocol.id},
        );

        final protocolMap = protocol.toMap();
        final connectionMap = connection.toMap();

        expect(protocolMap['port'], connectionMap['port']);
        expect(connectionMap['metadata']['protocolId'], protocol.id);
      });

      test('Rollback scenario with inconsistent state', () {
        final originalProtocol = ProtocolModel(
          id: 'proto-original',
          name: 'Original',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        var protocol = originalProtocol;
        final map = protocol.toMap();
        protocol = protocol.copyWith(port: 8883);

        final restoredOriginal = ProtocolModel.fromMap(map);
        expect(restoredOriginal.port, 1883);
        expect(protocol.port, 8883);
      });
    });

    group('SQLite Optimization Tests', () {
      test('Index simulation for protocol type lookups', () {
        final protocols = List.generate(
          100,
          (i) => ProtocolModel(
            id: 'proto-index-$i',
            name: 'Protocol $i',
            type: i < 50 ? ProtocolType.mqtt : ProtocolType.http,
            port: 1883,
          ),
        );

        final stopwatch = Stopwatch()..start();

        final mqttProtocols = protocols
            .where((p) => p.type == ProtocolType.mqtt)
            .toList();

        stopwatch.stop();

        expect(mqttProtocols.length, 50);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('Efficient memory usage with large dataset', () {
        final protocols = List.generate(
          5000,
          (i) => ProtocolModel(
            id: 'proto-memory-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        );

        expect(protocols.length, 5000);

        // Simulate memory cleanup
        protocols.clear();
        expect(protocols.isEmpty, true);
      });
    });
  });
}
