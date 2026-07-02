import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';

// Mock Repository
class MockProtocolRepository extends Mock implements ProtocolRepository {}

void main() {
  group('Protocol UseCases Tests', () {
    late MockProtocolRepository mockRepository;

    setUp(() {
      mockRepository = MockProtocolRepository();
    });

    group('GetAllProtocolsUseCase', () {
      test('returns list of protocols on success', () async {
        // Arrange
        final mockProtocols = [
          Protocol(
            id: 'mqtt-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'http-001',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        final useCase = GetAllProtocolsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, mockProtocols);
        expect(result.value!.length, 2);
        verify(mockRepository.getAllProtocols()).called(1);
      });

      test('returns error on repository failure', () async {
        // Arrange
        final error = Exception('Database error');
        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllProtocolsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
        verify(mockRepository.getAllProtocols()).called(1);
      });

      test('returns empty list when no protocols exist', () async {
        // Arrange
        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        final useCase = GetAllProtocolsUseCase(mockRepository);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, isEmpty);
      });
    });

    group('GetProtocolByIdUseCase', () {
      test('returns protocol by id on success', () async {
        // Arrange
        const protocolId = 'mqtt-001';
        final mockProtocol = Protocol(
          id: protocolId,
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockRepository.getProtocolById(protocolId))
            .thenAnswer((_) async => Result.success(mockProtocol));

        final useCase = GetProtocolByIdUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocolId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, mockProtocol);
        expect(result.value!.id, protocolId);
        verify(mockRepository.getProtocolById(protocolId)).called(1);
      });

      test('returns error when protocol not found', () async {
        // Arrange
        const protocolId = 'nonexistent';
        final error = Exception('Protocol not found');

        when(mockRepository.getProtocolById(protocolId))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetProtocolByIdUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocolId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('CreateProtocolUseCase', () {
      test('creates protocol successfully', () async {
        // Arrange
        final newProtocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockRepository.createProtocol(newProtocol))
            .thenAnswer((_) async => Result.success(newProtocol));

        final useCase = CreateProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(newProtocol);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, newProtocol);
        verify(mockRepository.createProtocol(newProtocol)).called(1);
      });

      test('returns error when creation fails', () async {
        // Arrange
        final protocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );
        final error = Exception('Creation failed');

        when(mockRepository.createProtocol(protocol))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = CreateProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocol);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('UpdateProtocolUseCase', () {
      test('updates protocol successfully', () async {
        // Arrange
        final updatedProtocol = Protocol(
          id: 'mqtt-001',
          name: 'MQTT Updated',
          type: ProtocolType.mqtt,
          port: 8883,
        );

        when(mockRepository.updateProtocol(updatedProtocol))
            .thenAnswer((_) async => Result.success(updatedProtocol));

        final useCase = UpdateProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(updatedProtocol);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.name, 'MQTT Updated');
        expect(result.value!.port, 8883);
        verify(mockRepository.updateProtocol(updatedProtocol)).called(1);
      });

      test('returns error when update fails', () async {
        // Arrange
        final protocol = Protocol(
          id: 'nonexistent',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );
        final error = Exception('Protocol not found');

        when(mockRepository.updateProtocol(protocol))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = UpdateProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocol);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('DeleteProtocolUseCase', () {
      test('deletes protocol successfully', () async {
        // Arrange
        const protocolId = 'mqtt-001';

        when(mockRepository.deleteProtocol(protocolId))
            .thenAnswer((_) async => Result.success(null));

        final useCase = DeleteProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocolId);

        // Assert
        expect(result.isSuccess, true);
        verify(mockRepository.deleteProtocol(protocolId)).called(1);
      });

      test('returns error when deletion fails', () async {
        // Arrange
        const protocolId = 'nonexistent';
        final error = Exception('Protocol not found');

        when(mockRepository.deleteProtocol(protocolId))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = DeleteProtocolUseCase(mockRepository);

        // Act
        final result = await useCase.call(protocolId);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('GetProtocolsByTypeUseCase', () {
      test('returns protocols by type', () async {
        // Arrange
        final mqttProtocols = [
          Protocol(
            id: 'mqtt-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'mqtt-002',
            name: 'MQTT TLS',
            type: ProtocolType.mqtt,
            port: 8883,
          ),
        ];

        when(mockRepository.getProtocolsByType(ProtocolType.mqtt))
            .thenAnswer((_) async => Result.success(mqttProtocols));

        final useCase = GetProtocolsByTypeUseCase(mockRepository);

        // Act
        final result = await useCase.call(ProtocolType.mqtt);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value!.length, 2);
        expect(result.value!.every((p) => p.type == ProtocolType.mqtt), true);
        verify(mockRepository.getProtocolsByType(ProtocolType.mqtt)).called(1);
      });

      test('returns empty list when no protocols of type found', () async {
        // Arrange
        when(mockRepository.getProtocolsByType(ProtocolType.coap))
            .thenAnswer((_) async => Result.success([]));

        final useCase = GetProtocolsByTypeUseCase(mockRepository);

        // Act
        final result = await useCase.call(ProtocolType.coap);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, isEmpty);
      });

      test('returns error on repository failure', () async {
        // Arrange
        final error = Exception('Database error');

        when(mockRepository.getProtocolsByType(ProtocolType.http))
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetProtocolsByTypeUseCase(mockRepository);

        // Act
        final result = await useCase.call(ProtocolType.http);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('UseCase Error Handling', () {
      test('use cases properly propagate errors', () async {
        // Arrange
        final error = Exception('Unexpected error');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllProtocolsUseCase(mockRepository);

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
        final protocols = [
          Protocol(
            id: 'mqtt-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        final useCase = GetAllProtocolsUseCase(mockRepository);

        // Act
        final result = await useCase.call();
        final mapped = result.map((protocols) => protocols.length);

        // Assert
        expect(mapped.isSuccess, true);
        expect(mapped.value, 1);
      });

      test('mapError on failed result', () async {
        // Arrange
        final originalError = Exception('Database error');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(originalError));

        final useCase = GetAllProtocolsUseCase(mockRepository);

        // Act
        final result = await useCase.call();
        final mapped = result.mapError(
          (error) => Exception('Mapped error: ${error.toString()}'),
        );

        // Assert
        expect(mapped.isFailure, true);
        expect(mapped.error.toString(), contains('Mapped error'));
      });
    });

    group('UseCase Chaining', () {
      test('chain multiple use cases', () async {
        // Arrange
        final protocols = [
          Protocol(
            id: 'mqtt-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        when(mockRepository.getProtocolById('mqtt-001'))
            .thenAnswer((_) async => Result.success(protocols[0]));

        final getAllUseCase = GetAllProtocolsUseCase(mockRepository);
        final getByIdUseCase = GetProtocolByIdUseCase(mockRepository);

        // Act
        final allResult = await getAllUseCase.call();
        final firstId = allResult.value![0].id;
        final singleResult = await getByIdUseCase.call(firstId);

        // Assert
        expect(allResult.isSuccess, true);
        expect(singleResult.isSuccess, true);
        expect(singleResult.value!.id, 'mqtt-001');
      });
    });
  });
}
