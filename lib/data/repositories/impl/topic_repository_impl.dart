// Repository Implementation: TopicRepositoryImpl
// Implémentation de la gestion des topics

import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/topic_local_datasource.dart';
import 'package:iot_manager/data/models/topic_model.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/events/topic_events.dart';
import 'package:iot_manager/domain/repositories/topic_repository.dart';

class TopicRepositoryImpl implements TopicRepository {
  final TopicLocalDataSource _localDataSource;
  final EventBus _eventBus;

  TopicRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<Topic>, Exception>> getAllTopics() async {
    try {
      final models = await _localDataSource.getAllTopics();
      final topics = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(TopicsLoadedEvent(topics));
      return Result.success(topics);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Topic, Exception>> getTopicById(String id) async {
    try {
      final model = await _localDataSource.getTopicById(id);
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Topic>, Exception>> getTopicsByConnectionId(String connectionId) async {
    try {
      final models = await _localDataSource.getTopicsByConnectionId(connectionId);
      final topics = models.map(_mapModelToEntity).toList();
      return Result.success(topics);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Topic>, Exception>> getSubscribedTopics() async {
    try {
      final models = await _localDataSource.getSubscribedTopics();
      final topics = models.map(_mapModelToEntity).toList();
      return Result.success(topics);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Topic, Exception>> createTopic(Topic topic) async {
    try {
      final model = _mapEntityToModel(topic);
      await _localDataSource.createTopic(model);
      await _eventBus.publish(TopicCreatedEvent(topic));
      return Result.success(topic);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Topic, Exception>> updateTopic(Topic topic) async {
    try {
      // Get previous state
      final previousModel = await _localDataSource.getTopicById(topic.id);
      final previousTopic = _mapModelToEntity(previousModel);

      final model = _mapEntityToModel(topic);
      await _localDataSource.updateTopic(model);
      
      await _eventBus.publish(TopicUpdatedEvent(
        topic: topic,
        previousTopic: previousTopic,
      ));
      return Result.success(topic);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteTopic(String id) async {
    try {
      // Get the topic before deletion
      final model = await _localDataSource.getTopicById(id);
      final deletedTopic = _mapModelToEntity(model);

      await _localDataSource.deleteTopic(id);
      await _eventBus.publish(TopicDeletedEvent(
        topicId: id,
        deletedTopic: deletedTopic,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteTopicsByConnectionId(String connectionId) async {
    try {
      await _localDataSource.deleteTopicsByConnectionId(connectionId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Topic>, Exception>> searchTopicsByPath(String pathPattern) async {
    try {
      final models = await _localDataSource.searchTopicsByPath(pathPattern);
      final topics = models.map(_mapModelToEntity).toList();
      return Result.success(topics);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  Topic _mapModelToEntity(TopicModel model) {
    return Topic(
      id: model.id,
      connectionId: model.connectionId,
      name: model.name,
      path: model.path,
      qos: TopicQos.values.firstWhere(
        (e) => e.toString().split('.').last == model.qos,
        orElse: () => TopicQos.atMostOnce,
      ),
      retain: model.retain,
      subscribed: model.subscribed,
      description: model.description,
      metadata: Map<String, String>.from(jsonDecode(model.metadata) as Map),
      messageCount: model.messageCount,
      lastMessageAt: model.lastMessageAt,
      messageRatePerSecond: model.messageRatePerSecond,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  TopicModel _mapEntityToModel(Topic entity) {
    return TopicModel(
      id: entity.id,
      connectionId: entity.connectionId,
      name: entity.name,
      path: entity.path,
      qos: entity.qos.toString().split('.').last,
      retain: entity.retain,
      subscribed: entity.subscribed,
      description: entity.description,
      metadata: jsonEncode(entity.metadata),
      messageCount: entity.messageCount,
      lastMessageAt: entity.lastMessageAt,
      messageRatePerSecond: entity.messageRatePerSecond,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
