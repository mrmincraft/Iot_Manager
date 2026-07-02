import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/connection.dart';

void main() {
  group('Connection Entity Tests', () {
    group('Connection Creation', () {
      test('creates connection with all parameters', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test Connection',
          status: ConnectionStatus.active,
          host: 'mqtt.example.com',
          port: 1883,
          username: 'user',
          password: 'password',
          metadata: {'tls': true},
          createdAt: DateTime(2024, 1, 1),
          lastConnectedAt: DateTime(2024, 1, 2),
        );

        expect(connection.id, 'conn-001');
        expect(connection.protocolId, 'mqtt-001');
        expect(connection.name, 'Test Connection');
        expect(connection.status, ConnectionStatus.active);
        expect(connection.host, 'mqtt.example.com');
        expect(connection.port, 1883);
        expect(connection.username, 'user');
        expect(connection.password, 'password');
      });

      test('creates connection with minimal parameters', () {
        final now = DateTime.now();
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Basic Connection',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        expect(connection.id, 'conn-001');
        expect(connection.protocolId, 'mqtt-001');
        expect(connection.name, 'Basic Connection');
        expect(connection.host, 'localhost');
        expect(connection.port, 1883);
        expect(connection.username, isNull);
        expect(connection.password, isNull);
      });

      test('validates connection ID is not empty', () {
        expect(
          () => Connection(
            id: '',
            protocolId: 'mqtt-001',
            name: 'Test',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 1883,
            createdAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates connection name is not empty', () {
        expect(
          () => Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: '',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 1883,
            createdAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates host is not empty', () {
        expect(
          () => Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Test',
            status: ConnectionStatus.active,
            host: '',
            port: 1883,
            createdAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates port is in valid range', () {
        expect(
          () => Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Test',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 0,
            createdAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );

        expect(
          () => Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Test',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 65536,
            createdAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('ConnectionStatus Enum', () {
      test('has active status', () {
        expect(ConnectionStatus.active, ConnectionStatus.active);
      });

      test('has inactive status', () {
        expect(ConnectionStatus.inactive, ConnectionStatus.inactive);
      });

      test('has connecting status', () {
        expect(ConnectionStatus.connecting, ConnectionStatus.connecting);
      });

      test('has failed status', () {
        expect(ConnectionStatus.failed, ConnectionStatus.failed);
      });

      test('all statuses are distinct', () {
        final statuses = {
          ConnectionStatus.active,
          ConnectionStatus.inactive,
          ConnectionStatus.connecting,
          ConnectionStatus.failed,
        };
        expect(statuses.length, 4);
      });
    });

    group('Connection copyWith', () {
      test('creates copy with changed values', () {
        final original = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Original Name',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime(2024, 1, 1),
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          status: ConnectionStatus.active,
        );

        expect(updated.id, 'conn-001'); // Unchanged
        expect(updated.name, 'Updated Name');
        expect(updated.status, ConnectionStatus.active);
        expect(updated.protocolId, 'mqtt-001'); // Unchanged
      });

      test('copyWith preserves original object', () {
        final original = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Original',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        original.copyWith(name: 'Updated');

        expect(original.name, 'Original'); // Unchanged
      });

      test('copyWith can change credentials', () {
        final original = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Connection',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          username: 'newuser',
          password: 'newpass',
        );

        expect(updated.username, 'newuser');
        expect(updated.password, 'newpass');
        expect(original.username, isNull); // Original unchanged
      });
    });

    group('Connection Equality', () {
      test('connections with same values are equal', () {
        final now = DateTime(2024, 1, 1);

        final connection1 = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        final connection2 = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        expect(connection1, connection2);
      });

      test('connections with different values are not equal', () {
        final now = DateTime.now();

        final connection1 = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        final connection2 = Connection(
          id: 'conn-002', // Different ID
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        expect(connection1, isNot(connection2));
      });

      test('hash codes are equal for equal connections', () {
        final now = DateTime(2024, 1, 1);

        final connection1 = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        final connection2 = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        expect(connection1.hashCode, connection2.hashCode);
      });
    });

    group('Connection Status Management', () {
      test('connection can transition from inactive to connecting', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final connecting = connection.copyWith(status: ConnectionStatus.connecting);
        expect(connecting.status, ConnectionStatus.connecting);
      });

      test('connection can transition from connecting to active', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.connecting,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final active = connection.copyWith(
          status: ConnectionStatus.active,
          lastConnectedAt: DateTime.now(),
        );

        expect(active.status, ConnectionStatus.active);
        expect(active.lastConnectedAt, isNotNull);
      });

      test('connection can fail during connection', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.connecting,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final failed = connection.copyWith(status: ConnectionStatus.failed);
        expect(failed.status, ConnectionStatus.failed);
      });
    });

    group('Connection Credentials', () {
      test('connection can be created without credentials', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.username, isNull);
        expect(connection.password, isNull);
      });

      test('connection can store credentials', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          username: 'testuser',
          password: 'testpass',
          createdAt: DateTime.now(),
        );

        expect(connection.username, 'testuser');
        expect(connection.password, 'testpass');
      });

      test('credentials can be updated via copyWith', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final withCredentials = connection.copyWith(
          username: 'newuser',
          password: 'newpass',
        );

        expect(withCredentials.username, 'newuser');
        expect(withCredentials.password, 'newpass');
      });
    });

    group('Connection Timestamps', () {
      test('created at timestamp is set', () {
        final now = DateTime.now();
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: now,
        );

        expect(connection.createdAt, now);
      });

      test('last connected at is optional', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.lastConnectedAt, isNull);
      });

      test('last connected at can be updated', () {
        final createdAt = DateTime(2024, 1, 1);
        final connectedAt = DateTime(2024, 1, 2);

        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: createdAt,
          lastConnectedAt: connectedAt,
        );

        expect(connection.lastConnectedAt, connectedAt);
      });
    });

    group('Connection Host and Port', () {
      test('supports hostname', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'mqtt.example.com',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.host, 'mqtt.example.com');
      });

      test('supports IP address', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: '192.168.1.100',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.host, '192.168.1.100');
      });

      test('supports localhost', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.host, 'localhost');
      });

      test('supports various ports', () {
        final ports = [80, 443, 1883, 8883, 5683, 8080];

        for (final port in ports) {
          final connection = Connection(
            id: 'conn-$port',
            protocolId: 'mqtt-001',
            name: 'Test',
            status: ConnectionStatus.inactive,
            host: 'localhost',
            port: port,
            createdAt: DateTime.now(),
          );

          expect(connection.port, port);
        }
      });
    });

    group('Connection Metadata', () {
      test('metadata is optional', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        expect(connection.metadata, {});
      });

      test('metadata can store connection settings', () {
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          metadata: {
            'tls': true,
            'certificate': 'cert-001',
            'keepAlive': 60,
            'timeout': 30,
          },
          createdAt: DateTime.now(),
        );

        expect(connection.metadata['tls'], true);
        expect(connection.metadata['certificate'], 'cert-001');
        expect(connection.metadata['keepAlive'], 60);
      });
    });
  });
}
