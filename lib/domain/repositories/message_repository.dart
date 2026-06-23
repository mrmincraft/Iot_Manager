// Domain Repository Interface: MessageRepository
// Interface pour la gestion des messages

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/message.dart';

abstract class MessageRepository {
  /// Récupère tous les messages
  Future<Result<List<Message>, Exception>> getAllMessages();

  /// Récupère un message par ID
  Future<Result<Message, Exception>> getMessageById(String id);

  /// Récupère les messages pour un topic
  Future<Result<List<Message>, Exception>> getMessagesByTopicId(String topicId);

  /// Récupère les messages pour une connexion
  Future<Result<List<Message>, Exception>> getMessagesByConnectionId(String connectionId);

  /// Récupère les messages non traités
  Future<Result<List<Message>, Exception>> getUnprocessedMessages();

  /// Crée un nouveau message
  Future<Result<Message, Exception>> createMessage(Message message);

  /// Met à jour un message
  Future<Result<Message, Exception>> updateMessage(Message message);

  /// Supprime un message
  Future<Result<void, Exception>> deleteMessage(String id);

  /// Supprime les messages d'un topic
  Future<Result<void, Exception>> deleteMessagesByTopicId(String topicId);

  /// Récupère les messages avec pagination
  Future<Result<List<Message>, Exception>> getMessagesPaginated(int page, int limit);

  /// Récupère les messages entre deux dates
  Future<Result<List<Message>, Exception>> getMessagesBetweenDates(DateTime startDate, DateTime endDate);

  /// Compte le nombre total de messages
  Future<Result<int, Exception>> getMessageCount();

  /// Supprime les anciens messages (par date)
  Future<Result<void, Exception>> deleteOldMessages(DateTime beforeDate);
}
