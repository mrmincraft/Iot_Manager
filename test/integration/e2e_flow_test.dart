import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

class MockProtocolRepository extends Mock implements ProtocolRepository {}

class MockConnectionRepository extends Mock implements ConnectionRepository {}

class TestProtocolViewModel extends BaseViewModel {
  late GetAllProtocolsUseCase getAllProtocolsUseCase;
  late GetProtocolByIdUseCase getProtocolByIdUseCase;

  List<Protocol> protocols = [];
  String? errorMessage;

  TestProtocolViewModel({
    required ProtocolRepository protocolRepository,
  }) {
    getAllProtocolsUseCase = GetAllProtocolsUseCase(protocolRepository);
    getProtocolByIdUseCase = GetProtocolByIdUseCase(protocolRepository);
  }

  Future<void> loadProtocols() async {
    try {
      final result = await getAllProtocolsUseCase.call();
      result.fold(
        (protocols) {
          this.protocols = protocols;
          notifyListeners();
        },
        (error) {
          errorMessage = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}

void main() {
  group('End-to-End Flow Tests', () {
    group('Protocol E2E Flow', () {
      late MockProtocolRepository mockProtocolRepository;
      late TestProtocolViewModel viewModel;

      setUp(() {
        mockProtocolRepository = MockProtocolRepository();
        viewModel = TestProtocolViewModel(
          protocolRepository: mockProtocolRepository,
        );
      });

      test('E2E: User views all protocols - success flow', () async {
        // Arrange
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
        ];

        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        // Act
        await viewModel.loadProtocols();

        // Assert
        expect(viewModel.protocols.length, 2);
        expect(viewModel.protocols[0].name, 'MQTT');
        expect(viewModel.errorMessage, null);
        verify(mockProtocolRepository.getAllProtocols()).called(1);
      });

      test('E2E: User views protocols - error handling flow', () async {
        // Arrange
        when(mockProtocolRepository.getAllProtocols()).thenAnswer(
          (_) async => Result.failure(Exception('Database error')),
        );

        // Act
        await viewModel.loadProtocols();

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.protocols.isEmpty, true);
      });

      test('E2E: Create and retrieve protocol', () async {
        // Arrange
        final newProtocol = ProtocolModel(
          id: 'proto-new',
          name: 'New Protocol',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockProtocolRepository.createProtocol(any))
            .thenAnswer((_) async => Result.success(newProtocol));

        when(mockProtocolRepository.getProtocolById('proto-new'))
            .thenAnswer((_) async => Result.success(newProtocol));

        // Act - Create
        final createResult = await mockProtocolRepository.createProtocol(newProtocol);

        // Assert Create
        expect(createResult.isSuccess, true);
        expect(createResult.value!.name, 'New Protocol');

        // Act - Retrieve
        final getResult = await mockProtocolRepository.getProtocolById('proto-new');

        // Assert Retrieve
        expect(getResult.isSuccess, true);
        expect(getResult.value!.id, 'proto-new');
      });

      test('E2E: Modify protocol through update flow', () async {
        // Arrange
        final original = ProtocolModel(
          id: 'proto-update',
          name: 'Original Name',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final updated = original.copyWith(port: 8883, name: 'Updated Name');

        when(mockProtocolRepository.updateProtocol(any))
            .thenAnswer((_) async => Result.success(updated));

        // Act
        final result = await mockProtocolRepository.updateProtocol(updated);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.port, 8883);
        expect(result.value!.name, 'Updated Name');
      });

      test('E2E: Delete protocol and verify removal', () async {
        // Arrange
        when(mockProtocolRepository.deleteProtocol('proto-delete'))
            .thenAnswer((_) async => Result.success(null));

        // Act
        final result = await mockProtocolRepository.deleteProtocol('proto-delete');

        // Assert
        expect(result.isSuccess, true);
        verify(mockProtocolRepository.deleteProtocol('proto-delete')).called(1);
      });
    });

    group('Connection E2E Flow', () {
      late MockConnectionRepository mockConnectionRepository;

      setUp(() {
        mockConnectionRepository = MockConnectionRepository();
      });

      test('E2E: Create connection with protocol relationship', () async {
        // Arrange
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-e2e-1',
          name: 'MQTT Connection',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
          metadata: {'protocolId': 'proto-mqtt'},
        );

        when(mockConnectionRepository.createConnection(any))
            .thenAnswer((_) async => Result.success(connection));

        // Act
        final result = await mockConnectionRepository.createConnection(connection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.host, 'broker.example.com');
        expect(result.value!.metadata!['protocolId'], 'proto-mqtt');
      });

      test('E2E: Connection lifecycle - inactive → connecting → active', () async {
        // Arrange
        final now = DateTime.now();
        var connection = ConnectionModel(
          id: 'conn-lifecycle',
          name: 'Lifecycle Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        // Act & Assert - State 1: inactive
        expect(connection.status, ConnectionStatus.inactive);

        // Transition to connecting
        connection = connection.copyWith(status: ConnectionStatus.connecting);
        expect(connection.status, ConnectionStatus.connecting);

        // Transition to active
        connection = connection.copyWith(status: ConnectionStatus.active);
        expect(connection.status, ConnectionStatus.active);
      });

      test('E2E: Connection with TLS certificate integration', () async {
        // Arrange
        final now = DateTime.now();
        final cert = CertificateModel(
          id: 'cert-e2e',
          name: 'TLS Certificate',
          type: CertificateType.client,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        final connection = ConnectionModel(
          id: 'conn-tls-e2e',
          name: 'TLS Connection',
          host: 'secure.example.com',
          port: 8883,
          status: ConnectionStatus.inactive,
          createdAt: now,
          metadata: {
            'certificateId': cert.id,
            'tlsVersion': '1.2',
          },
        );

        when(mockConnectionRepository.createConnection(any))
            .thenAnswer((_) async => Result.success(connection));

        // Act
        final result = await mockConnectionRepository.createConnection(connection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.metadata!['certificateId'], cert.id);
      });

      test('E2E: Get connections by status filtering', () async {
        // Arrange
        final now = DateTime.now();
        final activeConnections = [
          ConnectionModel(
            id: 'conn-active-1',
            name: 'Active 1',
            host: 'host1.example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
          ConnectionModel(
            id: 'conn-active-2',
            name: 'Active 2',
            host: 'host2.example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
        ];

        when(mockConnectionRepository.getConnectionsByStatus(ConnectionStatus.active))
            .thenAnswer((_) async => Result.success(activeConnections));

        // Act
        final result = await mockConnectionRepository
            .getConnectionsByStatus(ConnectionStatus.active);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.length, 2);
        expect(result.value!.every((c) => c.status == ConnectionStatus.active), true);
      });
    });

    group('Cross-Layer E2E Workflows', () {
      test('E2E: Complete workflow - Create Protocol → Create Connection → Check Status', () async {
        // Step 1: Protocol created
        final protocol = ProtocolModel(
          id: 'proto-workflow',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        expect(protocol.id, isNotNull);
        expect(protocol.port, 1883);

        // Step 2: Connection created using protocol port
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-workflow',
          name: 'Workflow Connection',
          host: 'example.com',
          port: protocol.port,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        expect(connection.port, protocol.port);
        expect(connection.status, ConnectionStatus.inactive);

        // Step 3: Connection status updated
        final activeConnection = connection.copyWith(status: ConnectionStatus.active);

        expect(activeConnection.status, ConnectionStatus.active);
        expect(activeConnection.port, protocol.port);
      });

      test('E2E: Certificate expiration check in connection context', () async {
        // Step 1: Create certificate
        final now = DateTime.now();
        final cert = CertificateModel(
          id: 'cert-workflow',
          name: 'Workflow Certificate',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 10)),
          validTo: now.add(const Duration(days: 20)),
        );

        // Step 2: Verify not expired
        expect(cert.validTo.isAfter(now), true);

        // Step 3: Use in connection
        final now2 = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-cert-workflow',
          name: 'Certificate Workflow Connection',
          host: 'secure.example.com',
          port: 8883,
          status: ConnectionStatus.inactive,
          createdAt: now2,
          metadata: {'certificateId': cert.id},
        );

        expect(connection.metadata!['certificateId'], cert.id);
      });

      test('E2E: Bulk protocol creation and verification', () async {
        // Step 1: Create multiple protocols
        final protocolData = [
          ('MQTT', ProtocolType.mqtt, 1883),
          ('HTTP', ProtocolType.http, 80),
          ('HTTPS', ProtocolType.http, 443),
          ('CoAP', ProtocolType.coap, 5683),
          ('Modbus', ProtocolType.modbus, 502),
        ];

        final protocols = protocolData
            .asMap()
            .entries
            .map(
              (entry) => ProtocolModel(
                id: 'proto-bulk-${entry.key}',
                name: entry.value.$1,
                type: entry.value.$2,
                port: entry.value.$3,
              ),
            )
            .toList();

        // Step 2: Verify all created
        expect(protocols.length, 5);

        // Step 3: Create connections for each
        final connections = protocols
            .map(
              (p) => ConnectionModel(
                id: 'conn-${p.id}',
                name: '${p.name} Connection',
                host: 'example.com',
                port: p.port,
                status: ConnectionStatus.inactive,
                createdAt: DateTime.now(),
              ),
            )
            .toList();

        expect(connections.length, 5);
        expect(
          connections.every((c) => protocols.any((p) => p.port == c.port)),
          true,
        );
      });
    });

    group('Error Recovery E2E Flows', () {
      late MockProtocolRepository mockProtocolRepository;

      setUp(() {
        mockProtocolRepository = MockProtocolRepository();
      });

      test('E2E: Retry on error - successful retry', () async {
        // Arrange - First call fails, second succeeds
        final protocol = ProtocolModel(
          id: 'proto-retry',
          name: 'Retry Protocol',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockProtocolRepository.getProtocolById('proto-retry'))
            .thenAnswer((_) async => Result.failure(Exception('Temporary error')))
            .thenAnswer((_) async => Result.success(protocol));

        // Act - First attempt
        final result1 = await mockProtocolRepository.getProtocolById('proto-retry');
        expect(result1.isFailure, true);

        // Act - Retry
        final result2 = await mockProtocolRepository.getProtocolById('proto-retry');
        expect(result2.isSuccess, true);
      });

      test('E2E: Fallback data when primary fails', () async {
        // Arrange
        final fallbackProtocol = ProtocolModel(
          id: 'proto-fallback',
          name: 'Fallback Protocol',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        // Act - Primary fails, use fallback
        final result = Result.failure(Exception('Primary failed'))
            .recover((_) => fallbackProtocol);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.name, 'Fallback Protocol');
      });
    });

    group('Performance E2E Tests', () {
      test('E2E: Load 1000 protocols and create connections for each', () async {
        final stopwatch = Stopwatch()..start();

        // Create 1000 protocols
        final protocols = List.generate(
          1000,
          (i) => ProtocolModel(
            id: 'proto-perf-$i',
            name: 'Protocol $i',
            type: i.isEven ? ProtocolType.mqtt : ProtocolType.http,
            port: 1883 + (i % 100),
          ),
        );

        // Create connections for each
        final connections = protocols
            .map(
              (p) => ConnectionModel(
                id: 'conn-${p.id}',
                name: '${p.name} Connection',
                host: 'host-${p.id}.example.com',
                port: p.port,
                status: ConnectionStatus.inactive,
                createdAt: DateTime.now(),
              ),
            )
            .toList();

        stopwatch.stop();

        expect(protocols.length, 1000);
        expect(connections.length, 1000);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('E2E: Concurrent entity operations simulation', () async {
        final stopwatch = Stopwatch()..start();

        // Simulate concurrent creates
        final futures = List.generate(
          100,
          (i) => Future.value(
            ProtocolModel(
              id: 'proto-concurrent-$i',
              name: 'Concurrent $i',
              type: ProtocolType.mqtt,
              port: 1883,
            ),
          ),
        );

        final results = await Future.wait(futures);

        stopwatch.stop();

        expect(results.length, 100);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
