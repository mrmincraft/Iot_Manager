import 'package:iot_manager/core/network/http_client_service.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/data/dtos/protocol_dto.dart';

/// Remote data source for Protocol - Fetches from backend API
abstract class ProtocolRemoteDataSource {
  /// Fetch all protocols from backend
  Future<Result<List<Protocol>, NetworkException>> getAllProtocols();

  /// Fetch protocol by ID from backend
  Future<Result<Protocol, NetworkException>> getProtocolById(String id);

  /// Create protocol on backend
  Future<Result<Protocol, NetworkException>> createProtocol(Protocol protocol);

  /// Update protocol on backend
  Future<Result<Protocol, NetworkException>> updateProtocol(Protocol protocol);

  /// Delete protocol on backend
  Future<Result<void, NetworkException>> deleteProtocol(String id);

  /// Fetch protocols by type from backend
  Future<Result<List<Protocol>, NetworkException>> getProtocolsByType(ProtocolType type);
}

/// Protocol Remote Data Source Implementation
class ProtocolRemoteDataSourceImpl implements ProtocolRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/protocols';

  ProtocolRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Protocol>, NetworkException>> getAllProtocols() async {
    try {
      final result = await _httpClient.get<List<ProtocolDTO>>(
        _baseEndpoint,
      );

      if (result.isSuccess) {
        final dtos = result.value ?? [];
        final protocols = dtos.map((dto) => dto.toEntity()).toList();
        return Result.success(protocols);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Protocol, NetworkException>> getProtocolById(String id) async {
    try {
      final result = await _httpClient.get<ProtocolDTO>(
        '$_baseEndpoint/$id',
      );

      if (result.isSuccess) {
        final protocol = result.value!.toEntity();
        return Result.success(protocol);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Protocol, NetworkException>> createProtocol(
    Protocol protocol,
  ) async {
    try {
      final dto = ProtocolDTO.fromEntity(protocol);
      final result = await _httpClient.post<ProtocolDTO>(
        _baseEndpoint,
        body: dto.toJson(),
      );

      if (result.isSuccess) {
        final createdProtocol = result.value!.toEntity();
        return Result.success(createdProtocol);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Protocol, NetworkException>> updateProtocol(
    Protocol protocol,
  ) async {
    try {
      final dto = ProtocolDTO.fromEntity(protocol);
      final result = await _httpClient.put<ProtocolDTO>(
        '$_baseEndpoint/${protocol.id}',
        body: dto.toJson(),
      );

      if (result.isSuccess) {
        final updatedProtocol = result.value!.toEntity();
        return Result.success(updatedProtocol);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteProtocol(String id) async {
    try {
      final result = await _httpClient.delete<void>(
        '$_baseEndpoint/$id',
      );

      if (result.isSuccess) {
        return Result.success(null);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<Protocol>, NetworkException>> getProtocolsByType(
    ProtocolType type,
  ) async {
    try {
      final result = await _httpClient.get<List<ProtocolDTO>>(
        _baseEndpoint,
        queryParameters: {'type': type.toString()},
      );

      if (result.isSuccess) {
        final dtos = result.value ?? [];
        final protocols = dtos.map((dto) => dto.toEntity()).toList();
        return Result.success(protocols);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}
