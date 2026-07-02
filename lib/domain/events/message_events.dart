import '../../core/events/app_event.dart';
import '../entities/message.dart';

/// Event fired when a message is received
class MessageReceivedEvent extends AppEvent {
  final Message message;
  final String connectionId;

  MessageReceivedEvent({
    required this.message,
    required this.connectionId,
  });
}

/// Event fired when a message is sent
class MessageSentEvent extends AppEvent {
  final Message message;
  final String connectionId;

  MessageSentEvent({
    required this.message,
    required this.connectionId,
  });
}

/// Event fired when a message sending fails
class MessageSendFailedEvent extends AppEvent {
  final String messageId;
  final String connectionId;
  final String error;
  final Exception? exception;

  MessageSendFailedEvent({
    required this.messageId,
    required this.connectionId,
    required this.error,
    this.exception,
  });
}

/// Event fired when a message is updated
class MessageUpdatedEvent extends AppEvent {
  final Message message;
  final Message? previousMessage;

  MessageUpdatedEvent({
    required this.message,
    this.previousMessage,
  });
}

/// Event fired when a message is deleted
class MessageDeletedEvent extends AppEvent {
  final String messageId;
  final Message? deletedMessage;

  MessageDeletedEvent({
    required this.messageId,
    this.deletedMessage,
  });
}

/// Event fired when all messages are loaded
class MessagesLoadedEvent extends AppEvent {
  final List<Message> messages;

  MessagesLoadedEvent(this.messages);
}

/// Event fired when messages are cleared for a connection
class MessagesClearedEvent extends AppEvent {
  final String connectionId;
  final int clearedCount;

  MessagesClearedEvent({
    required this.connectionId,
    required this.clearedCount,
  });
}
