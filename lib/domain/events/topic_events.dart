import '../../core/events/app_event.dart';
import '../entities/topic.dart';

/// Event fired when a new topic is created
class TopicCreatedEvent extends AppEvent {
  final Topic topic;

  TopicCreatedEvent(this.topic);
}

/// Event fired when a topic is updated
class TopicUpdatedEvent extends AppEvent {
  final Topic topic;
  final Topic? previousTopic;

  TopicUpdatedEvent({
    required this.topic,
    this.previousTopic,
  });
}

/// Event fired when a topic is deleted
class TopicDeletedEvent extends AppEvent {
  final String topicId;
  final Topic? deletedTopic;

  TopicDeletedEvent({
    required this.topicId,
    this.deletedTopic,
  });
}

/// Event fired when all topics are loaded
class TopicsLoadedEvent extends AppEvent {
  final List<Topic> topics;

  TopicsLoadedEvent(this.topics);
}

/// Event fired when a topic is subscribed to
class TopicSubscribedEvent extends AppEvent {
  final String topicId;
  final String connectionId;

  TopicSubscribedEvent({
    required this.topicId,
    required this.connectionId,
  });
}

/// Event fired when a topic is unsubscribed from
class TopicUnsubscribedEvent extends AppEvent {
  final String topicId;
  final String connectionId;

  TopicUnsubscribedEvent({
    required this.topicId,
    required this.connectionId,
  });
}
