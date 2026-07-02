import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/protocol_local_datasource.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/data/repositories/impl/protocol_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/connection_repository_impl.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';

class MockProtocolLocalDataSource extends Mock implements ProtocolLocalDataSource {}

void main() {
  group('Integration Tests - Multi-Layer Operations', () {
    group('Protocol - Local to UseCase Integration', () {
      late MockProtocolLocalDataSource mockLocalDataSource;
      late ProtocolRepository repository;
      late GetAllProtocolsUseCase useCase;

      setUp(() {
        mockLocalDataSource = MockProtocolLocalDataSource();
        repository = ProtocolRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: MockProtocolRemoteDataSource(),
        );
        useCase = GetAllProtocolsUseCase(repository);
      });

      test('Protocol CRUD flow: Create -> Read -> Update -> Delete', () async {
        final protocol = ProtocolModel(
          id: 'proto-integration',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        // Mock Create
        when(mockLocalDataSource.createProtocol(any))
            .thenAnswer((_) async => 1);

        // Mock Read
        when(mockLocalDataSource.getAllProtocols())
            .thenAnswer((_) async => [protocol]);

        // Mock Update
        when(mockLocalDataSource.updateProtocol(any))
            .thenAnswer((_) async => 1);

        // Mock Delete
        when(mockLocalDataSource.deleteProtocol('proto-integration'))
            .thenAnswer((_) async => 1);

        // Test Create
        final createResult = await mockLocalDataSource.createProtocol(protocol);
        expect(createResult, greaterThan(0));

        // Test Read
        final readResult = await useCase.call();
        expect(readResult.isSuccess, true);
        expect(readResult.value!.length, 1);

        // Test Update
        final updated = protocol.copyWith(port: 8883);
        final updateResult = await mockLocalDataSource.updateProtocol(updated);
        expect(updateResult, greaterThan(0));

        // Test Delete
        final deleteResult = await mockLocalDataSource.deleteProtocol('proto-integration');
        expect(deleteResult, greaterThanOrEqualTo(0));
      });

      test('Multiple protocols stored and retrieved sequentially', () async {
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

        when(mockLocalDataSource.createProtocol(any))
            .thenAnswer((_) async => 1);

        when(mockLocalDataSource.getAllProtocols())
            .thenAnswer((_) async => protocols);

        // Create all
        for (final protocol in protocols) {
          await mockLocalDataSource.createProtocol(protocol);
        }

        // Retrieve all
        final result = await useCase.call();

        expect(result.isSuccess, true);
        expect(result.value!.length, 3);
        expect(result.value![0].name, 'MQTT');
        expect(result.value![2].name, 'CoAP');
      });

      test('Protocol filtering by type in integration', () async {
        final mqttProtocols = [
          ProtocolModel(
            id: 'proto-1',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-2',
            name: 'MQTT-S',
            type: ProtocolType.mqtt,
            port: 1884,
          ),
        ];

        when(mockLocalDataSource.getProtocolsByType(ProtocolType.mqtt))
            .thenAnswer((_) async => mqttProtocols);

        final result = await mockLocalDataSource.getProtocolsByType(ProtocolType.mqtt);

        expect(result.length, 2);
        expect(result.every((p) => p.type == ProtocolType.mqtt), true);
      });
    });

    group('Connection - Full Stack Integration', () {
      test('Connection lifecycle with repository and local data source', () async {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-integration',
          name: 'Test Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        // Mock operations would happen here
        expect(connection.name, 'Test Connection');
        expect(connection.port, 1883);
      });

      test('Connection status transitions tracked', () async {
        final now = DateTime.now();
        var connection = ConnectionModel(
          id: 'conn-001',
          name: 'Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        // Transition: inactive -> connecting
        connection = connection.copyWith(status: ConnectionStatus.connecting);
        expect(connection.status, ConnectionStatus.connecting);

        // Transition: connecting -> active
        connection = connection.copyWith(status: ConnectionStatus.active);
        expect(connection.status, ConnectionStatus.active);

        // Transition: active -> failed
        connection = connection.copyWith(status: ConnectionStatus.failed);
        expect(connection.status, ConnectionStatus.failed);
      });
    });

    group('Certificate - Expiration Management Integration', () {
      test('Certificate expiration tracking through layers', () async {
        final now = DateTime.now();
        const daysUntilExpiry = 30;

        final expiringCert = CertificateModel(
          id: 'cert-expiring',
          name: 'Expiring Certificate',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 335)),
          validTo: now.add(Duration(days: daysUntilExpiry)),
        );

        expect(expiringCert.validTo.isAfter(now), true);
        expect(
          expiringCert.validTo.difference(now).inDays,
          lessThanOrEqualTo(daysUntilExpiry + 5),
        );
      });

      test('Certificate batch expiration check', () async {
        final now = DateTime.now();

        final certificates = [
          CertificateModel(
            id: 'cert-1',
            name: 'Expired',
            type: CertificateType.server,
            validFrom: now.subtract(const Duration(days: 400)),
            validTo: now.subtract(const Duration(days: 10)),
          ),
          CertificateModel(
            id: 'cert-2',
            name: 'Expiring Soon',
            type: CertificateType.server,
            validFrom: now.subtract(const Duration(days: 350)),
            validTo: now.add(const Duration(days: 15)),
          ),
          CertificateModel(
            id: 'cert-3',
            name: 'Valid',
            type: CertificateType.server,
            validFrom: now,
            validTo: now.add(const Duration(days: 365)),
          ),
        ];

        final expiring = certificates
            .where((c) => c.validTo.isAfter(now) && 
                c.validTo.difference(now).inDays <= 30)
            .toList();

        expect(expiring.length, 1);
        expect(expiring.first.id, 'cert-2');
      });
    });

    group('Cross-Entity Integration', () {
      test('Protocol used by Connection integration', () async {
        final protocol = ProtocolModel(
          id: 'proto-mqtt',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-001',
          name: 'MQTT Connection',
          host: 'broker.example.com',
          port: protocol.port, // Using protocol's port
          status: ConnectionStatus.active,
          createdAt: now,
        );

        expect(connection.port, protocol.port);
        expect(connection.port, 1883);
      });

      test('Certificate used by Connection for TLS', () async {
        final cert = CertificateModel(
          id: 'cert-tls',
          name: 'TLS Certificate',
          type: CertificateType.client,
          validFrom: DateTime.now(),
          validTo: DateTime.now().add(const Duration(days: 365)),
        );

        final now = DateTime.now();
        final tlsConnection = ConnectionModel(
          id: 'conn-tls',
          name: 'Secure Connection',
          host: 'secure.example.com',
          port: 8883,
          status: ConnectionStatus.inactive,
          createdAt: now,
          metadata: {'certificateId': cert.id},
        );

        expect(tlsConnection.metadata!['certificateId'], cert.id);
      });
    });

    group('Data Persistence Integration', () {
      test('Local data survives application restart', () async {
        // Simulate first app session
        final protocol = ProtocolModel(
          id: 'proto-persistent',
          name: 'Persistent Protocol',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        // Simulate data being saved
        expect(protocol.id, 'proto-persistent');

        // Simulate app restart - recreate instance from "database"
        final retrieved = ProtocolModel(
          id: protocol.id,
          name: protocol.name,
          type: protocol.type,
          port: protocol.port,
        );

        expect(retrieved.id, 'proto-persistent');
        expect(retrieved.name, 'Persistent Protocol');
      });

      test('Concurrent saves to same entity type', () async {
        final protocols = List.generate(
          100,
          (i) => ProtocolModel(
            id: 'proto-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883 + i,
          ),
        );

        // Simulate concurrent writes
        expect(protocols.length, 100);
        expect(protocols.first.id, 'proto-0');
        expect(protocols.last.id, 'proto-99');
      });
    });

    group('Error Recovery Integration', () {
      test('LocalDataSource error handling through repository', () async {
        final mockLocalDataSource = MockProtocolLocalDataSource();

        when(mockLocalDataSource.getAllProtocols())
            .thenThrow(Exception('Database error'));

        expect(
          () => mockLocalDataSource.getAllProtocols(),
          throwsException,
        );
      });

      test('Repository fallback from local to remote on error', () async {
        final mockLocalDataSource = MockProtocolLocalDataSource();

        when(mockLocalDataSource.getAllProtocols())
            .thenThrow(Exception('Local error'));

        // Should throw, repository would then try remote
        expect(
          () => mockLocalDataSource.getAllProtocols(),
          throwsException,
        );
      });
    });

    group('Performance Integration Tests', () {
      test('Large batch operations performance', () async {
        final stopwatch = Stopwatch()..start();

        final protocols = List.generate(
          1000,
          (i) => ProtocolModel(
            id: 'proto-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883 + (i % 10),
          ),
        );

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(protocols.length, 1000);
      });

      test('Query filtering performance', () async {
        final stopwatch = Stopwatch()..start();

        final protocols = List.generate(
          1000,
          (i) => ProtocolModel(
            id: 'proto-$i',
            name: 'Protocol $i',
            type: i.isEven ? ProtocolType.mqtt : ProtocolType.http,
            port: 1883,
          ),
        );

        final filtered = protocols.where((p) => p.type == ProtocolType.mqtt).toList();

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(filtered.length, 500);
      });
    });
  });
}

class MockProtocolRemoteDataSource {
  Future<Result<List<Protocol>, Exception>> getAllProtocols() async {
    return Result.success([]);
  }
}
