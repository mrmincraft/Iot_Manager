// Local DataSource Interface: MessageLocalDataSource
// Interface pour les opérations de base de données sur les messages

import 'package:iot_manager/data/models/message_model.dart';

abstract class MessageLocalDataSource {
  Future<List<MessageModel>> getAllMessages();
  Future<MessageModel> getMessageById(String id);
  Future<List<MessageModel>> getMessagesByTopicId(String topicId);
  Future<List<MessageModel>> getMessagesByConnectionId(String connectionId);
  Future<List<MessageModel>> getUnprocessedMessages();
  Future<void> createMessage(MessageModel message);
  Future<void> updateMessage(MessageModel message);
  Future<void> deleteMessage(String id);
  Future<void> deleteMessagesByTopicId(String topicId);
  Future<List<MessageModel>> getMessagesPaginated(int page, int limit);
  Future<List<MessageModel>> getMessagesBetweenDates(DateTime startDate, DateTime endDate);
  Future<int> getMessageCount();
  Future<void> deleteOldMessages(DateTime beforeDate);
}
