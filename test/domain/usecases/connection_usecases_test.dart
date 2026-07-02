import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';

// Mock Repository
class MockConnectionRepository extends Mock implements ConnectionRepository {}

void main() {
  group('Connection UseCases Tests', () {
    late MockConnectionRepository mockRepository;

    setUp(() {
      mockRepository = MockConnectionRepository();
    });

    group('GetAllConnectionsUseCase', () {
      test('returns list of connections on success', () async {
        // Arrange
        final mockConnections = [
          Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Connection 1',
            status: ConnectionStatus.active,
            host: 'mqtt.example.com',
            port: 1883,
            createdAt: DateTime(2024, 1, 1),
          ),
          Connection(
            id: 'conn-002',
            protocolId: 'http-001',
            name: 'Connection 2',
            status: ConnectionStatus.inactive,
            host: 'api.example.com',
            port: 80,
            createdAt: DateTime(2024, 1, 2),
          ),
        ];

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(mockConnections));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, mockConnections);
        expect(result.value!.length, 2);
        verify(mockRepository.getAllConnections()).called(1);
      });

      test('returns error on repository failure', () async {
        // Arrange
        final error = Exception('Database error');
        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });

      test('returns empty list when no connections exist', () async {
        // Arrange
        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success([]));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, isEmpty);
      });
    });

    group('GetConnectionByIdUseCase', () {
      test('returns connection by id on success', () async {
        // Arrange
        const connectionId = 'conn-001';
        final mockConnection = Connection(
          id: connectionId,
          protocolId: 'mqtt-001',
          name: 'Test Connection',
          status: ConnectionStatus.active,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        when(mockRepository.getConnectionById(connectionId))
            .thenAnswer((_) async => Result.success(mockConnection));

        final useCase = GetConnectionByIdUseCase(mockRepository);

        // Act
        final result = await useCase.call(connectionId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, mockConnection);
        expect(result.value!.id, connectionId);
      });

      test('returns error when connection not found', () async {
        // Arrange
        const connectionId = 'nonexistent';
        final error = Exception('Connection not found');

        when(mockRepository.getConnectionById(connectionId))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetConnectionByIdUseCase(mockRepository);

        // Act
        final result = await useCase.call(connectionId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('CreateConnectionUseCase', () {
      test('creates connection successfully', () async {
        // Arrange
        final newConnection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'New Connection',
          status: ConnectionStatus.inactive,
          host: 'mqtt.example.com',
          port: 1883,
          createdAt: DateTime.now(),
        );

        when(mockRepository.createConnection(newConnection))
            .thenAnswer((_) async => Result.success(newConnection));

        final useCase = CreateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(newConnection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, newConnection);
        verify(mockRepository.createConnection(newConnection)).called(1);
      });

      test('returns error when creation fails', () async {
        // Arrange
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );
        final error = Exception('Creation failed');

        when(mockRepository.createConnection(connection))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = CreateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(connection);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('UpdateConnectionUseCase', () {
      test('updates connection successfully', () async {
        // Arrange
        final updatedConnection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Updated Name',
          status: ConnectionStatus.active,
          host: 'mqtt.updated.com',
          port: 8883,
          createdAt: DateTime(2024, 1, 1),
          lastConnectedAt: DateTime.now(),
        );

        when(mockRepository.updateConnection(updatedConnection))
            .thenAnswer((_) async => Result.success(updatedConnection));

        final useCase = UpdateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(updatedConnection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.name, 'Updated Name');
        expect(result.value!.port, 8883);
        expect(result.value!.status, ConnectionStatus.active);
      });

      test('returns error when update fails', () async {
        // Arrange
        final connection = Connection(
          id: 'nonexistent',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.inactive,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );
        final error = Exception('Connection not found');

        when(mockRepository.updateConnection(connection))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = UpdateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(connection);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('DeleteConnectionUseCase', () {
      test('deletes connection successfully', () async {
        // Arrange
        const connectionId = 'conn-001';

        when(mockRepository.deleteConnection(connectionId))
            .thenAnswer((_) async => Result.success(null));

        final useCase = DeleteConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(connectionId);

        // Assert
        expect(result.isSuccess, true);
        verify(mockRepository.deleteConnection(connectionId)).called(1);
      });

      test('returns error when deletion fails', () async {
        // Arrange
        const connectionId = 'nonexistent';
        final error = Exception('Connection not found');

        when(mockRepository.deleteConnection(connectionId))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = DeleteConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(connectionId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('GetConnectionsByStatusUseCase', () {
      test('returns active connections', () async {
        // Arrange
        final activeConnections = [
          Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Active 1',
            status: ConnectionStatus.active,
            host: 'mqtt1.example.com',
            port: 1883,
            createdAt: DateTime.now(),
          ),
          Connection(
            id: 'conn-002',
            protocolId: 'mqtt-002',
            name: 'Active 2',
            status: ConnectionStatus.active,
            host: 'mqtt2.example.com',
            port: 1883,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getConnectionsByStatus(ConnectionStatus.active))
            .thenAnswer((_) async => Result.success(activeConnections));

        final useCase = GetConnectionsByStatusUseCase(mockRepository);

        // Act
        final result = await useCase.call(ConnectionStatus.active);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.length, 2);
        expect(
          result.value!.every((c) => c.status == ConnectionStatus.active),
          true,
        );
      });

      test('returns empty list when no connections of status found', () async {
        // Arrange
        when(mockRepository.getConnectionsByStatus(ConnectionStatus.failed))
            .thenAnswer((_) async => Result.success([]));

        final useCase = GetConnectionsByStatusUseCase(mockRepository);

        // Act
        final result = await useCase.call(ConnectionStatus.failed);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, isEmpty);
      });

      test('returns error on repository failure', () async {
        // Arrange
        final error = Exception('Database error');

        when(mockRepository.getConnectionsByStatus(ConnectionStatus.connecting))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetConnectionsByStatusUseCase(mockRepository);

        // Act
        final result = await useCase.call(ConnectionStatus.connecting);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('Connection Status Updates', () {
      test('update connection status to active', () async {
        // Arrange
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.connecting,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final activeConnection = connection.copyWith(
          status: ConnectionStatus.active,
          lastConnectedAt: DateTime.now(),
        );

        when(mockRepository.updateConnection(activeConnection))
            .thenAnswer((_) async => Result.success(activeConnection));

        final useCase = UpdateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(activeConnection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.status, ConnectionStatus.active);
        expect(result.value!.lastConnectedAt, isNotNull);
      });

      test('update connection status to failed', () async {
        // Arrange
        final connection = Connection(
          id: 'conn-001',
          protocolId: 'mqtt-001',
          name: 'Test',
          status: ConnectionStatus.connecting,
          host: 'localhost',
          port: 1883,
          createdAt: DateTime.now(),
        );

        final failedConnection = connection.copyWith(
          status: ConnectionStatus.failed,
        );

        when(mockRepository.updateConnection(failedConnection))
            .thenAnswer((_) async => Result.success(failedConnection));

        final useCase = UpdateConnectionUseCase(mockRepository);

        // Act
        final result = await useCase.call(failedConnection);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.status, ConnectionStatus.failed);
      });
    });

    group('UseCase Error Handling', () {
      test('use cases properly propagate errors', () async {
        // Arrange
        final error = Exception('Unexpected error');

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('UseCase Result Mapping', () {
      test('map result through useCase', () async {
        // Arrange
        final connections = [
          Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Connection',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 1883,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(connections));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();
        final mapped = result.map((connections) => connections.length);

        // Assert
        expect(mapped.isSuccess, true);
        expect(mapped.value, 1);
      });

      test('recover from failed result', () async {
        // Arrange
        final error = Exception('Database error');

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllConnectionsUseCase(mockRepository);

        // Act
        final result = await useCase.call();
        final recovered = result.recover((error) => []);

        // Assert
        expect(recovered.isSuccess, true);
        expect(recovered.value, isEmpty);
      });
    });

    group('UseCase Chaining', () {
      test('chain get all and get by id use cases', () async {
        // Arrange
        final connections = [
          Connection(
            id: 'conn-001',
            protocolId: 'mqtt-001',
            name: 'Connection 1',
            status: ConnectionStatus.active,
            host: 'localhost',
            port: 1883,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(connections));

        when(mockRepository.getConnectionById('conn-001'))
            .thenAnswer((_) async => Result.success(connections[0]));

        final getAllUseCase = GetAllConnectionsUseCase(mockRepository);
        final getByIdUseCase = GetConnectionByIdUseCase(mockRepository);

        // Act
        final allResult = await getAllUseCase.call();
        final firstId = allResult.value![0].id;
        final singleResult = await getByIdUseCase.call(firstId);

        // Assert
        expect(allResult.isSuccess, true);
        expect(singleResult.isSuccess, true);
        expect(singleResult.value!.id, 'conn-001');
      });
    });
  });
}
