import '../../core/events/app_event.dart';

/// Event fired when an MQTT message is received
class MQTTMessageReceivedEvent extends AppEvent {
  final String connectionId;
  final String topic;
  final String payload;
  final DateTime receivedAt;

  MQTTMessageReceivedEvent({
    required this.connectionId,
    required this.topic,
    required this.payload,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();
}

/// Event fired when an MQTT connection fails
class MQTTConnectionFailedEvent extends AppEvent {
  final String connectionId;
  final String error;
  final Exception? exception;

  MQTTConnectionFailedEvent({
    required this.connectionId,
    required this.error,
    this.exception,
  });
}

/// Event fired when an MQTT connection is successfully established
class MQTTConnectedEvent extends AppEvent {
  final String connectionId;
  final int keepAliveSeconds;

  MQTTConnectedEvent({
    required this.connectionId,
    this.keepAliveSeconds = 60,
  });
}

/// Event fired when an MQTT connection is disconnected
class MQTTDisconnectedEvent extends AppEvent {
  final String connectionId;
  final String? reason;

  MQTTDisconnectedEvent({
    required this.connectionId,
    this.reason,
  });
}

/// Event fired when an MQTT subscribe request is successful
class MQTTSubscribedEvent extends AppEvent {
  final String connectionId;
  final String topic;

  MQTTSubscribedEvent({
    required this.connectionId,
    required this.topic,
  });
}

/// Event fired when an MQTT unsubscribe request is successful
class MQTTUnsubscribedEvent extends AppEvent {
  final String connectionId;
  final String topic;

  MQTTUnsubscribedEvent({
    required this.connectionId,
    required this.topic,
  });
}

/// Event fired when an MQTT subscribe fails
class MQTTSubscribeFailedEvent extends AppEvent {
  final String connectionId;
  final String topic;
  final String error;
  final Exception? exception;

  MQTTSubscribeFailedEvent({
    required this.connectionId,
    required this.topic,
    required this.error,
    this.exception,
  });
}

/// Event fired when an MQTT message publish succeeds
class MQTTPublishSuccessEvent extends AppEvent {
  final String connectionId;
  final String topic;
  final String payload;

  MQTTPublishSuccessEvent({
    required this.connectionId,
    required this.topic,
    required this.payload,
  });
}

/// Event fired when an MQTT message publish fails
class MQTTPublishFailedEvent extends AppEvent {
  final String connectionId;
  final String topic;
  final String error;
  final Exception? exception;

  MQTTPublishFailedEvent({
    required this.connectionId,
    required this.topic,
    required this.error,
    this.exception,
  });
}

/// Event fired when MQTT connection quality changes
class MQTTQualityChangedEvent extends AppEvent {
  final String connectionId;
  final int signalStrength;
  final int latencyMs;

  MQTTQualityChangedEvent({
    required this.connectionId,
    required this.signalStrength,
    required this.latencyMs,
  });
}
