import 'package:iot_manager/core/network/http_client_service.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/data/dtos/connection_dto.dart';

/// Remote data source for Connection
abstract class ConnectionRemoteDataSource {
  Future<Result<List<Connection>, NetworkException>> getAllConnections();
  Future<Result<Connection, NetworkException>> getConnectionById(String id);
  Future<Result<Connection, NetworkException>> createConnection(Connection connection);
  Future<Result<Connection, NetworkException>> updateConnection(Connection connection);
  Future<Result<void, NetworkException>> deleteConnection(String id);
  Future<Result<List<Connection>, NetworkException>> getConnectionsByProtocol(String protocolId);
}

/// Connection Remote Data Source Implementation
class ConnectionRemoteDataSourceImpl implements ConnectionRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/connections';

  ConnectionRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Connection>, NetworkException>> getAllConnections() async {
    try {
      final result = await _httpClient.get<List<ConnectionDTO>>(
        _baseEndpoint,
      );
      if (result.isSuccess) {
        final dtos = result.value ?? [];
        return Result.success(dtos.map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Connection, NetworkException>> getConnectionById(String id) async {
    try {
      final result = await _httpClient.get<ConnectionDTO>(
        '$_baseEndpoint/$id',
      );
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Connection, NetworkException>> createConnection(
    Connection connection,
  ) async {
    try {
      final dto = ConnectionDTO.fromEntity(connection);
      final result = await _httpClient.post<ConnectionDTO>(
        _baseEndpoint,
        body: dto.toJson(),
      );
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Connection, NetworkException>> updateConnection(
    Connection connection,
  ) async {
    try {
      final dto = ConnectionDTO.fromEntity(connection);
      final result = await _httpClient.put<ConnectionDTO>(
        '$_baseEndpoint/${connection.id}',
        body: dto.toJson(),
      );
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteConnection(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<Connection>, NetworkException>> getConnectionsByProtocol(
    String protocolId,
  ) async {
    try {
      final result = await _httpClient.get<List<ConnectionDTO>>(
        _baseEndpoint,
        queryParameters: {'protocolId': protocolId},
      );
      if (result.isSuccess) {
        final dtos = result.value ?? [];
        return Result.success(dtos.map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}
