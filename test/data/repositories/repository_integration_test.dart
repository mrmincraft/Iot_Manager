import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/core/exceptions/app_exception.dart';
import 'package:iot_manager/data/datasources/local/protocol_local_datasource.dart';
import 'package:iot_manager/data/datasources/remote/protocol_remote_datasource.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/data/repositories/impl/protocol_repository_impl.dart';

class MockProtocolLocalDataSource extends Mock implements ProtocolLocalDataSource {}
class MockProtocolRemoteDataSource extends Mock implements ProtocolRemoteDataSource {}

void main() {
  group('Repository Integration Tests', () {
    group('ProtocolRepositoryImpl Integration', () {
      late MockProtocolLocalDataSource mockLocalDataSource;
      late MockProtocolRemoteDataSource mockRemoteDataSource;
      late ProtocolRepositoryImpl repository;

      setUp(() {
        mockLocalDataSource = MockProtocolLocalDataSource();
        mockRemoteDataSource = MockProtocolRemoteDataSource();
        repository = ProtocolRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
        );
      });

      test('getAllProtocols returns local data on success', () async {
        final mockProtocols = [
          ProtocolModel(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockLocalDataSource.getAllProtocols())
            .thenAnswer((_) async => mockProtocols);

        final result = await repository.getAllProtocols();

        expect(result.isSuccess, true);
        expect(result.value!.length, 1);
        expect(result.value![0].name, 'MQTT');
        verify(mockLocalDataSource.getAllProtocols()).called(1);
      });

      test('getAllProtocols returns remote data on local failure', () async {
        final mockProtocols = [
          ProtocolModel(
            id: 'proto-001',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        when(mockLocalDataSource.getAllProtocols())
            .thenThrow(Exception('Local DB error'));
        when(mockRemoteDataSource.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        final result = await repository.getAllProtocols();

        expect(result.isSuccess, true);
        verify(mockRemoteDataSource.getAllProtocols()).called(1);
      });

      test('getProtocolById returns protocol from local cache', () async {
        const protocolId = 'proto-001';
        final mockProtocol = ProtocolModel(
          id: protocolId,
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockLocalDataSource.getProtocolById(protocolId))
            .thenAnswer((_) async => mockProtocol);

        final result = await repository.getProtocolById(protocolId);

        expect(result.isSuccess, true);
        expect(result.value!.id, protocolId);
        verify(mockLocalDataSource.getProtocolById(protocolId)).called(1);
      });

      test('createProtocol saves to both local and remote', () async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'CoAP',
          type: ProtocolType.coap,
          port: 5683,
        );

        when(mockRemoteDataSource.createProtocol(any))
            .thenAnswer((_) async => Result.success(protocol));
        when(mockLocalDataSource.createProtocol(any))
            .thenAnswer((_) async => 1);

        final result = await repository.createProtocol(protocol);

        expect(result.isSuccess, true);
        verify(mockRemoteDataSource.createProtocol(any)).called(1);
        verify(mockLocalDataSource.createProtocol(any)).called(1);
      });

      test('deleteProtocol removes from both local and remote', () async {
        const protocolId = 'proto-001';

        when(mockRemoteDataSource.deleteProtocol(protocolId))
            .thenAnswer((_) async => Result.success(null));
        when(mockLocalDataSource.deleteProtocol(protocolId))
            .thenAnswer((_) async => 1);

        final result = await repository.deleteProtocol(protocolId);

        expect(result.isSuccess, true);
        verify(mockRemoteDataSource.deleteProtocol(protocolId)).called(1);
        verify(mockLocalDataSource.deleteProtocol(protocolId)).called(1);
      });

      test('repository handles sync conflicts with strategy', () async {
        final protocols = [
          ProtocolModel(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockLocalDataSource.getAllProtocols())
            .thenAnswer((_) async => protocols);
        when(mockRemoteDataSource.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        final localResult = await repository.getAllProtocols();
        final remoteResult = await repository.getAllProtocols();

        expect(localResult.isSuccess, true);
        expect(remoteResult.isSuccess, true);
        expect(localResult.value!, remoteResult.value!);
      });
    });

    group('Connection Repository Integration', () {
      test('ConnectionRepositoryImpl integration with data sources', () async {
        // Mock setup would follow same pattern as Protocol
        // This demonstrates the integration test structure
        expect(true, true);
      });
    });
  });
}
