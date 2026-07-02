// Repository Implementation: MessageRepositoryImpl
// Implémentation de la gestion des messages

import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/message_local_datasource.dart';
import 'package:iot_manager/data/models/message_model.dart';
import 'package:iot_manager/domain/entities/message.dart';
import 'package:iot_manager/domain/events/message_events.dart';
import 'package:iot_manager/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageLocalDataSource _localDataSource;
  final EventBus _eventBus;

  MessageRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<Message>, Exception>> getAllMessages() async {
    try {
      final models = await _localDataSource.getAllMessages();
      final messages = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(MessagesLoadedEvent(messages));
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Message, Exception>> getMessageById(String id) async {
    try {
      final model = await _localDataSource.getMessageById(id);
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Message>, Exception>> getMessagesByTopicId(String topicId) async {
    try {
      final models = await _localDataSource.getMessagesByTopicId(topicId);
      final messages = models.map(_mapModelToEntity).toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Message>, Exception>> getMessagesByConnectionId(String connectionId) async {
    try {
      final models = await _localDataSource.getMessagesByConnectionId(connectionId);
      final messages = models.map(_mapModelToEntity).toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Message>, Exception>> getUnprocessedMessages() async {
    try {
      final models = await _localDataSource.getUnprocessedMessages();
      final messages = models.map(_mapModelToEntity).toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Message, Exception>> createMessage(Message message) async {
    try {
      final model = _mapEntityToModel(message);
      await _localDataSource.createMessage(model);
      
      // Determine if this is incoming or outgoing
      if (message.direction == MessageDirection.incoming) {
        await _eventBus.publish(MessageReceivedEvent(
          message: message,
          connectionId: message.connectionId,
        ));
      } else {
        await _eventBus.publish(MessageSentEvent(
          message: message,
          connectionId: message.connectionId,
        ));
      }
      
      return Result.success(message);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Message, Exception>> updateMessage(Message message) async {
    try {
      // Get previous state
      final previousModel = await _localDataSource.getMessageById(message.id);
      final previousMessage = _mapModelToEntity(previousModel);

      final model = _mapEntityToModel(message);
      await _localDataSource.updateMessage(model);
      
      await _eventBus.publish(MessageUpdatedEvent(
        message: message,
        previousMessage: previousMessage,
      ));
      return Result.success(message);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteMessage(String id) async {
    try {
      // Get the message before deletion
      final model = await _localDataSource.getMessageById(id);
      final deletedMessage = _mapModelToEntity(model);

      await _localDataSource.deleteMessage(id);
      await _eventBus.publish(MessageDeletedEvent(
        messageId: id,
        deletedMessage: deletedMessage,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteMessagesByTopicId(String topicId) async {
    try {
      await _localDataSource.deleteMessagesByTopicId(topicId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Message>, Exception>> getMessagesPaginated(int page, int limit) async {
    try {
      final models = await _localDataSource.getMessagesPaginated(page, limit);
      final messages = models.map(_mapModelToEntity).toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Message>, Exception>> getMessagesBetweenDates(DateTime startDate, DateTime endDate) async {
    try {
      final models = await _localDataSource.getMessagesBetweenDates(startDate, endDate);
      final messages = models.map(_mapModelToEntity).toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<int, Exception>> getMessageCount() async {
    try {
      final count = await _localDataSource.getMessageCount();
      return Result.success(count);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteOldMessages(DateTime beforeDate) async {
    try {
      await _localDataSource.deleteOldMessages(beforeDate);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  Message _mapModelToEntity(MessageModel model) {
    return Message(
      id: model.id,
      topicId: model.topicId,
      connectionId: model.connectionId,
      direction: MessageDirection.values.firstWhere(
        (e) => e.toString().split('.').last == model.direction,
        orElse: () => MessageDirection.incoming,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == model.type,
        orElse: () => MessageType.text,
      ),
      payload: model.payload,
      payloadSize: model.payloadSize,
      properties: Map<String, String>.from(jsonDecode(model.properties) as Map),
      senderIdentifier: model.senderIdentifier,
      receiverIdentifier: model.receiverIdentifier,
      processed: model.processed,
      processingError: model.processingError,
      timestamp: model.timestamp,
      receivedAt: model.receivedAt,
    );
  }

  MessageModel _mapEntityToModel(Message entity) {
    return MessageModel(
      id: entity.id,
      topicId: entity.topicId,
      connectionId: entity.connectionId,
      direction: entity.direction.toString().split('.').last,
      type: entity.type.toString().split('.').last,
      payload: entity.payload,
      payloadSize: entity.payloadSize,
      properties: jsonEncode(entity.properties),
      senderIdentifier: entity.senderIdentifier,
      receiverIdentifier: entity.receiverIdentifier,
      processed: entity.processed,
      processingError: entity.processingError,
      timestamp: entity.timestamp,
      receivedAt: entity.receivedAt,
    );
  }
}
