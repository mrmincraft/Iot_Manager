// Repository Implementation: ProtocolRepositoryImpl
// Implémentation de la gestion des protocoles

import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/protocol_local_datasource.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/events/protocol_events.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';

class ProtocolRepositoryImpl implements ProtocolRepository {
  final ProtocolLocalDataSource _localDataSource;
  final EventBus _eventBus;

  ProtocolRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<Protocol>, Exception>> getAllProtocols() async {
    try {
      final models = await _localDataSource.getAllProtocols();
      final protocols = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(ProtocolsLoadedEvent(protocols));
      return Result.success(protocols);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Protocol, Exception>> getProtocolById(String id) async {
    try {
      final model = await _localDataSource.getProtocolById(id);
      final protocol = _mapModelToEntity(model);
      await _eventBus.publish(ProtocolRetrievedEvent(protocol));
      return Result.success(protocol);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Protocol, Exception>> createProtocol(Protocol protocol) async {
    try {
      final model = _mapEntityToModel(protocol);
      await _localDataSource.createProtocol(model);
      await _eventBus.publish(ProtocolAddedEvent(protocol));
      return Result.success(protocol);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Protocol, Exception>> updateProtocol(Protocol protocol) async {
    try {
      // Get previous state
      final previousModel = await _localDataSource.getProtocolById(protocol.id);
      final previousProtocol = _mapModelToEntity(previousModel);
      
      // Update
      final model = _mapEntityToModel(protocol);
      await _localDataSource.updateProtocol(model);
      await _eventBus.publish(ProtocolUpdatedEvent(
        protocol: protocol,
        previousProtocol: previousProtocol,
      ));
      return Result.success(protocol);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteProtocol(String id) async {
    try {
      // Get the protocol before deletion
      final model = await _localDataSource.getProtocolById(id);
      final deletedProtocol = _mapModelToEntity(model);
      
      await _localDataSource.deleteProtocol(id);
      await _eventBus.publish(ProtocolDeletedEvent(
        protocolId: id,
        deletedProtocol: deletedProtocol,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Protocol>, Exception>> getProtocolsByType(ProtocolType type) async {
    try {
      final models = await _localDataSource.getProtocolsByType(type.toString().split('.').last);
      final protocols = models.map(_mapModelToEntity).toList();
      return Result.success(protocols);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  /// Mappe un modèle vers une entité
  Protocol _mapModelToEntity(ProtocolModel model) {
    return Protocol(
      id: model.id,
      name: model.name,
      type: ProtocolType.values.firstWhere(
        (e) => e.toString().split('.').last == model.type,
        orElse: () => ProtocolType.unknown,
      ),
      description: model.description,
      defaultPort: model.defaultPort,
      requiresAuthentication: model.requiresAuthentication,
      supportedFeatures: List<String>.from(jsonDecode(model.supportedFeatures) as List),
      documentation: model.documentation,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Mappe une entité vers un modèle
  ProtocolModel _mapEntityToModel(Protocol entity) {
    return ProtocolModel(
      id: entity.id,
      name: entity.name,
      type: entity.type.toString().split('.').last,
      description: entity.description,
      defaultPort: entity.defaultPort,
      requiresAuthentication: entity.requiresAuthentication,
      supportedFeatures: jsonEncode(entity.supportedFeatures),
      documentation: entity.documentation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
