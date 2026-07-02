import '../../core/events/app_event.dart';
import '../entities/connection.dart';

/// Event fired when a new connection is created
class ConnectionCreatedEvent extends AppEvent {
  final Connection connection;

  ConnectionCreatedEvent(this.connection);
}

/// Event fired when a connection status changes
class ConnectionStatusChangedEvent extends AppEvent {
  final Connection connection;
  final String previousStatus;
  final String newStatus;

  ConnectionStatusChangedEvent({
    required this.connection,
    required this.previousStatus,
    required this.newStatus,
  });
}

/// Event fired when a connection is established/activated
class ConnectionEstablishedEvent extends AppEvent {
  final Connection connection;

  ConnectionEstablishedEvent(this.connection);
}

/// Event fired when a connection is closed/deactivated
class ConnectionClosedEvent extends AppEvent {
  final String connectionId;
  final Connection? closedConnection;
  final String? reason;

  ConnectionClosedEvent({
    required this.connectionId,
    this.closedConnection,
    this.reason,
  });
}

/// Event fired when a connection is updated
class ConnectionUpdatedEvent extends AppEvent {
  final Connection connection;
  final Connection? previousConnection;

  ConnectionUpdatedEvent({
    required this.connection,
    this.previousConnection,
  });
}

/// Event fired when a connection is deleted
class ConnectionDeletedEvent extends AppEvent {
  final String connectionId;
  final Connection? deletedConnection;

  ConnectionDeletedEvent({
    required this.connectionId,
    this.deletedConnection,
  });
}

/// Event fired when all connections are loaded
class ConnectionsLoadedEvent extends AppEvent {
  final List<Connection> connections;

  ConnectionsLoadedEvent(this.connections);
}

/// Event fired when a connection error occurs
class ConnectionErrorEvent extends AppEvent {
  final String connectionId;
  final String error;
  final Exception? exception;

  ConnectionErrorEvent({
    required this.connectionId,
    required this.error,
    this.exception,
  });
}
