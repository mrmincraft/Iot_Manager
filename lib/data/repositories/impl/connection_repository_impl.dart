import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/connection_local_datasource.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/events/connection_events.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionLocalDataSource _localDataSource;
  final EventBus _eventBus;

  ConnectionRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<Connection>, Exception>> getAllConnections() async {
    try {
      final models = await _localDataSource.getAllConnections();
      final connections = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(ConnectionsLoadedEvent(connections));
      return Result.success(connections);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Connection, Exception>> getConnectionById(String id) async {
    try {
      final model = await _localDataSource.getConnectionById(id);
      final connection = _mapModelToEntity(model);
      return Result.success(connection);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Connection, Exception>> createConnection(Connection connection) async {
    try {
      final model = _mapEntityToModel(connection);
      await _localDataSource.createConnection(model);
      await _eventBus.publish(ConnectionCreatedEvent(connection));
      return Result.success(connection);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Connection, Exception>> updateConnection(Connection connection) async {
    try {
      // Get previous state
      final previousModel = await _localDataSource.getConnectionById(connection.id);
      final previousConnection = _mapModelToEntity(previousModel);

      // Update
      final model = _mapEntityToModel(connection);
      await _localDataSource.updateConnection(model);
      
      // Check if status changed
      if (previousConnection.status != connection.status) {
        await _eventBus.publish(ConnectionStatusChangedEvent(
          connection: connection,
          previousStatus: previousConnection.status.toString(),
          newStatus: connection.status.toString(),
        ));
      }
      
      await _eventBus.publish(ConnectionUpdatedEvent(
        connection: connection,
        previousConnection: previousConnection,
      ));
      return Result.success(connection);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteConnection(String id) async {
    try {
      // Get the connection before deletion
      final model = await _localDataSource.getConnectionById(id);
      final deletedConnection = _mapModelToEntity(model);

      await _localDataSource.deleteConnection(id);
      await _eventBus.publish(ConnectionDeletedEvent(
        connectionId: id,
        deletedConnection: deletedConnection,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Connection>, Exception>> getConnectionsByProtocol(String protocolId) async {
    try {
      final models = await _localDataSource.getConnectionsByProtocol(protocolId);
      final connections = models.map(_mapModelToEntity).toList();
      return Result.success(connections);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  /// Maps a model to an entity
  Connection _mapModelToEntity(ConnectionModel model) {
    return Connection(
      id: model.id,
      name: model.name,
      protocolId: model.protocolId,
      broker: model.broker,
      port: model.port,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == model.status,
        orElse: () => ConnectionStatus.inactive,
      ),
      certificateId: model.certificateId,
      username: model.username,
      password: model.password,
      customSettings: Map<String, dynamic>.from(
        jsonDecode(model.customSettings) as Map<String, dynamic>,
      ),
      lastConnectedAt: model.lastConnectedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Maps an entity to a model
  ConnectionModel _mapEntityToModel(Connection entity) {
    return ConnectionModel(
      id: entity.id,
      name: entity.name,
      protocolId: entity.protocolId,
      broker: entity.broker,
      port: entity.port,
      status: entity.status.toString().split('.').last,
      certificateId: entity.certificateId,
      username: entity.username,
      password: entity.password,
      customSettings: jsonEncode(entity.customSettings),
      lastConnectedAt: entity.lastConnectedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
