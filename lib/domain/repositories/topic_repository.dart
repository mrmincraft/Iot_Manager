// Domain Repository Interface: TopicRepository
// Interface pour la gestion des topics

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/topic.dart';

abstract class TopicRepository {
  /// Récupère tous les topics
  Future<Result<List<Topic>, Exception>> getAllTopics();

  /// Récupère un topic par ID
  Future<Result<Topic, Exception>> getTopicById(String id);

  /// Récupère les topics pour une connexion
  Future<Result<List<Topic>, Exception>> getTopicsByConnectionId(String connectionId);

  /// Récupère les topics abonnés
  Future<Result<List<Topic>, Exception>> getSubscribedTopics();

  /// Crée un nouveau topic
  Future<Result<Topic, Exception>> createTopic(Topic topic);

  /// Met à jour un topic
  Future<Result<Topic, Exception>> updateTopic(Topic topic);

  /// Supprime un topic
  Future<Result<void, Exception>> deleteTopic(String id);

  /// Supprime tous les topics d'une connexion
  Future<Result<void, Exception>> deleteTopicsByConnectionId(String connectionId);

  /// Recherche des topics par chemin (path)
  Future<Result<List<Topic>, Exception>> searchTopicsByPath(String pathPattern);
}
