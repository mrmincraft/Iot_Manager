// Local DataSource Interface: TopicLocalDataSource
// Interface pour les opérations de base de données sur les topics

import 'package:iot_manager/data/models/topic_model.dart';

abstract class TopicLocalDataSource {
  Future<List<TopicModel>> getAllTopics();
  Future<TopicModel> getTopicById(String id);
  Future<List<TopicModel>> getTopicsByConnectionId(String connectionId);
  Future<List<TopicModel>> getSubscribedTopics();
  Future<void> createTopic(TopicModel topic);
  Future<void> updateTopic(TopicModel topic);
  Future<void> deleteTopic(String id);
  Future<void> deleteTopicsByConnectionId(String connectionId);
  Future<List<TopicModel>> searchTopicsByPath(String pathPattern);
}
